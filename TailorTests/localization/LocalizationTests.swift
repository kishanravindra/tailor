import XCTest

class LocalizationTests: XCTestCase {
  override func setUp() {
    TestApplication.start()
  }
  
  func testInitializationSetsLocale() {
    let localization = Localization(locale: "en")
    XCTAssertEqual(localization.locale, "en", "sets the locale")
  }
  
  func testFetchGetsNil() {
    let localization = Localization(locale: "en")
    let string = localization.fetch("localization_test")
    XCTAssertNil(string, "gets a nil result from fetch")
  }
}