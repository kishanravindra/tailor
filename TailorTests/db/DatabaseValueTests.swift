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
    assert(value.valueDescription, equals: "Hello")
  }
  
  func testDescriptionWithBooleanGetsTrueOrValue() {
    let value1 = DatabaseValue.Boolean(true)
    assert(value1.valueDescription, equals: "true")
    let value2 = DatabaseValue.Boolean(false)
    assert(value2.valueDescription, equals: "false")
  }
  
  func testDescriptionWithDataGetsDataDescription() {
    let data = NSData(bytes: [1,2,3,4])
    let value = DatabaseValue.Data(data)
    assert(value.valueDescription, equals: data.description)
  }
  
  func testDescriptionWithIntegerGetsIntegerAsString() {
    let value = DatabaseValue.Integer(42)
    assert(value.valueDescription, equals: "42")
  }
  
  func testDescriptionWithDoubleGetsDoubleAsString() {
    let value = DatabaseValue.Double(35.5)
    assert(value.valueDescription, equals: "35.5")
  }
  
  func testDescriptionWithTimestampGetsFormattedDate() {
    let timestamp = Timestamp.now()
    let value = DatabaseValue.Timestamp(timestamp)
    assert(value.valueDescription, equals: timestamp.format(TimeFormat.Database))
  }
  
  func testDescriptionWithDateUsesDateDescription() {
    let date = Date(year: 1999, month: 7, day: 12)
    let value = DatabaseValue.Date(date)
    assert(value.valueDescription, equals: date.description)
  }
  
  func testDescriptionWithTimeUsesTimeDescription() {
    let time = Time(hour: 15, minute: 7, second: 11, nanosecond: 0, timeZone: TimeZone(name: "US/Pacific"))
    let value = DatabaseValue.Time(time)
    assert(value.valueDescription, equals: time.description)
  }
  
  func testDescriptionWithNullGetsNull() {
    let value = DatabaseValue.Null
    assert(value.valueDescription, equals: "NULL")
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
  
  func testComparisonWithUnequalTimestampsAreNotEqual() {
    let value1 = DatabaseValue.Timestamp(Timestamp(epochSeconds: 1234512345))
    let value2 = DatabaseValue.Timestamp(Timestamp(epochSeconds: 1234512346))
    XCTAssertNotEqual(value1, value2)
  }
  
  func testComparisonWithEqualTimesAreEqual() {
    let value1 = DatabaseValue.Time(Timestamp(epochSeconds: 1234512345).time)
    let value2 = DatabaseValue.Time(Timestamp(epochSeconds: 1234512345).time)
    assert(value1, equals: value2)
  }
  
  func testComparisonWithUnequalTimesAreNotEqual() {
    let value1 = DatabaseValue.Time(Timestamp(epochSeconds: 1234512345).time)
    let value2 = DatabaseValue.Time(Timestamp(epochSeconds: 1234512346).time)
    XCTAssertNotEqual(value1, value2)
  }
  
  func testComparisonWithEqualDatesAreEqual() {
    let value1 = DatabaseValue.Date(Timestamp(epochSeconds: 1234512345).date)
    let value2 = DatabaseValue.Date(Timestamp(epochSeconds: 1234512345).date)
    assert(value1, equals: value2)
  }
  
  func testComparisonWithUnequalDatesAreNotEqual() {
    let value1 = DatabaseValue.Date(Timestamp(epochSeconds: 1234512345).date)
    let value2 = DatabaseValue.Date(Timestamp(epochSeconds: 2234512345).date)
    XCTAssertNotEqual(value1, value2)
  }
  
  func testComparisonWithNullsIsEqual() {
    assert(DatabaseValue.Null, equals: DatabaseValue.Null)
  }
  
  //MARK: - Conformance In Basic Types
  
  func testStringConvertsToStringDatabaseValue() {
    let value = "test"
    assert(value.databaseValue, equals: DatabaseValue.String(value))
  }
  
  func testBoolConvertsToBoolDatabaseValue() {
    let value = false
    assert(value.databaseValue, equals: DatabaseValue.Boolean(value))
  }
  
  func testDataConvertsToDataDatabaseValue() {
    let value = NSData(bytes: [1,2,3,4])
    assert(value.databaseValue, equals: DatabaseValue.Data(value))
  }
  
  func testIntConvertsToIntDatabaseValue() {
    let value = 25
    assert(value.databaseValue, equals: DatabaseValue.Integer(value))
  }
  
  func testDoubleConvertsToDoubleDatabaseValue() {
    let value = 1.75
    assert(value.databaseValue, equals: DatabaseValue.Double(value))
  }
  
  func testFoundationDateConvertsToTimestampDatabaseValue() {
    let value = NSDate(timeIntervalSince1970: 1234512345)
    assert(value.databaseValue, equals: DatabaseValue.Timestamp(Timestamp(epochSeconds: 1234512345)))
  }
  
  func testTimestampConvertsToTimestampDatabaseValue() {
    let value = Timestamp(epochSeconds: 1234512345)
    assert(value.databaseValue, equals: DatabaseValue.Timestamp(value))
  }
  
  func testTimeConvertsToTimeDatabaseValue() {
    let value = Time(hour: 12, minute: 14, second: 3, nanosecond: 0)
    assert(value.databaseValue, equals: DatabaseValue.Time(value))
  }
  
  func testDateConvertsToDateDatabaseValue() {
    let value = Date.today()
    assert(value.databaseValue, equals: DatabaseValue.Date(value))
  }
  
  func testDatabaseValueConvertsToItself() {
    let value = DatabaseValue.String("test")
    assert(value.databaseValue, equals: value)
  }

  //MARK: - JSON Serialization

  func testNullSerializesToNullJsonValue() {
    assert(DatabaseValue.Null.toJson(), equals: JsonPrimitive.Null)
  }
  
  func testStringSerializesToStringJsonValue() {
    let value = DatabaseValue.String("test")
    assert(value.toJson(), equals: JsonPrimitive.String("test"))
  }
  
  func testBooleanSeralizesToIntegerJsonValue() {
    let value = DatabaseValue.Boolean(true)
    assert(value.toJson(), equals: JsonPrimitive.Number(1))
  }
  
  func testDataSerializesToStringJsonValueWithDataRepresentation() {
    let value = DatabaseValue.Data(NSData(bytes: [1,2,3,4]))
    assert(value.toJson(), equals: JsonPrimitive.String("<01020304>"))
  }
  
  func testIntegerSerializesToIntegerJsonValue() {
    let value = DatabaseValue.Integer(93)
    assert(value.toJson(), equals: JsonPrimitive.Number(93))
  }
  
  func testDoubleSerializesToDoubleJsonValue() {
    let value = DatabaseValue.Double(39.12)
    assert(value.toJson(), equals: JsonPrimitive.Number(39.12))
  }
  
  func testTimestampSerializesToStringJsonValueWithDatabaseFormat() {
    let timestamp = Timestamp.now()
    let value = DatabaseValue.Timestamp(timestamp)
    assert(value.toJson(), equals: JsonPrimitive.String(timestamp.format(TimeFormat.Database)))
  }
  
  func testTimeSerializesToStringJsonValueWithDatabaseFormat() {
    let timestamp = Timestamp.now()
    let value = DatabaseValue.Time(timestamp.time)
    let string = timestamp.format(TimeFormat(.Hour, ":", .Minute, ":", .Seconds))
    assert(value.toJson(), equals: JsonPrimitive.String(string))
  }
  
  func testDateSerializesToStringJsonValueWithDatabaseFormat() {
    let timestamp = Timestamp.now()
    let value = DatabaseValue.Date(timestamp.date)
    assert(value.toJson(), equals: JsonPrimitive.String(timestamp.format(TimeFormat(.Year, "-", .Month, "-", .Day))))
  }
  
  func testInitializationWithJsonNullCreatesNullValue() {
    do {
      let value = try DatabaseValue(json: .Null)
      assert(value, equals: .Null)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testInitializationWithJsonStringCreatesStringValue() {
    do {
      let value = try DatabaseValue(json: .String("test"))
      assert(value, equals: .String("test"))
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testInitializationWithJsonIntegerCreatesIntegerValue() {
    do {
      let value = try DatabaseValue(json: .Number(19))
      assert(value, equals: .Integer(19))
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testInitializationWithJsonDoubleCreatesIntegerValue() {
    do {
      let value = try DatabaseValue(json: .Number(84.9))
      assert(value, equals: .Double(84.9))
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }

  func testInitializationWithJsonArrayThrowsException() {
    do {
      _ = try DatabaseValue(json: .Array([JsonPrimitive.String("test")]))
      assert(false, message: "should throw some kind of exception")
    }
    catch JsonParsingError.UnsupportedType(let type) {
      assert(type == [JsonPrimitive].self)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testInitializationWithJsonDictionaryThrowsException() {
    do {
      _ = try DatabaseValue(json: .Dictionary(["key1": JsonPrimitive.String("test")]))
      assert(false, message: "should throw some kind of exception")
    }
    catch JsonParsingError.UnsupportedType(let type) {
      assert(type == [String:JsonPrimitive].self)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
}