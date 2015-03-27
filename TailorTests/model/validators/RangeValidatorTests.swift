import XCTest
import Tailor
import TailorTesting

class RangeValidatorTests: TailorTestCase {
  let validator = RangeValidator(key: "brimSize", max: 20, min: 10)
  let record = Hat()
  
  func testValidatorPutsErrorWhenValueIsBelowMin() {
    record.brimSize = 8
    validator.validate(record)
    let error = ValidationError(modelType: Hat.self, key: "brimSize", message: "tooLow", data: ["min": "10"])
    assert(record.errors.errors, equals: [error], message: "puts the error on the record")
  }
  
  func testValidatorPutsErrorWhenValueIsAboveMax() {
    record.brimSize = 25
    validator.validate(record)
    let error = ValidationError(modelType: Hat.self, key: "brimSize", message: "tooHigh", data: ["max": "20"])
    assert(record.errors.errors, equals: [error], message: "puts the error on the record")
  }
  
  func testValidatorPutsNoErrorWhenValueIsInRange() {
    record.brimSize = 15
    validator.validate(record)
    XCTAssertTrue(record.errors.isEmpty, "has no errors")
  }
  
  func testValidatorPutsNoErrorWhenValueIsTheMinimum() {
    record.brimSize = 10
    validator.validate(record)
    XCTAssertTrue(record.errors.isEmpty, "has no errors")
  }
  
  func testValidatorPutsNoErrorWhenValueIsTheMaximum() {
    record.brimSize = 20
    validator.validate(record)
    XCTAssertTrue(record.errors.isEmpty, "has no errors")
  }
  
  func testValidatorPutsErrorWhenValueIsNil() {
    validator.validate(record)
    let error = ValidationError(modelType: Hat.self, key: "brimSize", message: "blank", data: [:])
    assert(record.errors.errors, equals: [error], message: "puts the error on the record")
  }
  
  func testValidatorPutsErrorWhenValueIsAString() {
    record.color = "red"
    let validator2 = RangeValidator(key: "color", min: 10, max: 20)
    validator2.validate(record)
    let error = ValidationError(modelType: Hat.self, key: "color", message: "nonNumeric", data: [:])
    assert(record.errors.errors, equals: [error], message: "puts the error on the record")
  }
  
  func testValidatorDoesNotHaveErrorWithNoMinOrMax() {
    record.brimSize = 10
    let validator2 = RangeValidator(key: "brimSize", min: nil, max: nil)
    validator2.validate(record)
    XCTAssertTrue(record.errors.isEmpty, "has no errors")
  }
}
