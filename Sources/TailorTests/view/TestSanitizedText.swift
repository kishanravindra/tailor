import XCTest
import Tailor
import TailorTesting

struct TestSanitizedText: XCTestCase, TailorTestable {
  var allTests: [(String, () throws -> Void)] { return [
    ("testCanInitializeWithStringLiteral", testCanInitializeWithStringLiteral),
    ("testCanInitializeWithGraphemeClusterLiteral", testCanInitializeWithGraphemeClusterLiteral),
    ("testCanInitializeWithUnicodeScalarLiteral", testCanInitializeWithUnicodeScalarLiteral),
    ("testSanitizedTextWithSameInformationAreEqual", testSanitizedTextWithSameInformationAreEqual),
    ("testSanitizedTextWithDifferentTextAreNotEqual", testSanitizedTextWithDifferentTextAreNotEqual),
    ("testSanitizedTextWithDifferentMappingsAreNotEqual", testSanitizedTextWithDifferentMappingsAreNotEqual),
  ]}

  func setUp() {
    setUpTestCase()
  }
  
  func testCanInitializeWithStringLiteral() {
    let text : SanitizedText = "abc"
    assert(text.text, equals: "abc", message: "uses the string literal as the text")
    assert(text.sanitizers.isEmpty)
  }
  
  func testCanInitializeWithGraphemeClusterLiteral() {
    let text = SanitizedText(extendedGraphemeClusterLiteral: "abc")
    assert(text.text, equals: "abc", message: "uses the string literal as the text")
    assert(text.sanitizers.isEmpty)
  }
  
  func testCanInitializeWithUnicodeScalarLiteral() {
    let text = SanitizedText(unicodeScalarLiteral: "abc")
    assert(text.text, equals: "abc", message: "uses the string literal as the text")
    assert(text.sanitizers.isEmpty)
  }
  
  func testSanitizedTextWithSameInformationAreEqual() {
    let text1 = SanitizedText(text: "&lt;b&gt;", sanitizers: [Sanitizer.htmlSanitizer])
    let text2 = SanitizedText(text: "&lt;b&gt;", sanitizers: [Sanitizer.htmlSanitizer])
    assert(text1, equals: text2)
  }
  
  func testSanitizedTextWithDifferentTextAreNotEqual() {
    let text1 = SanitizedText(text: "&lt;b&gt;", sanitizers: [Sanitizer.htmlSanitizer])
    let text2 = SanitizedText(text: "&lt;i&gt;", sanitizers: [Sanitizer.htmlSanitizer])
    assert(text1, doesNotEqual: text2)
  }
  
  func testSanitizedTextWithDifferentMappingsAreNotEqual() {
    let text1 = SanitizedText(text: "&lt;b&gt;", sanitizers: [Sanitizer.htmlSanitizer])
    let text2 = SanitizedText(text: "&lt;b&gt;", sanitizers: [Sanitizer.htmlSanitizer, Sanitizer.sqlSanitizer])
    assert(text1, doesNotEqual: text2)
  }
}
