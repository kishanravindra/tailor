import XCTest

class DatabaseLocalizationTests: XCTestCase {
  var localization: Localization!
  override func setUp() {
    super.setUp()
    TestApplication.start()
    DatabaseConnection.sharedConnection().executeQuery("TRUNCATE TABLE `tailor_translations`")
    localization = DatabaseLocalization(locale: "es")
    DatabaseLocalization.Translation.create(["translationKey": "database.message", "locale": "en", "translatedText": "Hello"])
  }
  
  func testTranslationAcceptsRecordWithAllFields() {
    let translation = DatabaseLocalization.Translation(data: ["translationKey": "testMessage", "locale": "en", "translatedText": "Hello"])
    XCTAssertTrue(translation.validate())
  }
  
  func testTranslationRejectsRecordWithNoKey() {
    let translation = DatabaseLocalization.Translation(data: ["translationKey": "", "locale": "en", "translatedText": "Hello"])
    XCTAssertFalse(translation.validate())
  }
  
  func testTranslationRejectsRecordWithNoLocale() {
    let translation = DatabaseLocalization.Translation(data: ["translationKey": "testMessage", "locale": "", "translatedText": "Hello"])
    XCTAssertFalse(translation.validate())
  }
  
  func testFetchGetsValueFromTranslation() {
    DatabaseLocalization.Translation.create(["translationKey": "database.message", "locale": "es", "translatedText": "Hola"])
    let value = localization.fetch("database.message")
    XCTAssertNotNil(value, "gets a value")
    if value != nil {
      XCTAssertEqual(value!, "Hola", "gets the value for that locale")
    }
  }
  
  func testFetchGetsNilForMissingValue() {
    let localization = DatabaseLocalization(locale: "es")
    let value = localization.fetch("database.message")
    XCTAssertNil(value, "does not get a value")
  }
}
