import Tailor
import TailorTesting
import XCTest

class FileEmailAgentTests: XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
  func testInitializationWithFullConfigSetsFields() {
    let agent = FileEmailAgent(path: "/tmp/test_mail.txt")
    assert(agent.path, equals: "/tmp/test_mail.txt")
  }
  
  func testInitializationWithoutPathSetsDefaultPath() {
    let agent = FileEmailAgent()
    assert(agent.path, equals: "/tmp/mail.txt")
  }
  
  func testDeliverWithValidPathStoresContentsInFile() {
    let agent = FileEmailAgent()
    do {
      try NSFileManager.defaultManager().removeItemAtPath(agent.path)
    }
    catch {}
    let email1 = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Exciting Offer", body: "<h1>Hi!</h1><p>I have an exciting offer for you</p>")
    let contents1 = email1.fullMessage
    let expectedContents = NSMutableData()
    expectedContents.appendData(contents1)
    expectedContents.appendData(NSData(bytes: [13,10]))
    let expectation = expectationWithDescription("callback called")
    agent.deliver(email1) {
      success,code,message in
      expectation.fulfill()
      XCTAssertTrue(success)
      XCTAssertEqual(code, 0)
      XCTAssertEqual(message, "")
    }
    let contents = NSFileManager.defaultManager().contentsAtPath(agent.path)
    assert(contents, equals: expectedContents)
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }
  
  func testDeliverAppendsMultipleMessagesToOneFile() {
    let agent = FileEmailAgent()
    do {
      try NSFileManager.defaultManager().removeItemAtPath(agent.path)
    }
    catch {}
    let email1 = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Exciting Offer", body: "<h1>Hi!</h1><p>I have an exciting offer for you</p>")
    let email2 = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Exciting Offer", body: "<h1>Hello again!</h1><p>I have another exciting offer for you</p>")
    let contents1 = email1.fullMessage
    let contents2 = email2.fullMessage
    let expectedContents = NSMutableData()
    expectedContents.appendData(contents1)
    expectedContents.appendData(NSData(bytes: [13,10]))
    expectedContents.appendData(contents2)
    expectedContents.appendData(NSData(bytes: [13,10]))
    let expectation1 = expectationWithDescription("callback 1 called")
    let expectation2 = expectationWithDescription("callback 2 called")
    agent.deliver(email1) {
      success,code,message in
      expectation1.fulfill()
      XCTAssertTrue(success)
      XCTAssertEqual(code, 0)
      XCTAssertEqual(message, "")
    }
    agent.deliver(email2) {
      success,code,message in
      expectation2.fulfill()
      XCTAssertTrue(success)
      XCTAssertEqual(code, 0)
      XCTAssertEqual(message, "")
    }
    let contents = NSFileManager.defaultManager().contentsAtPath(agent.path)
    assert(contents, equals: expectedContents)
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }
  
  func testDeliverWithInvalidPathCallsCallbackWithError() {
    let agent = FileEmailAgent(path: "/rootfile")
    let email1 = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Exciting Offer", body: "<h1>Hi!</h1><p>I have an exciting offer for you</p>")
    let expectation = expectationWithDescription("callback called")
    agent.deliver(email1) {
      success,code,message in
      expectation.fulfill()
      XCTAssertFalse(success)
      XCTAssertEqual(code, 1)
      XCTAssertEqual(message, "Error writing to email file")
    }
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }
}
