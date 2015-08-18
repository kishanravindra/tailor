import Foundation

/**
  This method provides a task for exiting immediately.
*/
public final class ExitTask : TaskType {
  /** The command for the task. */
  public static let commandName = "tailor.exit"
  
  /**
    This method runs the task.

    It does nothing.
    */
  public static func runTask() {
    
  }
}