import XCTest
import Tailor
import TailorTesting

class DatabaseLocalizationTests: TailorTestCase {
  var localization: LocalizationSource!
  override func setUp() {
    super.setUp()
    Application.sharedDatabaseConnection().executeQuery("DELETE FROM `tailor_translations`")
    localization = DatabaseLocalization(locale: "en")
    DatabaseLocalization.Translation(translationKey: "database.message", locale: "en", translatedText: "Hello").save()
  }
  
  func testTranslationInitializationWithAllFieldsSetsFields() {
    let translation = DatabaseLocalization.Translation(databaseRow: ["translation_key": "database.message".databaseValue
      , "locale": "en".databaseValue, "translated_text": "Hello".databaseValue, "id": 1.databaseValue])
    assert(translation?.id, equals: 1)
    assert(translation?.translationKey, equals: "database.message")
    assert(translation?.locale, equals: "en")
    assert(translation?.translatedText, equals: "Hello")
  }
  
  func testTranslationInitializationWithNoIdIsNil() {
    let translation = DatabaseLocalization.Translation(databaseRow: ["translation_key": "database.message".databaseValue
      , "locale": "en".databaseValue, "translated_text": "Hello".databaseValue])
    assert(isNil: translation)
  }
  
  func testTranslationInitializationWithNoKeyIsNil() {
    let translation = DatabaseLocalization.Translation(databaseRow: ["locale": "en".databaseValue, "translated_text": "Hello".databaseValue, "id": 1.databaseValue])
    assert(isNil: translation)
  }
  
  func testTranslationInitializationWithNoLocaleIsNil() {
    let translation = DatabaseLocalization.Translation(databaseRow: ["translation_key": "database.message".databaseValue
      , "translated_text": "Hello".databaseValue, "id": 1.databaseValue])
    assert(isNil: translation)
  }
  
  func testTranslationInitializationWithNoTranslatedTextIsNil() {
    let translation = DatabaseLocalization.Translation(databaseRow: ["translation_key": "database.message".databaseValue
      , "locale": "en".databaseValue, "id": 1.databaseValue])
    assert(isNil: translation)
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
