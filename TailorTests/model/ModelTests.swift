import XCTest

class ModelTests: XCTestCase {
  @objc(HatForModel) class Hat : TailorTests.Hat {
    var keysToFail = [String]()
    override class func validators() -> [Validator] {
      return [
        TestValidator(key: "brimSize"),
        TestValidator(key: "color")
      ]
    }
  }
  class TestValidator : Validator {
    override func validate(model: Model) {
      let hat = model as! Hat
      if(contains(hat.keysToFail, key)) {
        hat.errors.add(key, "failed validation")
      }
    }
  }
  
  override func setUp() {
    TestApplication.start()
  }
  
  //MARK: - Structure
  
  func testModelNameIsTakenFromClassName() {
    XCTAssertEqual(TailorTests.Hat.modelName(), "hat", "gets lowercased class name for model")
    XCTAssertEqual(Hat.modelName(), "hat_for_model", "gets lowercased class name with underscores for for HatForModel")
  }
  
  //MARK: - Validations
  
  func testValidateLeavesErrorsEmptyWhenValidationsPass() {
    let hat = Hat()
    hat.validate()
    XCTAssertTrue(hat.errors.isEmpty(), "hat has no errors")
  }
  
  func testValidateReturnsTrueWhenValidationsPass() {
    let hat = Hat()
    let result = hat.validate()
    XCTAssertTrue(result, "method returns true")
  }
  
  func testValidatePutsErrorMessageInErrorListWhenValidationFails() {
    let hat = Hat()
    hat.keysToFail.append("brimSize")
    hat.validate()
    if let errors = hat.errors.errors["brimSize"] {
      XCTAssertEqual(errors.count, 1, "has one error")
      if errors.count > 0 {
        XCTAssertEqual(errors[0], "failed validation", "has the error provided by the validator")
      }
    }
    else {
      XCTFail("has an error for brim sizes")
    }
  }
  
  func testValidateReturnsFalseWhenValidationFails() {
    let hat = Hat()
    hat.keysToFail.append("brimSize")
    let result = hat.validate()
    XCTAssertFalse(result, "returns false")
  }
  
  func testValidateCanCollectMultipleErrors() {
    let hat = Hat()
    hat.keysToFail.append("brimSize")
    hat.keysToFail.append("color")
    hat.validate()
    
    if let errors = hat.errors.errors["brimSize"] {
      XCTAssertEqual(errors.count, 1, "has one error for brim size")
    }
    else {
      XCTFail("has an error for brim size")
    }
    
    if let errors = hat.errors.errors["color"] {
      XCTAssertEqual(errors.count, 1, "has one error for color")
    }
    else {
      XCTFail("has an error for color")
    }
  }
  
  //MARK: - Dynamic Properties

  func testHumanAttributeNameSeparatesWords() {
    let name = Hat.humanAttributeName("brimSize")
    XCTAssertEqual(name, "brim size", "gets words from attribute name")
  }
  
  func testHumanAttributeNameCanCapitalizeName() {
    let name = Hat.humanAttributeName("brimSize", capitalize: true)
    XCTAssertEqual(name, "Brim Size", "gets capitalized words from attribute name")
  }
  
  func testHumanAttributeNameCanGetNameFromLocalization() {
    class TestLocalization : Localization {
      override func fetch(key: String) -> String? {
        return key + " translated"
      }
    }
    
    let name = Hat.humanAttributeName("brimSize", localization: TestLocalization(locale: "en"))
    XCTAssertEqual(name, "record.hat_for_model.attributes.brim_size translated", "gets string from localization")
  }
  
  func testValueForKeyGetsValueFromInstanceVariable() {
    let hat = Hat()
    hat.color = "black"
    let result = hat.valueForKey("color") as! String
    XCTAssertEqual(result, "black", "gets the value stored on the object")
  }
  
  func testValueForKeyReturnsNilForInvalidName() {
    let hat = Hat()
    XCTAssertNil(hat.valueForKey("brandName"), "returns nil")
  }
  
  func testSetValueCanSetStringValue() {
    let hat = Hat()
    hat.setValue("red", forKey: "color")
    XCTAssertEqual(hat.color, "red", "sets the value on the object")
  }
  
  func testSetValueCanSetIntValue() {
    let hat = Hat()
    hat.setValue(5, forKey: "brimSize")
    XCTAssertEqual(hat.brimSize, 5, "sets the value on the object")
  }
}
