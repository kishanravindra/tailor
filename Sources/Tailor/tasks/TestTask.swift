#if os(OSX)
import Cocoa
#endif

/**
  This task is used by the unit tests.

  It just causes the run loop to stall so that the tests can run in their
  thread.
  */
@available(*, deprecated, message="This is not necessary on the Swift runtime")
public final class TestTask: TaskType {
  /** The name of the command for the task. */
  public static var commandName: String { return "run_tests" }
  
  /**
    This method runs the task.
    */
  public static func runTask() {
    #if os(OSX)
      NSApplication.sharedApplication().run()
    #endif
  }
}

