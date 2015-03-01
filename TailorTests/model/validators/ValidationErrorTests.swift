import XCTest

class ValidationErrorTests: XCTestCase {
  let error = ValidationError(modelType: Hat.self, key: "height", message: "tooLow", data: ["value": "7"])
  let localization = PropertyListLocalization(locale: "en")
  var content: ConfigurationSetting!
  
  override func setUp() {
    TestApplication.start()
    content = TestApplication.sharedApplication().configuration.child("localization.content.en")
    content.addDictionary([
      "hat.errors.height.too_low": "is too short",
      "hat.errors.too_low": "is too low",
      "model.errors.height.too_low": "is way too short",
      "model.errors.too_low": "is way too low"
    ])
  }
  func testEqualityAcceptsErrorsWithSameInformation() {
    let error2 = ValidationError(modelType: Hat.self, key: "height", message: "tooLow", data: ["value": "7"])
    XCTAssertEqual(error, error2)
  }
  
  func testEqualityRejectsErrorsWithDifferentMessage() {
    let error2 = ValidationError(modelType: Hat.self, key: "height", message: "tooHigh", data: ["value": "7"])
    XCTAssertNotEqual(error, error2)
  }
  
  func testEqualityRejectsErrorsWithDifferentDataValues() {
    let error2 = ValidationError(modelType: Hat.self, key: "height", message: "tooLow", data: ["value": "8"])
    XCTAssertNotEqual(error, error2)
  }
  
  func testEqualityRejectsErrorsWithDifferentDataKeys() {
    let error2 = ValidationError(modelType: Hat.self, key: "height", message: "tooLow", data: ["value": "7", "otherValue": "8"])
    XCTAssertNotEqual(error, error2)
    XCTAssertNotEqual(error2, error)
  }
  
  func testEqualityRejectsErrorWithDifferentKeys() {
    let error2 = ValidationError(modelType: Hat.self, key: "width", message: "tooLow", data: ["value": "7"])
    XCTAssertNotEqual(error, error2)
  }
  
  func testEqualityAcceptsErrorsWithDifferentModels() {
    let error2 = ValidationError(modelType: Record.self, key: "height", message: "tooLow", data: ["value": "7"])
    XCTAssertEqual(error, error2)
  }
  
  func testLocalizeCanFindContentForModelAndKey() {
    XCTAssertEqual(error.localize(localization), "is too short")
  }
  
  func testLocalizeCanFindContentForModel() {
    content["hat.errors.height.too_low"] = nil
    XCTAssertEqual(error.localize(localization), "is too low")
  }
  
  func testLocalizeCanFindContentForKey() {
    content["hat.errors.height.too_low"] = nil
    content["hat.errors.too_low"] = nil
    XCTAssertEqual(error.localize(localization), "is way too short")
  }
  
  func testLocalizeCanFindTopLevelContent() {
    content["hat.errors.height.too_low"] = nil
    content["hat.errors.too_low"] = nil
    content["model.errors.height.too_low"] = nil
    XCTAssertEqual(error.localize(localization), "is way too low")
  }
  
  func testLocalizeCanFallBackToRawMessage() {
    content["hat.errors.height.too_low"] = nil
    content["hat.errors.too_low"] = nil
    content["model.errors.height.too_low"] = nil
    content["model.errors.too_low"] = nil
    XCTAssertEqual(error.localize(localization), "tooLow")
  }
  
  func testLocalizeCanUnderscoreKey() {
    content["hat.errors.brim_size.too_low"] = "test"
    let error = ValidationError(modelType: Hat.self, key: "brimSize", message: "tooLow", data: [:])
    XCTAssertEqual(error.localize(localization), "test")
  }
  
  func testLocalizeCanUnderscoreModelName() {
    @objc(TestHat) class TestHat: Hat {
      
    }
    content["test_hat.errors.height.too_low"] = "test"
    let error = ValidationError(modelType: TestHat.self, key: "height", message: "tooLow", data: [:])
    XCTAssertEqual(error.localize(localization), "test")
  }
  
  func testLocalizeCanInterpolateData() {
    content["hat.errors.height.too_low"] = "must be at least \\(height)"
    let error = ValidationError(modelType: Hat.self, key: "height", message: "tooLow", data: ["height": "10"])
    XCTAssertEqual(error.localize(localization), "must be at least 10")
  }
}
