import XCTest
import Tailor
import TailorTesting

class ValidationErrorTests: XCTestCase, TailorTestable {
  let error = ValidationError(modelName: "hat", key: "height", message: "tooLow", data: ["value": "7"])
  let localization = PropertyListLocalization(locale: "en")
  
  override func setUp() {
    super.setUp()
    setUpTestCase()
    Application.configuration.staticContent = merge(Application.configuration.staticContent, [
      "en.hat.errors.height.too_low": "is too short",
      "en.hat.errors.too_low": "is too low",
      "en.model.errors.height.too_low": "is way too short",
      "en.model.errors.too_low": "is way too low"
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
    Application.configuration.staticContent["en.hat.errors.height.too_low"] = nil
    assert(error.localize(localization), equals: "is too low")
  }
  
  func testLocalizeCanFindContentForKey() {
    Application.configuration.staticContent["en.hat.errors.height.too_low"] = nil
    Application.configuration.staticContent["en.hat.errors.too_low"] = nil
    assert(error.localize(localization), equals: "is way too short")
  }
  
  func testLocalizeCanFindTopLevelContent() {
    Application.configuration.staticContent["en.hat.errors.height.too_low"] = nil
    Application.configuration.staticContent["en.hat.errors.too_low"] = nil
    Application.configuration.staticContent["en.model.errors.height.too_low"] = nil
    assert(error.localize(localization), equals: "is way too low")
  }
  
  func testLocalizeCanFallBackToRawMessage() {
    Application.configuration.staticContent["en.hat.errors.height.too_low"] = nil
    Application.configuration.staticContent["en.hat.errors.too_low"] = nil
    Application.configuration.staticContent["en.model.errors.height.too_low"] = nil
    Application.configuration.staticContent["en.model.errors.too_low"] = nil
    assert(error.localize(localization), equals: "tooLow")
  }
  
  func testLocalizeCanUnderscoreKey() {
    Application.configuration.staticContent["en.hat.errors.brim_size.too_low"] = "test"
    let error = ValidationError(modelName: "hat", key: "brimSize", message: "tooLow", data: [:])
    assert(error.localize(localization), equals: "test")
  }
  
  func testLocalizeCanInterpolateData() {
    Application.configuration.staticContent["en.hat.errors.height.too_low"] = "must be at least \\(height)"
    let error = ValidationError(modelName: "hat", key: "height", message: "tooLow", data: ["height": "10"])
    assert(error.localize(localization), equals: "must be at least 10")
  }
}
