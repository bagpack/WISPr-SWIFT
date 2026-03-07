import XCTest
@testable import WISPrSwift
import OHHTTPStubs
import OHHTTPStubsSwift

private let username = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxxxx@xxxxx@xxx"
private let password = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"

final class WISPrClientTests: XCTestCase, TestBundleUsable {

    override func setUp() {
        super.setUp()
        stub(condition: isHost("mywebservice.com") && isPath("/login")) { _ in
            fixture(filePath: self.fixturePath("wi2.html"), status: 200, headers: ["Content-Type": "text/html"])
        }

        stub(condition: isHost("mywebservice.com") && isPath("/proxy-reply")) { _ in
            fixture(filePath: self.fixturePath("proxy-reply.xml"), status: 200, headers: ["Content-Type": "text/html"])
        }

        stub(condition: isHost("mywebservice.com") && isPath("/auth-poll")) { _ in
            fixture(filePath: self.fixturePath("authentication-poll.xml"), status: 200, headers: ["Content-Type": "text/html"])
        }

        stub(condition: isHost("service.wi2.ne.jp") && isPath("/wi2net/RLogin/1")) { _ in
            fixture(filePath: self.fixturePath("login-successful.xml"), status: 200, headers: ["Content-Type": "text/html"])
        }

        stub(condition: isHost("www.acmewisp.com") && isPath("/proxypoll")) { _ in
            fixture(filePath: self.fixturePath("login-successful.xml"), status: 200, headers: ["Content-Type": "text/html"])
        }
    }

    override func tearDown() {
        HTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testLoginSuccessful() {
        let loginExpectation = expectation(description: "login")
        WISPrClient().login(url: "http://mywebservice.com/login", username: username, password: password) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTFail("login failed")
            }
            loginExpectation.fulfill()
        }

        wait(for: [loginExpectation], timeout: 60)
    }

    func testProxyReply() {
        let loginExpectation = expectation(description: "proxy reply")
        WISPrClient().login(url: "http://mywebservice.com/proxy-reply", username: username, password: password) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTFail("proxy reply failed")
            }
            loginExpectation.fulfill()
        }

        wait(for: [loginExpectation], timeout: 60)
    }

    func testAuthenticationPoll() {
        let loginExpectation = expectation(description: "authentication poll")
        WISPrClient().login(url: "http://mywebservice.com/auth-poll", username: username, password: password) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTFail("authentication poll failed")
            }
            loginExpectation.fulfill()
        }

        wait(for: [loginExpectation], timeout: 60)
    }
}
