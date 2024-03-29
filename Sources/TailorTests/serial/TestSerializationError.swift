import TailorTesting
import Tailor
import XCTest
import Foundation

struct TestSerializationError: XCTestCase, TailorTestable {
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
  
  func testUnsupportedTypeErrorsWithSameTypeAreEqual() {
    let value1 = SerializationParsingError.UnsupportedType(String.self)
    let value2 = SerializationParsingError.UnsupportedType(String.self)
    assert(value1, equals: value2)
  }
  
  func testUnsupportedTypeErrorsWithDifferentTypesAreEqual() {
    let value1 = SerializationParsingError.UnsupportedType(String.self)
    let value2 = SerializationParsingError.UnsupportedType(NSData.self)
    assert(value1, doesNotEqual: value2)
  }
  
  func testUnsupportedTypeErrorDoesNotEqualWrongFieldTypeError() {
    let value1 = SerializationParsingError.UnsupportedType(String.self)
    let value2 = SerializationParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    assert(value1, doesNotEqual: value2)
  }
  
  func testWrongFieldTypeErrorsWithSameInfoAreEqual() {
    let value1 = SerializationParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    let value2 = SerializationParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    assert(value1, equals: value2)
  }
  
  func testWrongFieldTypeErrorsWithDifferentFieldsAreNotEqual() {
    let value1 = SerializationParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    let value2 = SerializationParsingError.WrongFieldType(field: "name", type: String.self, caseType: NSData.self)
    assert(value1, doesNotEqual: value2)
  }
  
  func testWrongFieldTypeErrorsWithDifferentTypesAreNotEqual() {
    let value1 = SerializationParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    let value2 = SerializationParsingError.WrongFieldType(field: "root", type: NSURL.self, caseType: NSData.self)
    assert(value1, doesNotEqual: value2)
  }
  
  func testWrongFieldTypeErrorsWithDifferentCaseTypesAreNotEqual() {
    let value1 = SerializationParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    let value2 = SerializationParsingError.WrongFieldType(field: "root", type: String.self, caseType: String.self)
    assert(value1, doesNotEqual: value2)
  }
  
  func testWrongFieldTypeErrorDoesNotEqualUnsupportedTypeError() {
    let value1 = SerializationParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    let value2 = SerializationParsingError.UnsupportedType(String.self)
    assert(value1, doesNotEqual: value2)
  }
  
  func testMissingFieldErrorsWithSameFieldAreEqual() {
    let value1 = SerializationParsingError.MissingField(field: "name")
    let value2 = SerializationParsingError.MissingField(field: "name")
    assert(value1, equals: value2)
  }
  
  func testMissingFieldErrorsWithDifferentFieldsAreEqual() {
    let value1 = SerializationParsingError.MissingField(field: "name")
    let value2 = SerializationParsingError.MissingField(field: "age")
    assert(value1, doesNotEqual: value2)
  }
  
  func testMissingFieldErrorDoesNotEqualWrongFieldTypeError() {
    let value1 = SerializationParsingError.MissingField(field: "name")
    let value2 = SerializationParsingError.WrongFieldType(field: "root", type: String.self, caseType: NSData.self)
    assert(value1, doesNotEqual: value2)
  }
  
  func testParsingErrorWithFieldPrefixWithWrongFieldTypeErrorAddsPrefixToField() {
    do {
      try SerializationParsingError.withFieldPrefix("test") {
        Void->Void in
        throw SerializationParsingError.WrongFieldType(field: "value", type: String.self, caseType: NSNumber.self)
      }
      assert(false, message: "should throw some kind of exception")
    }
    catch SerializationParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
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
      try SerializationParsingError.withFieldPrefix("test") {
        Void->Void in
        throw SerializationParsingError.MissingField(field: "name")
      }
      assert(false, message: "should throw some kind of exception")
    }
    catch SerializationParsingError.MissingField(field: let field) {
      assert(field, equals: "test.name")
    }
    catch  {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  /*
  func testParsingErrorWithFieldPrefixWithUnsupportedTypeErrorRethrowsError() {
    do {
      try SerializationParsingError.withFieldPrefix("test") {
        Void->Void in
        throw SerializationParsingError.UnsupportedType(NSColor.self)
      }
      assert(false, message: "should throw some kind of exception")
    }
    catch SerializationParsingError.UnsupportedType(let type) {
      assert(type == NSColor.self)
    }
    catch  {
      assert(false, message: "threw unexpected exception")
    }
  }
  */
  
  func testParsingErrorWithFieldPrefixWithNoErrorReturnsValue() {
    do {
      let value = try SerializationParsingError.withFieldPrefix("test") { "Hello" }
      assert(value, equals: "Hello")
    }
    catch  {
      assert(false, message: "threw unexpected exception")
    }
  }
}
