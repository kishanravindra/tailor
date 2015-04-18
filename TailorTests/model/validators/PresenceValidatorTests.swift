import XCTest
import Tailor
import TailorTesting

class PresenceValidatorTests: TailorTestCase {
  let validator = PresenceValidator(key: "name")
  
  func testValidatorPutsNoErrorsOnRecordWithValue() {
    let record = Store(name: "Shop")
    validator.validate(record)
    XCTAssertTrue(record.errors.isEmpty)
  }
  
  func testValidatorPutsErrorOnRecordWithBlankValue() {
    let record = Store(name: "")
    validator.validate(record)
    let error = ValidationError(modelType: Store.self, key: "name", message: "blank", data: [:])
    assert(record.errors.errors, equals: [error], message: "puts the error on the record")
  }
  
  func testValidatorPutsErrorOnRecordWithoutColumn() {
    let record = Hat()
    validator.validate(record)
    let error = ValidationError(modelType: Store.self, key: "name", message: "blank", data: [:])
    assert(record.errors.errors, equals: [error], message: "puts the error on the record")
  }
}
