import XCTest
import Tailor
import TailorTesting

class DatabaseLocalizationTests: TailorTestCase {
  var localization: Localization!
  override func setUp() {
    super.setUp()
    Application.start()
    DatabaseConnection.sharedConnection().executeQuery("TRUNCATE TABLE `tailor_translations`")
    localization = DatabaseLocalization(locale: "en")
    saveRecord(DatabaseLocalization.Translation(translationKey: "database.message", locale: "en", translatedText: "Hello"))
  }
  
  func testFetchInLocaleGetsValueFromTranslation() {
    saveRecord(DatabaseLocalization.Translation(translationKey: "database.message", locale: "es", translatedText: "Hola"))
    let value = localization.fetch("database.message", inLocale: "es")
    assert(value, equals: "Hola", message: "gets the value for that locale")
  }
  
  func testFetchInLocaleGetsNilForMissingValue() {
    let value = localization.fetch("database.message", inLocale: "es")
    XCTAssertNil(value, "does not get a value")
  }
}
