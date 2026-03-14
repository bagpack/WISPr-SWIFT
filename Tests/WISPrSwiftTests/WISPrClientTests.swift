import XCTest
@testable import WISPrSwift
import OHHTTPStubs
import OHHTTPStubsSwift

private let username = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxxxx@xxxxx@xxx"
private let password = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"

final class WISPrClientTests: XCTestCase, TestBundleUsable {

    private var capturedRequestBody: String?
    private var capturedContentType: String?

    override func setUp() {
        super.setUp()
        capturedRequestBody = nil
        capturedContentType = nil

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

        stub(condition: isHost("mywebservice.com") && isPath("/invalid-next-url")) { _ in
            fixture(filePath: self.fixturePath("invalid-next-url.xml"), status: 200, headers: ["Content-Type": "text/html"])
        }

        stub(condition: isHost("mywebservice.com") && isPath("/invalid-login-results-url")) { _ in
            fixture(filePath: self.fixturePath("invalid-login-results-url.xml"), status: 200, headers: ["Content-Type": "text/html"])
        }

        stub(condition: isHost("mywebservice.com") && isPath("/invalid-login-url")) { _ in
            fixture(filePath: self.fixturePath("invalid-login-url.xml"), status: 200, headers: ["Content-Type": "text/html"])
        }

        stub(condition: isHost("mywebservice.com") && isPath("/unknown-message-type")) { _ in
            fixture(filePath: self.fixturePath("unknown-message-type.xml"), status: 200, headers: ["Content-Type": "text/html"])
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

    func testLoginFailsForInvalidURLInput() {
        let loginExpectation = expectation(description: "invalid url")
        WISPrClient().login(url: "http://exa mple.com", username: username, password: password) { result in
            switch result {
            case .success:
                XCTFail("login should fail")
            case let .failure(error):
                XCTAssertEqual(error as? WISPrError, .invalidURL("http://exa mple.com"))
            }
            loginExpectation.fulfill()
        }

        wait(for: [loginExpectation], timeout: 5)
    }

    func testLogoffFailsForInvalidURLInput() {
        let expectation = expectation(description: "invalid logoff url")
        WISPrClient().logoff(logoffURL: "http://exa mple.com") { result in
            switch result {
            case .success:
                XCTFail("logoff should fail")
            case let .failure(error):
                XCTAssertEqual(error as? WISPrError, .invalidURL("http://exa mple.com"))
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testLoginFailsForInvalidNextURLInPayload() {
        let expectation = expectation(description: "invalid next url")
        WISPrClient().login(url: "http://mywebservice.com/invalid-next-url", username: username, password: password) { result in
            switch result {
            case .success:
                XCTFail("login should fail")
            case let .failure(error):
                XCTAssertEqual(error as? WISPrError, .invalidURL("http://exa mple.com"))
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testLoginFailsForInvalidLoginResultsURLInPayload() {
        let expectation = expectation(description: "invalid login results url")
        WISPrClient().login(url: "http://mywebservice.com/invalid-login-results-url", username: username, password: password) { result in
            switch result {
            case .success:
                XCTFail("login should fail")
            case let .failure(error):
                XCTAssertEqual(error as? WISPrError, .invalidURL("http://exa mple.com"))
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testLoginFailsForInvalidLoginURLInPayload() {
        let expectation = expectation(description: "invalid login url in payload")
        WISPrClient().login(url: "http://mywebservice.com/invalid-login-url", username: username, password: password) { result in
            switch result {
            case .success:
                XCTFail("login should fail")
            case let .failure(error):
                XCTAssertEqual(error as? WISPrError, .invalidURL("http://exa mple.com"))
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testLoginSendsFormURLEncodedBody() {
        let expectation = expectation(description: "form body")
        let specialUsername = "user+name&part =value"
        let specialPassword = "pa ss+word&pair=value"

        stub(condition: isHost("service.wi2.ne.jp") && isPath("/wi2net/RLogin/1")) { request in
            self.capturedRequestBody = request.ohhttpStubs_httpBody.flatMap { String(data: $0, encoding: .utf8) }
            self.capturedContentType = request.value(forHTTPHeaderField: "Content-Type")
            return fixture(filePath: self.fixturePath("login-successful.xml"), status: 200, headers: ["Content-Type": "text/html"])
        }

        WISPrClient().login(url: "http://mywebservice.com/login", username: specialUsername, password: specialPassword) { result in
            switch result {
            case .success:
                XCTAssertEqual(
                    self.capturedRequestBody,
                    "UserName=user%2Bname%26part%20%3Dvalue&Password=pa%20ss%2Bword%26pair%3Dvalue&button=Login&FNAME=0&OriginatingServer=http%3A%2F%2Fwww.apple.com%2Flibrary%2Ftest%2Fsuccess.html"
                )
                XCTAssertEqual(self.capturedContentType, "application/x-www-form-urlencoded; charset=utf-8")
            case .failure:
                XCTFail("login failed")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)
    }

    func testLoginFailsForUnknownMessageTypePayload() {
        let expectation = expectation(description: "unknown message type")
        WISPrClient().login(url: "http://mywebservice.com/unknown-message-type", username: username, password: password) { result in
            switch result {
            case .success:
                XCTFail("login should fail")
            case let .failure(error):
                XCTAssertEqual(error as? WISPrError, .notFoundPayload)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }
}
