
/**
  This protocol describes a task that can be run when the application starts.
  */
public protocol TaskType: class {
  /**
    The name of the command.
  
    The default is the class name, converted to snake case.
    */
  static var commandName: String { get }
  
  /**
    This method performs the work for the task.
    */
  static func runTask()
}

extension TaskType {
  public static var commandName: String {
    return String(reflecting: self).underscored().componentsSeparatedByString(".").last ?? ""
  }
}