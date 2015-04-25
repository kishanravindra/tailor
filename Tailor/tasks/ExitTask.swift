import Foundation

/**
  This method provides a task for exiting immediately.
*/
public class ExitTask : Task {
  /** The command for the task. */
  public override class func command() -> String { return "tailor.exit" }
}