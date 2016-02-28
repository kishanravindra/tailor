import TailorTesting
import Tailor
import XCTest
import Foundation

struct TestJsonError: XCTestCase, TailorTestable {
  @available(*, deprecated)
  //FIXME: Re-enable disabled test cases
  var allTests: [(String, () throws -> Void)] { return [
    ("testUnsupportedTypeErrorsWithSameTypeAreEqual", testUnsupportedTypeErrorsWithSameTypeAreEqual),
    ("testUnsupportedTypeErrorsWithDifferentTypesAreEqual", testUnsupportedTypeErrorsWithDifferentTypesAreEqual),
    ("testUnsupportedTypeErrorDoesNotEqualWrongFieldTypeError", testUnsupportedTypeErrorDoesNotEqualWrongFieldTypeError),
    ("testWrongFieldTypeErrorsWithSameInfoAreEqual", testWrongFieldTypeErrorsWithSameInfoAreEqual),
    ("testWrongFieldTypeErrorsWithDifferentFieldsAreNotEqual", testWrongFieldTypeErrorsWithDifferentFieldsAreNotEqual),
    ("testWrongFieldTypeErrorsWithDifferentTypesAreNotEqual", testWrongFieldTypeErrorsWithDifferentTypesAreNotEqual),
    ("testWrongFieldTypeErrorsWithDifferentCaseTypesAreNotEqual", testWrongFieldTypeErrorsWithDifferentCaseTypesAreNotEqual),
    ("testWrongFieldTypeErrorDoesNotEqualUnsupportedTypeError", testWrongFieldTypeErrorDoesNotEqualUnsupportedTypeError),
    ("testMissingFieldErrorsWithSameFieldAreEqual", testMissingFieldErrorsWithSameFieldAreEqual),
    ("testMissingFieldErrorsWithDifferentFieldsAreEqual", testMissingFieldErrorsWithDifferentFieldsAreEqual),
    ("testMissingFieldErrorDoesNotEqualWrongFieldTypeError", testMissingFieldErrorDoesNotEqualWrongFieldTypeError),
    ("testParsingErrorWithFieldPrefixWithWrongFieldTypeErrorAddsPrefixToField", testParsingErrorWithFieldPrefixWithWrongFieldTypeErrorAddsPrefixToField),
    ("testParsingErrorWithFieldPrefixWithMissingFieldErrorAddsPrefixToField", testParsingErrorWithFieldPrefixWithMissingFieldErrorAddsPrefixToField),
    //("testParsingErrorWithFieldPrefixWithUnsupportedTypeErrorRethrowsError", testParsingErrorWithFieldPrefixWithUnsupportedTypeErrorRethrowsError),
    ("testParsingErrorWithFieldPrefixWithNoErrorReturnsValue", testParsingErrorWithFieldPrefixWithNoErrorReturnsValue),
  ]}

  func setUp() {
    setUpTestCase()
  }

  @available(*, deprecated)  
  func testUnsupportedTypeErrorsWithSameTypeAreEqual() {
    let value1 = JsonParsingError.UnsupportedType(String.self)
    let value2 = JsonParsingError.UnsupportedType(String.self)
    assert(value1, equals: value2)
  }
  
  @available(*, deprecated)
  func testUnsupportedTypeErrorsWithDifferentTypesAreEqual() {
    let value1 = JsonParsingError.UnsupportedType(String.self)
    let value2 = JsonParsingError.UnsupportedType(NSData.self)
    assert(value1, doesNotEqual: value2)
  }
  
  @available(*, deprecated)
  func testUnsupportedTypeErrorDoesNotEqualWrongFieldTypeError() {
    let value1 = JsonParsingError.UnsupportedType(String.self)
    let value2 = JsonParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    assert(value1, doesNotEqual: value2)
  }
  
  @available(*, deprecated)
  func testWrongFieldTypeErrorsWithSameInfoAreEqual() {
    let value1 = JsonParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    let value2 = JsonParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    assert(value1, equals: value2)
  }
  
  @available(*, deprecated)
  func testWrongFieldTypeErrorsWithDifferentFieldsAreNotEqual() {
    let value1 = JsonParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    let value2 = JsonParsingError.WrongFieldType(field: "name", type: String.self, caseType: NSData.self)
    assert(value1, doesNotEqual: value2)
  }
  
  @available(*, deprecated)
  func testWrongFieldTypeErrorsWithDifferentTypesAreNotEqual() {
    let value1 = JsonParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    let value2 = JsonParsingError.WrongFieldType(field: "root", type: NSURL.self, caseType: NSData.self)
    assert(value1, doesNotEqual: value2)
  }
  
  @available(*, deprecated)
  func testWrongFieldTypeErrorsWithDifferentCaseTypesAreNotEqual() {
    let value1 = JsonParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    let value2 = JsonParsingError.WrongFieldType(field: "root", type: String.self, caseType: String.self)
    assert(value1, doesNotEqual: value2)
  }
  
  @available(*, deprecated)
  func testWrongFieldTypeErrorDoesNotEqualUnsupportedTypeError() {
    let value1 = JsonParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    let value2 = JsonParsingError.UnsupportedType(String.self)
    assert(value1, doesNotEqual: value2)
  }
  
  @available(*, deprecated)
  func testMissingFieldErrorsWithSameFieldAreEqual() {
    let value1 = JsonParsingError.MissingField(field: "name")
    let value2 = JsonParsingError.MissingField(field: "name")
    assert(value1, equals: value2)
  }
  
  @available(*, deprecated)
  func testMissingFieldErrorsWithDifferentFieldsAreEqual() {
    let value1 = JsonParsingError.MissingField(field: "name")
    let value2 = JsonParsingError.MissingField(field: "age")
    assert(value1, doesNotEqual: value2)
  }
  
  @available(*, deprecated)
  func testMissingFieldErrorDoesNotEqualWrongFieldTypeError() {
    let value1 = JsonParsingError.MissingField(field: "name")
    let value2 = JsonParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    assert(value1, doesNotEqual: value2)
  }
  
  @available(*, deprecated)
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
  
  @available(*, deprecated)
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
  
  /*
  @available(*, deprecated)
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
  */
  
  @available(*, deprecated)
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
