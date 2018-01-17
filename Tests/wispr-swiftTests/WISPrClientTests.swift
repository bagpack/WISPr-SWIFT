//
//  WISPrClientTests.swift
//  wispr-swiftTests
//
//  Created by bagpack on 2018/02/14.
//

import XCTest

@testable import wispr_swift

import OHHTTPStubs

private let username = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxxxx@xxxxx@xxx"
private let password = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"

class WISPrClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        stub(condition: isHost("mywebservice.com") && isPath("/login")) { request in
            return OHHTTPStubsResponse(
                fileAtPath: OHPathForFile("Samples/wi2.html", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"text/html"]
            )
        }

        stub(condition: isHost("mywebservice.com") && isPath("/proxy-reply")) { request in
            return OHHTTPStubsResponse(
                fileAtPath: OHPathForFile("Samples/proxy-reply.xml", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"text/html"]
            )
        }

        stub(condition: isHost("mywebservice.com") && isPath("/auth-poll")) { request in
            return OHHTTPStubsResponse(
                fileAtPath: OHPathForFile("Samples/authentication-poll.xml", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"text/html"]
            )
        }

        stub(condition: isHost("service.wi2.ne.jp") && isPath("/wi2net/RLogin/1")) { request in
            return OHHTTPStubsResponse(
                fileAtPath: OHPathForFile("Samples/login-successful.xml", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"text/html"]
            )
        }

        stub(condition: isHost("www.acmewisp.com") && isPath("/proxypoll")) { request in
            return OHHTTPStubsResponse(
                fileAtPath: OHPathForFile("Samples/login-successful.xml", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"text/html"]
            )
        }
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testLoginSuccessful() {
        let loginExpectation: XCTestExpectation =
            self.expectation(description: "login")
        WISPrClient().login(url: "http://mywebservice.com/login", username: username, password: password) { (result) in
            switch result {
            case .success(_):
                XCTAssert(true)
            case .failure(_):
                XCTAssert(false)
            }
            loginExpectation.fulfill()
        }

        wait(for: [loginExpectation], timeout: 60)
    }

    func testProxyReply() {
        let loginExpectation: XCTestExpectation =
            self.expectation(description: "proxy reply")
        WISPrClient().login(url: "http://mywebservice.com/proxy-reply", username: username, password: password) { (result) in
            switch result {
            case .success(_):
                XCTAssert(true)
            case .failure(_):
                XCTAssert(false)
            }
            loginExpectation.fulfill()
        }

        wait(for: [loginExpectation], timeout: 60)
    }

    func testAuthenticationPoll() {
        let loginExpectation: XCTestExpectation =
            self.expectation(description: "authentiation poll")
        WISPrClient().login(url: "http://mywebservice.com/auth-poll", username: username, password: password) { (result) in
            switch result {
            case .success(_):
                XCTAssert(true)
            case .failure(_):
                XCTAssert(false)
            }
            loginExpectation.fulfill()
        }

        wait(for: [loginExpectation], timeout: 60)
    }
}
