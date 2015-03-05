import XCTest

class ModelTests: XCTestCase {
  @objc(HatForModel) class HatForModel : Hat {
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
      let hat = model as! HatForModel
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
    XCTAssertEqual(Hat.modelName(), "hat", "gets lowercased class name for model")
    XCTAssertEqual(HatForModel.modelName(), "hat_for_model", "gets lowercased class name with underscores for for HatForModel")
  }
  
  //MARK: - Validations
  
  func testValidateLeavesErrorsEmptyWhenValidationsPass() {
    let hat = Hat()
    hat.validate()
    XCTAssertTrue(hat.errors.isEmpty, "hat has no errors")
  }
  
  func testValidateReturnsTrueWhenValidationsPass() {
    let hat = Hat()
    let result = hat.validate()
    XCTAssertTrue(result, "method returns true")
  }
  
  func testValidatePutsErrorMessageInErrorListWhenValidationFails() {
    let hat = HatForModel()
    hat.keysToFail.append("brimSize")
    hat.validate()
    let errors = hat.errors.errors
    XCTAssertEqual(errors.count, 1, "has one error")
    if errors.count > 0 {
      let error = errors[0]
      XCTAssertEqual(error.message, "failed validation", "has the error provided by the validator")
    }
  }
  
  func testValidateReturnsFalseWhenValidationFails() {
    let hat = HatForModel()
    hat.keysToFail.append("brimSize")
    let result = hat.validate()
    XCTAssertFalse(result, "returns false")
  }
  
  func testValidateCanCollectMultipleErrors() {
    let hat = HatForModel()
    hat.keysToFail.append("brimSize")
    hat.keysToFail.append("color")
    hat.validate()
    
    XCTAssertEqual(hat.errors["brimSize"].count, 1, "has one error for brim size")
    XCTAssertEqual(hat.errors["color"].count, 1, "has one error for color")
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
      override func fetch(key: String, inLocale locale: String) -> String? {
        return key + " translated"
      }
    }
    
    let name = HatForModel.humanAttributeName("brimSize", localization: TestLocalization(locale: "en"))
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
