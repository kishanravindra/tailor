import Foundation

/**
  This class models a task that can be run from the command-line.

  Tailor comes with a few built-in tasks for running the server and running
  alterations. 

  **NOTE**: This has been deprecated in favor of the `TaskType` protocol.
  */
@available(*, deprecated, message="Use TaskType instead") public class Task {
  /**
    This method initializes a task.
  
    It doesn't do anything, but we need a required initializer to be able to
    dynamically initialize them when running tasks.
    */
  public required init() {
  }
  
  /**
    This method gets the command that is specified on the command-line to run
    this task.

    The default implemenation generates a command based on the task name,
    but subclasses can override it to give themselves a custom command name.
    */
  public class func command() -> String {
    return NSStringFromClass(self).underscored()
  }
  
  /**
    This method runs the task.
  
    Subclasses should override this with their real task behavior.
    */
  public func run() {
  }

  /**
    This method gets the command name for the task.
    */
  public class var commandName: String { return command() }
  
  /**
    This method runs the task.
    */
  public class func runTask() {
    self.init().run()
  }
}