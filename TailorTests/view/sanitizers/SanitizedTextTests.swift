import XCTest
import Tailor
import TailorTesting

class SanitizedTextTests: TailorTestCase {
  func testCanInitializeWithStringLiteral() {
    let text : SanitizedText = "abc"
    assert(text.text, equals: "abc", message: "uses the string literal as the text")
    XCTAssertTrue(text.sanitizers.isEmpty, "has no sanitizers applied")
  }
}
