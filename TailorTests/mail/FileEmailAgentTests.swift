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
    let contents1 = email1.fullMessage
    let expectedContents = NSMutableData()
    expectedContents.appendData(contents1)
    expectedContents.appendData(NSData(bytes: [13,10]))
    agent.deliver(email1)
    let contents = NSFileManager.defaultManager().contentsAtPath(agent.path)
    assert(contents, equals: expectedContents)
  }
  
  func testDeliverAppendsMultipleMessagesToOneFile() {
    let agent = FileEmailAgent([:])
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
    agent.deliver(email1)
    agent.deliver(email2)
    let contents = NSFileManager.defaultManager().contentsAtPath(agent.path)
    assert(contents, equals: expectedContents)
  }
  
  func testDeliverWithInvalidPathDoesNotDie() {
    let agent = FileEmailAgent(["path": "/rootfile"])
    let email1 = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Exciting Offer", body: "<h1>Hi!</h1><p>I have an exciting offer for you</p>")
    agent.deliver(email1)
    assert(true, message: "Did not die")
  }
}
