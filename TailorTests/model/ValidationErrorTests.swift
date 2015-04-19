import XCTest
import Tailor
import TailorTesting

class ValidationErrorTests: TailorTestCase {
  let error = ValidationError(modelName: "hat", key: "height", message: "tooLow", data: ["value": "7"])
  let localization = PropertyListLocalization(locale: "en")
  var content: ConfigurationSetting!
  
  override func setUp() {
    Application.start()
    content = TestApplication.sharedApplication().configuration.child("localization.content.en")
    content.addDictionary([
      "hat.errors.height.too_low": "is too short",
      "hat.errors.too_low": "is too low",
      "model.errors.height.too_low": "is way too short",
      "model.errors.too_low": "is way too low"
    ])
  }
  func testEqualityAcceptsErrorsWithSameInformation() {
    let error2 = ValidationError(modelName: "hat", key: "height", message: "tooLow", data: ["value": "7"])
    assert(error, equals: error2)
  }
  
  func testEqualityRejectsErrorsWithDifferentMessage() {
    let error2 = ValidationError(modelName: "hat", key: "height", message: "tooHigh", data: ["value": "7"])
    XCTAssertNotEqual(error, error2)
  }
  
  func testEqualityRejectsErrorsWithDifferentDataValues() {
    let error2 = ValidationError(modelName: "hat", key: "height", message: "tooLow", data: ["value": "8"])
    XCTAssertNotEqual(error, error2)
  }
  
  func testEqualityRejectsErrorsWithDifferentDataKeys() {
    let error2 = ValidationError(modelName: "hat", key: "height", message: "tooLow", data: ["value": "7", "otherValue": "8"])
    XCTAssertNotEqual(error, error2)
    XCTAssertNotEqual(error2, error)
  }
  
  func testEqualityRejectsErrorWithDifferentKeys() {
    let error2 = ValidationError(modelName: "hat", key: "width", message: "tooLow", data: ["value": "7"])
    XCTAssertNotEqual(error, error2)
  }
  
  func testEqualityAcceptsErrorsWithDifferentModels() {
    let error2 = ValidationError(modelName: "shelf", key: "height", message: "tooLow", data: ["value": "7"])
    assert(error, equals: error2)
  }
  
  func testLocalizeCanFindContentForModelAndKey() {
    assert(error.localize(localization), equals: "is too short")
  }
  
  func testLocalizeCanFindContentForModel() {
    content["hat.errors.height.too_low"] = nil
    assert(error.localize(localization), equals: "is too low")
  }
  
  func testLocalizeCanFindContentForKey() {
    content["hat.errors.height.too_low"] = nil
    content["hat.errors.too_low"] = nil
    assert(error.localize(localization), equals: "is way too short")
  }
  
  func testLocalizeCanFindTopLevelContent() {
    content["hat.errors.height.too_low"] = nil
    content["hat.errors.too_low"] = nil
    content["model.errors.height.too_low"] = nil
    assert(error.localize(localization), equals: "is way too low")
  }
  
  func testLocalizeCanFallBackToRawMessage() {
    content["hat.errors.height.too_low"] = nil
    content["hat.errors.too_low"] = nil
    content["model.errors.height.too_low"] = nil
    content["model.errors.too_low"] = nil
    assert(error.localize(localization), equals: "tooLow")
  }
  
  func testLocalizeCanUnderscoreKey() {
    content["hat.errors.brim_size.too_low"] = "test"
    let error = ValidationError(modelName: "hat", key: "brimSize", message: "tooLow", data: [:])
    assert(error.localize(localization), equals: "test")
  }
  
  func testLocalizeCanInterpolateData() {
    content["hat.errors.height.too_low"] = "must be at least \\(height)"
    let error = ValidationError(modelName: "hat", key: "height", message: "tooLow", data: ["height": "10"])
    assert(error.localize(localization), equals: "must be at least 10")
  }
}
