import Tailor
import TailorTesting

class FileEmailAgentTests: TailorTestCase {
  func testInitializationWithFullConfigSetsFields() {
    let agent = FileEmailAgent(["path": "/tmp/test_mail.txt"])
    assert(agent.path, equals: "/tmp/test_mail.txt")
  }
  
  func testInitializationWithoutPathSetsDefaultPath() {
    let agent = FileEmailAgent([:])
    assert(agent.path, equals: "/tmp/mail.txt")
  }
  
  func testDeliverWithValidPathStoresContentsInFile() {
    let agent = FileEmailAgent([:])
    do {
      try NSFileManager.defaultManager().removeItemAtPath(agent.path)
    }
    catch {}
    let email1 = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Exciting Offer", body: "<h1>Hi!</h1><p>I have an exciting offer for you</p>")
    guard let contents1 = email1.fullMessage.dataUsingEncoding(NSASCIIStringEncoding) else {
      assert(false, message: "Error generating test contents")
      return
    }
    let expectedContents = NSMutableData()
    expectedContents.appendData(contents1)
    expectedContents.appendData(NSData(bytes: [13,10]))
    do {
      try agent.deliver(email1)
      let contents = NSFileManager.defaultManager().contentsAtPath(agent.path)
      assert(contents, equals: expectedContents)
    }
    catch {
      assert(false, message: "Raised unexpected error")
    }
  }
  
  func testDeliverAppendsMultipleMessagesToOneFile() {
    let agent = FileEmailAgent([:])
    do {
      try NSFileManager.defaultManager().removeItemAtPath(agent.path)
    }
    catch {}
    let email1 = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Exciting Offer", body: "<h1>Hi!</h1><p>I have an exciting offer for you</p>")
    let email2 = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Exciting Offer", body: "<h1>Hello again!</h1><p>I have another exciting offer for you</p>")
    guard let contents1 = email1.fullMessage.dataUsingEncoding(NSASCIIStringEncoding) else {
      assert(false, message: "Error generating test contents")
      return
    }
    guard let contents2 = email2.fullMessage.dataUsingEncoding(NSASCIIStringEncoding) else {
      assert(false, message: "Error generating test contents")
      return
    }
    let expectedContents = NSMutableData()
    expectedContents.appendData(contents1)
    expectedContents.appendData(NSData(bytes: [13,10]))
    expectedContents.appendData(contents2)
    expectedContents.appendData(NSData(bytes: [13,10]))
    do {
      try agent.deliver(email1)
      try agent.deliver(email2)
      let contents = NSFileManager.defaultManager().contentsAtPath(agent.path)
      assert(contents, equals: expectedContents)
    }
    catch {
      assert(false, message: "Raised unexpected error")
    }
  }
  
  func testDeliverWithInvalidPathThrowsException() {
    let agent = FileEmailAgent(["path": "/rootfile"])
    let email1 = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Exciting Offer", body: "<h1>Hi!</h1><p>I have an exciting offer for you</p>")
    do {
      try agent.deliver(email1)
      assert(false, message: "Did not raise an error")
    }
    catch let error as NSError {
      assert(error.domain, equals: "NSPOSIXErrorDomain")
      assert(error.code, equals: 13)
    }
    catch {
      assert(false, message: "Raised unexpected error")
    }
  }
}
