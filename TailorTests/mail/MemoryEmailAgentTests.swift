import Tailor
import TailorTesting
import XCTest

class MemoryEmailAgentTests: XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
  func testDeliverAddsEmailToDeliveries() {
    let email = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Welcome", body: "Welcome to our site")
    let agent = MemoryEmailAgent()
    MemoryEmailAgent.deliveries = []
    agent.deliver(email) {
      result,code,message in
      XCTAssertTrue(result)
      XCTAssertEqual(code, 0)
      XCTAssertEqual(message, "")
    }
    assert(MemoryEmailAgent.deliveries, equals: [email])
  }
  
  func testDeliverAppendsEmails() {
    let email1 = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Welcome", body: "Welcome to our site")
    let email2 = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Goodbye", body: "Sorry you are leaving our site")
    let agent = MemoryEmailAgent()
    MemoryEmailAgent.deliveries = []
    agent.deliver(email1) {_,_,_ in}
    agent.deliver(email2) {_,_,_ in}
    assert(MemoryEmailAgent.deliveries, equals: [email1, email2])
  }
}

