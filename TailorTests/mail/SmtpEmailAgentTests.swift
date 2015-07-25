@testable import Tailor
import TailorTesting

class SmptEmailAgentTests: TailorTestCase {
  override func setUp() {
    super.setUp()
    ExternalProcess.startStubbing()
  }
  
  func testInitializeWithAllFieldsSetsFields() {
    let agent = SmtpEmailAgent([
      "host": "tailorframe.work",
      "username": "jim",
      "password": "Monkey",
      "ssl": "false",
      "port": "123"
    ])
    assert(agent.host, equals: "tailorframe.work")
    assert(agent.username, equals: "jim")
    assert(agent.password, equals: "Monkey")
    assert(agent.ssl, equals: false)
    assert(agent.port, equals: 123)
  }
  
  func testInitializeWithNoFieldsSetsDefaults() {
    let agent = SmtpEmailAgent([:])
    assert(agent.host, equals: "")
    assert(agent.username, equals: "")
    assert(agent.password, equals: "")
    assert(agent.port, equals: 465)
    assert(agent.ssl, equals: true)
  }
  
  func testInitializeWithNoPortWithoutSslUsesCorrectPort() {
    let agent = SmtpEmailAgent(["ssl": "false"])
    assert(agent.ssl, equals: false)
    assert(agent.port, equals: 587)
  }
  
  func testDeliverWithSingleRecipientCallsCurl() {
    let agent = SmtpEmailAgent([
      "host": "tailorframe.work",
      "username": "jim",
      "password": "Monkey",
      "ssl": "false",
      "port": "123"
      ])
    let email = Email(from: "jim+mail@tailorframe.work", to: "jane@gmail.com", subject: "Greetings", body: "How are you doing?")
    agent.deliver(email)
    assert(ExternalProcess.stubs.count, equals: 1, message: "creates a single process")
    guard let process = ExternalProcess.stubs.first else { return }
    assert(process.launchPath, equals: "/usr/bin/curl")
    assert(process.arguments ?? [], equals: [
      "smtps://tailorframe.work",
      "--mail-from",
      "jim+mail@tailorframe.work",
      "--mail-rcpt",
      "jane@gmail.com",
      "--ssl",
      "-u",
      "jim:Monkey",
      "-T",
      "-"
    ])
    let expectedData = NSMutableData()
    expectedData.appendData(email.fullMessage)
    assert(process.writtenData, equals: expectedData)
  }
  
  func testDeliverWithMultipleRecipientCallsCurlMultipleTimes() {
    let agent = SmtpEmailAgent([
      "host": "tailorframe.work",
      "username": "jim",
      "password": "Monkey",
      "ssl": "false",
      "port": "123"
      ])
    let email = Email(from: "jim+mail@tailorframe.work", recipients: ["jane@gmail.com", "john@gmail.com"], ccs: ["george@tailorframe.work", "bob@tailorframe.work"], bccs: ["alice@tailorframe.work"], subject: "Greetings", body: "How are you doing?")
    agent.deliver(email)
    let recipients = ["jane@gmail.com", "john@gmail.com", "george@tailorframe.work", "bob@tailorframe.work", "alice@tailorframe.work"]
    assert(ExternalProcess.stubs.count, equals: recipients.count, message: "creates a process for each recipient")
    
    for (index,recipient) in recipients.enumerate() {
      let process = ExternalProcess.stubs[index]
    
      assert(process.launchPath, equals: "/usr/bin/curl")
      assert(process.arguments ?? [], equals: [
        "smtps://tailorframe.work",
        "--mail-from",
        "jim+mail@tailorframe.work",
        "--mail-rcpt",
        recipient,
        "--ssl",
        "-u",
        "jim:Monkey",
        "-T",
        "-"
      ])
      
      let expectedData = NSMutableData()
      expectedData.appendData(email.fullMessage)
      assert(process.writtenData, equals: expectedData)
    }
  }
}