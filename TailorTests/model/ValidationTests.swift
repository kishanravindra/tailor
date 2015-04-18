import Tailor
import TailorTesting
import XCTest

class ValidationTests: TailorTestCase {
  //MARK: - Running Validations
  
  func testValidatePresenceOfWithValueGetsError() {
    let hat = Hat()
    let result = Validation<Hat>().validate(presenceOf: "owner", hat.owner)
    assert(result.errors, equals: [
      ValidationError(modelType: Hat.self, key: "owner", message: "blank")
    ])
  }
  
  func testValidatePresenceOfWithIntegerGetsNoError() {
    let hat = Hat(brimSize: 10)
    let result = Validation<Hat>().validate(presenceOf: "brimSize", hat.brimSize)
    assert(result.errors, equals: [])
  }
  
  func testValidatePresenceOfWithStringGetsNoError() {
    let hat = Hat(color: "red")
    let result = Validation<Hat>().validate(presenceOf: "color", hat.color)
    assert(result.errors, equals: [])
  }
  
  func testValidatePresenceOfWithEmptyStringGetsError() {
    let hat = Hat(color: "")
    let result = Validation<Hat>().validate(presenceOf: "color", hat.color)
    assert(result.errors, equals: [
      ValidationError(modelType: Hat.self, key: "color", message: "blank")
      ])
  }
  
  func testValidateBoundsWithValueInBoundsGetsNoError() {
    let hat = Hat(brimSize: 10)
    let result = Validation<Hat>().validate("brimSize", hat.brimSize, inBounds: 5...15)
    assert(result.errors, equals: [])
  }
  
  func testValidateBoundsWithValueBelowBoundsGetsError() {
    let hat = Hat(brimSize: 4)
    let result = Validation<Hat>().validate("brimSize", hat.brimSize, inBounds: 5...15)
    assert(result.errors, equals: [
      ValidationError(modelType: Hat.self, key: "brimSize", message: "tooLow", data: ["min": "5"])
    ])
  }
  
  func testValidateBoundsWithValueAtBottomOfOpenIntervalGetsNoError() {
    let hat = Hat(brimSize: 5)
    let result = Validation<Hat>().validate("brimSize", hat.brimSize, inBounds: 5..<15)
    assert(result.errors, equals: [])
  }
  
  func testValidateBoundsWithValueAboveBoundsGetsError() {
    let hat = Hat(brimSize: 16)
    let result = Validation<Hat>().validate("brimSize", hat.brimSize, inBounds: 5...15)
    assert(result.errors, equals: [
      ValidationError(modelType: Hat.self, key: "brimSize", message: "tooHigh", data: ["max": "15"])
    ])
  }
  
  func testValidateBoundsWithValueAtTopOfOpenIntervalGetsNoError() {
    let hat = Hat(brimSize: 15)
    let result = Validation<Hat>().validate("brimSize", hat.brimSize, inBounds: 5..<15)
    assert(result.errors, equals: [
      ValidationError(modelType: Hat.self, key: "brimSize", message: "tooHigh", data: ["max": "15"])
    ])
  }
  
  func testValidateBoundsWithValueAtTopOfClosedIntervalGetsNoError() {
    let hat = Hat(brimSize: 15)
    let result = Validation<Hat>().validate("brimSize", hat.brimSize, inBounds: 5...15)
    assert(result.errors, equals: [])
  }
  
  func testValidateWithMultipleErrorsCollectsErrors() {
    let hat = Hat(brimSize: 5, color: "")
    let result = Validation<Hat>()
      .validate(presenceOf: "color", hat.color)
      .validate("brimSize", hat.brimSize, inBounds: 10...15)
    
    assert(result.errors, equals: [
      ValidationError(modelType: Hat.self, key: "color", message: "blank"),
      ValidationError(modelType: Hat.self, key: "brimSize", message: "tooLow", data: ["min": "10"])
      ])
  }
  
  func testValidateWithBlockAddsErrors() {
    let result = Validation<Hat>().validate {
      [
        ("color", "blank", [:]),
        ("brimSize", "tooLow", ["min": "5"])
      ]
    }
    assert(result.errors, equals: [
      ValidationError(modelType: Hat.self, key: "color", message: "blank"),
      ValidationError(modelType: Hat.self, key: "brimSize", message: "tooLow", data: ["min": "5"])
    ])
  }
  
  func testValidateUniquenessWithTakenFieldHasError() {
    let hat1 = Hat(color: "red")
    hat1.save()
    let hat2 = Hat(color: "red")
    let result = Validation<Hat>().validate(uniquenessOf: ["color": hat2.color], id: hat2.id)
    assert(result.errors, equals: [
      ValidationError(modelType: Hat.self, key: "color", message: "taken")
    ])
  }
  
  func testValidateUniquenessWithNoOthersHasNoError() {
    let hat1 = Hat(color: "red")
    let result = Validation<Hat>().validate(uniquenessOf: ["color": hat1.color], id: hat1.id)
    assert(result.errors, equals: [])
  }
  
  func testValidateUniquenessWithSavedRecordWithNoOthersHasNoError() {
    let hat1 = Hat(color: "red")
    hat1.save()
    let result = Validation<Hat>().validate(uniquenessOf: ["color": hat1.color], id: hat1.id)
    assert(result.errors, equals: [])
  }
  
  func testValidateUniquenessWithSavedRecordWithTakenFieldHasError() {
    let hat1 = Hat(color: "red")
    hat1.save()
    let hat2 = Hat(color: "red")
    hat2.save()
    let result = Validation<Hat>().validate(uniquenessOf: ["color": hat2.color], id: hat2.id)
    assert(result.errors, equals: [
      ValidationError(modelType: Hat.self, key: "color", message: "taken")
      ])
  }
  
  func testValidateUniquenessWithMultipleFieldsWithAllTakenHasError() {
    let hat1 = Hat(color: "red", brimSize: 10)
    hat1.save()
    let hat2 = Hat(color: "red", brimSize: 10)
    let result = Validation<Hat>().validate(uniquenessOf: ["color": hat2.color, "brim_size": hat2.brimSize], id: hat2.id)
    assert(result.errors, equals: [
      ValidationError(modelType: Hat.self, key: "brim_size_color", message: "taken")
      ])
  }
  
  func testValidateUniquenessWithPartialOverlapHasNoError() {
    let hat1 = Hat(color: "red", brimSize: 10)
    hat1.save()
    let hat2 = Hat(color: "red", brimSize: 15)
    hat2.save()
    let hat3 = Hat(color: "brown", brimSize: 10)
    hat3.save()
    let result1 = Validation<Hat>().validate(uniquenessOf: ["color": hat2.color, "brim_size": hat2.brimSize], id: hat2.id)
    let result2 = Validation<Hat>().validate(uniquenessOf: ["color": hat3.color, "brim_size": hat3.brimSize], id: hat3.id)
    assert(result1.errors, equals: [])
    assert(result2.errors, equals: [])
  }
  
  func testValidateUniquenessWithNilValueWithNullTakenReturnsError() {
    let shelf1 = Shelf(name: nil)
    shelf1.save()
    let shelf2 = Shelf(name: nil)
    let result = Validation<Shelf>().validate(uniquenessOf: ["name": shelf2.name], id: shelf2.id)
    assert(result.errors, equals: [
      ValidationError(modelType: Shelf.self, key: "name", message: "taken")
    ])
  }
  
  func testValidateUniquenessWIthNilValueWithRealValueTakenReturnsNoError() {
    let shelf1 = Shelf(name: "Shelf")
    shelf1.save()
    let shelf2 = Shelf(name: nil)
    let result = Validation<Shelf>().validate(uniquenessOf: ["name": shelf2.name], id: shelf2.id)
    assert(result.errors, equals: [])
  }
  
  //MARK: - Error Access
  
  func testSubscriptReturnsErrorsWithMatchingKey() {
    let validation = Validation<Hat>([
      ValidationError(modelType: Hat.self, key: "color", message: "blank"),
      ValidationError(modelType: Hat.self, key: "brimSize", message: "blank"),
      ValidationError(modelType: Hat.self, key: "color", message: "tooShort"),
    ])
    let errors = validation["color"]
    assert(errors, equals: [
      ValidationError(modelType: Hat.self, key: "color", message: "blank"),
      ValidationError(modelType: Hat.self, key: "color", message: "tooShort"),
    ])
  }
  
  func testValidationWithNoErrorsIsValid() {
    let validation = Validation<Hat>()
    XCTAssertTrue(validation.valid)
  }
  
  func testValidationWithErrorIsNotValid() {
    let validation = Validation<Hat>([
      ValidationError(modelType: Hat.self, key: "color", message: "blank")
    ])
    XCTAssertFalse(validation.valid)
  }
}