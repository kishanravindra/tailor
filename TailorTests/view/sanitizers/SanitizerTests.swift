import XCTest
import Tailor

class SanitizerTests: XCTestCase {
  class TestSanitizer : Sanitizer {
    
    override class func mapping() -> [Character:String] {
      return ["é": "e", "ø": "o", "æ": "ae"]
    }
    
    func setMapping(mapping: [Character:String]) {
    }
    
    required init() {
      super.init()
    }
  }
  
  func testIsSanitizedIsTrueWhenSanitizerIsApplied() {
    var text = SanitizedText(text: "", sanitizers: [])
    XCTAssertFalse(TestSanitizer.isSanitized(text), "text is not sanitized with empty list")
    text = SanitizedText(text: "", sanitizers: [HtmlSanitizer.self])
    XCTAssertFalse(TestSanitizer.isSanitized(text), "text is not sanitized with another sanitizer")
    text = SanitizedText(text: "", sanitizers: [HtmlSanitizer.self, TestSanitizer.self])
    XCTAssertTrue(TestSanitizer.isSanitized(text), "text is sanitized when its sanitizers includes the given one")
  }
  
  func testSanitizeStringMethodReplacesCharactersWithSubstitutions() {
    let sanitizer = TestSanitizer()
    let result = sanitizer.sanitizeString("æronautic léøn")
    XCTAssertEqual(result, "aeronautic leon", "replaces the input characters with their replacements")
  }
  
  func testSanitizeMethodReplacesCharacters() {
    let sanitizer = TestSanitizer()
    sanitizer.setMapping(["é": "e"])
    let result = sanitizer.sanitize(SanitizedText(text: "olé", sanitizers: []))
    XCTAssertEqual(result.text, "ole", "replaces characters in text")
  }
  
  func testSanitizeMethodFlagsTextAsSanitized() {
    let sanitizer = TestSanitizer()
    sanitizer.setMapping(["é": "e"])
    let result = sanitizer.sanitize(SanitizedText(text: "olé", sanitizers: []))
    XCTAssertTrue(TestSanitizer.isSanitized(result), "flags text as sanitized")
  }
}
