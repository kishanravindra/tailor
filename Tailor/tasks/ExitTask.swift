import Foundation

/**
  This method provides a task for exiting immediately.
*/
public class ExitTask : Task {
  public override class func command() -> String { return "tailor.exit" }
}