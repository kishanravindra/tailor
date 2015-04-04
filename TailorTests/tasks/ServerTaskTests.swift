import XCTest
import Tailor

class ServerTaskTests: XCTestCase {
  func testRunStartsServer() {
    let expectation = expectationWithDescription("server started")
    class ServerTestApplication : Application {
      var expectation: XCTestExpectation?
      
      override func startServer() {
        expectation?.fulfill()
      }
    }
    let application = ServerTestApplication()
    application.expectation = expectation
    NSThread.currentThread().threadDictionary["SHARED_APPLICATION"] = application
    ServerTask().run()
    waitForExpectationsWithTimeout(0.01, handler: nil)
    NSThread.currentThread().threadDictionary.removeObjectForKey("SHARED_APPLICATION")
  }
}
