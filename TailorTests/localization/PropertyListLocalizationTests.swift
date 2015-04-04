import XCTest
import Tailor
import TailorTesting

class PropertyListLocalizationTests: TailorTestCase {
  override func setUp() {
    Application.start()
    let key = "localization.content.en.localization_test"
    TestApplication.sharedApplication().configuration[key] = "Hello"
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
}
