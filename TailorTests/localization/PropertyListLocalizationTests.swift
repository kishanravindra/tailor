import XCTest

class PropertyListLocalizationTests: XCTestCase {
  override func setUp() {
    TestApplication.start()
    let key = "localization.content.en.localization_test"
    TestApplication.sharedApplication().configuration[key] = "Hello"
  }
  
  func testFetchGetsValueFromConfiguration() {
    let localization = PropertyListLocalization(locale: "en")
    let string = localization.fetch("localization_test")
    XCTAssertNotNil(string, "gets a string")
    if string != nil { XCTAssertEqual(string!, "Hello", "gets a string") }
  }
  
  func testFetchGetsNilValueForMissingKey() {
    let localization = PropertyListLocalization(locale: "en")
    let string = localization.fetch("invalid_key")
    XCTAssertNil(string)
  }
}
