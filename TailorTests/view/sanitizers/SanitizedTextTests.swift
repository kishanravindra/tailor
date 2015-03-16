import XCTest
import Tailor

class SanitizedTextTests: XCTestCase {
  func testCanInitializeWithStringLiteral() {
    let text : SanitizedText = "abc"
    XCTAssertEqual(text.text, "abc", "uses the string literal as the text")
    XCTAssertTrue(text.sanitizers.isEmpty, "has no sanitizers applied")
  }
}
