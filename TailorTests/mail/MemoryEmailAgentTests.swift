import Tailor
import TailorTesting

class MemoryEmailAgentTests: TailorTestCase {
  func testDeliverAddsEmailToDeliveries() {
    let email = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Welcome", body: "Welcome to our site")
    let agent = MemoryEmailAgent([:])
    MemoryEmailAgent.deliveries = []
    agent.deliver(email)
    assert(MemoryEmailAgent.deliveries, equals: [email])
  }
  
  func testDeliverAppendsEmails() {
    let email1 = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Welcome", body: "Welcome to our site")
    let email2 = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Goodbye", body: "Sorry you are leaving our site")
    let agent = MemoryEmailAgent([:])
    MemoryEmailAgent.deliveries = []
    agent.deliver(email1)
    agent.deliver(email2)
    assert(MemoryEmailAgent.deliveries, equals: [email1, email2])
  }
}

