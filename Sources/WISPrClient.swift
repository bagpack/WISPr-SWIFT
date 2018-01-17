//
//  WISPrClient.swift
//  wispr-swift
//
//  Created by bagpack on 2018/01/19.
//

import Foundation

enum WISPrError: Error {
    case unknownPayload
    case notFoundPayload
    case missingParamter
    case logoffFailed
}

class WISPrClient {

    static let userAgent: String =
    "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1"
    static let wellKnownWebPage = "http://www.apple.com/library/test/success.html"

    /// Attempt to authenticate WISPr network.
    ///
    /// - Parameters:
    ///   - url: arbitary url
    ///   - username: network username
    ///   - password: network password
    ///   - completion: callback handler
    func login(url: String = WISPrClient.wellKnownWebPage, username: String, password: String, completion: @escaping (Result) -> Void) {
        loginFunc(username: username, password: password)(url, completion)
    }

    /// Attempt logoff from WISPr network.
    ///
    /// - Parameters:
    ///   - logoffURL: logoffURL is included in payload
    ///   - completion: callback handler
    func logoff(logoffURL: String, completion: @escaping (Result) -> Void) {
        request(url: logoffURL) { result in
            switch result {
            case let .success(payload: payload):
                if payload.messageType == .logoffNotification && payload.responseCode == .logoffSucceeded {
                    completion(Result.success(payload: payload))
                } else {
                    completion(Result.failure(error: WISPrError.logoffFailed))
                }
            case let .failure(error: error):
                completion(Result.failure(error: error))
            }
        }
    }

    private func loginFunc(username: String, password: String) ->
        (_ url: String, _ completion: @escaping (Result) -> Void) -> Void {
        func login(url: String, completion: @escaping (Result) -> Void) {
            request(url: url) { result in
                switch result {
                case let .success(payload: payload):
                    switch (payload.messageType, payload.responseCode) {
                    case (.proxyNotification, .proxyDetection):
                        // Proxy
                        let delay = payload.delay ?? 0
                        let nextURL = payload.nextURL ?? url
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
                            login(url: nextURL, completion: completion)
                        }
                    case (.initialRedirectMessage, .noError):
                        // Redirect
                        self.authenticate(username: username, password: password, loginURL: payload.loginURL!, completion: { result in
                            switch result {
                            case let .success(payload: payload):
                                completion(Result.success(payload: payload))
                            case let .failure(error: error):
                                completion(Result.failure(error: error))
                            }
                        })
                    case (.responseToAuthenticationPoll, .authenticationPending):
                        // Response to Authentication Poll
                        guard let loginResultsURL = payload.loginResultsURL else {
                            completion(Result.failure(error: WISPrError.unknownPayload))
                            return
                        }
                        let delay = payload.delay ?? 0
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
                            login(url: loginResultsURL, completion: completion)
                        }
                    case (.authenticationNotification, .loginSucceeded):
                        completion(Result.success(payload: payload))
                    default:
                        completion(Result.failure(error: WISPrError.unknownPayload))
                    }
                case let .failure(error: error):
                    completion(Result.failure(error: error))
                }
            }
        }

        return login
    }

    private func authenticate(username: String, password: String, loginURL: String, completion: @escaping (Result) -> Void) {
        let url = URL(string: loginURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(WISPrClient.userAgent, forHTTPHeaderField: "User-Agent")
        let parameters = [
            "UserName": username,
            "Password": password,
            "button": "Login",
            "FNAME": "0",
            "OriginatingServer": WISPrClient.wellKnownWebPage
        ]
        request.httpBody = queryString(from: parameters).data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let encodingName = response?.textEncodingName ?? "utf-8"
                let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(encodingName as CFString!))
                let html = String(data: data, encoding: String.Encoding(rawValue: encoding)) ?? ""
                guard let payload = PayloadParser.parse(html: html) else {
                    completion(Result.failure(error: WISPrError.notFoundPayload))
                    return
                }

                if payload.messageType == .authenticationNotification && payload.responseCode == .loginSucceeded {
                    completion(Result.success(payload: payload))
                } else {
                    completion(Result.failure(error: WISPrError.missingParamter))
                }
            } else if let error = error {
                completion(Result.failure(error: error))
            }
        }
        task.resume()
    }

    private func queryString(from dictionary: [String: String]) -> String {
        return dictionary.enumerated().reduce("") { input, tuple -> String in
            let value = tuple.element.value.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? ""
            return input + tuple.element.key + "=" + value + (dictionary.count - 1 > tuple.offset ? "&" : "")
        }
    }

    private func request(url: String, completion: @escaping (Result) -> Void) {
        var request = URLRequest(url: URL(string: url)!)
        request.addValue(WISPrClient.userAgent, forHTTPHeaderField: "User-Agent")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let encodingName = response?.textEncodingName ?? "utf-8"
                let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(encodingName as CFString!))
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
}
