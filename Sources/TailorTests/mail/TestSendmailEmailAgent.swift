@testable import Tailor
import TailorTesting
import XCTest
import Foundation

struct TestSendmailEmailAgent: XCTestCase, TailorTestable {
  //FIXME - Re-enable disabled tests
  var allTests: [(String, () throws -> Void)] { return [
    //("testSendmailAgentSendsSmtpCommandsToTask", testSendmailAgentSendsSmtpCommandsToTask),
    //("testSendmailAgentSendsSeparateEmailsForMultipleRecipients", testSendmailAgentSendsSeparateEmailsForMultipleRecipients),
    ("testSendmailAgentCallsWithOkResponseGivesSuccessfulResult", testSendmailAgentCallsWithOkResponseGivesSuccessfulResult),
    ("testSendmailAgentCallsWithOkResponseWithStrayNewlineGivesSuccessfulResult", testSendmailAgentCallsWithOkResponseWithStrayNewlineGivesSuccessfulResult),
    ("testSendmailAgentCallsWithErrorResponseGivesUnsuccessfulResult", testSendmailAgentCallsWithErrorResponseGivesUnsuccessfulResult),
    ("testSendmailAgentWithNonUtf8ResponseHasEmptyMessage", testSendmailAgentWithNonUtf8ResponseHasEmptyMessage),
  ]}

  func setUp() {
    setUpTestCase()
    ExternalProcess.startStubbing()
  }
  
  func testSendmailAgentSendsSmtpCommandsToTask() {
    let email = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Hello", body: "Greetings")
    let agent = SendmailEmailAgent()
    agent.deliver(email){
      _,_,_ in
    }
    
    assert(ExternalProcess.stubs.count, equals: 1, message: "launches a single process")
    guard let process = ExternalProcess.stubs.last else {
      return
    }
    
    assert(process.launchPath, equals: "/usr/sbin/sendmail")
    assert(process.arguments ?? [], equals: ["-bs"])
    let data = process.writtenData
    let expectedData = NSMutableData()
    expectedData.appendData("MAIL FROM: test1@tailorframe.work\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData("RCPT TO: test2@tailorframe.work\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData("DATA\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData(email.fullMessage)
    expectedData.appendData("\r\n.\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    assert(data, equals: expectedData)
  }
  
  func testSendmailAgentSendsSeparateEmailsForMultipleRecipients() {
    let email = Email(from: "test1@tailorframe.work", recipients: ["test2@tailorframe.work", "test3@tailorframe.work"], ccs: ["test4@tailorframe.work"], bccs: ["test5@tailorframe.work"], subject: "Hello", body: "Greetings")
    
    let agent = SendmailEmailAgent()
    agent.deliver(email){
      _,_,_ in
    }
    
    assert(ExternalProcess.stubs.count, equals: 1, message: "launches a single process")
    guard let process = ExternalProcess.stubs.last else {
      return
    }
    
    assert(process.launchPath, equals: "/usr/sbin/sendmail")
    assert(process.arguments ?? [], equals: ["-bs"])
    
    let data = process.writtenData
    
    let expectedData = NSMutableData()
    expectedData.appendData("MAIL FROM: test1@tailorframe.work\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData("RCPT TO: test2@tailorframe.work\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData("DATA\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData(email.fullMessage)
    expectedData.appendData("\r\n.\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData("MAIL FROM: test1@tailorframe.work\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData("RCPT TO: test3@tailorframe.work\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData("DATA\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData(email.fullMessage)
    expectedData.appendData("\r\n.\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData("MAIL FROM: test1@tailorframe.work\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData("RCPT TO: test4@tailorframe.work\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData("DATA\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData(email.fullMessage)
    expectedData.appendData("\r\n.\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData("MAIL FROM: test1@tailorframe.work\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData("RCPT TO: test5@tailorframe.work\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData("DATA\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData(email.fullMessage)
    expectedData.appendData("\r\n.\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    
    assert(data, equals: expectedData)
  }
  
  func testSendmailAgentCallsWithOkResponseGivesSuccessfulResult() {
    let email = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Hello", body: "Greetings")
    let agent = SendmailEmailAgent()
    let expectation = expectationWithDescription("callback called")
    let message = "250 2.1.0 Ok\r\n250 2.1.5 Ok\r\n354 End data with <CR><LF>.<CR><LF>\r\n250 2.0.0 Ok: queued as 8139FC52951"
    ExternalProcess.stubResult = (0, NSData(bytes: message.utf8))
    agent.deliver(email) {
      success,code,message in
      expectation.fulfill()
      XCTAssertTrue(success)
      XCTAssertEqual(code, 0)
      XCTAssertEqual(message, message)
    }
    
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }
  
  func testSendmailAgentCallsWithOkResponseWithStrayNewlineGivesSuccessfulResult() {
    let email = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Hello", body: "Greetings")
    let agent = SendmailEmailAgent()
    let expectation = expectationWithDescription("callback called")
    let message = "250 2.1.0 Ok\r\n250 2.1.5 Ok\r\n354 End data with <CR><LF>.<CR><LF>\r\n250 2.0.0 Ok: queued as 8139FC52951\n"
    ExternalProcess.stubResult = (0, NSData(bytes: message.utf8))
    agent.deliver(email) {
      success,code,message in
      expectation.fulfill()
      XCTAssertTrue(success)
      XCTAssertEqual(code, 0)
      XCTAssertEqual(message, message)
    }
    
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }
  
  func testSendmailAgentCallsWithErrorResponseGivesUnsuccessfulResult() {
    let email = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Hello", body: "Greetings")
    let agent = SendmailEmailAgent()
    let expectation = expectationWithDescription("callback called")
    let message = "250 2.1.0 Ok\r\n554 5.5.1 Error: no valid recipients\r\n221 2.7.0 Error: I can break rules, too. Goodbye."
    ExternalProcess.stubResult = (0, NSData(bytes: message.utf8))
    agent.deliver(email) {
      success,code,message in
      expectation.fulfill()
      XCTAssertFalse(success)
      XCTAssertEqual(code, 1)
      XCTAssertEqual(message, message)
    }
    
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }
  
  func testSendmailAgentWithNonUtf8ResponseHasEmptyMessage() {
    let email = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Hello", body: "Greetings")
    let agent = SendmailEmailAgent()
    let expectation = expectationWithDescription("callback called")
    ExternalProcess.stubResult = (1, NSData(bytes: [0xFF]))
    agent.deliver(email) {
      success,code,message in
      expectation.fulfill()
      XCTAssertFalse(success)
      XCTAssertEqual(code, 1)
      XCTAssertEqual(message, "")
    }
    
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }
}
