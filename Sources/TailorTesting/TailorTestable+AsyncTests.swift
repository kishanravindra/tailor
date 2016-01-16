#if os(Linux)
import Foundation
import Glibc

public final class XCTestExpectation {
  public var description: String
  public var file: StaticString
  public var line: UInt
  public private(set) var fulfilled: Bool

  public init(description: String, file: StaticString, line: UInt) {
    self.description = description
    self.fulfilled = false
    self.file = file
    self.line = line
  }

  public func fulfill() {
    self.fulfilled = true
  }
}

extension TailorTestable {
  public func expectationWithDescription(description: String, file: StaticString = __FILE__, line: UInt = __LINE__) -> XCTestExpectation {
    let expectation = XCTestExpectation(description: description, file: file, line: line)
    XC_TEST_CURRENT_EXPECTATIONS.append(expectation)
    return expectation
  }

  var hasUnfulfilledExpectations: Bool {
    return !XC_TEST_CURRENT_EXPECTATIONS.filter { !$0.fulfilled }.isEmpty
  }

  public func waitForExpectationsWithTimeout(timeout: Int, handler: Optional<(NSError)->Void>) {
    let startTime = time(nil)
    while hasUnfulfilledExpectations {
      if time(nil) - startTime > timeout {
        break
      }
      usleep(100000)
    }
    if hasUnfulfilledExpectations {
      let expectations = XC_TEST_CURRENT_EXPECTATIONS.filter { !$0.fulfilled }
      let description = expectations.map { $0.description }.joinWithSeparator(", ")
      let message = "Expectations not met: " + description
      self.testFailure(message, expected: true, file: expectations[0].file, line: expectations[0].line)
    }
    XC_TEST_CURRENT_EXPECTATIONS = []
  }
}

private var XC_TEST_CURRENT_EXPECTATIONS = [XCTestExpectation]()
#endif