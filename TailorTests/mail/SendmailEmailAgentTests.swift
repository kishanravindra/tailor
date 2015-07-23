@testable import Tailor
import TailorTesting

class SendmailEmailAgentTests: TailorTestCase {
  override func setUp() {
    super.setUp()
    ExternalProcess.startStubbing()
  }
  
  func testSendmailAgentSendsSmtpCommandsToTask() {
    let email = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Hello", body: "Greetings")
    let agent = SendmailEmailAgent([:])
    agent.deliver(email)
    
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
    let email = Email(from: "test1@tailorframe.work", recipients: ["test2@tailorframe.work", "test3@tailorframe.work"], subject: "Hello", body: "Greetings")
    
    let agent = SendmailEmailAgent([:])
    agent.deliver(email)
    
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
    
    assert(data, equals: expectedData)
  }
  
}
