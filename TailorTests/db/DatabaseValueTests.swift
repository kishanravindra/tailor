import Tailor
import TailorTesting
import XCTest

class DatabaseValueTests: TailorTestCase {
  //MARK: - Casting
  
  func testStringValueWithStringTypeReturnsString() {
    let value = DatabaseValue.String("Test")
    
    let string = value.stringValue
    assert(string, equals: "Test")
  }
  
  func testStringValueWithIntegerTypeReturnsNil() {
    let value = DatabaseValue.Integer(5)
    let string = value.stringValue
    XCTAssertNil(string)
  }
  
  func testBoolValueWithBooleanReturnsValue() {
    let value = DatabaseValue.Boolean(true)
    let boolean = value.boolValue
    assert(boolean, equals: true)
  }
  
  func testBoolValueWithIntegerTypeReturnsNil() {
    let value = DatabaseValue.Integer(0)
    let boolean = value.boolValue
    XCTAssertNil(boolean)
  }
  
  func testIntValueWithIntegerReturnsValue() {
    let value = DatabaseValue.Integer(42)
    let integer = value.intValue
    assert(integer, equals: 42)
  }
  
  func testIntValueWithStringReturnsNil() {
    let value = DatabaseValue.String("17")
    let integer = value.intValue
    XCTAssertNil(integer)
  }
  
  func testDataValueWithDataReturnsValue() {
    let data1 = NSData(bytes: [1,2,3,4])
    let value = DatabaseValue.Data(data1)
    let data2 = value.dataValue
    assert(data2, equals: data1)
  }
  
  func testDataValueWithStringReturnsNil() {
    let value = DatabaseValue.String("Test")
    let data = value.dataValue
    XCTAssertNil(data)
  }
  
  func testDoubleValueWithDoubleReturnsValue() {
    let value = DatabaseValue.Double(4.5)
    let double = value.doubleValue
    assert(double, equals: 4.5)
  }
  
  func testDoubleValueWithIntReturnsNil() {
    let value = DatabaseValue.Integer(4)
    let double = value.doubleValue
    XCTAssertNil(double)
  }
  
  func testDateValueWithDateReturnsValue() {
    let date1 = NSDate()
    let value = DatabaseValue.Date(date1)
    let date2 = value.dateValue
    assert(date2, equals: date1)
  }
  
  func testDateValueWithStringReturnsNil() {
    let value = DatabaseValue.String("2015-04-15")
    let date = value.dateValue
    XCTAssertNil(date)
  }
}