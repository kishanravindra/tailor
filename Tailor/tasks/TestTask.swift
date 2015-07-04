import Cocoa
import Tailor

public class TestTask: TaskType {
  public static var commandName: String { return "run_tests" }
  public static func runTask() {
    NSApplication.sharedApplication().run()
  }
}

