import XCTest
import Tailor
import TailorTesting

class TaskTests: TailorTestCase {
  func testTaskGetsCommandFromClassNames() {
    @objc(CommandNameTestTask) class CommandNameTestTask : Task {}
    assert(CommandNameTestTask.command(), equals: "command_name_test_task")
  }
}
