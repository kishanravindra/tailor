import Tailor
import TailorTesting
import XCTest
import Foundation

struct TestDatabaseValue: XCTestCase, TailorTestable {
  func setUp() {
    setUpTestCase()
  }

  @available(*, deprecated)  
  var allTests: [(String, () throws -> Void)] { return [
    ("testStringValueWithStringTypeReturnsString", testStringValueWithStringTypeReturnsString),
    ("testStringValueWithIntegerTypeReturnsNil", testStringValueWithIntegerTypeReturnsNil),
    ("testStringValueWithDescriptionOfStringReturnsString", testStringValueWithDescriptionOfStringReturnsString),
    ("testBoolValueWithBooleanReturnsValue", testBoolValueWithBooleanReturnsValue),
    ("testBoolValueWithZeroReturnsFalse", testBoolValueWithZeroReturnsFalse),
    ("testBoolValueWithOneReturnsTrue", testBoolValueWithOneReturnsTrue),
    ("testBoolValueWithStringReturnsNil", testBoolValueWithStringReturnsNil),
    ("testBoolValueWithDescriptionOfBoolReturnsBool", testBoolValueWithDescriptionOfBoolReturnsBool),
    ("testIntValueWithIntegerReturnsValue", testIntValueWithIntegerReturnsValue),
    ("testIntValueWithStringReturnsNil", testIntValueWithStringReturnsNil),
    ("testIntValueWithDescriptionOfIntReturnsInt", testIntValueWithDescriptionOfIntReturnsInt),
    ("testDataValueWithDataReturnsValue", testDataValueWithDataReturnsValue),
    ("testDataValueWithStringReturnsNil", testDataValueWithStringReturnsNil),
    ("testDoubleValueWithDoubleReturnsValue", testDoubleValueWithDoubleReturnsValue),
    ("testDoubleValueWithDescriptionOfDoubleReturnsDouble", testDoubleValueWithDescriptionOfDoubleReturnsDouble),
    ("testFoundationDateValueWithTimestampReturnsValue", testFoundationDateValueWithTimestampReturnsValue),
    ("testFoundationDateValueWithStringReturnsNil", testFoundationDateValueWithStringReturnsNil),
    ("testTimestampValueWithTimestampReturnsValue", testTimestampValueWithTimestampReturnsValue),
    ("testTimestampValueWithPartialStringReturnsNil", testTimestampValueWithPartialStringReturnsNil),
    ("testTimestampValueWithFullTimestampStringReturnsTimestamp", testTimestampValueWithFullTimestampStringReturnsTimestamp),
    ("testTimestampValueWithDescriptionOfTimestampReturnsTimestamp", testTimestampValueWithDescriptionOfTimestampReturnsTimestamp),
    ("testTimestampValueWithIntegerReturnsNil", testTimestampValueWithIntegerReturnsNil),
    ("testDateValueWithDateReturnsDate", testDateValueWithDateReturnsDate),
    ("testDateValueWithTimestampReturnsDateFromTimestamp", testDateValueWithTimestampReturnsDateFromTimestamp),
    ("testDateValueWithTimeReturnsNil", testDateValueWithTimeReturnsNil),
    ("testDateValueWithValidStringReturnsDate", testDateValueWithValidStringReturnsDate),
    ("testDateValueWithInvalidStringReturnsNil", testDateValueWithInvalidStringReturnsNil),
    ("testDateValueWithDescriptionOfDateReturnsDate", testDateValueWithDescriptionOfDateReturnsDate),
    ("testDateValueWithIntReturnsNil", testDateValueWithIntReturnsNil),
    ("testTimeValueWithTimeReturnsTime", testTimeValueWithTimeReturnsTime),
    ("testTimeValueWithTimestampReturnsTimeFromTimestamp", testTimeValueWithTimestampReturnsTimeFromTimestamp),
    ("testTimeValueWithDateReturnsNil", testTimeValueWithDateReturnsNil),
    ("testTimeValueWithStringReturnsNil", testTimeValueWithStringReturnsNil),
    ("testTimeValueWithDescriptionOfTimeGetsTime", testTimeValueWithDescriptionOfTimeGetsTime),
    ("testDescriptionWithStringGetsString", testDescriptionWithStringGetsString),
    ("testDescriptionWithBooleanGetsTrueOrValue", testDescriptionWithBooleanGetsTrueOrValue),
    ("testDescriptionWithDataGetsDataDescription", testDescriptionWithDataGetsDataDescription),
    ("testDescriptionWithIntegerGetsIntegerAsString", testDescriptionWithIntegerGetsIntegerAsString),
    ("testDescriptionWithDoubleGetsDoubleAsString", testDescriptionWithDoubleGetsDoubleAsString),
    ("testDescriptionWithTimestampGetsFormattedDate", testDescriptionWithTimestampGetsFormattedDate),
    ("testDescriptionWithDateUsesDateDescription", testDescriptionWithDateUsesDateDescription),
    ("testDescriptionWithTimeUsesTimeDescription", testDescriptionWithTimeUsesTimeDescription),
    ("testDescriptionWithNullGetsNull", testDescriptionWithNullGetsNull),
    ("testComparisonWithEqualStringsIsEqual", testComparisonWithEqualStringsIsEqual),
    ("testComparisonWithUnequalStringsIsNotEqual", testComparisonWithUnequalStringsIsNotEqual),
    ("testComparisonWithStringAndIntIsNotEqual", testComparisonWithStringAndIntIsNotEqual),
    ("testComparisonWithEqualIntsIsEqual", testComparisonWithEqualIntsIsEqual),
    ("testComparisonWithUnequalIntsIsNotEqual", testComparisonWithUnequalIntsIsNotEqual),
    ("testComparisonWithEqualBoolsIsEqual", testComparisonWithEqualBoolsIsEqual),
    ("testComparisonWithEqualDoublesIsEqual", testComparisonWithEqualDoublesIsEqual),
    ("testComparisonWithUnequalDoublesIsNotEqual", testComparisonWithUnequalDoublesIsNotEqual),
    ("testComparisonWithEqualDatasAreEqual", testComparisonWithEqualDatasAreEqual),
    ("testComparisonWithUnequalDatasAreNotEqual", testComparisonWithUnequalDatasAreNotEqual),
    ("testComparisonWithEqualTimestampsAreEqual", testComparisonWithEqualTimestampsAreEqual),
    ("testComparisonWithUnequalTimestampsAreNotEqual", testComparisonWithUnequalTimestampsAreNotEqual),
    ("testComparisonWithEqualTimesAreEqual", testComparisonWithEqualTimesAreEqual),
    ("testComparisonWithUnequalTimesAreNotEqual", testComparisonWithUnequalTimesAreNotEqual),
    ("testComparisonWithEqualDatesAreEqual", testComparisonWithEqualDatesAreEqual),
    ("testComparisonWithUnequalDatesAreNotEqual", testComparisonWithUnequalDatesAreNotEqual),
    ("testComparisonWithNullsIsEqual", testComparisonWithNullsIsEqual),
    ("testStringConvertsToStringDatabaseValue", testStringConvertsToStringDatabaseValue),
    ("testBoolConvertsToBoolDatabaseValue", testBoolConvertsToBoolDatabaseValue),
    ("testDataConvertsToDataDatabaseValue", testDataConvertsToDataDatabaseValue),
    ("testIntConvertsToIntDatabaseValue", testIntConvertsToIntDatabaseValue),
    ("testDoubleConvertsToDoubleDatabaseValue", testDoubleConvertsToDoubleDatabaseValue),
    ("testFoundationDateConvertsToTimestampDatabaseValue", testFoundationDateConvertsToTimestampDatabaseValue),
    ("testTimestampConvertsToTimestampDatabaseValue", testTimestampConvertsToTimestampDatabaseValue),
    ("testTimeConvertsToTimeDatabaseValue", testTimeConvertsToTimeDatabaseValue),
    ("testDateConvertsToDateDatabaseValue", testDateConvertsToDateDatabaseValue),
    ("testDatabaseValueConvertsToItself", testDatabaseValueConvertsToItself),
  ]}

  //MARK: - Casting
  
  @available(*, deprecated)
  func testStringValueWithStringTypeReturnsString() {
    let value = DatabaseValue.String("Test")
    
    let string = value.stringValue
    assert(string, equals: "Test")
  }
  
  @available(*, deprecated)
  func testStringValueWithIntegerTypeReturnsNil() {
    let value = DatabaseValue.Integer(5)
    let string = value.stringValue
    XCTAssertNil(string)
  }
  
  @available(*, deprecated)
  func testStringValueWithDescriptionOfStringReturnsString() {
    let value = DatabaseValue.String("Test").valueDescription.databaseValue
    assert(value.stringValue, equals: "Test")
  }
  
  @available(*, deprecated)
  func testBoolValueWithBooleanReturnsValue() {
    let value = DatabaseValue.Boolean(true)
    let boolean = value.boolValue
    assert(boolean, equals: true)
  }
  
  @available(*, deprecated)
  func testBoolValueWithZeroReturnsFalse() {
    let value = DatabaseValue.Integer(0)
    let boolean = value.boolValue
    assert(boolean, equals: false)
  }
  
  @available(*, deprecated)
  func testBoolValueWithOneReturnsTrue() {
    let value = DatabaseValue.Integer(1)
    let boolean = value.boolValue
    assert(boolean, equals: true)
  }
  
  @available(*, deprecated)
  func testBoolValueWithStringReturnsNil() {
    let value = DatabaseValue.String("hi")
    let boolean = value.boolValue
    assert(isNil: boolean)
  }
  
  @available(*, deprecated)
  func testBoolValueWithDescriptionOfBoolReturnsBool() {
    let value = DatabaseValue.Boolean(true).valueDescription.databaseValue
    assert(value.boolValue, equals: true)
  }
  
  @available(*, deprecated)
  func testIntValueWithIntegerReturnsValue() {
    let value = DatabaseValue.Integer(42)
    let integer = value.intValue
    assert(integer, equals: 42)
  }
  
  @available(*, deprecated)
  func testIntValueWithStringReturnsNil() {
    let value = DatabaseValue.String("yo")
    let integer = value.intValue
    XCTAssertNil(integer)
  }
  
  @available(*, deprecated)
  func testIntValueWithDescriptionOfIntReturnsInt() {
    let value = DatabaseValue.Integer(5).valueDescription.databaseValue
    assert(value.intValue, equals: 5)
  }
  
  @available(*, deprecated)
  func testDataValueWithDataReturnsValue() {
    let data1 = NSData(bytes: [1,2,3,4])
    let value = DatabaseValue.Data(data1)
    let data2 = value.dataValue
    assert(data2, equals: data1)
  }
  
  @available(*, deprecated)
  func testDataValueWithStringReturnsNil() {
    let value = DatabaseValue.String("Test")
    let data = value.dataValue
    XCTAssertNil(data)
  }
  
  @available(*, deprecated)
  func testDoubleValueWithDoubleReturnsValue() {
    let value = DatabaseValue.Double(4.5)
    let double = value.doubleValue
    assert(double, equals: 4.5)
  }
  
  @available(*, deprecated)
  func testDoubleValueWithDescriptionOfDoubleReturnsDouble() {
    let value = DatabaseValue.Double(5.4).valueDescription.databaseValue
    assert(value.doubleValue, equals: 5.4)
  }
  
  @available(*, deprecated)
  func testFoundationDateValueWithTimestampReturnsValue() {
    let timestamp = Timestamp.now()
    let value = DatabaseValue.Timestamp(timestamp)
    let date = value.foundationDateValue
    assert(date, equals: timestamp.foundationDateValue)
  }
  
  @available(*, deprecated)
  func testFoundationDateValueWithStringReturnsNil() {
    let value = DatabaseValue.String("2015-04-15")
    let date = value.foundationDateValue
    XCTAssertNil(date)
  }
  
  @available(*, deprecated)
  func testTimestampValueWithTimestampReturnsValue() {
    let timestamp = Timestamp.now()
    let value = DatabaseValue.Timestamp(timestamp)
    let timestamp2 = value.timestampValue
    assert(timestamp2, equals: timestamp)
  }
  
  @available(*, deprecated)
  func testTimestampValueWithPartialStringReturnsNil() {
    let value = DatabaseValue.String("2015-04-15")
    let timestamp = value.timestampValue
    assert(isNil: timestamp)
  }
  
  @available(*, deprecated)
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
  
  @available(*, deprecated)
  func testTimestampValueWithDescriptionOfTimestampReturnsTimestamp() {
    let timestamp = Timestamp.now().change(nanosecond: 0)
    let value = DatabaseValue.Timestamp(timestamp).valueDescription.databaseValue
    let timestamp2 = value.timestampValue
    assert(timestamp2, equals: timestamp)
  }
  
  @available(*, deprecated)
  func testTimestampValueWithIntegerReturnsNil() {
    let value = DatabaseValue.Integer(12345)
    let timestamp = value.timestampValue
    assert(isNil: timestamp)
  }
  
  @available(*, deprecated)
  func testDateValueWithDateReturnsDate() {
    let date = Date(year: 1995, month: 12, day: 1)
    let value = DatabaseValue.Date(date)
    assert(value.dateValue, equals: date)
  }
  
  @available(*, deprecated)
  func testDateValueWithTimestampReturnsDateFromTimestamp() {
    let timestamp = Timestamp(year: 2007, month: 3, day: 25, hour: 12, minute: 7, second: 44, nanosecond: 0)
    let value = DatabaseValue.Timestamp(timestamp)
    assert(value.dateValue, equals: timestamp.date)
  }
  
  @available(*, deprecated)
  func testDateValueWithTimeReturnsNil() {
    let value = DatabaseValue.Time(Time(hour: 11, minute: 30, second: 0, nanosecond: 0))
    assert(isNil: value.dateValue)
  }
  
  @available(*, deprecated)
  func testDateValueWithValidStringReturnsDate() {
    let value = DatabaseValue.String("2015-10-02")
    assert(isNotNil: value.dateValue)
    if value.dateValue != nil {
      assert(value.dateValue?.year, equals: 2015)
      assert(value.dateValue?.month, equals: 10)
      assert(value.dateValue?.day, equals: 2)
    }
  }
  
  @available(*, deprecated)
  func testDateValueWithInvalidStringReturnsNil() {
    let value = DatabaseValue.String("2015-10")
    assert(isNil: value.dateValue)
  }
  
  @available(*, deprecated)
  func testDateValueWithDescriptionOfDateReturnsDate() {
    let date = Date(year: 1995, month: 12, day: 1)
    let value = DatabaseValue.Date(date).valueDescription.databaseValue
    assert(isNotNil: value.dateValue)
    if value.dateValue != nil {
      assert(value.dateValue?.year, equals: 1995)
      assert(value.dateValue?.month, equals: 12)
      assert(value.dateValue?.day, equals: 1)
    }
  }
  
  @available(*, deprecated)
  func testDateValueWithIntReturnsNil() {
    let value = DatabaseValue.Integer(20151002)
    assert(isNil: value.dateValue)
  }
  
  @available(*, deprecated)
  func testTimeValueWithTimeReturnsTime() {
    let time = Time(hour: 11, minute: 30, second: 0, nanosecond: 0)
    let value = DatabaseValue.Time(time)
    assert(value.timeValue, equals: time)
  }
  
  @available(*, deprecated)
  func testTimeValueWithTimestampReturnsTimeFromTimestamp() {
    let timestamp = Timestamp(year: 2007, month: 3, day: 25, hour: 12, minute: 7, second: 44, nanosecond: 0)
    let value = DatabaseValue.Timestamp(timestamp)
    assert(value.timeValue, equals: timestamp.time)
  }
  
  @available(*, deprecated)
  func testTimeValueWithDateReturnsNil() {
    let date = Date(year: 1995, month: 12, day: 1)
    let value = DatabaseValue.Date(date)
    assert(isNil: value.timeValue)
  }
  
  @available(*, deprecated)
  func testTimeValueWithStringReturnsNil() {
    let value = DatabaseValue.String("07:00")
    assert(isNil: value.timeValue)
  }
  
  @available(*, deprecated)
  func testTimeValueWithDescriptionOfTimeGetsTime() {
    let time = Time(hour: 11, minute: 30, second: 0, nanosecond: 0)
    let value = DatabaseValue.Time(time).valueDescription.databaseValue
    assert(value.timeValue, equals: time)
  }
  
  @available(*, deprecated)
  func testDescriptionWithStringGetsString() {
    let value = DatabaseValue.String("Hello")
    assert(value.valueDescription, equals: "Hello")
  }
  
  @available(*, deprecated)
  func testDescriptionWithBooleanGetsTrueOrValue() {
    let value1 = DatabaseValue.Boolean(true)
    assert(value1.valueDescription, equals: "true")
    let value2 = DatabaseValue.Boolean(false)
    assert(value2.valueDescription, equals: "false")
  }
  
  @available(*, deprecated)
  func testDescriptionWithDataGetsDataDescription() {
    let data = NSData(bytes: [1,2,3,4])
    let value = DatabaseValue.Data(data)
    assert(value.valueDescription, equals: data.description)
  }
  
  @available(*, deprecated)
  func testDescriptionWithIntegerGetsIntegerAsString() {
    let value = DatabaseValue.Integer(42)
    assert(value.valueDescription, equals: "42")
  }
  
  @available(*, deprecated)
  func testDescriptionWithDoubleGetsDoubleAsString() {
    let value = DatabaseValue.Double(35.5)
    assert(value.valueDescription, equals: "35.5")
  }
  
  @available(*, deprecated)
  func testDescriptionWithTimestampGetsFormattedDate() {
    let timestamp = Timestamp.now()
    let value = DatabaseValue.Timestamp(timestamp)
    assert(value.valueDescription, equals: timestamp.format(TimeFormat.Database))
  }
  
  @available(*, deprecated)
  func testDescriptionWithDateUsesDateDescription() {
    let date = Date(year: 1999, month: 7, day: 12)
    let value = DatabaseValue.Date(date)
    assert(value.valueDescription, equals: date.description)
  }
  
  @available(*, deprecated)
  func testDescriptionWithTimeUsesTimeDescription() {
    let time = Time(hour: 15, minute: 7, second: 11, nanosecond: 0, timeZone: TimeZone(name: "US/Pacific"))
    let value = DatabaseValue.Time(time)
    assert(value.valueDescription, equals: time.description)
  }
  
  @available(*, deprecated)
  func testDescriptionWithNullGetsNull() {
    let value = DatabaseValue.Null
    assert(value.valueDescription, equals: "NULL")
  }
  
  //MARK: - Comparision
  
  @available(*, deprecated)
  func testComparisonWithEqualStringsIsEqual() {
    let value1 = DatabaseValue.String("hello")
    let value2 = DatabaseValue.String("hello")
    assert(value1, equals: value2)
  }
  
  @available(*, deprecated)
  func testComparisonWithUnequalStringsIsNotEqual() {
    let value1 = DatabaseValue.String("hello")
    let value2 = DatabaseValue.String("goodbye")
    XCTAssertNotEqual(value1, value2)
  }
  
  @available(*, deprecated)
  func testComparisonWithStringAndIntIsNotEqual() {
    let value1 = DatabaseValue.String("42")
    let value2 = DatabaseValue.Integer(42)
    XCTAssertNotEqual(value1, value2)
  }
  
  @available(*, deprecated)
  func testComparisonWithEqualIntsIsEqual() {
    let value1 = DatabaseValue.Integer(25)
    let value2 = DatabaseValue.Integer(25)
    assert(value1, equals: value2)
  }
  
  @available(*, deprecated)
  func testComparisonWithUnequalIntsIsNotEqual() {
    let value1 = DatabaseValue.Integer(25)
    let value2 = DatabaseValue.Integer(26)
    XCTAssertNotEqual(value1, value2)
  }
  
  @available(*, deprecated)
  func testComparisonWithEqualBoolsIsEqual() {
    let value1 = DatabaseValue.Boolean(true)
    let value2 = DatabaseValue.Boolean(true)
    let value3 = DatabaseValue.Boolean(false)
    let value4 = DatabaseValue.Boolean(false)
    assert(value1, equals: value2)
    assert(value3, equals: value4)
    XCTAssertNotEqual(value1, value3)
  }
  
  @available(*, deprecated)
  func testComparisonWithEqualDoublesIsEqual() {
    let value1 = DatabaseValue.Double(1.5)
    let value2 = DatabaseValue.Double(1.5)
    assert(value1, equals: value2)
  }
  
  @available(*, deprecated)
  func testComparisonWithUnequalDoublesIsNotEqual() {
    let value1 = DatabaseValue.Double(1.5)
    let value2 = DatabaseValue.Double(1.6)
    XCTAssertNotEqual(value1, value2)
  }
  
  @available(*, deprecated)
  func testComparisonWithEqualDatasAreEqual() {
    let value1 = DatabaseValue.Data(NSData(bytes: [4,3,2,1]))
    let value2 = DatabaseValue.Data(NSData(bytes: [4,3,2,1]))
    assert(value1, equals: value2)
  }
  
  @available(*, deprecated)
  func testComparisonWithUnequalDatasAreNotEqual() {
    let value1 = DatabaseValue.Data(NSData(bytes: [4,3,2,1]))
    let value2 = DatabaseValue.Data(NSData(bytes: [1,2,3,4]))
    XCTAssertNotEqual(value1, value2)
  }
  
  @available(*, deprecated)
  func testComparisonWithEqualTimestampsAreEqual() {
    let value1 = DatabaseValue.Timestamp(Timestamp(epochSeconds: 1234512345))
    let value2 = DatabaseValue.Timestamp(Timestamp(epochSeconds: 1234512345))
    assert(value1, equals: value2)
  }
  
  @available(*, deprecated)
  func testComparisonWithUnequalTimestampsAreNotEqual() {
    let value1 = DatabaseValue.Timestamp(Timestamp(epochSeconds: 1234512345))
    let value2 = DatabaseValue.Timestamp(Timestamp(epochSeconds: 1234512346))
    XCTAssertNotEqual(value1, value2)
  }
  
  @available(*, deprecated)
  func testComparisonWithEqualTimesAreEqual() {
    let value1 = DatabaseValue.Time(Timestamp(epochSeconds: 1234512345).time)
    let value2 = DatabaseValue.Time(Timestamp(epochSeconds: 1234512345).time)
    assert(value1, equals: value2)
  }
  
  @available(*, deprecated)
  func testComparisonWithUnequalTimesAreNotEqual() {
    let value1 = DatabaseValue.Time(Timestamp(epochSeconds: 1234512345).time)
    let value2 = DatabaseValue.Time(Timestamp(epochSeconds: 1234512346).time)
    XCTAssertNotEqual(value1, value2)
  }
  
  @available(*, deprecated)
  func testComparisonWithEqualDatesAreEqual() {
    let value1 = DatabaseValue.Date(Timestamp(epochSeconds: 1234512345).date)
    let value2 = DatabaseValue.Date(Timestamp(epochSeconds: 1234512345).date)
    assert(value1, equals: value2)
  }
  
  @available(*, deprecated)
  func testComparisonWithUnequalDatesAreNotEqual() {
    let value1 = DatabaseValue.Date(Timestamp(epochSeconds: 1234512345).date)
    let value2 = DatabaseValue.Date(Timestamp(epochSeconds: 2234512345).date)
    XCTAssertNotEqual(value1, value2)
  }
  
  @available(*, deprecated)
  func testComparisonWithNullsIsEqual() {
    assert(DatabaseValue.Null, equals: DatabaseValue.Null)
  }
  
  //MARK: - Conformance In Basic Types
  
  @available(*, deprecated)
  func testStringConvertsToStringDatabaseValue() {
    let value = "test"
    assert(value.databaseValue, equals: DatabaseValue.String(value))
  }
  
  @available(*, deprecated)
  func testBoolConvertsToBoolDatabaseValue() {
    let value = false
    assert(value.databaseValue, equals: DatabaseValue.Boolean(value))
  }
  
  @available(*, deprecated)
  func testDataConvertsToDataDatabaseValue() {
    let value = NSData(bytes: [1,2,3,4])
    assert(value.databaseValue, equals: DatabaseValue.Data(value))
  }
  
  @available(*, deprecated)
  func testIntConvertsToIntDatabaseValue() {
    let value = 25
    assert(value.databaseValue, equals: DatabaseValue.Integer(value))
  }
  
  @available(*, deprecated)
  func testDoubleConvertsToDoubleDatabaseValue() {
    let value = 1.75
    assert(value.databaseValue, equals: DatabaseValue.Double(value))
  }
  
  @available(*, deprecated)
  func testFoundationDateConvertsToTimestampDatabaseValue() {
    let value = NSDate(timeIntervalSince1970: 1234512345)
    assert(value.databaseValue, equals: DatabaseValue.Timestamp(Timestamp(epochSeconds: 1234512345)))
  }
  
  @available(*, deprecated)
  func testTimestampConvertsToTimestampDatabaseValue() {
    let value = Timestamp(epochSeconds: 1234512345)
    assert(value.databaseValue, equals: DatabaseValue.Timestamp(value))
  }
  
  @available(*, deprecated)
  func testTimeConvertsToTimeDatabaseValue() {
    let value = Time(hour: 12, minute: 14, second: 3, nanosecond: 0)
    assert(value.databaseValue, equals: DatabaseValue.Time(value))
  }
  
  @available(*, deprecated)
  func testDateConvertsToDateDatabaseValue() {
    let value = Date.today()
    assert(value.databaseValue, equals: DatabaseValue.Date(value))
  }
  
  @available(*, deprecated)
  func testDatabaseValueConvertsToItself() {
    let value = DatabaseValue.String("test")
    assert(value.databaseValue, equals: value)
  }
}