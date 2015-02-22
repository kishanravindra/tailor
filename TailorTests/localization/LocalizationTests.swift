import XCTest

class LocalizationTests: XCTestCase {
  class TestLocalization: Localization {
    override func fetch(key: String, inLocale locale: String) -> String? {
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
  }
  override func setUp() {
    TestApplication.start()
  }
  
  func testInitializationSetsLocale() {
    let localization = Localization(locale: "en")
    XCTAssertEqual(localization.locale, "en", "sets the locale")
  }
  
  func testFallbackLocalesWithGlobalEnglishIsEmpty() {
    let locales = Localization.fallbackLocales("en")
    XCTAssertTrue(locales.isEmpty)
  }
  
  func testFallbackLocalesWithLocalEnglishHasGlobalEnglish() {
    let locales = Localization.fallbackLocales("en-gb")
    XCTAssertEqual(locales, ["en"])
  }
  
  func testFallbackLocalesWithLocalSpanishHasSpanishAndEnglish() {
    let locales = Localization.fallbackLocales("es-mx")
    XCTAssertEqual(locales, ["es", "en"])
  }
  
  func testFallbackLocalesWIthMultiplePartsHasAllAncestors() {
    let locales = Localization.fallbackLocales("en-gb-123")
    XCTAssertEqual(locales, ["en-gb", "en"])
  }
  
  func testFetchWithSpecificTranslationUsesTranslation() {
    let localization = TestLocalization(locale: "en-gb")
    let result = localization.fetch("description")
    XCTAssertNotNil(result, "gets a result")
    if result != nil {
      XCTAssertEqual(result!, "British", "uses the specific translation")
    }
  }
  
  func testFetchWithMissingTranslationUsesFirstFallback() {
    let localization = TestLocalization(locale: "es-mx")
    let result = localization.fetch("description")
    XCTAssertNotNil(result, "gets a result")
    if result != nil {
      XCTAssertEqual(result!, "Spanish", "uses the first fallback")
    }
  }
  
  func testFetchWithMissingTranslationsContinuesTryingFallbacks() {
    let localization = TestLocalization(locale: "fr-fr")
    let result = localization.fetch("description")
    XCTAssertNotNil(result, "gets a result")
    if result != nil {
      XCTAssertEqual(result!, "English", "uses the second fallback")
    }
  }
  
  func testFetchInLocaleGetsNil() {
    let localization = Localization(locale: "en")
    let string = localization.fetch("localization_test", inLocale: "en")
    XCTAssertNil(string, "gets a nil result from fetchInLocale")
  }
}