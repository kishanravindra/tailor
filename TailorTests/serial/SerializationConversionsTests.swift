import Tailor
import TailorTesting
import XCTest

class SerializationConversionsTests: XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
  func testStringCanInitializeFromSerializableValue() {
    let primitive = SerializableValue.String("Hello")
    do {
      let string = try String(deserialize: primitive)
      assert(string, equals: "Hello")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testStringInitializedWithSerializedArrayThrowsException() {
    let primitive = SerializableValue.Array([
      .String("A"),
      .String("B")
      ])
    do {
      _ = try String(deserialize: primitive)
      assert(false, message: "should throw an exception")
    }
    catch SerializationParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "root")
      assert(type == String.self)
      assert(caseType == [SerializableValue].self)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testStringConvertsToSerializableValue() {
    let string = "Test"
    assert(string.serialize, equals: .String("Test"))
  }
  
  func testIntegerCanInitializeFromSerializableValue() {
    let primitive = SerializableValue.Integer(5)
    do {
      let int = try Int(deserialize: primitive)
      assert(int, equals: 5)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testIntegerCanInitializeFromSerializedDouble() {
    let primitive = SerializableValue.Double(5.5)
    do {
      let int = try Int(deserialize: primitive)
      assert(int, equals: 5)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testIntegerCanInitializeFromSerializedStringWithInteger() {
    let primitive = SerializableValue.String("45")
    do {
      let int = try Int(deserialize: primitive)
      assert(int, equals: 45)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testIntegerInitializedWithBadStringThrowsException() {
    let primitive = SerializableValue.String("bad")
    do {
      _ = try Int(deserialize: primitive)
      assert(false, message: "should throw an exception")
    }
    catch SerializationParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "root")
      assert(type == Int.self)
      assert(caseType == String.self)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testIntegerInitializedWithSerializedArrayThrowsException() {
    let primitive = SerializableValue.Array([
      .String("A"),
      .String("B")
      ])
    do {
      _ = try Int(deserialize: primitive)
      assert(false, message: "should throw an exception")
    }
    catch SerializationParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "root")
      assert(type == Int.self)
      assert(caseType == [SerializableValue].self)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testIntSerializesAsSerializableValue() {
    let int = 19
    assert(int.serialize, equals: .Integer(19))
  }
  
  func testDoubleCanInitializeFromSerializableValue() {
    let primitive = SerializableValue.Double(4.1)
    do {
      let double = try Double(deserialize: primitive)
      assert(double, equals: 4.1)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDoubleCanInitializeFromSerializedInteger() {
    let primitive = SerializableValue.Integer(18)
    do {
      let double = try Double(deserialize: primitive)
      assert(double, equals: 18)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDoubleCanInitializeFromSerializedStringWithDouble() {
    let primitive = SerializableValue.String("12.3")
    do {
      let double = try Double(deserialize: primitive)
      assert(double, equals: 12.3)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDoubleInitializedWithBadStringThrowsException() {
    let primitive = SerializableValue.String("bad")
    do {
      _ = try Double(deserialize: primitive)
      assert(false, message: "should throw an exception")
    }
    catch SerializationParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "root")
      assert(type == Double.self)
      assert(caseType == String.self)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDoubleInitializedWithSerializedArrayThrowsException() {
    let primitive = SerializableValue.Array([
      .String("A"),
      .String("B")
      ])
    do {
      _ = try Double(deserialize: primitive)
      assert(false, message: "should throw an exception")
    }
    catch SerializationParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "root")
      assert(type == Double.self)
      assert(caseType == [SerializableValue].self)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDoubleSerializesAsSerializableValue() {
    let double = 1.1
    assert(double.serialize, equals: .Double(1.1))
  }
  
  func testUnsignedIntegerCanInitializeFromInteger() {
    let primitive = SerializableValue.Integer(45)
    do {
      let int = try UInt(deserialize: primitive)
      assert(int, equals: 45)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testUnsignedIntegerInitializedWithBadStringThrowsException() {
    let primitive = SerializableValue.String("bad")
    do {
      _ = try Int(deserialize: primitive)
      assert(false, message: "should throw an exception")
    }
    catch SerializationParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "root")
      assert(type == Int.self)
      assert(caseType == String.self)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testUnsignedIntegerSerializesAsIntegerValue() {
    let value: UInt = 10
    assert(value.serialize, equals: .Integer(10))
  }
  
  func testBooleanCanInitializeFromSerializableValue() {
    let primitive1 = SerializableValue.Boolean(false)
    let primitive2 = SerializableValue.Boolean(true)
    do {
      let flag1 = try Bool(deserialize: primitive1)
      let flag2 = try Bool(deserialize: primitive2)
      assert(!flag1)
      assert(flag2)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testBooleanInitializedWithIntegerComparesIntegerToOne() {
    let value1 = SerializableValue.Integer(0)
    let value2 = SerializableValue.Integer(1)
    let value3 = SerializableValue.Integer(3)
    do {
      let flag1 = try Bool(deserialize: value1)
      let flag2 = try Bool(deserialize: value2)
      let flag3 = try Bool(deserialize: value3)
      assert(!flag1)
      assert(flag2)
      assert(!flag3)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testBooleanInitializedWithStringComparesStringToTrue() {
    let value1 = SerializableValue.String("true")
    let value2 = SerializableValue.String("false")
    do {
      let flag1 = try Bool(deserialize: value1)
      let flag2 = try Bool(deserialize: value2)
      assert(flag1)
      assert(!flag2)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testBooleanInitializedWithBadStringThrowsException() {
    let value = SerializableValue.String("bad')")
    do {
      _ = try Bool(deserialize: value)
      assert(false, message: "should throw an exception")
    }
    catch SerializationParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "root")
      assert(type == Bool.self)
      assert(caseType == String.self)
    }
    catch {
      assert(false, message: "threw unexpected exception")

    }
  }
  
  func testBooleanInitializedWithSerializedArrayThrowsException() {
    let primitive = SerializableValue.Array([
      .String("A"),
      .String("B")
      ])
    do {
      _ = try Bool(deserialize: primitive)
      assert(false, message: "should throw an exception")
    }
    catch SerializationParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "root")
      assert(type == Bool.self)
      assert(caseType == [SerializableValue].self)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testBooleanSerializesAsSerializableValue() {
    assert(true.serialize, equals: .Boolean(true))
    assert(false.serialize, equals: .Boolean(false))
  }
  
  func testTimestampInitializedWithTimestampReturnsValue() {
    let timestamp = Timestamp.now()
    let value = SerializableValue.Timestamp(timestamp)
    do {
      let timestamp2 = try Timestamp(deserialize: value)
      assert(timestamp2, equals: timestamp)
    }
    catch let e {
      assert(false, message: "threw unexpected exception: \(e)")
    }
  }
  
  func testTimestampInitializedWithPartialStringThrowsException() {
    let value = SerializableValue.String("2015-04-15")
    do {
      _ = try Timestamp(deserialize: value)
      assert(false, message: "should throw exception")
    }
    catch let SerializationParsingError.WrongFieldType(field, type, caseType) {
      assert(field, equals: "root")
      assert(type == Timestamp.self)
      assert(caseType == String.self)
    }
    catch let e {
      assert(false, message: "threw unexpected exception: \(e)")
    }
  }
  
  func testTimestampInitializedWithFullTimestampStringReturnsTimestamp() {
    let value = SerializableValue.String("2015-04-15 09:30:15")
    
    do {
      let timestamp = try Timestamp(deserialize: value)
      assert(timestamp.year, equals: 2015)
      assert(timestamp.month, equals: 4)
      assert(timestamp.day, equals: 15)
      assert(timestamp.hour, equals: 9)
      assert(timestamp.minute, equals: 30)
      assert(timestamp.second, equals: 15)
    }
    catch let e {
      assert(false, message: "threw unexpected exception: \(e)")
    }
  }
  
  func testTimestampInitializedWithDescriptionOfTimestampReturnsTimestamp() {
    let timestamp = Timestamp.now().change(nanosecond: 0)
    let value = SerializableValue.Timestamp(timestamp).valueDescription.serialize
    
    do {
      let timestamp2 = try Timestamp(deserialize: value)
      assert(timestamp2, equals: timestamp)
    }
    catch let e {
      assert(false, message: "threw unexpected exception: \(e)")
    }
  }
  
  func testTimestampInitializedWithIntegerThrowsException() {
    let value = SerializableValue.Integer(12345)
    do {
      _ = try Timestamp(deserialize: value)
      assert(false, message: "should throw exception")
    }
    catch let SerializationParsingError.WrongFieldType(field, type, caseType) {
      assert(field, equals: "root")
      assert(type == Timestamp.self)
      assert(caseType == Int.self)
    }
    catch let e {
      assert(false, message: "threw unexpected exception: \(e)")
    }
  }
  
  func testTimestampSerializesAsTimestamp() {
    let timestamp = Timestamp.now()
    let value = timestamp.serialize
    assert(value, equals: SerializableValue.Timestamp(timestamp))
  }
  
  func testFoundationDateSerializesAsTimestamp() {
    let timestamp = Timestamp.now()
    let date = NSDate(timeIntervalSince1970: timestamp.epochSeconds)
    let value = date.serialize
    assert(value, equals: SerializableValue.Timestamp(timestamp))
  }
  
  func testDateInitializedWithDateReturnsDate() {
    let date = Date(year: 1995, month: 12, day: 1)
    let value = SerializableValue.Date(date)
    do {
      let date2 = try Date(deserialize: value)
      assert(date2, equals: date)
    }
    catch let e {
      assert(false, message: "threw unexpected exception: \(e)")
    }
  }
  
  func testDateInitializedWithTimestampReturnsDateFromTimestamp() {
    let timestamp = Timestamp(year: 2007, month: 3, day: 25, hour: 12, minute: 7, second: 44, nanosecond: 0)
    let value = SerializableValue.Timestamp(timestamp)
    
    do {
      let date2 = try Date(deserialize: value)
      assert(date2, equals: timestamp.date)
    }
    catch let e {
      assert(false, message: "threw unexpected exception: \(e)")
    }
  }
  
  func testDateInitializedWithTimeThrowsException() {
    let value = SerializableValue.Time(Time(hour: 11, minute: 30, second: 0, nanosecond: 0))
    
    do {
      _ = try Date(deserialize: value)
      assert(false, message: "should throw exception")
    }
    catch let SerializationParsingError.WrongFieldType(field, type, caseType) {
      assert(field, equals: "root")
      assert(type == Date.self)
      assert(caseType == Time.self)
    }
    catch let e {
      assert(false, message: "threw unexpected exception: \(e)")
    }
  }
  
  func testDateInitializedWithValidStringReturnsDate() {
    let value = SerializableValue.String("2015-10-02")
    
    do {
      let date = try Date(deserialize: value)
      assert(date.year, equals: 2015)
      assert(date.month, equals: 10)
      assert(date.day, equals: 2)
    }
    catch let e {
      assert(false, message: "threw unexpected exception: \(e)")
    }
  }
  
  func testDateInitializedWithInvalidStringReturnsNil() {
    let value = SerializableValue.String("2015-10")
    
    do {
      _ = try Date(deserialize: value)
      assert(false, message: "should throw exception")
    }
    catch let SerializationParsingError.WrongFieldType(field, type, caseType) {
      assert(field, equals: "root")
      assert(type == Date.self)
      assert(caseType == String.self)
    }
    catch let e {
      assert(false, message: "threw unexpected exception: \(e)")
    }
  }
  
  func testDateInitializedWithDescriptionOfDateReturnsDate() {
    let date = Date(year: 1995, month: 12, day: 1)
    let value = SerializableValue.Date(date).valueDescription.serialize
    
    do {
      let date2 = try Date(deserialize: value)
      assert(date2, equals: date)
    }
    catch let e {
      assert(false, message: "threw unexpected exception: \(e)")
    }
  }
  
  func testDateInitializedWithIntReturnsNil() {
    let value = SerializableValue.Integer(20151002)
    
    do {
      _ = try Date(deserialize: value)
      assert(false, message: "should throw exception")
    }
    catch let SerializationParsingError.WrongFieldType(field, type, caseType) {
      assert(field, equals: "root")
      assert(type == Date.self)
      assert(caseType == Int.self)
    }
    catch let e {
      assert(false, message: "threw unexpected exception: \(e)")
    }
  }
  
  func testDateSerializesAsDateValue() {
    let date = Date(year: 1995, month: 12, day: 1)
    let value = date.serialize
    assert(value, equals: SerializableValue.Date(date))
  }
  
  func testTimeInitializedWithTimeReturnsTime() {
    let time = Time(hour: 11, minute: 30, second: 0, nanosecond: 0)
    let value = SerializableValue.Time(time)
    
    do {
      let time2 = try Time(deserialize: value)
      assert(time, equals: time2)
    }
    catch let e {
      assert(false, message: "threw unexpected exception: \(e)")
    }
  }
  
  func testTimeInitializedWithTimestampReturnsTimeFromTimestamp() {
    let timestamp = Timestamp(year: 2007, month: 3, day: 25, hour: 12, minute: 7, second: 44, nanosecond: 0)
    let value = SerializableValue.Timestamp(timestamp)
    
    do {
      let time = try Time(deserialize: value)
      assert(time, equals: timestamp.time)
    }
    catch let e {
      assert(false, message: "threw unexpected exception: \(e)")
    }
  }
  
  func testTimeInitializedWithDateThrowsException() {
    let date = Date(year: 1995, month: 12, day: 1)
    let value = SerializableValue.Date(date)
    
    do {
      _ = try Time(deserialize: value)
      assert(false, message: "should throw exception")
    }
    catch let SerializationParsingError.WrongFieldType(field, type, caseType) {
      assert(field, equals: "root")
      assert(type == Time.self)
      assert(caseType == Date.self)
    }
    catch let e {
      assert(false, message: "threw unexpected exception: \(e)")
    }
  }
  
  func testTimeInitializedWithStringThrowsExceptions() {
    let value = SerializableValue.String("07:00")
    
    do {
      _ = try Time(deserialize: value)
      assert(false, message: "should throw exception")
    }
    catch let SerializationParsingError.WrongFieldType(field, type, caseType) {
      assert(field, equals: "root")
      assert(type == Time.self)
      assert(caseType == String.self)
    }
    catch let e {
      assert(false, message: "threw unexpected exception: \(e)")
    }
  }
  
  func testTimeInitializedWithDescriptionOfTimeGetsTime() {
    let time = Time(hour: 11, minute: 30, second: 0, nanosecond: 0)
    let value = SerializableValue.Time(time).valueDescription.serialize
    
    do {
      let time2 = try Time(deserialize: value)
      assert(time2, equals: time)
    }
    catch let e {
      assert(false, message: "threw unexpected exception: \(e)")
    }
  }
  
  func testTimeSerializesAsTime() {
    let time = Time(hour: 11, minute: 30, second: 0, nanosecond: 0)
    assert(time.serialize, equals: SerializableValue.Time(time))
  }
  
  func testSerializableValueSerializesAsItself() {
    let primitive = SerializableValue.Integer(19)
    assert(primitive.serialize, equals: primitive)
  }
  
  func testSerializableValueInitializesWithSerializableValueByCopying() {
    let primitive = SerializableValue.Integer(19)
    let primitive2 = SerializableValue(deserialize: primitive)
    assert(primitive, equals: primitive2)
  }
  
  func testArrayOfConvertiblesSerializesAsArrayOfPrimitives() {
    let array = ["A", "B", "C"]
    let converted = array.serialize
    assert(converted, equals: .Array([
      .String("A"),
      .String("B"),
      .String("C")
      ]))
  }
  
  func testDictionaryOfConvertiblesSerializesWithDictionaryValues() {
    let value = ["key1": "A", "key2": "B"]
    let primitive = value.serialize
    assert(primitive, equals: SerializableValue.Dictionary([
      "key1": SerializableValue.String("A"),
      "key2": SerializableValue.String("B")
      ])
    )
  }
}
