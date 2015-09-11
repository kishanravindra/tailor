import XCTest
import Tailor
import TailorTesting

class CommandNameTestTask : TaskType {
  class func runTask() {}
}

class TaskTests: XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
  func testTaskGetsCommandFromClassNames() {
    assert(CommandNameTestTask.commandName, equals: "command_name_test_task")
  }
}
