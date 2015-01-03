import XCTest

class SanitizerTests: XCTestCase {
  class ArbitrarySanitizer : Sanitizer {
    func setMapping(mapping: [Character:String]) {
      self.mapping = mapping
    }
    
    required init() {
      super.init()
    }
  }
  
  func testIsSanitizedIsTrueWhenSanitizerIsApplied() {
    var text = SanitizedText(text: "", sanitizers: [])
    XCTAssertFalse(ArbitrarySanitizer.isSanitized(text), "text is not sanitized with empty list")
    text = SanitizedText(text: "", sanitizers: [HtmlSanitizer.self])
    XCTAssertFalse(ArbitrarySanitizer.isSanitized(text), "text is not sanitized with another sanitizer")
    text = SanitizedText(text: "", sanitizers: [HtmlSanitizer.self, ArbitrarySanitizer.self])
    XCTAssertTrue(ArbitrarySanitizer.isSanitized(text), "text is sanitized when its sanitizers includes the given one")
  }
  
  func testSanitizeStringMethodReplacesCharactersWithSubstitutions() {
    let sanitizer = ArbitrarySanitizer()
    sanitizer.setMapping(["é": "e", "ø": "o", "æ": "ae"])
    let result = sanitizer.sanitizeString("æronautic léøn")
    XCTAssertEqual(result, "aeronautic leon", "replaces the input characters with their replacements")
  }
  
  func testSanitizeMethodReplacesCharacters() {
    let sanitizer = ArbitrarySanitizer()
    sanitizer.setMapping(["é": "e"])
    let result = sanitizer.sanitize(SanitizedText(text: "olé", sanitizers: []))
    XCTAssertEqual(result.text, "ole", "replaces characters in text")
  }
  
  func testSanitizeMethodFlagsTextAsSanitized() {
    let sanitizer = ArbitrarySanitizer()
    sanitizer.setMapping(["é": "e"])
    let result = sanitizer.sanitize(SanitizedText(text: "olé", sanitizers: []))
    XCTAssertTrue(ArbitrarySanitizer.isSanitized(result), "flags text as sanitized")
  }
}
