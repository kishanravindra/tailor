import XCTest
import Tailor

class PropertyListLocalizationTests: XCTestCase {
  override func setUp() {
    TestApplication.start()
    let key = "localization.content.en.localization_test"
    TestApplication.sharedApplication().configuration[key] = "Hello"
  }
  
  func testFetchInLocaleGetsValueFromConfiguration() {
    let localization = PropertyListLocalization(locale: "es")
    let string = localization.fetch("localization_test", inLocale: "en")
    XCTAssertNotNil(string, "gets a string")
    if string != nil { XCTAssertEqual(string!, "Hello", "gets a string") }
  }
  
  func testFetchGetsNilValueForMissingKey() {
    let localization = PropertyListLocalization(locale: "es")
    let string = localization.fetch("invalid_key", inLocale: "en")
    XCTAssertNil(string)
  }
}
