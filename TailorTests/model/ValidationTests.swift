import Tailor
import TailorTesting
import XCTest

class ValidationTests: XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
  //MARK: - Initialization
  
  func testInitializationSetsModelNameAndErrors() {
    let errors = [ValidationError(modelName: "Hat", key: "color", message: "blank")]
    let validation = Validation("Hat", errors: errors)
    assert(validation.modelName, equals: "Hat")
    assert(validation.errors, equals: errors)
  }
  
  //MARK: - Running Validations
  
  func testValidatePresenceOfWithValueGetsError() {
    let hat = Hat()
    let result = Validation(Hat.self).validate(presenceOf: "owner", hat.owner)
    assert(result.errors, equals: [
      ValidationError(modelName: Hat.modelName(), key: "owner", message: "blank")
    ])
  }
  
  func testValidatePresenceOfWithIntegerGetsNoError() {
    let hat = Hat(brimSize: 10)
    let result = Validation(Hat.self).validate(presenceOf: "brimSize", hat.brimSize)
    assert(result.errors, equals: [])
  }
  
  func testValidatePresenceOfWithStringGetsNoError() {
    let hat = Hat(color: "red")
    let result = Validation(Hat.modelName()).validate(presenceOf: "color", hat.color)
    assert(result.errors, equals: [])
  }
  
  func testValidatePresenceOfWithEmptyStringGetsError() {
    let hat = Hat(color: "")
    let result = Validation(Hat.self).validate(presenceOf: "color", hat.color)
    assert(result.errors, equals: [
      ValidationError(modelName: Hat.modelName(), key: "color", message: "blank")
      ])
  }
  
  func testValidateBoundsWithValueInBoundsGetsNoError() {
    let hat = Hat(brimSize: 10)
    let result = Validation(Hat.self).validate("brimSize", hat.brimSize, inBounds: 5...15)
    assert(result.errors, equals: [])
  }
  
  func testValidateBoundsWithValueBelowBoundsGetsError() {
    let hat = Hat(brimSize: 4)
    let result = Validation(Hat.self).validate("brimSize", hat.brimSize, inBounds: 5...15)
    assert(result.errors, equals: [
      ValidationError(modelName: Hat.modelName(), key: "brimSize", message: "tooLow", data: ["min": "5"])
    ])
  }
  
  func testValidateBoundsWithValueAtBottomOfOpenIntervalGetsNoError() {
    let hat = Hat(brimSize: 5)
    let result = Validation(Hat.self).validate("brimSize", hat.brimSize, inBounds: 5..<15)
    assert(result.errors, equals: [])
  }
  
  func testValidateBoundsWithValueAboveBoundsGetsError() {
    let hat = Hat(brimSize: 16)
    let result = Validation(Hat.self).validate("brimSize", hat.brimSize, inBounds: 5...15)
    assert(result.errors, equals: [
      ValidationError(modelName: Hat.modelName(), key: "brimSize", message: "tooHigh", data: ["max": "15"])
    ])
  }
  
  func testValidateBoundsWithValueAtTopOfOpenIntervalGetsNoError() {
    let hat = Hat(brimSize: 15)
    let result = Validation(Hat.self).validate("brimSize", hat.brimSize, inBounds: 5..<15)
    assert(result.errors, equals: [
      ValidationError(modelName: Hat.modelName(), key: "brimSize", message: "tooHigh", data: ["max": "15"])
    ])
  }
  
  func testValidateBoundsWithValueAtTopOfClosedIntervalGetsNoError() {
    let hat = Hat(brimSize: 15)
    let result = Validation(Hat.self).validate("brimSize", hat.brimSize, inBounds: 5...15)
    assert(result.errors, equals: [])
  }
  
  func testValidateWithMultipleErrorsCollectsErrors() {
    let hat = Hat(brimSize: 5, color: "")
    let result = Validation(Hat.self)
      .validate(presenceOf: "color", hat.color)
      .validate("brimSize", hat.brimSize, inBounds: 10...15)
    
    assert(result.errors, equals: [
      ValidationError(modelName: Hat.modelName(), key: "color", message: "blank"),
      ValidationError(modelName: Hat.modelName(), key: "brimSize", message: "tooLow", data: ["min": "10"])
      ])
  }
  
  func testValidateWithBlockAddsErrors() {
    let result = Validation(Hat.self).validate {
      [
        ("color", "blank", [:]),
        ("brimSize", "tooLow", ["min": "5"])
      ]
    }
    assert(result.errors, equals: [
      ValidationError(modelName: Hat.modelName(), key: "color", message: "blank"),
      ValidationError(modelName: Hat.modelName(), key: "brimSize", message: "tooLow", data: ["min": "5"])
    ])
  }
  
  func testValidateUniquenessWithTakenFieldHasError() {
    Hat(color: "red").save()
    let hat2 = Hat(color: "red")
    let result = Validation(Hat.self).validate(uniquenessOf: ["color": hat2.color], on: hat2)
    assert(result.errors, equals: [
      ValidationError(modelName: Hat.modelName(), key: "color", message: "taken")
    ])
  }
  
  func testValidateUniquenessWithNoOthersHasNoError() {
    let hat1 = Hat(color: "red")
    let result = Validation(Hat.self).validate(uniquenessOf: ["color": hat1.color], on: hat1)
    assert(result.errors, equals: [])
  }
  
  func testValidateUniquenessWithSavedRecordWithNoOthersHasNoError() {
    let hat1 = Hat(color: "red").save()!
    let result = Validation(Hat.self).validate(uniquenessOf: ["color": hat1.color], on: hat1)
    assert(result.errors, equals: [])
  }
  
  func testValidateUniquenessWithSavedRecordWithTakenFieldHasError() {
    Hat(color: "red").save()!
    let hat2 = Hat(color: "red").save()!
    let result = Validation(Hat.self).validate(uniquenessOf: ["color": hat2.color], on: hat2)
    assert(result.errors, equals: [
      ValidationError(modelName: Hat.modelName(), key: "color", message: "taken")
      ])
  }
  
  func testValidateUniquenessWithMultipleFieldsWithAllTakenHasError() {
    Hat(color: "red", brimSize: 10).save()!
    let hat2 = Hat(color: "red", brimSize: 10)
    let result = Validation(Hat.self).validate(uniquenessOf: ["color": hat2.color, "brim_size": hat2.brimSize], on: hat2)
    assert(result.errors, equals: [
      ValidationError(modelName: Hat.modelName(), key: "brim_size_color", message: "taken")
      ])
  }
  
  func testValidateUniquenessWithPartialOverlapHasNoError() {
    Hat(color: "red", brimSize: 10).save()!
    let hat2 = Hat(color: "red", brimSize: 15).save()!
    let hat3 = Hat(color: "brown", brimSize: 10).save()!
    let result1 = Validation(Hat.self).validate(uniquenessOf: ["color": hat2.color, "brim_size": hat2.brimSize], on: hat2)
    let result2 = Validation(Hat.self).validate(uniquenessOf: ["color": hat3.color, "brim_size": hat3.brimSize], on: hat3)
    assert(result1.errors, equals: [])
    assert(result2.errors, equals: [])
  }
  
  func testValidateUniquenessWithNilValueWithNullTakenReturnsError() {
    Shelf(name: nil).save()!
    let shelf2 = Shelf(name: nil)
    let result = Validation(Shelf.self).validate(uniquenessOf: ["name": shelf2.name], on: shelf2)
    assert(result.errors, equals: [
      ValidationError(modelName: "shelf", key: "name", message: "taken")
    ])
  }
  
  func testValidateUniquenessWIthNilValueWithRealValueTakenReturnsNoError() {
    Shelf(name: "Shelf").save()!
    let shelf2 = Shelf(name: nil)
    let result = Validation(Shelf.self).validate(uniquenessOf: ["name": shelf2.name], on: shelf2)
    assert(result.errors, equals: [])
  }
  
  func testValidateUniquenessWithNoFieldHasNoError() {
    Hat(color: "red").save()
    let hat2 = Hat(color: "red")
    let result = Validation(Hat.self).validate(uniquenessOf: [:], on: hat2)
    assert(result.errors, equals: [])
  }
  
  //MARK: - Error Access
  
  func testSubscriptReturnsErrorsWithMatchingKey() {
    let validation = Validation(Hat.self, errors: [
      ValidationError(modelName: Hat.modelName(), key: "color", message: "blank"),
      ValidationError(modelName: Hat.modelName(), key: "brimSize", message: "blank"),
      ValidationError(modelName: Hat.modelName(), key: "color", message: "tooShort"),
    ])
    let errors = validation["color"]
    assert(errors, equals: [
      ValidationError(modelName: Hat.modelName(), key: "color", message: "blank"),
      ValidationError(modelName: Hat.modelName(), key: "color", message: "tooShort"),
    ])
  }
  
  func testValidationWithNoErrorsIsValid() {
    let validation = Validation(Hat.self)
    XCTAssertTrue(validation.valid)
  }
  
  func testValidationWithErrorIsNotValid() {
    let validation = Validation(Hat.self, errors: [
      ValidationError(modelName: Hat.modelName(), key: "color", message: "blank")
    ])
    XCTAssertFalse(validation.valid)
  }
  
  //MARK: - Comparisons
  
  func testValidationsAreEqualWithSameInfo() {
    let validation1 = Validation(Hat.self, errors: [
      ValidationError(modelName: Hat.modelName(), key: "color", message: "blank"),
      ValidationError(modelName: Hat.modelName(), key: "brimSize", message: "blank"),
      ValidationError(modelName: Hat.modelName(), key: "color", message: "tooShort"),
      ])
    let validation2 = Validation(Hat.self, errors: [
      ValidationError(modelName: Hat.modelName(), key: "color", message: "blank"),
      ValidationError(modelName: Hat.modelName(), key: "brimSize", message: "blank"),
      ValidationError(modelName: Hat.modelName(), key: "color", message: "tooShort"),
    ])
    assert(validation1, equals: validation2)
  }
  
  func testValidationsAreUnequalWithDifferentModels() {
    let validation1 = Validation(Hat.self, errors: [
      ValidationError(modelName: Hat.modelName(), key: "color", message: "blank"),
      ValidationError(modelName: Hat.modelName(), key: "brimSize", message: "blank"),
      ValidationError(modelName: Hat.modelName(), key: "color", message: "tooShort"),
      ])
    let validation2 = Validation(Store.self, errors: [
      ValidationError(modelName: Hat.modelName(), key: "color", message: "blank"),
      ValidationError(modelName: Hat.modelName(), key: "brimSize", message: "blank"),
      ValidationError(modelName: Hat.modelName(), key: "color", message: "tooShort"),
      ])
    assert(validation1, doesNotEqual: validation2)
  }
  
  func testValidationsAreUnequalWithDifferentErrors() {
    let validation1 = Validation(Hat.self, errors: [
      ValidationError(modelName: Hat.modelName(), key: "color", message: "blank"),
      ValidationError(modelName: Hat.modelName(), key: "brimSize", message: "blank"),
      ValidationError(modelName: Hat.modelName(), key: "color", message: "tooShort"),
      ])
    let validation2 = Validation(Hat.self, errors: [
      ValidationError(modelName: Hat.modelName(), key: "color", message: "blank"),
      ValidationError(modelName: Hat.modelName(), key: "brimSize", message: "blank"),
      ValidationError(modelName: Hat.modelName(), key: "color", message: "tooLong"),
      ])
    assert(validation1, doesNotEqual: validation2)
  }
}