import XCTest

class ServerTaskTests: XCTestCase {
  func testRunStartsServer() {
    let expectation = expectationWithDescription("server started")
    class ServerTestApplication : Application {
      var expectation: XCTestExpectation?
      
      override func startServer() {
        expectation?.fulfill()
      }
    }
    let application = ServerTestApplication(arguments: ["tailor.exit"])
    application.expectation = expectation
    SHARED_APPLICATION = application
    ServerTask().run()
    waitForExpectationsWithTimeout(0.01, handler: nil)
    SHARED_APPLICATION = nil
  }
}
