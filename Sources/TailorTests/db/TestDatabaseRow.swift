import XCTest
import Tailor
import TailorTesting
import TailorSqlite
import Foundation

struct TestDatabaseRow: XCTestCase, TailorTestable {
  @available(*, deprecated)
  var allTests: [(String, () throws -> Void)] { return [
    ("testRowInitializationWithConvertibleValuesWrapsValues", testRowInitializationWithConvertibleValuesWrapsValues),
    ("testRowInitializationWithErrorSetsError", testRowInitializationWithErrorSetsError),
    ("testReadWithStringValueCanReadStringValue", testReadWithStringValueCanReadStringValue),
    ("testReadWithStringValueThrowsExceptionOnIntegerValue", testReadWithStringValueThrowsExceptionOnIntegerValue),
    ("testReadWithStringValueThrowsExceptionOnTimestampValue", testReadWithStringValueThrowsExceptionOnTimestampValue),
    ("testReadWithStringValueThrowsExceptionForMissingValue", testReadWithStringValueThrowsExceptionForMissingValue),
    ("testReadWithIntegerValueCanReadIntegerValue", testReadWithIntegerValueCanReadIntegerValue),
    ("testReadWithIntegerValueThrowsExceptionForStringValue", testReadWithIntegerValueThrowsExceptionForStringValue),
    ("testReadWithUnsignedIntegerValueCanReadIntegerValue", testReadWithUnsignedIntegerValueCanReadIntegerValue),
    ("testReadWithUnsignedIntegerValueThrowsExceptionForStringValue", testReadWithUnsignedIntegerValueThrowsExceptionForStringValue),
    ("testReadWithTimestampValueCanReadTimestampValue", testReadWithTimestampValueCanReadTimestampValue),
    ("testReadWithTimestampValueCanReadStringWithValidTimestamp", testReadWithTimestampValueCanReadStringWithValidTimestamp),
    ("testReadWithTimestampValueThrowsExceptionForIntegerValue", testReadWithTimestampValueThrowsExceptionForIntegerValue),
    ("testReadWithTimestampValueThrowsExceptionForStringValue", testReadWithTimestampValueThrowsExceptionForStringValue),
    ("testReadWithDateValueCanReadDateValue", testReadWithDateValueCanReadDateValue),
    ("testReadWithDateValueThrowsExceptionForIntegerValue", testReadWithDateValueThrowsExceptionForIntegerValue),
    ("testReadWithTimeValueCanReadTimeValue", testReadWithTimeValueCanReadTimeValue),
    ("testReadWithTimeValueThrowsExceptionForIntegerValue", testReadWithTimeValueThrowsExceptionForIntegerValue),
    ("testReadWithBoolValueCanReadBoolValue", testReadWithBoolValueCanReadBoolValue),
    ("testReadWithBoolValueCanReadIntegerValue", testReadWithBoolValueCanReadIntegerValue),
    ("testReadWithBooleanValueThrowsExceptionForStringValue", testReadWithBooleanValueThrowsExceptionForStringValue),
    ("testReadWithDataValueCanReadDataValue", testReadWithDataValueCanReadDataValue),
    ("testReadWithDataValueThrowsExceptionForIntegerValue", testReadWithDataValueThrowsExceptionForIntegerValue),
    ("testReadWithDoubleValueCanReadDoubleValue", testReadWithDoubleValueCanReadDoubleValue),
    ("testReadWithOptionalValueCanReadRealValue", testReadWithOptionalValueCanReadRealValue),
    ("testReadWithOptionalValueReturnsNilForMissingValue", testReadWithOptionalValueReturnsNilForMissingValue),
    ("testReadWithOptionalValueReturnsNilForNullValue", testReadWithOptionalValueReturnsNilForNullValue),
    ("testReadWithOptionalValueReturnsNilForEmptyStringValue", testReadWithOptionalValueReturnsNilForEmptyStringValue),
    ("testReadWithOptionalValueThrowsExceptionForWrongType", testReadWithOptionalValueThrowsExceptionForWrongType),
    ("testReadWithUnsupportedTypeThrowsException", testReadWithUnsupportedTypeThrowsException),
    ("testReadWithPersistableTypeWithOptionalWithMissingIdIsNil", testReadWithPersistableTypeWithOptionalWithMissingIdIsNil),
    ("testReadWithPersistableTypeWithOptionalWithValidIdReturnsRecord", testReadWithPersistableTypeWithOptionalWithValidIdReturnsRecord),
    ("testReadWithPersistableTypeWithOptionalWithInvalidIdReturnsNil", testReadWithPersistableTypeWithOptionalWithInvalidIdReturnsNil),
    ("testReadWithPersistableTypeWithOptionalWithStringIdThrowsException", testReadWithPersistableTypeWithOptionalWithStringIdThrowsException),
    ("testReadWithPersistableTypeWithValidIdReturnsRecord", testReadWithPersistableTypeWithValidIdReturnsRecord),
    ("testReadWithPersistableTypeWithInvalidIdThrowsException", testReadWithPersistableTypeWithInvalidIdThrowsException),
    ("testReadWithPersistableTypeWithStringIdThrowsException", testReadWithPersistableTypeWithStringIdThrowsException),
    ("testReadEnumWithIdWithOptionalWithValidIdGivesValue", testReadEnumWithIdWithOptionalWithValidIdGivesValue),
    ("testReadEnumWithIdWithOptionalWithBadIdReturnsNil", testReadEnumWithIdWithOptionalWithBadIdReturnsNil),
    ("testReadEnumWithIdWithOptionalWithNoValueReturnsNil", testReadEnumWithIdWithOptionalWithNoValueReturnsNil),
    ("testReadEnumWithIdWithOptionalWithStringValueThrowsException", testReadEnumWithIdWithOptionalWithStringValueThrowsException),
    ("testReadEnumWithIdWithValidValueGivesValue", testReadEnumWithIdWithValidValueGivesValue),
    ("testReadEnumWithIdWithBadIdThrowsException", testReadEnumWithIdWithBadIdThrowsException),
    ("testReadEnumWithIdWithStringValueThrowsException", testReadEnumWithIdWithStringValueThrowsException),
    ("testReadEnumWithNameWithOptionalWithValidValueGivesValue", testReadEnumWithNameWithOptionalWithValidValueGivesValue),
    ("testReadEnumWithNameWithOptionalWithBadNameReturnsNil", testReadEnumWithNameWithOptionalWithBadNameReturnsNil),
    ("testReadEnumWithNameWithOptionalWithMissingValueReturnsNil", testReadEnumWithNameWithOptionalWithMissingValueReturnsNil),
    ("testReadEnumWithNameWithOptionalWithIntegerValueThrowsException", testReadEnumWithNameWithOptionalWithIntegerValueThrowsException),
    ("testReadEnumWithNameWithValidValueGivesValue", testReadEnumWithNameWithValidValueGivesValue),
    ("testReadEnumWithNameWithBadNameThrowsException", testReadEnumWithNameWithBadNameThrowsException),
    ("testReadEnumWithNameWithIntegerValueThrowsException", testReadEnumWithNameWithIntegerValueThrowsException),
  ]}

  func setUp() {
    setUpTestCase()
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE IF EXISTS hat_types")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE hat_types (id integer PRIMARY KEY, name string)")
    Application.sharedDatabaseConnection().executeQuery("INSERT INTO hat_types VALUES (1,'feathered')")
  }
  
  func testRowInitializationWithConvertibleValuesWrapsValues() {
    let row = DatabaseRow(rawData: ["name": "John", "height": 200])
    let name = row.data["name"]
    assert(name, equals: SerializableValue.String("John"))
    let height = row.data["height"]
    assert(height, equals: SerializableValue.Integer(200))
  }
  
  func testRowInitializationWithErrorSetsError() {
    let row = DatabaseRow(error: "my error")
    assert(row.error, equals: "my error")
  }
  
  
  //MARK: - Database Row
  
  @available(*, deprecated)
  func testReadWithStringValueCanReadStringValue() {
    let row = DatabaseRow(data: ["key1": SerializableValue.String("value1")])
    do {
      let value = try row.read("key1") as String
      assert(value, equals: "value1")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithStringValueThrowsExceptionOnIntegerValue() {
    let row = DatabaseRow(data: ["key1": SerializableValue.Integer(5)])
    do {
      _ = try row.read("key1") as String
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "Integer")
      assert(desiredType, equals: "String")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithStringValueThrowsExceptionOnTimestampValue() {
    let row = DatabaseRow(data: ["key1": SerializableValue.Timestamp(Timestamp.now())])
    do {
      _ = try row.read("key1") as String
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "Timestamp")
      assert(desiredType, equals: "String")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithStringValueThrowsExceptionForMissingValue() {
    let row = DatabaseRow(data: ["key2": SerializableValue.Integer(5)])
    do {
      _ = try row.read("key1") as String
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.MissingField(name) {
      assert(name, equals: "key1")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithIntegerValueCanReadIntegerValue() {
    let row = DatabaseRow(data: ["key1": SerializableValue.Integer(12)])
    do {
      let value = try row.read("key1") as Int
      assert(value, equals: 12)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithIntegerValueThrowsExceptionForStringValue() {
    let row = DatabaseRow(data: ["key1": SerializableValue.String("hello")])
    do {
      _ = try row.read("key1") as Int
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "String")
      assert(desiredType, equals: "Int")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithUnsignedIntegerValueCanReadIntegerValue() {
    let row = DatabaseRow(data: ["key1": SerializableValue.Integer(12)])
    do {
      let value = try row.read("key1") as UInt
      assert(value, equals: 12)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithUnsignedIntegerValueThrowsExceptionForStringValue() {
    let row = DatabaseRow(data: ["key1": SerializableValue.String("hello")])
    do {
      _ = try row.read("key1") as UInt
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "String")
      assert(desiredType, equals: "UInt")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithTimestampValueCanReadTimestampValue() {
    let row = DatabaseRow(data: ["key1": SerializableValue.Timestamp(Timestamp.now())])
    do {
      let value = try row.read("key1") as Timestamp
      assert(value, equals: Timestamp.now())
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithTimestampValueCanReadStringWithValidTimestamp() {
    let row = DatabaseRow(data: ["key1": SerializableValue.String("2015-12-14 09:30:00")])
    do {
      let value = try row.read("key1") as Timestamp
      assert(value, equals: Timestamp(year: 2015, month: 12, day: 14, hour: 9, minute: 30, second: 0, nanosecond: 0))
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithTimestampValueThrowsExceptionForIntegerValue() {
    let row = DatabaseRow(data: ["key1": SerializableValue.Integer(14)])
    do {
      _ = try row.read("key1") as Timestamp
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "Integer")
      assert(desiredType, equals: "Timestamp")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithTimestampValueThrowsExceptionForStringValue() {
    let row = DatabaseRow(data: ["key1": SerializableValue.String("hello")])
    do {
      _ = try row.read("key1") as Timestamp
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "String")
      assert(desiredType, equals: "Timestamp")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithDateValueCanReadDateValue() {
    let date = Date.today()
    let row = DatabaseRow(data: ["key1": SerializableValue.Date(date)])
    do {
      let value = try row.read("key1") as Date
      assert(value, equals: date)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithDateValueThrowsExceptionForIntegerValue() {
    let row = DatabaseRow(data: ["key1": SerializableValue.Integer(5)])
    do {
      _ = try row.read("key1") as Date
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "Integer")
      assert(desiredType, equals: "Date")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithTimeValueCanReadTimeValue() {
    let time = Timestamp.now().time
    let row = DatabaseRow(data: ["key1": SerializableValue.Time(time)])
    do {
      let value = try row.read("key1") as Time
      assert(value, equals: time)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithTimeValueThrowsExceptionForIntegerValue() {
    let row = DatabaseRow(data: ["key1": SerializableValue.Integer(5)])
    do {
      _ = try row.read("key1") as Time
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "Integer")
      assert(desiredType, equals: "Time")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithBoolValueCanReadBoolValue() {
    let row = DatabaseRow(data: ["key1": SerializableValue.Boolean(true), "key2": SerializableValue.Boolean(false)])
    do {
      let value1 = try row.read("key1") as Bool
      let value2 = try row.read("key2") as Bool
      assert(value1, equals: true)
      assert(value2, equals: false)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithBoolValueCanReadIntegerValue() {
    let row = DatabaseRow(data: ["key1": SerializableValue.Integer(1), "key2": SerializableValue.Integer(0)])
    do {
      let value1 = try row.read("key1") as Bool
      let value2 = try row.read("key2") as Bool
      assert(value1, equals: true)
      assert(value2, equals: false)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithBooleanValueThrowsExceptionForStringValue() {
    let row = DatabaseRow(data: ["key1": SerializableValue.String("yo")])
    do {
      _ = try row.read("key1") as Bool
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "String")
      assert(desiredType, equals: "Bool")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithDataValueCanReadDataValue() {
    let data = NSData(bytes: [1,2,3,4])
    let row = DatabaseRow(data: ["key1": SerializableValue.Data(data)])
    do {
      let value = try row.read("key1") as NSData
      assert(value, equals: data)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithDataValueThrowsExceptionForIntegerValue() {
    let row = DatabaseRow(data: ["key1": SerializableValue.Integer(5)])
    do {
      _ = try row.read("key1") as NSData
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "Integer")
      assert(desiredType, equals: "NSData")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithDoubleValueCanReadDoubleValue() {
    let row = DatabaseRow(data: ["key1": SerializableValue.Double(1.5)])
    do {
      let value = try row.read("key1") as Double
      assert(value, equals: 1.5)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithOptionalValueCanReadRealValue() {
    let row = DatabaseRow(data: ["key1": SerializableValue.Integer(1)])
    do {
      let value: Int? = try row.read("key1")
      assert(value, equals: 1)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithOptionalValueReturnsNilForMissingValue() {
    let row = DatabaseRow(data: ["key2": SerializableValue.Integer(1)])
    do {
      let value: Int? = try row.read("key1")
      assert(isNil: value)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithOptionalValueReturnsNilForNullValue() {
    let row = DatabaseRow(data: ["key1": SerializableValue.Null])
    do {
      let value: Int? = try row.read("key1")
      assert(isNil: value)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithOptionalValueReturnsNilForEmptyStringValue() {
    let row = DatabaseRow(data: ["key1": SerializableValue.String("")])
    do {
      let value: Int? = try row.read("key1")
      assert(isNil: value)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithOptionalValueThrowsExceptionForWrongType() {
    let row = DatabaseRow(data: ["key1": SerializableValue.String("hello")])
    do {
      let value: Int? = try row.read("key1")
      assert(isNil: value)
      assert(false, message: "should throw an exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "String")
      assert(desiredType, equals: "Int")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithUnsupportedTypeThrowsException() {
    let row = DatabaseRow(data: ["key1": SerializableValue.Integer(5)])
    do {
      _ = try row.read("key1") as SerializableValue
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "Integer")
      assert(desiredType, equals: "SerializableValue")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithPersistableTypeWithOptionalWithMissingIdIsNil() {
    let record = Hat().save()!
    let row = DatabaseRow(rawData: ["hats_id": record.id])
    do {
      let result = try row.read("hat_id") as Hat?
      assert(isNil: result)
    }
    catch {
      assert(false, message: "threw unexecpted exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithPersistableTypeWithOptionalWithValidIdReturnsRecord() {
    let record = Hat().save()!
    let row = DatabaseRow(rawData: ["hat_id": record.id])
    do {
      let result = try row.read("hat_id") as Hat?
      assert(result, equals: record)
    }
    catch {
      assert(false, message: "threw unexecpted exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithPersistableTypeWithOptionalWithInvalidIdReturnsNil() {
    let record = Hat().save()!
    let row = DatabaseRow(rawData: ["hat_id": record.id + 1])
    do {
      let result = try row.read("hat_id") as Hat?
      assert(isNil: result)
    }
    catch {
      assert(false, message: "threw unexecpted exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithPersistableTypeWithOptionalWithStringIdThrowsException() {
    _ = Hat().save()!
    let row = DatabaseRow(rawData: ["hat_id": "blue"])
    do {
      _ = try row.read("hat_id") as Hat?
      assert(false, message: "should throw exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "hat_id")
      assert(actualType, equals: "String")
      assert(desiredType, equals: "Int")
    }
    catch {
      assert(false, message: "threw unexecpted exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithPersistableTypeWithValidIdReturnsRecord() {
    let record = Hat().save()!
    let row = DatabaseRow(rawData: ["hat_id": record.id])
    do {
      let result = try row.read("hat_id") as Hat
      assert(result, equals: record)
    }
    catch {
      assert(false, message: "threw unexecpted exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithPersistableTypeWithInvalidIdThrowsException() {
    let record = Hat().save()!
    let row = DatabaseRow(rawData: ["hat_id": record.id + 1])
    do {
      _ = try row.read("hat_id") as Hat
    }
    catch let DatabaseError.MissingField(name) {
      assert(name, equals: "hat_id")
    }
    catch {
      assert(false, message: "threw unexecpted exception")
    }
  }
  
  @available(*, deprecated)
  func testReadWithPersistableTypeWithStringIdThrowsException() {
    _ = Hat().save()!
    let row = DatabaseRow(rawData: ["hat_id": "blue"])
    do {
      _ = try row.read("hat_id") as Hat
      assert(false, message: "should throw exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "hat_id")
      assert(actualType, equals: "String")
      assert(desiredType, equals: "Int")
    }
    catch {
      assert(false, message: "threw unexecpted exception")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithIdWithOptionalWithValidIdGivesValue() {
    let color1 = HatType.Feathered
    _ = HatType.WideBrim
    let row = DatabaseRow(data: ["key1": color1.id.serialize])
    do {
      let value = try row.readEnum(id: "key1") as HatType?
      assert(value, equals: .Feathered)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithIdWithOptionalWithBadIdReturnsNil() {
    _ = HatType.Feathered
    let color2 = HatType.WideBrim
    let row = DatabaseRow(data: ["key1": (color2.id + 1).serialize])
    do {
      let value = try row.readEnum(id: "key1") as HatType?
      assert(isNil: value)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithIdWithOptionalWithNoValueReturnsNil() {
    let color1 = HatType.Feathered
    _ = HatType.WideBrim
    let row = DatabaseRow(data: ["key2": color1.id.serialize])
    do {
      let value = try row.readEnum(id: "key1") as HatType?
      assert(isNil: value)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }

  
  @available(*, deprecated)
  func testReadEnumWithIdWithOptionalWithStringValueThrowsException() {
    _ = HatType.Feathered
    let row = DatabaseRow(data: ["key1": "foo".serialize])
    do {
      _ = try row.readEnum(id: "key1") as HatType?
      assert(false, message: "should throw exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "String")
      assert(desiredType, equals: "Int")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithIdWithValidValueGivesValue() {
    let color1 = HatType.Feathered
    _ = HatType.WideBrim
    let row = DatabaseRow(data: ["key1": color1.id.serialize])
    do {
      let value = try row.readEnum(id: "key1") as HatType
      assert(value, equals: .Feathered)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithIdWithBadIdThrowsException() {
    _ = HatType.Feathered
    let color2 = HatType.WideBrim
    let row = DatabaseRow(data: ["key1": (color2.id + 1).serialize])
    do {
      _ = try row.readEnum(id: "key1") as HatType
      assert(false, message: "should throw exception")
    }
    catch let DatabaseError.MissingField(name) {
      assert(name, equals: "key1")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithIdWithStringValueThrowsException() {
    _ = HatType.Feathered
    let row = DatabaseRow(data: ["key1": "foo".serialize])
    do {
      _ = try row.readEnum(id: "key1") as HatType?
      assert(false, message: "should throw exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "String")
      assert(desiredType, equals: "Int")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithNameWithOptionalWithValidValueGivesValue() {
    _ = HatType.Feathered
    _ = HatType.WideBrim
    let row = DatabaseRow(data: ["key1": "feathered".serialize])
    do {
      let value = try row.readEnum(name: "key1") as HatType?
      assert(value, equals: .Feathered)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithNameWithOptionalWithBadNameReturnsNil() {
    _ = HatType.Feathered
    _ = HatType.WideBrim
    let row = DatabaseRow(data: ["key1": "bad_value".serialize])
    do {
      let value = try row.readEnum(name: "key1") as HatType?
      assert(isNil: value)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithNameWithOptionalWithMissingValueReturnsNil() {
    _ = HatType.Feathered
    _ = HatType.WideBrim
    let row = DatabaseRow(data: ["key2": "feathered".serialize])
    do {
      let value = try row.readEnum(name: "key1") as HatType?
      assert(isNil: value)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithNameWithOptionalWithIntegerValueThrowsException() {
    _ = HatType.Feathered
    let row = DatabaseRow(data: ["key1": 1.serialize])
    do {
      _ = try row.readEnum(name: "key1") as HatType?
      assert(false, message: "should throw exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "Integer")
      assert(desiredType, equals: "String")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithNameWithValidValueGivesValue() {
    _ = HatType.Feathered
    _ = HatType.WideBrim
    let row = DatabaseRow(data: ["key1": "feathered".serialize])
    do {
      let value = try row.readEnum(name: "key1") as HatType
      assert(value, equals: .Feathered)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithNameWithBadNameThrowsException() {
    _ = HatType.Feathered
    _ = HatType.WideBrim
    let row = DatabaseRow(data: ["key1": "bad_name".serialize])
    do {
      _ = try row.readEnum(name: "key1") as HatType
      assert(false, message: "should throw exception")
    }
    catch let DatabaseError.MissingField(name) {
      assert(name, equals: "key1")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithNameWithIntegerValueThrowsException() {
    _ = HatType.Feathered
    let row = DatabaseRow(data: ["key1": 1.serialize])
    do {
      _ = try row.readEnum(name: "key1") as HatType?
      assert(false, message: "should throw exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "Integer")
      assert(desiredType, equals: "String")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
}
