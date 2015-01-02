import XCTest

class PresenceValidatorTests: XCTestCase {
  let validator = PresenceValidator(key: "name")
  
  func testValidatorPutsNoErrorsOnRecordWithValue() {
    let record = Store(data: ["name": "Shop"])
    validator.validate(record)
    XCTAssertTrue(record.errors.isEmpty())
  }
  
  func testValidatorPutsErrorOnRecordWithoutValue() {
    let record = Store()
    validator.validate(record)
    XCTAssertEqual(record.errors.errors, ["name": ["cannot be blank"]], "puts the error on the record")
  }
  
  func testValidatorPutsErrorOnRecordWithBlankValue() {
    let record = Store(data: ["name": ""])
    validator.validate(record)
    XCTAssertEqual(record.errors.errors, ["name": ["cannot be blank"]], "puts the error on the record")

  }
  
  func testValidatorPutsErrorOnRecordWithoutColumn() {
    let record = Hat()
    validator.validate(record)
    XCTAssertEqual(record.errors.errors, ["name": ["cannot be blank"]], "puts the error on the record")
  }
}
