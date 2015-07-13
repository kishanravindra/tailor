import XCTest
import Tailor
import TailorTesting

@available(*, deprecated) class LocalizationTests: TailorTestCase {
  class TestLocalization: Localization {
    override func fetch(key: String, inLocale locale: String) -> String? {
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
  }
  
  func testInitializationSetsLocale() {
    let localization = Localization(locale: "en")
    assert(localization.locale, equals: "en", message: "sets the locale")
  }
  
  func testFallbackLocalesWithGlobalEnglishIsEmpty() {
    let locales = Localization.fallbackLocales("en")
    XCTAssertTrue(locales.isEmpty)
  }
  
  func testFallbackLocalesWithLocalEnglishHasGlobalEnglish() {
    let locales = Localization.fallbackLocales("en-gb")
    assert(locales, equals: ["en"])
  }
  
  func testFallbackLocalesWithLocalSpanishHasSpanishAndEnglish() {
    let locales = Localization.fallbackLocales("es-mx")
    assert(locales, equals: ["es", "en"])
  }
  
  func testFallbackLocalesWIthMultiplePartsHasAllAncestors() {
    let locales = Localization.fallbackLocales("en-gb-123")
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
  
  func testFetchInLocaleGetsNil() {
    let localization = Localization(locale: "en")
    let string = localization.fetch("localization_test", inLocale: "en")
    XCTAssertNil(string, "gets a nil result from fetchInLocale")
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