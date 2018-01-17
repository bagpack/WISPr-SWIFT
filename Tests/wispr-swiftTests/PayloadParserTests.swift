//
//  PayloadParserTests.swift
//  wispr-swiftTests
//
//  Created by bagpack on 2018/01/17.
//

import XCTest

@testable import wispr_swift

class PayloadParserTests: XCTestCase, TestBundleUsable {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParseHtmlWi2() {
        let html = readBundle(forResource: "Samples/wi2", withExtension: "html")
        let payload = PayloadParser.parse(html: html)
        XCTAssertEqual(payload?.loginURL, "https://service.wi2.ne.jp/wi2net/RLogin/1/?SSID=xxxxxxxxxxxxxxxxxxxxxxxxxx")
        XCTAssertEqual(payload?.messageType, MessageType.initialRedirectMessage)
        XCTAssertEqual(payload?.responseCode, ResponseCode.noError)
    }

    func testParseHtmlWi2Logoff() {
        let html = readBundle(forResource: "Samples/wi2-logoff", withExtension: "html")
        let payload = PayloadParser.parse(html: html)
        XCTAssertEqual(payload?.messageType, MessageType.logoffNotification)
        XCTAssertEqual(payload?.responseCode, ResponseCode.logoffSucceeded)
    }

    func testParseXMLRedirectReply() {
        let xml = readBundle(forResource: "Samples/redirect-reply", withExtension: "xml")
        let dic = PayloadParser.parse(xml: xml)
        XCTAssertEqual(dic["AccessProcedure"], "1.0")
        XCTAssertEqual(dic["AccessLocation"], "12")
        XCTAssertEqual(dic["LocationName"], "ACMEWISP,Gate_14_Terminal_C_of_Newark_Airport")
        XCTAssertEqual(dic["LoginURL"], "http://www.acmewisp.com/login/")
        XCTAssertEqual(dic["AbortLoginURL"], "http://www.acmewisp.com/abortlogin/")
        XCTAssertEqual(dic["MessageType"], "100")
        XCTAssertEqual(dic["ResponseCode"], "0")

        let payload = try! Payload.create(from: dic)
        XCTAssertEqual(payload.messageType, .initialRedirectMessage)
        XCTAssertEqual(payload.loginURL, "http://www.acmewisp.com/login/")
        XCTAssertEqual(payload.responseCode, .noError)
    }

    func testParseXMLProxyReply() {
        let xml = readBundle(forResource: "Samples/proxy-reply", withExtension: "xml")
        let dic = PayloadParser.parse(xml: xml)
        XCTAssertEqual(dic["MessageType"], "110")
        XCTAssertEqual(dic["NextURL"], "http://www.acmewisp.com/proxypoll")
        XCTAssertEqual(dic["ResponseCode"], "200")
        XCTAssertEqual(dic["Delay"], "5")

        let payload = try! Payload.create(from: dic)
        XCTAssertEqual(payload.messageType, .proxyNotification)
        XCTAssertEqual(payload.nextURL, "http://www.acmewisp.com/proxypoll")
        XCTAssertEqual(payload.responseCode, .proxyDetection)
        XCTAssertEqual(payload.delay, 5)
    }

    func testParseXMLLoginSuccessfull() {
        let xml = readBundle(forResource: "Samples/login-successful", withExtension: "xml")
        let dic = PayloadParser.parse(xml: xml)
        XCTAssertEqual(dic["MessageType"], "120")
        XCTAssertEqual(dic["ResponseCode"], "50")
        XCTAssertEqual(dic["ReplyMessage"], "Authentication Success")
        XCTAssertEqual(dic["LoginResultsURL"], "http://www.acmewisp.com/loginresults/")
        XCTAssertEqual(dic["LogoffURL"], "http://www.acmewisp.com/logoff/")

        let payload = try! Payload.create(from: dic)
        XCTAssertEqual(payload.messageType, .authenticationNotification)
        XCTAssertEqual(payload.loginResultsURL, "http://www.acmewisp.com/loginresults/")
        XCTAssertEqual(payload.responseCode, .loginSucceeded)
    }

    func testParseXMLLoginRejected() {
        let xml = readBundle(forResource: "Samples/login-rejected", withExtension: "xml")
        let dic = PayloadParser.parse(xml: xml)
        XCTAssertEqual(dic["MessageType"], "120")
        XCTAssertEqual(dic["ResponseCode"], "100")
        XCTAssertEqual(dic["ReplyMessage"], "Invalid Password")
        XCTAssertEqual(dic["LoginResultsURL"], "http://www.acmewisp.com/loginresults/")
        XCTAssertEqual(dic["LogoffURL"], "http://www.acmewisp.com/logoff/")

        let payload = try! Payload.create(from: dic)
        XCTAssertEqual(payload.messageType, .authenticationNotification)
        XCTAssertEqual(payload.loginResultsURL, "http://www.acmewisp.com/loginresults/")
        XCTAssertEqual(payload.logoffURL, "http://www.acmewisp.com/logoff/")
        XCTAssertEqual(payload.responseCode, .loginFailed)
    }
}
