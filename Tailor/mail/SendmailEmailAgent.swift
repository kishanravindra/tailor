/**
  This protocol describes the behavior of NSTask that is used by
  SendmailEmailAgent.

  It is used internally to allow stubbing out the task in testing.
  */
internal protocol NSTaskType {
  /** The pipe for sending input to the task. */
  var standardInput: AnyObject? { get }
  
  /** The pipe for reading output from the task. */
  var standardOutput: AnyObject? { get }
}

/**
  This class provides an email agent for sending mail using sendmail.

  This assumes that you have sendmail defined at `/usr/sbin/sendmail`. If you
  don't, this will cause a fatal error.
  */
public final class SendmailEmailAgent: EmailAgent {
  /**
    The task that we are runninfg to communicate with sendmail.
  
    Under normall circumstances, this will be created automatically while
    delivering an email. This can also be set in the initializer.
    */
  private var task: NSTaskType?
  
  /**
    A handle that we can to get output from the sendmail task.
    */
  private var handleForReading: NSFileHandle? {
    if let pipe = self.task?.standardOutput as? NSPipe {
      return pipe.fileHandleForReading
    }
    else {
      return nil
    }
  }
  
  /**
    A handle that we can use to get output from the sendmail task.
    */
  private var handleForWriting: NSFileHandle? {
    if let pipe = self.task?.standardInput as? NSPipe {
      return pipe.fileHandleForWriting
    }
    else {
      return nil
    }
  }
  
  /**
    This initializer creates a sendmail agent.

    - parameter config:   The application's mail config.
    */
  public init(_ config: [String: String]) {
    self.task = nil
  }
  
  /**
    This initializer creates a sendmail agent with a stubbed out task.
    */
  internal init(task: NSTaskType) {
    self.task = task
  }
  
  /**
    This method writes a string to the input for the sendmail task.

    This will also read data from the task's output, so that sendmail is ready
    for the next command.
    */
  private func writeString(string: String) {
    if let data = string.dataUsingEncoding(NSASCIIStringEncoding) {
      handleForWriting?.writeData(data)
      handleForReading?.availableData
    }
  }
  
  /**
    This method launches a new sendmail task.

    - returns:    The new task.
    */
  private func launchTask() -> NSTask {
    let task = NSTask()
    task.launchPath = "/usr/sbin/sendmail"
    task.arguments = ["-bs"]
    task.standardInput = NSPipe()
    task.standardOutput = NSPipe()
    task.launch()
    return task
  }
  
  /**
    This method delivers an email with sendmail.

    This will run a sendmail command, feed it the email over its standard input,
    and then close the task.
    
    - parameter email:    The email to deliver.
    */
  public func deliver(email: Email) {
    let needsTask = (task == nil)
    if needsTask {
      let task = launchTask()
      self.task = task
      self.handleForReading
    }
    defer {
      if needsTask {
        if let task = self.task as? NSTask {
          task.terminate()
          self.task = nil
        }
      }
    }
    self.writeString("MAIL FROM: \(email.from)\r\n")
    self.writeString("RCPT TO: \(email.to)\r\n")
    self.writeString("DATA\r\n")
    self.writeString(email.fullMessage)
    self.writeString("\r\n.\r\n")
  }
}

extension NSTask: NSTaskType {
  
}