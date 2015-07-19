@testable import Tailor
import TailorTesting
import XCTest

class EmailAgentTests: TailorTestCase {
  func testSharedEmailAgentCreatesEmailAgentBasedOnConfiguration() {
    final class MyAgent: EmailAgent {
      init(_ config: [String:String]) {
        if let value = config["testKey"] {
          XCTAssertEqual(value, "testValue")
        }
        else {
          XCTFail("Did not send a configuration key for testKey")
        }
      }
      func deliver(email: Email) {
        
      }
    }
    SHARED_EMAIL_AGENT = nil
    Application.sharedApplication().configuration.child("email").addDictionary([
      "klass": NSStringFromClass(MyAgent),
      "testKey": "testValue"
    ])
    let emailAgent = Application.sharedEmailAgent()
    assert(emailAgent is MyAgent)
  }
  
  func testSharedEmailAgentDefaultsToFileEmailAgent() {
    SHARED_EMAIL_AGENT = nil
    Application.sharedApplication().configuration["child"] = nil
    let emailAgent = Application.sharedEmailAgent()
    assert(emailAgent is FileEmailAgent)
  }
  
  func testSharedEmailAgentStoresValuesForSubsequentCalls() {
    final class MyAgent: EmailAgent {
      static var calls = 0
      init(_ config: [String:String]) {
        MyAgent.calls += 1
      }
      func deliver(email: Email) {
        
      }
    }
    SHARED_EMAIL_AGENT = nil
    Application.sharedApplication().configuration.child("email").addDictionary([
      "klass": NSStringFromClass(MyAgent),
      "testKey": "testValue"
      ])
    _ = Application.sharedEmailAgent()
    _ = Application.sharedEmailAgent()
    assert(MyAgent.calls, equals: 1)

  }
}
