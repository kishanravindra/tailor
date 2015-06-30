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
  
  func testBoolValueWithZeroReturnsFalse() {
    let value = DatabaseValue.Integer(0)
    let boolean = value.boolValue
    assert(boolean, equals: false)
  }
  
  func testBoolValueWithOneReturnsTrue() {
    let value = DatabaseValue.Integer(1)
    let boolean = value.boolValue
    assert(boolean, equals: true)
  }
  
  func testBoolValueWithStringReturnsNil() {
    let value = DatabaseValue.String("true")
    let boolean = value.boolValue
    assert(isNil: boolean)
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
  
  func testFoundationDateValueWitTimestampReturnsValue() {
    let timestamp = Timestamp.now()
    let value = DatabaseValue.Timestamp(timestamp)
    let date = value.foundationDateValue
    assert(date, equals: timestamp.foundationDateValue)
  }
  
  func testFoundationDateValueWithStringReturnsNil() {
    let value = DatabaseValue.String("2015-04-15")
    let date = value.foundationDateValue
    XCTAssertNil(date)
  }
  
  func testTimestampValueWitTimestampReturnsValue() {
    let timestamp = Timestamp.now()
    let value = DatabaseValue.Timestamp(timestamp)
    let timestamp2 = value.timestampValue
    assert(timestamp2, equals: timestamp)
  }
  
  func testTimestampValueWithPartialStringReturnsNil() {
    let value = DatabaseValue.String("2015-04-15")
    let timestamp = value.timestampValue
    assert(isNil: timestamp)
  }
  
  func testTimestampValueWithFullTimestampStringReturnsTimestamp() {
    let value = DatabaseValue.String("2015-04-15 09:30:15")
    let timestamp = value.timestampValue
    assert(isNotNil: timestamp)
    if timestamp != nil {
      assert(timestamp?.year, equals: 2015)
      assert(timestamp?.month, equals: 4)
      assert(timestamp?.day, equals: 15)
      assert(timestamp?.hour, equals: 9)
      assert(timestamp?.minute, equals: 30)
      assert(timestamp?.second, equals: 15)
    }
  }
  
  func testTimestampValueWithIntegerReturnsNil() {
    let value = DatabaseValue.Integer(12345)
    let timestamp = value.timestampValue
    assert(isNil: timestamp)
  }
  
  func testDateValueWithDateReturnsDate() {
    let date = Date(year: 1995, month: 12, day: 1)
    let value = DatabaseValue.Date(date)
    assert(value.dateValue, equals: date)
  }
  
  func testDateValueWithTimestampReturnsDateFromTimestamp() {
    let timestamp = Timestamp(year: 2007, month: 3, day: 25, hour: 12, minute: 7, second: 44, nanosecond: 0)
    let value = DatabaseValue.Timestamp(timestamp)
    assert(value.dateValue, equals: timestamp.date)
  }
  
  func testDateValueWithTimeReturnsNil() {
    let value = DatabaseValue.Time(Time(hour: 11, minute: 30, second: 0, nanosecond: 0))
    assert(isNil: value.dateValue)
  }
  
  func testDateValueWithValidStringReturnsDate() {
    let value = DatabaseValue.String("2015-10-02")
    assert(isNotNil: value.dateValue)
    if value.dateValue != nil {
      assert(value.dateValue?.year, equals: 2015)
      assert(value.dateValue?.month, equals: 10)
      assert(value.dateValue?.day, equals: 2)
    }
  }
  
  func testDateValueWithInvalidStringReturnsNil() {
    let value = DatabaseValue.String("2015-10")
    assert(isNil: value.dateValue)
  }
  
  func testDateValueWithIntReturnsNil() {
    let value = DatabaseValue.Integer(20151002)
    assert(isNil: value.dateValue)
  }
  
  func testTimeValueWithTimeReturnsTime() {
    let time = Time(hour: 11, minute: 30, second: 0, nanosecond: 0)
    let value = DatabaseValue.Time(time)
    assert(value.timeValue, equals: time)
  }
  
  func testTimeValueWithTimestampReturnsTimeFromTimestamp() {
    let timestamp = Timestamp(year: 2007, month: 3, day: 25, hour: 12, minute: 7, second: 44, nanosecond: 0)
    let value = DatabaseValue.Timestamp(timestamp)
    assert(value.timeValue, equals: timestamp.time)
  }
  
  func testTimeValueWithDateReturnsNil() {
    let date = Date(year: 1995, month: 12, day: 1)
    let value = DatabaseValue.Date(date)
    assert(isNil: value.timeValue)
  }
  
  func testTimeValueWithStringReturnsNil() {
    let value = DatabaseValue.String("07:00")
    assert(isNil: value.timeValue)
  }
  
  func testDescriptionWithStringGetsString() {
    let value = DatabaseValue.String("Hello")
    assert(value.description, equals: "Hello")
  }
  
  func testDescriptionWithBooleanGetsTrueOrValue() {
    let value1 = DatabaseValue.Boolean(true)
    assert(value1.description, equals: "true")
    let value2 = DatabaseValue.Boolean(false)
    assert(value2.description, equals: "false")
  }
  
  func testDescriptionWithDataGetsDataDescription() {
    let data = NSData(bytes: [1,2,3,4])
    let value = DatabaseValue.Data(data)
    assert(value.description, equals: data.description)
  }
  
  func testDescriptionWithIntegerGetsIntegerAsString() {
    let value = DatabaseValue.Integer(42)
    assert(value.description, equals: "42")
  }
  
  func testDescriptionWithDoubleGetsDoubleAsString() {
    let value = DatabaseValue.Double(35.5)
    assert(value.description, equals: "35.5")
  }
  
  func testDescriptionWithTimestampGetsFormattedDate() {
    let timestamp = Timestamp.now()
    let value = DatabaseValue.Timestamp(timestamp)
    assert(value.description, equals: timestamp.format(TimeFormat.Database))
  }
  
  func testDescriptionWithDateUsesDateDescription() {
    let date = Date(year: 1999, month: 7, day: 12)
    let value = DatabaseValue.Date(date)
    assert(value.description, equals: date.description)
  }
  
  func testDescriptionWithTimeUsesTimeDescription() {
    let time = Time(hour: 15, minute: 7, second: 11, nanosecond: 0, timeZone: TimeZone(name: "US/Pacific"))
    let value = DatabaseValue.Time(time)
    assert(value.description, equals: time.description)
  }
  
  func testDescriptionWithNullGetsNull() {
    let value = DatabaseValue.Null
    assert(value.description, equals: "NULL")
  }
  
  //MARK: - Comparision
  
  func testComparisonWithEqualStringsIsEqual() {
    let value1 = DatabaseValue.String("hello")
    let value2 = DatabaseValue.String("hello")
    assert(value1, equals: value2)
  }
  
  func testComparisonWithUnequalStringsIsNotEqual() {
    let value1 = DatabaseValue.String("hello")
    let value2 = DatabaseValue.String("goodbye")
    XCTAssertNotEqual(value1, value2)
  }
  
  func testComparisonWithStringAndIntIsNotEqual() {
    let value1 = DatabaseValue.String("42")
    let value2 = DatabaseValue.Integer(42)
    XCTAssertNotEqual(value1, value2)
  }
  
  func testComparisonWithEqualIntsIsEqual() {
    let value1 = DatabaseValue.Integer(25)
    let value2 = DatabaseValue.Integer(25)
    assert(value1, equals: value2)
  }
  
  func testComparisonWithUnequalIntsIsNotEqual() {
    let value1 = DatabaseValue.Integer(25)
    let value2 = DatabaseValue.Integer(26)
    XCTAssertNotEqual(value1, value2)
  }
  
  func testComparisonWithEqualBoolsIsEqual() {
    let value1 = DatabaseValue.Boolean(true)
    let value2 = DatabaseValue.Boolean(true)
    let value3 = DatabaseValue.Boolean(false)
    let value4 = DatabaseValue.Boolean(false)
    assert(value1, equals: value2)
    assert(value3, equals: value4)
    XCTAssertNotEqual(value1, value3)
  }
  
  func testComparisonWithEqualDoublesIsEqual() {
    let value1 = DatabaseValue.Double(1.5)
    let value2 = DatabaseValue.Double(1.5)
    assert(value1, equals: value2)
  }
  
  func testComparisonWithUnequalDoublesIsNotEqual() {
    let value1 = DatabaseValue.Double(1.5)
    let value2 = DatabaseValue.Double(1.6)
    XCTAssertNotEqual(value1, value2)
  }
  
  func testComparisonWithEqualDatasAreEqual() {
    let value1 = DatabaseValue.Data(NSData(bytes: [4,3,2,1]))
    let value2 = DatabaseValue.Data(NSData(bytes: [4,3,2,1]))
    assert(value1, equals: value2)
  }
  
  func testComparisonWithUnequalDatasAreNotEqual() {
    let value1 = DatabaseValue.Data(NSData(bytes: [4,3,2,1]))
    let value2 = DatabaseValue.Data(NSData(bytes: [1,2,3,4]))
    XCTAssertNotEqual(value1, value2)
  }
  
  func testComparisonWithEqualTimestampsAreEqual() {
    let value1 = DatabaseValue.Timestamp(Timestamp(epochSeconds: 1234512345))
    let value2 = DatabaseValue.Timestamp(Timestamp(epochSeconds: 1234512345))
    assert(value1, equals: value2)
  }
  
  func testComparisonWithUnequalDatesAreNotEqual() {
    let value1 = DatabaseValue.Timestamp(Timestamp(epochSeconds: 1234512345))
    let value2 = DatabaseValue.Timestamp(Timestamp(epochSeconds: 1234512346))
    XCTAssertNotEqual(value1, value2)
  }
  
  func testComparisonWithNullsIsEqual() {
    assert(DatabaseValue.Null, equals: DatabaseValue.Null)
  }
}