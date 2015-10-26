import TailorTesting
import Tailor
import XCTest

@available(*, deprecated)
class JsonErrorTests: XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
  func testUnsupportedTypeErrorsWithSameTypeAreEqual() {
    let value1 = JsonParsingError.UnsupportedType(String.self)
    let value2 = JsonParsingError.UnsupportedType(String.self)
    assert(value1, equals: value2)
  }
  
  func testUnsupportedTypeErrorsWithDifferentTypesAreEqual() {
    let value1 = JsonParsingError.UnsupportedType(String.self)
    let value2 = JsonParsingError.UnsupportedType(NSData.self)
    assert(value1, doesNotEqual: value2)
  }
  
  func testUnsupportedTypeErrorDoesNotEqualWrongFieldTypeError() {
    let value1 = JsonParsingError.UnsupportedType(String.self)
    let value2 = JsonParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    assert(value1, doesNotEqual: value2)
  }
  
  func testWrongFieldTypeErrorsWithSameInfoAreEqual() {
    let value1 = JsonParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    let value2 = JsonParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    assert(value1, equals: value2)
  }
  
  func testWrongFieldTypeErrorsWithDifferentFieldsAreNotEqual() {
    let value1 = JsonParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    let value2 = JsonParsingError.WrongFieldType(field: "name", type: String.self, caseType: NSData.self)
    assert(value1, doesNotEqual: value2)
  }
  
  func testWrongFieldTypeErrorsWithDifferentTypesAreNotEqual() {
    let value1 = JsonParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    let value2 = JsonParsingError.WrongFieldType(field: "root", type: NSURL.self, caseType: NSData.self)
    assert(value1, doesNotEqual: value2)
  }
  
  func testWrongFieldTypeErrorsWithDifferentCaseTypesAreNotEqual() {
    let value1 = JsonParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    let value2 = JsonParsingError.WrongFieldType(field: "root", type: String.self, caseType: String.self)
    assert(value1, doesNotEqual: value2)
  }
  
  func testWrongFieldTypeErrorDoesNotEqualUnsupportedTypeError() {
    let value1 = JsonParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    let value2 = JsonParsingError.UnsupportedType(String.self)
    assert(value1, doesNotEqual: value2)
  }
  
  func testMissingFieldErrorsWithSameFieldAreEqual() {
    let value1 = JsonParsingError.MissingField(field: "name")
    let value2 = JsonParsingError.MissingField(field: "name")
    assert(value1, equals: value2)
  }
  
  func testMissingFieldErrorsWithDifferentFieldsAreEqual() {
    let value1 = JsonParsingError.MissingField(field: "name")
    let value2 = JsonParsingError.MissingField(field: "age")
    assert(value1, doesNotEqual: value2)
  }
  
  func testMissingFieldErrorDoesNotEqualWrongFieldTypeError() {
    let value1 = JsonParsingError.MissingField(field: "name")
    let value2 = JsonParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    assert(value1, doesNotEqual: value2)
  }
  
  func testParsingErrorWithFieldPrefixWithWrongFieldTypeErrorAddsPrefixToField() {
    do {
      try JsonParsingError.withFieldPrefix("test") {
        Void->Void in
        throw JsonParsingError.WrongFieldType(field: "value", type: String.self, caseType: NSNumber.self)
      }
      assert(false, message: "should throw some kind of exception")
    }
    catch JsonParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "test.value")
      assert(type == String.self)
      assert(caseType == NSNumber.self)
    }
    catch  {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testParsingErrorWithFieldPrefixWithMissingFieldErrorAddsPrefixToField() {
    do {
      try JsonParsingError.withFieldPrefix("test") {
        Void->Void in
        throw JsonParsingError.MissingField(field: "name")
      }
      assert(false, message: "should throw some kind of exception")
    }
    catch JsonParsingError.MissingField(field: let field) {
      assert(field, equals: "test.name")
    }
    catch  {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testParsingErrorWithFieldPrefixWithUnsupportedTypeErrorRethrowsError() {
    do {
      try JsonParsingError.withFieldPrefix("test") {
        Void->Void in
        throw JsonParsingError.UnsupportedType(NSColor.self)
      }
      assert(false, message: "should throw some kind of exception")
    }
    catch JsonParsingError.UnsupportedType(let type) {
      assert(type == NSColor.self)
    }
    catch  {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testParsingErrorWithFieldPrefixWithNoErrorReturnsValue() {
    do {
      let value = try JsonParsingError.withFieldPrefix("test") { "Hello" }
      assert(value, equals: "Hello")
    }
    catch  {
      assert(false, message: "threw unexpected exception")
    }
  }
}