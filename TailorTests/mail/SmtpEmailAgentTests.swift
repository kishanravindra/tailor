@testable import Tailor
import TailorTesting
import XCTest

class SmptEmailAgentTests: TailorTestCase {
  override func setUp() {
    super.setUp()
    ExternalProcess.startStubbing()
  }
  
  func testInitializeWithAllFieldsSetsFields() {
    let agent = SmtpEmailAgent(
      host: "tailorframe.work",
      username: "jim",
      password: "Monkey",
      ssl: false,
      port: 123
    )
    assert(agent.host, equals: "tailorframe.work")
    assert(agent.username, equals: "jim")
    assert(agent.password, equals: "Monkey")
    assert(agent.ssl, equals: false)
    assert(agent.port, equals: 123)
  }
  
  func testDeliverWithSingleRecipientCallsCurl() {
    let agent = SmtpEmailAgent(
      host: "tailorframe.work",
      username: "jim",
      password: "Monkey"
    )
    let email = Email(from: "jim+mail@tailorframe.work", to: "jane@gmail.com", subject: "Greetings", body: "How are you doing?")
    agent.deliver(email) {
      _,_,_ in
    }
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
    let agent = SmtpEmailAgent(
      host: "tailorframe.work",
      username: "jim",
      password: "Monkey"
      )
    let email = Email(from: "jim+mail@tailorframe.work", recipients: ["jane@gmail.com", "john@gmail.com"], ccs: ["george@tailorframe.work", "bob@tailorframe.work"], bccs: ["alice@tailorframe.work"], subject: "Greetings", body: "How are you doing?")
    agent.deliver(email){
      _,_,_ in
    }
    let recipients = ["jane@gmail.com", "john@gmail.com", "george@tailorframe.work", "bob@tailorframe.work", "alice@tailorframe.work"]
    assert(ExternalProcess.stubs.count, equals: recipients.count, message: "creates a process for each recipient")
    
    let expectedData = NSMutableData()
    expectedData.appendData(email.fullMessage)
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
      
      assert(process.writtenData, equals: expectedData)
    }
  }
  
  func testDeliverWithSuccessfulResponseGivesSuccessfulResponse() {
    let agent = SmtpEmailAgent(
      host: "tailorframe.work",
      username: "jim",
      password: "Monkey"
    )
    let email = Email(from: "jim+mail@tailorframe.work", to: "jane@gmail.com", subject: "Greetings", body: "How are you doing?")
    ExternalProcess.stubResult = (0, NSData(bytes: "Sending info\ncurl:All cool".utf8))
    let expectation = expectationWithDescription("callback called")
    agent.deliver(email) {
      success,code,message in
      expectation.fulfill()
      XCTAssertTrue(success)
      XCTAssertEqual(code, 0)
      XCTAssertEqual(message, "")
    }
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }
  
  func testDeliverWithUnsuccessfulResponseGivesUnsuccessfulResponse() {
    let agent = SmtpEmailAgent(
      host: "tailorframe.work",
      username: "jim",
      password: "Monkey"
    )
    let email = Email(from: "jim+mail@tailorframe.work", to: "jane@gmail.com", subject: "Greetings", body: "How are you doing?")
    ExternalProcess.stubResult = (1, NSData(bytes: "Sending info\ncurl:No can do".utf8))
    let expectation = expectationWithDescription("callback called")
    agent.deliver(email) {
      success,code,message in
      expectation.fulfill()
      XCTAssertFalse(success)
      XCTAssertEqual(code, 1)
      XCTAssertEqual(message, "No can do")
    }
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }
  
  func testDeliverWithNonAsciiResponseGivesEmptyStringForResponse() {
    let agent = SmtpEmailAgent(
      host: "tailorframe.work",
      username: "jim",
      password: "Monkey"
    )
    let email = Email(from: "jim+mail@tailorframe.work", to: "jane@gmail.com", subject: "Greetings", body: "How are you doing?")
    ExternalProcess.stubResult = (0, NSData(bytes: [0xff]))
    let expectation = expectationWithDescription("callback called")
    agent.deliver(email) {
      success,code,message in
      expectation.fulfill()
      XCTAssertTrue(success)
      XCTAssertEqual(code, 0)
      XCTAssertEqual(message, "")
    }
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }
}