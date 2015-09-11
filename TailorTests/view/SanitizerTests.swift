import XCTest
import Tailor
import TailorTesting

class SanitizerTests: XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
  let testSanitizer = Sanitizer(["é": "e", "ø": "o", "æ": "ae"])
  
  func testIsSanitizedIsTrueWhenSanitizerIsApplied() {
    var text = SanitizedText(text: "", sanitizers: [])
    XCTAssertFalse(testSanitizer.isSanitized(text), "text is not sanitized with empty list")
    text = SanitizedText(text: "", sanitizers: [Sanitizer.htmlSanitizer])
    XCTAssertFalse(testSanitizer.isSanitized(text), "text is not sanitized with another sanitizer")
    text = SanitizedText(text: "", sanitizers: [Sanitizer.htmlSanitizer, testSanitizer])
    XCTAssertTrue(testSanitizer.isSanitized(text), "text is sanitized when its sanitizers includes the given one")
  }
  
  func testSanitizeStringMethodReplacesCharactersWithSubstitutions() {
    let result = testSanitizer.sanitizeString("æronautic léøn")
    assert(result, equals: "aeronautic leon", message: "replaces the input characters with their replacements")
  }
  
  func testSanitizeMethodReplacesCharacters() {
    let result = testSanitizer.sanitize(SanitizedText(text: "olé", sanitizers: []))
    assert(result.text, equals: "ole", message: "replaces characters in text")
  }
  
  func testSanitizeMethodFlagsTextAsSanitized() {
    let result = testSanitizer.sanitize(SanitizedText(text: "olé", sanitizers: []))
    XCTAssertTrue(testSanitizer.isSanitized(result), "flags text as sanitized")
  }
  
  func testSanitizeMethodDoesNotRunReplacementsTwice() {
    let testSanitizer = Sanitizer(["&": "&amp;"])
    let result1 = testSanitizer.sanitize(SanitizedText(text: "you & I", sanitizers: []))
    let result2 = testSanitizer.sanitize(result1)
    assert(result2.text, equals: "you &amp; I", message: "only runs 1 replacement")
  }
  
  func testAcceptMethodFlagsTextAsSanitizedWithoutModification() {
    let result = testSanitizer.accept("olé")
    assert(result.text, equals: "olé", message: "leaves text intact")
    assert(testSanitizer.isSanitized(result), message: "flags text as sanitized")
  }
  
  
  //MARK: - Built-in sanitizers
  
  func testHtmlSanitizerHasMappingForEscapeCharacters() {
    let string = Sanitizer.htmlSanitizer.sanitizeString("a < 5 & b > 7 & \"name\"=\"O'Brien\"")
    assert(string, equals: "a &lt; 5 &amp; b &gt; 7 &amp; &quot;name&quot;=&quot;O&#39;Brien&quot;", message: "escapes all special characters")
  }
  
  func testSqlSanitizerReplacesSqlEscapeCharacters() {
    let result = Sanitizer.sqlSanitizer.sanitizeString("BOBBY '; DROP TABLE \\ students\"")
    assert(result, equals: "BOBBY \\'; DROP TABLE \\\\ students\\\"", message: "sanitizes all escape characters")
  }
  
  //MARK: - Comparison
  
  func testSanitizersAreEqualWithSameMapping() {
    let sanitizer1 = Sanitizer(["<": "&lt;", ">": "gt;"])
    let sanitizer2 = Sanitizer(["<": "&lt;", ">": "gt;"])
    assert(sanitizer1, equals: sanitizer2)
  }
  
  func testSanitizersAreEqualWithDifferentMapping() {
    let sanitizer1 = Sanitizer(["<": "&lt;", ">": "gt;"])
    let sanitizer2 = Sanitizer(["<": "&lt;", ">": "gt;", "&": "&amp;"])
    assert(sanitizer1, doesNotEqual: sanitizer2)
  }
}
