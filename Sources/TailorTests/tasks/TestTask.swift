import XCTest
import Tailor
import TailorTesting

class CommandNameTestTask : TaskType {
  class func runTask() {}
}

struct TestTask: XCTestCase, TailorTestable {
  var allTests: [(String, () throws -> Void)] { return [
    ("testTaskGetsCommandFromClassNames", testTaskGetsCommandFromClassNames),
  ]}

  func setUp() {
    setUpTestCase()
  }
  
  func testTaskGetsCommandFromClassNames() {
    assert(CommandNameTestTask.commandName, equals: "command_name_test_task")
  }
}
