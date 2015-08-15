import XCTest
import Tailor
import TailorTesting

class PropertyListLocalizationTests: TailorTestCase {
  override func setUp() {
    super.setUp()
    Application.configuration.staticContent[ "en.localization_test"] = "Hello"
    Application.configuration.staticContent[ "es.localization_test"] = "Hola"
  }
  
  func testFetchInLocaleGetsValueFromConfiguration() {
    let localization = PropertyListLocalization(locale: "es")
    let string = localization.fetch("localization_test", inLocale: "en")
    XCTAssertNotNil(string, "gets a string")
    if string != nil { assert(string, equals: "Hello", message: "gets a string") }
  }
  
  func testFetchGetsNilValueForMissingKey() {
    let localization = PropertyListLocalization(locale: "es")
    let string = localization.fetch("invalid_key", inLocale: "en")
    XCTAssertNil(string)
  }
  
  func testAvailableLocalesGetsKeysFromStaticContent() {
    assert(PropertyListLocalization.availableLocales, equals: ["en", "es"])
  }
}
