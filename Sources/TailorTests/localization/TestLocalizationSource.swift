import XCTest
import Tailor
import TailorTesting

struct TestLocalizationSource: XCTestCase, TailorTestable {
  var allTests: [(String, () throws -> Void)] { return [
    ("testFallbackLocalesWithGlobalEnglishIsEmpty", testFallbackLocalesWithGlobalEnglishIsEmpty),
    ("testFallbackLocalesWithLocalEnglishHasGlobalEnglish", testFallbackLocalesWithLocalEnglishHasGlobalEnglish),
    ("testFallbackLocalesWithLocalSpanishHasSpanishAndEnglish", testFallbackLocalesWithLocalSpanishHasSpanishAndEnglish),
    ("testFallbackLocalesWithGlobalSpanishHasEnglish", testFallbackLocalesWithGlobalSpanishHasEnglish),
    ("testFallbackLocalesWithMultiplePartsHasAllAncestors", testFallbackLocalesWithMultiplePartsHasAllAncestors),
    ("testFetchWithSpecificTranslationUsesTranslation", testFetchWithSpecificTranslationUsesTranslation),
    ("testFetchWithMissingTranslationUsesFirstFallback", testFetchWithMissingTranslationUsesFirstFallback),
    ("testFetchWithMissingTranslationsContinuesTryingFallbacks", testFetchWithMissingTranslationsContinuesTryingFallbacks),
    ("testFetchWithInterpolationPutsValueInTranslation", testFetchWithInterpolationPutsValueInTranslation),
  ]}
  
  final class TestLocalization: LocalizationSource {
    let locale: String
    
    init(locale: String) {
      self.locale = locale
    }
    func fetch(key: String, inLocale locale: String) -> String? {
      if key == "description" {
        switch(locale) {
        case "en-gb":
          return "British"
        case "en":
          return "English"
        case "es":
          return "Spanish"
        default:
          return nil
        }
      }
      else if key == "interpolation_test" {
        return "My name is \\(name)"
      }
      else {
        return nil
      }
    }
    
    static var availableLocales: [String] { return [] }
  }
  
  func setUp() {
    setUpTestCase()
  }
  
  func testFallbackLocalesWithGlobalEnglishIsEmpty() {
    let locales = TestLocalization(locale: "en").fallbackLocales()
    XCTAssertTrue(locales.isEmpty)
  }
  
  func testFallbackLocalesWithLocalEnglishHasGlobalEnglish() {
    let locales = TestLocalization(locale: "en-gb").fallbackLocales()
    assert(locales, equals: ["en"])
  }
  
  func testFallbackLocalesWithLocalSpanishHasSpanishAndEnglish() {
    let locales = TestLocalization(locale: "es-mx").fallbackLocales()
    assert(locales, equals: ["es", "en"])
  }
  
  func testFallbackLocalesWithGlobalSpanishHasEnglish() {
    let locales = TestLocalization(locale: "es").fallbackLocales()
    assert(locales, equals: ["en"])
  }
  
  func testFallbackLocalesWithMultiplePartsHasAllAncestors() {
    let locales = TestLocalization(locale: "en-gb-123").fallbackLocales()
    assert(locales, equals: ["en-gb", "en"])
  }
  
  func testFetchWithSpecificTranslationUsesTranslation() {
    let localization = TestLocalization(locale: "en-gb")
    let result = localization.fetch("description")
    XCTAssertNotNil(result, "gets a result")
    if result != nil {
      assert(result!, equals: "British", message: "uses the specific translation")
    }
  }
  
  func testFetchWithMissingTranslationUsesFirstFallback() {
    let localization = TestLocalization(locale: "es-mx")
    let result = localization.fetch("description")
    XCTAssertNotNil(result, "gets a result")
    if result != nil {
      assert(result!, equals: "Spanish", message: "uses the first fallback")
    }
  }
  
  func testFetchWithMissingTranslationsContinuesTryingFallbacks() {
    let localization = TestLocalization(locale: "fr-fr")
    let result = localization.fetch("description")
    XCTAssertNotNil(result, "gets a result")
    if result != nil {
      assert(result!, equals: "English", message: "uses the second fallback")
    }
  }
  
  func testFetchWithInterpolationPutsValueInTranslation() {
    let localization = TestLocalization(locale: "en")
    let result = localization.fetch("interpolation_test", interpolations: ["name": "John"])
    XCTAssertNotNil(result, "gets a result")
    if result != nil {
      assert(result!, equals: "My name is John", message: "puts the interpolated value in the content")
    }
  }
}