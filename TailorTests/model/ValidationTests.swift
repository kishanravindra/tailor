import Tailor
import TailorTesting
import XCTest

class ValidationTests: TailorTestCase {
  //MARK: - Initialization
  
  func testInitializationSetsModelNameAndErrors() {
    
  }
  
  //MARK: - Running Validations
  
  func testValidatePresenceOfWithValueGetsError() {
    let hat = Hat()
    let result = Validation(modelName(Hat.self)).validate(presenceOf: "owner", hat.owner)
    assert(result.errors, equals: [
      ValidationError(modelName: modelName(Hat.self), key: "owner", message: "blank")
    ])
  }
  
  func testValidatePresenceOfWithIntegerGetsNoError() {
    let hat = Hat(brimSize: 10)
    let result = Validation(modelName(Hat.self)).validate(presenceOf: "brimSize", hat.brimSize)
    assert(result.errors, equals: [])
  }
  
  func testValidatePresenceOfWithStringGetsNoError() {
    let hat = Hat(color: "red")
    let result = Validation(modelName(Hat.self)).validate(presenceOf: "color", hat.color)
    assert(result.errors, equals: [])
  }
  
  func testValidatePresenceOfWithEmptyStringGetsError() {
    let hat = Hat(color: "")
    let result = Validation(modelName(Hat.self)).validate(presenceOf: "color", hat.color)
    assert(result.errors, equals: [
      ValidationError(modelName: modelName(Hat.self), key: "color", message: "blank")
      ])
  }
  
  func testValidateBoundsWithValueInBoundsGetsNoError() {
    let hat = Hat(brimSize: 10)
    let result = Validation(modelName(Hat.self)).validate("brimSize", hat.brimSize, inBounds: 5...15)
    assert(result.errors, equals: [])
  }
  
  func testValidateBoundsWithValueBelowBoundsGetsError() {
    let hat = Hat(brimSize: 4)
    let result = Validation(modelName(Hat.self)).validate("brimSize", hat.brimSize, inBounds: 5...15)
    assert(result.errors, equals: [
      ValidationError(modelName: modelName(Hat.self), key: "brimSize", message: "tooLow", data: ["min": "5"])
    ])
  }
  
  func testValidateBoundsWithValueAtBottomOfOpenIntervalGetsNoError() {
    let hat = Hat(brimSize: 5)
    let result = Validation(modelName(Hat.self)).validate("brimSize", hat.brimSize, inBounds: 5..<15)
    assert(result.errors, equals: [])
  }
  
  func testValidateBoundsWithValueAboveBoundsGetsError() {
    let hat = Hat(brimSize: 16)
    let result = Validation(modelName(Hat.self)).validate("brimSize", hat.brimSize, inBounds: 5...15)
    assert(result.errors, equals: [
      ValidationError(modelName: modelName(Hat.self), key: "brimSize", message: "tooHigh", data: ["max": "15"])
    ])
  }
  
  func testValidateBoundsWithValueAtTopOfOpenIntervalGetsNoError() {
    let hat = Hat(brimSize: 15)
    let result = Validation(modelName(Hat.self)).validate("brimSize", hat.brimSize, inBounds: 5..<15)
    assert(result.errors, equals: [
      ValidationError(modelName: modelName(Hat.self), key: "brimSize", message: "tooHigh", data: ["max": "15"])
    ])
  }
  
  func testValidateBoundsWithValueAtTopOfClosedIntervalGetsNoError() {
    let hat = Hat(brimSize: 15)
    let result = Validation(modelName(Hat.self)).validate("brimSize", hat.brimSize, inBounds: 5...15)
    assert(result.errors, equals: [])
  }
  
  func testValidateWithMultipleErrorsCollectsErrors() {
    let hat = Hat(brimSize: 5, color: "")
    let result = Validation(modelName(Hat.self))
      .validate(presenceOf: "color", hat.color)
      .validate("brimSize", hat.brimSize, inBounds: 10...15)
    
    assert(result.errors, equals: [
      ValidationError(modelName: modelName(Hat.self), key: "color", message: "blank"),
      ValidationError(modelName: modelName(Hat.self), key: "brimSize", message: "tooLow", data: ["min": "10"])
      ])
  }
  
  func testValidateWithBlockAddsErrors() {
    let result = Validation(modelName(Hat.self)).validate {
      [
        ("color", "blank", [:]),
        ("brimSize", "tooLow", ["min": "5"])
      ]
    }
    assert(result.errors, equals: [
      ValidationError(modelName: modelName(Hat.self), key: "color", message: "blank"),
      ValidationError(modelName: modelName(Hat.self), key: "brimSize", message: "tooLow", data: ["min": "5"])
    ])
  }
  
  func testValidateUniquenessWithTakenFieldHasError() {
    _ = saveRecord(Hat(color: "red"))!
    let hat2 = Hat(color: "red")
    let result = Validation(modelName(Hat.self)).validate(uniquenessOf: ["color": hat2.color], on: hat2)
    assert(result.errors, equals: [
      ValidationError(modelName: modelName(Hat.self), key: "color", message: "taken")
    ])
  }
  
  func testValidateUniquenessWithNoOthersHasNoError() {
    let hat1 = Hat(color: "red")
    let result = Validation(modelName(Hat.self)).validate(uniquenessOf: ["color": hat1.color], on: hat1)
    assert(result.errors, equals: [])
  }
  
  func testValidateUniquenessWithSavedRecordWithNoOthersHasNoError() {
    let hat1 = saveRecord(Hat(color: "red"))!
    let result = Validation(modelName(Hat.self)).validate(uniquenessOf: ["color": hat1.color], on: hat1)
    assert(result.errors, equals: [])
  }
  
  func testValidateUniquenessWithSavedRecordWithTakenFieldHasError() {
    _ = saveRecord(Hat(color: "red"))!
    let hat2 = saveRecord(Hat(color: "red"))!
    let result = Validation(modelName(Hat.self)).validate(uniquenessOf: ["color": hat2.color], on: hat2)
    assert(result.errors, equals: [
      ValidationError(modelName: modelName(Hat.self), key: "color", message: "taken")
      ])
  }
  
  func testValidateUniquenessWithMultipleFieldsWithAllTakenHasError() {
    _ = saveRecord(Hat(color: "red", brimSize: 10))!
    let hat2 = Hat(color: "red", brimSize: 10)
    let result = Validation(modelName(Hat.self)).validate(uniquenessOf: ["color": hat2.color, "brim_size": hat2.brimSize], on: hat2)
    assert(result.errors, equals: [
      ValidationError(modelName: modelName(Hat.self), key: "brim_size_color", message: "taken")
      ])
  }
  
  func testValidateUniquenessWithPartialOverlapHasNoError() {
    _ = saveRecord(Hat(color: "red", brimSize: 10))!
    let hat2 = saveRecord(Hat(color: "red", brimSize: 15))!
    let hat3 = saveRecord(Hat(color: "brown", brimSize: 10))!
    let result1 = Validation(modelName(Hat.self)).validate(uniquenessOf: ["color": hat2.color, "brim_size": hat2.brimSize], on: hat2)
    let result2 = Validation(modelName(Hat.self)).validate(uniquenessOf: ["color": hat3.color, "brim_size": hat3.brimSize], on: hat3)
    assert(result1.errors, equals: [])
    assert(result2.errors, equals: [])
  }
  
  func testValidateUniquenessWithNilValueWithNullTakenReturnsError() {
    _ = saveRecord(Shelf(name: nil))!
    let shelf2 = Shelf(name: nil)
    let result = Validation(modelName(Shelf.self)).validate(uniquenessOf: ["name": shelf2.name], on: shelf2)
    assert(result.errors, equals: [
      ValidationError(modelName: "shelf", key: "name", message: "taken")
    ])
  }
  
  func testValidateUniquenessWIthNilValueWithRealValueTakenReturnsNoError() {
    _ = saveRecord(Shelf(name: "Shelf"))!
    let shelf2 = Shelf(name: nil)
    let result = Validation(modelName(Shelf.self)).validate(uniquenessOf: ["name": shelf2.name], on: shelf2)
    assert(result.errors, equals: [])
  }
  
  //MARK: - Error Access
  
  func testSubscriptReturnsErrorsWithMatchingKey() {
    let validation = Validation(modelName(Hat.self), errors: [
      ValidationError(modelName: modelName(Hat.self), key: "color", message: "blank"),
      ValidationError(modelName: modelName(Hat.self), key: "brimSize", message: "blank"),
      ValidationError(modelName: modelName(Hat.self), key: "color", message: "tooShort"),
    ])
    let errors = validation["color"]
    assert(errors, equals: [
      ValidationError(modelName: modelName(Hat.self), key: "color", message: "blank"),
      ValidationError(modelName: modelName(Hat.self), key: "color", message: "tooShort"),
    ])
  }
  
  func testValidationWithNoErrorsIsValid() {
    let validation = Validation(modelName(Hat.self))
    XCTAssertTrue(validation.valid)
  }
  
  func testValidationWithErrorIsNotValid() {
    let validation = Validation(modelName(Hat.self), errors: [
      ValidationError(modelName: modelName(Hat.self), key: "color", message: "blank")
    ])
    XCTAssertFalse(validation.valid)
  }
}