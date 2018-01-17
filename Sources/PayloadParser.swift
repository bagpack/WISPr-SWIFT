//
//  PayloadParser.swift
//  wispr-swift
//
//  Created by bagpack on 2018/01/17.
//

import Foundation

enum PayloadPraseError: Error {
    case missingParamter
    case unexpectedParamter
}

enum MessageType: Int {
    case initialRedirectMessage = 100
    case proxyNotification = 110
    case authenticationNotification = 120
    case logoffNotification = 130
    case responseToAuthenticationPoll = 140
    case responseToAbortLogin = 150
}

enum ResponseCode: Int {
    case noError = 0
    case loginSucceeded = 50
    case loginFailed = 100
    case RADIUSServerError = 102
    case networkAdministratorError = 105
    case logoffSucceeded = 150
    case loginAborted = 151
    case proxyDetection = 200
    case authenticationPending = 201
    case accessGatewayInternalError = 255
}

struct Payload {
    let loginURL: String?
    let logoffURL: String?
    let nextURL: String?
    let loginResultsURL: String?
    let delay: Int?
    let messageType: MessageType
    let responseCode: ResponseCode

    enum CodingKeys: String, CodingKey {
        case loginURL = "LoginURL"
        case logoffURL = "LogoffURL"
        case nextURL = "NextURL"
        case loginResultsURL = "LoginResultsURL"
        case delay = "Delay"
        case messageType = "MessageType"
        case responseCode = "ResponseCode"
    }

    static func create(from dictionary: [String: String]) throws -> Payload {
        let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        return try JSONDecoder().decode(Payload.self, from: jsonData)
    }
}

extension Payload: Decodable {

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        loginURL = try? values.decode(String.self, forKey: .loginURL)
        logoffURL = try? values.decode(String.self, forKey: .logoffURL)
        nextURL = try? values.decode(String.self, forKey: .nextURL)
        loginResultsURL = try? values.decode(String.self, forKey: .loginResultsURL)
        if let delay = try? values.decode(String.self, forKey: .delay) {
            self.delay = Int(delay)
        } else {
            self.delay = nil
        }
        messageType = MessageType(rawValue: Int(try values.decode(String.self, forKey: .messageType)) ?? -1)!
        responseCode = ResponseCode(rawValue: Int( try values.decode(String.self, forKey: .responseCode)) ?? -1)!
    }
}

class PayloadParser {
    
    class func parse(html: String) -> Payload? {
        let text = html as NSString
        let pattern = "<\\?xml.+>.*<WISPAccessGatewayParam.+>.+</WISPAccessGatewayParam>"
        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: [
                NSRegularExpression.Options.caseInsensitive, NSRegularExpression.Options.dotMatchesLineSeparators]) else {
            fatalError("invalid regex")
        }
        
        if let match = regex.firstMatch(in: html, options: [], range: NSRange(location: 0, length: text.length)) {
            let matchAll = text.substring(with: match.range(at: 0))
            return try? Payload.create(from: parse(xml: matchAll))
        }

        return nil
    }
    
    class func parse(xml: String) -> [String: String] {
        let nsXML = xml as NSString
        let pattern = "<(.*?)>(.*?)</\\1>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options:
            [NSRegularExpression.Options.caseInsensitive, NSRegularExpression.Options.dotMatchesLineSeparators]) else {
            fatalError("invalid regex")
        }
        
        var dic = [String: String]()
        if let match = regex.firstMatch(in: xml, options: [], range: NSRange(location: 0, length: nsXML.length)) {
            let innerText = nsXML.substring(with: match.range(at: 2))
            let nsInnerText = innerText as NSString
            for match in regex.matches(in: innerText, options: [], range: NSRange(location: 0, length: nsInnerText.length)) {
                let tag = nsInnerText.substring(with: match.range(at: 1))
                let value = nsInnerText.substring(with: match.range(at: 2)).trimmingCharacters(in: .whitespacesAndNewlines)
                dic[tag] = value
            }
        }

        return dic
    }
}
