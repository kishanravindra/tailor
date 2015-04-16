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
    DatabaseLocalization.Translation(translationKey: "database.message", locale: "en", translatedText: "Hello").save()
  }
  
  func testTranslationAcceptsRecordWithAllFields() {
    let translation = DatabaseLocalization.Translation(translationKey: "testMessage", locale: "en", translatedText: "Hello")
    XCTAssertTrue(translation.validate())
  }
  
  func testTranslationRejectsRecordWithNoKey() {
    let translation = DatabaseLocalization.Translation(translationKey: "", locale: "en", translatedText: "Hello")
    XCTAssertFalse(translation.validate())
  }
  
  func testTranslationRejectsRecordWithNoLocale() {
    let translation = DatabaseLocalization.Translation(translationKey: "testMessage", locale: "", translatedText: "Hello")
    XCTAssertFalse(translation.validate())
  }
  
  func testFetchInLocaleGetsValueFromTranslation() {
    DatabaseLocalization.Translation(translationKey: "database.message", locale: "es", translatedText: "Hola").save()
    let value = localization.fetch("database.message", inLocale: "es")
    assert(value, equals: "Hola", message: "gets the value for that locale")
  }
  
  func testFetchInLocaleGetsNilForMissingValue() {
    let value = localization.fetch("database.message", inLocale: "es")
    XCTAssertNil(value, "does not get a value")
  }
}
