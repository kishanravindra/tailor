import XCTest
import Tailor
import TailorTesting

class DatabaseLocalizationTests: XCTestCase, TailorTestable {
  var localization: LocalizationSource!
  override func setUp() {
    super.setUp()
    setUpTestCase()
    Application.sharedDatabaseConnection().executeQuery("DELETE FROM `tailor_translations`")
    localization = DatabaseLocalization(locale: "en")
    DatabaseLocalization.Translation(translationKey: "database.message", locale: "en", translatedText: "Hello").save()
    DatabaseLocalization.Translation(translationKey: "database.message", locale: "fr", translatedText: "Bonjour").save()
  }
  
  func testTranslationInitializationWithAllFieldsSetsFields() {
    let translation = try! DatabaseLocalization.Translation(deserialize: SerializableValue.Dictionary(["translation_key": "database.message".serialize
      , "locale": "en".serialize, "translated_text": "Hello".serialize, "id": 1.serialize]))
    assert(translation.id, equals: 1)
    assert(translation.translationKey, equals: "database.message")
    assert(translation.locale, equals: "en")
    assert(translation.translatedText, equals: "Hello")
  }
  
  func testTranslationInitializationWithNoKeyIsNil() {
    do {
      _ = try DatabaseLocalization.Translation(deserialize: SerializableValue.Dictionary([
        "locale": "en".serialize,
        "translated_text": "Hello".serialize,
        "id": 1.serialize
      ]))
      assert(false, message: "should throw an exception")
    }
    catch let SerializationParsingError.MissingField(name) {
      assert(name, equals: "translation_key")
    }
    catch {
      assert(false, message: "threw unexpected exception)")
    }
  }
  
  func testTranslationInitializationWithNoLocaleIsNil() {
    do {
      _ = try DatabaseLocalization.Translation(deserialize: SerializableValue.Dictionary([
        "translation_key": "database.message".serialize,
        "translated_text": "Hello".serialize,
        "id": 1.serialize
        ]))
      assert(false, message: "should throw an exception")
    }
    catch let SerializationParsingError.MissingField(name) {
      assert(name, equals: "locale")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testTranslationInitializationWithNoTranslatedTextIsNil() {
    do {
      _ = try DatabaseLocalization.Translation(deserialize: SerializableValue.Dictionary([
        "translation_key": "database.message".serialize,
        "locale": "en".serialize,
        "id": 1.serialize
        ]))
      assert(false, message: "should throw an exception")
    }
    catch let SerializationParsingError.MissingField(name) {
      assert(name, equals: "translated_text")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
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
  
  func testAvailableLocalesGetsKeysFromDatabase() {
    assert(DatabaseLocalization.availableLocales, equals: ["en", "fr"])
  }
}
