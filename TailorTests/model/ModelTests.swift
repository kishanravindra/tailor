import XCTest
import Tailor
import TailorTesting

class ModelTests: TailorTestCase {
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
    Application.start()
  }
  
  //MARK: - Structure
  
  func testModelNameIsTakenFromClassName() {
    assert(TailorTests.Hat.modelName(), equals: "hat", message: "gets lowercased class name for model")
    assert(Hat.modelName(), equals: "hat_for_model", message: "gets lowercased class name with underscores for for HatForModel")
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
    let hat = Hat()
    hat.keysToFail.append("brimSize")
    hat.validate()
    let errors = hat.errors.errors
    assert(errors.count, equals: 1, message: "has one error")
    if errors.count > 0 {
      let error = errors[0]
      assert(error.message, equals: "failed validation", message: "has the error provided by the validator")
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
    
    assert(hat.errors["brimSize"].count, equals: 1, message: "has one error for brim size")
    assert(hat.errors["color"].count, equals: 1, message: "has one error for color")
  }
  
  //MARK: - Dynamic Properties

  func testHumanAttributeNameSeparatesWords() {
    let name = Hat.humanAttributeName("brimSize")
    assert(name, equals: "brim size", message: "gets words from attribute name")
  }
  
  func testHumanAttributeNameCanCapitalizeName() {
    let name = Hat.humanAttributeName("brimSize", capitalize: true)
    assert(name, equals: "Brim Size", message: "gets capitalized words from attribute name")
  }
  
  func testHumanAttributeNameCanGetNameFromLocalization() {
    class TestLocalization : Localization {
      override func fetch(key: String, inLocale locale: String) -> String? {
        return key + " translated"
      }
    }
    
    let name = Hat.humanAttributeName("brimSize", localization: TestLocalization(locale: "en"))
    assert(name, equals: "record.hat_for_model.attributes.brim_size translated", message: "gets string from localization")
  }
  
  func testValueForKeyGetsValueFromInstanceVariable() {
    let hat = Hat()
    hat.color = "black"
    let result = hat.valueForKey("color") as! String
    assert(result, equals: "black", message: "gets the value stored on the object")
  }
  
  func testValueForKeyReturnsNilForInvalidName() {
    let hat = Hat()
    XCTAssertNil(hat.valueForKey("brandName"), "returns nil")
  }
  
  func testSetValueCanSetStringValue() {
    let hat = Hat()
    hat.setValue("red", forKey: "color")
    assert(hat.color, equals: "red", message: "sets the value on the object")
  }
  
  func testSetValueCanSetIntValue() {
    let hat = Hat()
    hat.setValue(5, forKey: "brimSize")
    assert(hat.brimSize, equals: 5, message: "sets the value on the object")
  }
}
