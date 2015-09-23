import XCTest
import Tailor
import TailorTesting
import TailorSqlite


class DatabaseRowTests: XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE IF EXISTS hat_types")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE hat_types (id integer PRIMARY KEY, name string)")
    Application.sharedDatabaseConnection().executeQuery("INSERT INTO hat_types VALUES (1,'feathered')")
  }
  
  func testRowInitializationWithConvertibleValuesWrapsValues() {
    let row = DatabaseRow(rawData: ["name": "John", "height": 200])
    let name = row.data["name"]?.stringValue
    assert(name, equals: "John")
    let height = row.data["height"]?.intValue
    assert(height, equals: 200)
  }
  
  func testRowInitializationWithErrorSetsError() {
    let row = DatabaseRow(error: "my error")
    assert(row.error, equals: "my error")
  }
  
  
  //MARK: - Database Row
  
  func testReadWithStringValueCanReadStringValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.String("value1")])
    do {
      let value = try row.read("key1") as String
      assert(value, equals: "value1")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadWithStringValueThrowsExceptionOnIntegerValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Integer(5)])
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
  
  func testReadWithStringValueThrowsExceptionOnTimestampValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Timestamp(Timestamp.now())])
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
  
  func testReadWithStringValueThrowsExceptionForMissingValue() {
    let row = DatabaseRow(data: ["key2": DatabaseValue.Integer(5)])
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
  
  func testReadWithIntegerValueCanReadIntegerValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Integer(12)])
    do {
      let value = try row.read("key1") as Int
      assert(value, equals: 12)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadWithIntegerValueThrowsExceptionForStringValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.String("hello")])
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
  
  func testReadWithTimestampValueCanReadTimestampValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Timestamp(Timestamp.now())])
    do {
      let value = try row.read("key1") as Timestamp
      assert(value, equals: Timestamp.now())
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadWithTimestampValueCanReadStringWithValidTimestamp() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.String("2015-12-14 09:30:00")])
    do {
      let value = try row.read("key1") as Timestamp
      assert(value, equals: Timestamp(year: 2015, month: 12, day: 14, hour: 9, minute: 30, second: 0, nanosecond: 0))
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadWithTimestampValueThrowsExceptionForIntegerValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Integer(14)])
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
  
  func testReadWithTimestampValueThrowsExceptionForStringValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.String("hello")])
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
  
  func testReadWithDateValueCanReadDateValue() {
    let date = Date.today()
    let row = DatabaseRow(data: ["key1": DatabaseValue.Date(date)])
    do {
      let value = try row.read("key1") as Date
      assert(value, equals: date)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadWithDateValueThrowsExceptionForIntegerValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Integer(5)])
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
  
  func testReadWithTimeValueCanReadTimeValue() {
    let time = Timestamp.now().time
    let row = DatabaseRow(data: ["key1": DatabaseValue.Time(time)])
    do {
      let value = try row.read("key1") as Time
      assert(value, equals: time)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadWithTimeValueThrowsExceptionForIntegerValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Integer(5)])
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
  
  func testReadWithBoolValueCanReadBoolValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Boolean(true), "key2": DatabaseValue.Boolean(false)])
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
  
  func testReadWithBoolValueCanReadIntegerValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Integer(1), "key2": DatabaseValue.Integer(0)])
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
  
  func testReadWithBooleanValueThrowsExceptionForStringValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.String("yo")])
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
  
  func testReadWithDataValueCanReadDataValue() {
    let data = NSData(bytes: [1,2,3,4])
    let row = DatabaseRow(data: ["key1": DatabaseValue.Data(data)])
    do {
      let value = try row.read("key1") as NSData
      assert(value, equals: data)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadWithDataValueThrowsExceptionForIntegerValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Integer(5)])
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
  
  func testReadWithDoubleValueCanReadDoubleValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Double(1.5)])
    do {
      let value = try row.read("key1") as Double
      assert(value, equals: 1.5)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadWithDoubleValueThrowsExceptionForIntegerValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Integer(5)])
    do {
      _ = try row.read("key1") as Double
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "Integer")
      assert(desiredType, equals: "Double")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadWithOptionalValueCanReadRealValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Integer(1)])
    do {
      let value: Int? = try row.read("key1")
      assert(value, equals: 1)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadWithOptionalValueReturnsNilForMissingValue() {
    let row = DatabaseRow(data: ["key2": DatabaseValue.Integer(1)])
    do {
      let value: Int? = try row.read("key1")
      assert(isNil: value)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadWithOptionalValueReturnsNilForNullValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Null])
    do {
      let value: Int? = try row.read("key1")
      assert(isNil: value)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadWithOptionalValueReturnsNilForEmptyStringValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.String("")])
    do {
      let value: Int? = try row.read("key1")
      assert(isNil: value)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadWithOptionalValueThrowsExceptionForWrongType() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.String("hello")])
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
  
  func testReadWithUnsupportedTypeThrowsException() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Integer(5)])
    do {
      _ = try row.read("key1") as DatabaseValue
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "Integer")
      assert(desiredType, equals: "DatabaseValue")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadWithPersistableTypeWithOptionalWithMissingIdIsNil() {
    let record = Hat().save()!
    let row = DatabaseRow(rawData: ["hats_id": record.id!])
    do {
      let result = try row.read("hat_id") as Hat?
      assert(isNil: result)
    }
    catch {
      assert(false, message: "threw unexecpted exception")
    }
  }
  
  func testReadWithPersistableTypeWithOptionalWithValidIdReturnsRecord() {
    let record = Hat().save()!
    let row = DatabaseRow(rawData: ["hat_id": record.id!])
    do {
      let result = try row.read("hat_id") as Hat?
      assert(result, equals: record)
    }
    catch {
      assert(false, message: "threw unexecpted exception")
    }
  }
  
  func testReadWithPersistableTypeWithOptionalWithInvalidIdReturnsNil() {
    let record = Hat().save()!
    let row = DatabaseRow(rawData: ["hat_id": record.id! + 1])
    do {
      let result = try row.read("hat_id") as Hat?
      assert(isNil: result)
    }
    catch {
      assert(false, message: "threw unexecpted exception")
    }
  }
  
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
  
  func testReadWithPersistableTypeWithValidIdReturnsRecord() {
    let record = Hat().save()!
    let row = DatabaseRow(rawData: ["hat_id": record.id!])
    do {
      let result = try row.read("hat_id") as Hat
      assert(result, equals: record)
    }
    catch {
      assert(false, message: "threw unexecpted exception")
    }
  }
  
  func testReadWithPersistableTypeWithInvalidIdThrowsException() {
    let record = Hat().save()!
    let row = DatabaseRow(rawData: ["hat_id": record.id! + 1])
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
  
  func testReadEnumWithIdWithOptionalWithValidIdGivesValue() {
    typealias HatType = PersistableEnumTests.HatType
    let color1 = PersistableEnumTests.HatType.Feathered
    _ = PersistableEnumTests.HatType.WideBrim
    let row = DatabaseRow(data: ["key1": color1.id!.databaseValue])
    do {
      let value = try row.readEnum(id: "key1") as PersistableEnumTests.HatType?
      assert(value, equals: .Feathered)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadEnumWithIdWithOptionalWithBadIdReturnsNil() {
    typealias HatType = PersistableEnumTests.HatType
    _ = PersistableEnumTests.HatType.Feathered
    let color2 = PersistableEnumTests.HatType.WideBrim
    let row = DatabaseRow(data: ["key1": (color2.id! + 1).databaseValue])
    do {
      let value = try row.readEnum(id: "key1") as PersistableEnumTests.HatType?
      assert(isNil: value)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadEnumWithIdWithOptionalWithNoValueReturnsNil() {
    typealias HatType = PersistableEnumTests.HatType
    let color1 = PersistableEnumTests.HatType.Feathered
    _ = PersistableEnumTests.HatType.WideBrim
    let row = DatabaseRow(data: ["key2": color1.id!.databaseValue])
    do {
      let value = try row.readEnum(id: "key1") as PersistableEnumTests.HatType?
      assert(isNil: value)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }

  
  func testReadEnumWithIdWithOptionalWithStringValueThrowsException() {
    typealias HatType = PersistableEnumTests.HatType
    _ = PersistableEnumTests.HatType.Feathered
    let row = DatabaseRow(data: ["key1": "foo".databaseValue])
    do {
      _ = try row.readEnum(id: "key1") as PersistableEnumTests.HatType?
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
  
  func testReadEnumWithIdWithValidValueGivesValue() {
    typealias HatType = PersistableEnumTests.HatType
    let color1 = PersistableEnumTests.HatType.Feathered
    _ = PersistableEnumTests.HatType.WideBrim
    let row = DatabaseRow(data: ["key1": color1.id!.databaseValue])
    do {
      let value = try row.readEnum(id: "key1") as PersistableEnumTests.HatType
      assert(value, equals: .Feathered)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadEnumWithIdWithBadIdThrowsException() {
    typealias HatType = PersistableEnumTests.HatType
    _ = PersistableEnumTests.HatType.Feathered
    let color2 = PersistableEnumTests.HatType.WideBrim
    let row = DatabaseRow(data: ["key1": (color2.id! + 1).databaseValue])
    do {
      _ = try row.readEnum(id: "key1") as PersistableEnumTests.HatType
      assert(false, message: "should throw exception")
    }
    catch let DatabaseError.MissingField(name) {
      assert(name, equals: "key1")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadEnumWithIdWithStringValueThrowsException() {
    typealias HatType = PersistableEnumTests.HatType
    _ = PersistableEnumTests.HatType.Feathered
    let row = DatabaseRow(data: ["key1": "foo".databaseValue])
    do {
      _ = try row.readEnum(id: "key1") as PersistableEnumTests.HatType?
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
  
  func testReadEnumWithNameWithOptionalWithValidValueGivesValue() {
    typealias HatType = PersistableEnumTests.HatType
    _ = PersistableEnumTests.HatType.Feathered
    _ = PersistableEnumTests.HatType.WideBrim
    let row = DatabaseRow(data: ["key1": "feathered".databaseValue])
    do {
      let value = try row.readEnum(name: "key1") as PersistableEnumTests.HatType?
      assert(value, equals: .Feathered)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadEnumWithNameWithOptionalWithBadNameReturnsNil() {
    typealias HatType = PersistableEnumTests.HatType
    _ = PersistableEnumTests.HatType.Feathered
    _ = PersistableEnumTests.HatType.WideBrim
    let row = DatabaseRow(data: ["key1": "bad_value".databaseValue])
    do {
      let value = try row.readEnum(name: "key1") as PersistableEnumTests.HatType?
      assert(isNil: value)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadEnumWithNameWithOptionalWithMissingValueReturnsNil() {
    typealias HatType = PersistableEnumTests.HatType
    _ = PersistableEnumTests.HatType.Feathered
    _ = PersistableEnumTests.HatType.WideBrim
    let row = DatabaseRow(data: ["key2": "feathered".databaseValue])
    do {
      let value = try row.readEnum(name: "key1") as PersistableEnumTests.HatType?
      assert(isNil: value)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadEnumWithNameWithOptionalWithIntegerValueThrowsException() {
    typealias HatType = PersistableEnumTests.HatType
    _ = PersistableEnumTests.HatType.Feathered
    let row = DatabaseRow(data: ["key1": 1.databaseValue])
    do {
      _ = try row.readEnum(name: "key1") as PersistableEnumTests.HatType?
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
  
  func testReadEnumWithNameWithValidValueGivesValue() {
    typealias HatType = PersistableEnumTests.HatType
    _ = PersistableEnumTests.HatType.Feathered
    _ = PersistableEnumTests.HatType.WideBrim
    let row = DatabaseRow(data: ["key1": "feathered".databaseValue])
    do {
      let value = try row.readEnum(name: "key1") as PersistableEnumTests.HatType
      assert(value, equals: .Feathered)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadEnumWithNameWithBadNameThrowsException() {
    typealias HatType = PersistableEnumTests.HatType
    _ = PersistableEnumTests.HatType.Feathered
    _ = PersistableEnumTests.HatType.WideBrim
    let row = DatabaseRow(data: ["key1": "bad_name".databaseValue])
    do {
      _ = try row.readEnum(name: "key1") as PersistableEnumTests.HatType
      assert(false, message: "should throw exception")
    }
    catch let DatabaseError.MissingField(name) {
      assert(name, equals: "key1")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadEnumWithNameWithIntegerValueThrowsException() {
    typealias HatType = PersistableEnumTests.HatType
    _ = PersistableEnumTests.HatType.Feathered
    let row = DatabaseRow(data: ["key1": 1.databaseValue])
    do {
      _ = try row.readEnum(name: "key1") as PersistableEnumTests.HatType?
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
