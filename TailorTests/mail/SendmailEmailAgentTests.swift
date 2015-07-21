@testable import Tailor
import TailorTesting

class SendmailEmailAgentTests: TailorTestCase {
  class StubTask: NSTaskType {
    let inputPipe = NSPipe()
    let outputPipe = NSPipe()
    var standardInput: AnyObject? { return inputPipe }
    var standardOutput: AnyObject? { return nil }
  }
  
  func testSendmailAgentSendsSmtpCommandsToTask() {
    let email = Email(from: "test1@tailorframe.work", to: "test2@tailorframe.work", subject: "Hello", body: "Greetings")
    let task = StubTask()
    let agent = SendmailEmailAgent(task: task)
    agent.deliver(email)
    let data = task.inputPipe.fileHandleForReading.availableData
    let expectedData = NSMutableData()
    expectedData.appendData("MAIL FROM: test1@tailorframe.work\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData("RCPT TO: test2@tailorframe.work\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData("DATA\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData(email.fullMessage.dataUsingEncoding(NSASCIIStringEncoding)!)
    expectedData.appendData("\r\n.\r\n".dataUsingEncoding(NSASCIIStringEncoding)!)
    assert(data, equals: expectedData)
  }
}
