@testable import Tailor
import TailorTesting
import XCTest

class EmailAgentTests: XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
  func testSharedEmailAgentCreatesEmailAgentBasedOnConfiguration() {
    struct MyAgent: EmailAgent {
      func deliver(email: Email, callback: Email.ResultHandler) {
        
      }
    }
    SHARED_EMAIL_AGENT = nil
    Application.configuration.emailAgent = { MyAgent() }
    let emailAgent = Application.sharedEmailAgent()
    assert(emailAgent is MyAgent)
  }
  
  func testSharedEmailAgentDefaultsToFileEmailAgent() {
    SHARED_EMAIL_AGENT = nil
    Application.configuration = .init()
    let emailAgent = Application.sharedEmailAgent()
    assert(emailAgent is FileEmailAgent)
  }
  
  func testSharedEmailAgentStoresValuesForSubsequentCalls() {
    struct MyAgent: EmailAgent {
      static var calls = 0
      init() {
        MyAgent.calls += 1
      }
      func deliver(email: Email, callback: Email.ResultHandler) {
        
      }
    }
    SHARED_EMAIL_AGENT = nil
    Application.configuration.emailAgent = { return MyAgent() }
    _ = Application.sharedEmailAgent()
    _ = Application.sharedEmailAgent()
    assert(MyAgent.calls, equals: 1)

  }
}
