import TailorTesting
import Tailor

class JsonErrorsTests: TailorTestCase {
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
}