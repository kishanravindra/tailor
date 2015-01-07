import XCTest

class TaskTests: XCTestCase {
  func testTaskGetsCommandFromClassNames() {
    @objc(CommandNameTestTask) class CommandNameTestTask : Task {}
    XCTAssertEqual(CommandNameTestTask.command(), "command_name_test_task")
  }
}
