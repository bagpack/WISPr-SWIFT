import Foundation

public enum WISPrError: Error, Equatable {
    case unknownPayload
    case notFoundPayload
    case missingParamter
    case logoffFailed
    case invalidURL(String)
}

public class WISPrClient: @unchecked Sendable {

    static let userAgent: String =
        "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1"
    public static let wellKnownWebPage = "http://www.apple.com/library/test/success.html"

    private final class CompletionBox: @unchecked Sendable {
        let closure: (Result) -> Void

        init(_ closure: @escaping (Result) -> Void) {
            self.closure = closure
        }
    }

    public func login(
        url: String = WISPrClient.wellKnownWebPage,
        username: String,
        password: String,
        completion: @escaping (Result) -> Void
    ) {
        let completionBox = CompletionBox(completion)
        loginStep(url: url, username: username, password: password, completion: completionBox)
    }

    public func logoff(logoffURL: String, completion: @escaping (Result) -> Void) {
        let completionBox = CompletionBox(completion)
        request(url: logoffURL) { result in
            switch result {
            case let .success(payload: payload):
                if payload.messageType == .logoffNotification && payload.responseCode == .logoffSucceeded {
                    completionBox.closure(Result.success(payload: payload))
                } else {
                    completionBox.closure(Result.failure(error: WISPrError.logoffFailed))
                }
            case let .failure(error: error):
                completionBox.closure(Result.failure(error: error))
            }
        }
    }

    private func loginStep(
        url: String,
        username: String,
        password: String,
        completion: CompletionBox
    ) {
        request(url: url) { [self] result in
            switch result {
            case let .success(payload: payload):
                switch (payload.messageType, payload.responseCode) {
                case (.proxyNotification, .proxyDetection):
                    let delay = payload.delay ?? 0
                    let nextURL = payload.nextURL ?? url
                    DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(delay)) { [self] in
                        loginStep(url: nextURL, username: username, password: password, completion: completion)
                    }
                case (.initialRedirectMessage, .noError):
                    guard let loginURL = payload.loginURL else {
                        completion.closure(Result.failure(error: WISPrError.unknownPayload))
                        return
                    }
                    authenticate(username: username, password: password, loginURL: loginURL, completion: completion)
                case (.responseToAuthenticationPoll, .authenticationPending):
                    guard let loginResultsURL = payload.loginResultsURL else {
                        completion.closure(Result.failure(error: WISPrError.unknownPayload))
                        return
                    }
                    let delay = payload.delay ?? 0
                    DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(delay)) { [self] in
                        loginStep(url: loginResultsURL, username: username, password: password, completion: completion)
                    }
                case (.authenticationNotification, .loginSucceeded):
                    completion.closure(Result.success(payload: payload))
                default:
                    completion.closure(Result.failure(error: WISPrError.unknownPayload))
                }
            case let .failure(error: error):
                completion.closure(Result.failure(error: error))
            }
        }
    }

    private func authenticate(
        username: String,
        password: String,
        loginURL: String,
        completion: CompletionBox
    ) {
        guard let url = validURL(from: loginURL) else {
            completion.closure(Result.failure(error: WISPrError.invalidURL(loginURL)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(WISPrClient.userAgent, forHTTPHeaderField: "User-Agent")
        request.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let parameters = [
            ("UserName", username),
            ("Password", password),
            ("button", "Login"),
            ("FNAME", "0"),
            ("OriginatingServer", WISPrClient.wellKnownWebPage)
        ]
        request.httpBody = queryString(from: parameters).data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let encodingName = response?.textEncodingName ?? "utf-8"
                let encoding = CFStringConvertEncodingToNSStringEncoding(
                    CFStringConvertIANACharSetNameToEncoding(encodingName as CFString)
                )
                let html = String(data: data, encoding: String.Encoding(rawValue: encoding)) ?? ""
                guard let payload = PayloadParser.parse(html: html) else {
                    completion.closure(Result.failure(error: WISPrError.notFoundPayload))
                    return
                }

                if payload.messageType == .authenticationNotification && payload.responseCode == .loginSucceeded {
                    completion.closure(Result.success(payload: payload))
                } else {
                    completion.closure(Result.failure(error: WISPrError.missingParamter))
                }
            } else if let error = error {
                completion.closure(Result.failure(error: error))
            }
        }
        task.resume()
    }

    private func queryString(from parameters: [(String, String)]) -> String {
        parameters.map { key, value in
            let encodedKey = formURLEncoded(key)
            let encodedValue = formURLEncoded(value)
            return encodedKey + "=" + encodedValue
        }
        .joined(separator: "&")
    }

    private func request(url: String, completion: @escaping @Sendable (Result) -> Void) {
        guard let validURL = validURL(from: url) else {
            completion(Result.failure(error: WISPrError.invalidURL(url)))
            return
        }

        var request = URLRequest(url: validURL)
        request.addValue(WISPrClient.userAgent, forHTTPHeaderField: "User-Agent")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let encodingName = response?.textEncodingName ?? "utf-8"
                let encoding = CFStringConvertEncodingToNSStringEncoding(
                    CFStringConvertIANACharSetNameToEncoding(encodingName as CFString)
                )
                let html = String(data: data, encoding: String.Encoding(rawValue: encoding)) ?? ""
                if let payload = PayloadParser.parse(html: html) {
                    completion(Result.success(payload: payload))
                } else {
                    completion(Result.failure(error: WISPrError.notFoundPayload))
                }
            } else if let error = error {
                completion(Result.failure(error: error))
            }
        }
        task.resume()
    }

    private func validURL(from string: String) -> URL? {
        guard let url = URL(string: string), url.scheme != nil, url.host != nil else {
            return nil
        }
        return url
    }

    private func formURLEncoded(_ string: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._*"))
        return string.unicodeScalars.map { scalar in
            if allowed.contains(scalar) {
                return String(scalar)
            }
            if scalar == " " {
                return "%20"
            }
            let utf8Bytes = String(scalar).utf8.map { String(format: "%%%02X", $0) }
            return utf8Bytes.joined()
        }
        .joined()
    }
}
