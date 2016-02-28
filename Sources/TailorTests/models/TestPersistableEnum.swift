import Tailor
import TailorTesting
import XCTest

struct TestPersistableEnum: XCTestCase, TailorTestable {

  var allTests: [(String, () throws -> Void)] { return [
    ("testStringPersistableEnumGetsStringFromFromCaseName", testStringPersistableEnumGetsStringFromFromCaseName),
    ("testStringPersistableEnumCanGenerateValueFromString", testStringPersistableEnumCanGenerateValueFromString),
    ("testStringPersistableEnumGetsNilForInvalidCaseName", testStringPersistableEnumGetsNilForInvalidCaseName),
    ("testStringPersistableEnumGetsNilForIntegerValue", testStringPersistableEnumGetsNilForIntegerValue),
    ("testDatabasePersistableEnumRecognizesExistingRecord", testDatabasePersistableEnumRecognizesExistingRecord),
    ("testDatabasePersistableEnumCreatesNewRecord", testDatabasePersistableEnumCreatesNewRecord),
    ("testDatabasePersistableEnumWithProblemInsertingRecordReturnsZero", testDatabasePersistableEnumWithProblemInsertingRecordReturnsZero),
    ("testDatabasePersistableEnumWithBadStructureReturnsZero", testDatabasePersistableEnumWithBadStructureReturnsZero),
    ("testDatabasePersistableEnumCanGenerateValueFromId", testDatabasePersistableEnumCanGenerateValueFromId),
    ("testDatabasePersistableEnumGetsNilForInvalidId", testDatabasePersistableEnumGetsNilForInvalidId),
    ("testDatabasePersistableEnumGetsValuesToPersistWithCaseName", testDatabasePersistableEnumGetsValuesToPersistWithCaseName),
    ("testDatabasePersistableEnumCanBeInitializedFromDatabaseRowWithCaseName", testDatabasePersistableEnumCanBeInitializedFromDatabaseRowWithCaseName),
  ]}

  func setUp() {
    setUpTestCase() 
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE hat_types")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE hat_types (id integer PRIMARY KEY, name string)")
  }
  
  func testStringPersistableEnumGetsStringFromFromCaseName() {
    assert(Color.Red.serialize, equals: SerializableValue.String("red"))
    assert(Color.DarkBlue.serialize, equals: SerializableValue.String("dark_blue"))
  }
  
  func testStringPersistableEnumCanGenerateValueFromString() {
    assert(Color.fromSerializableValue(SerializableValue.String("red")), equals: Color.Red)
    assert(Color.fromSerializableValue(SerializableValue.String("dark_blue")), equals: Color.DarkBlue)
  }
  
  func testStringPersistableEnumGetsNilForInvalidCaseName() {
    assert(isNil: Color.fromSerializableValue(SerializableValue.String("blue")))
  }
  
  func testStringPersistableEnumGetsNilForIntegerValue() {
    assert(isNil: Color.fromSerializableValue(SerializableValue.Integer(5)))
  }
  
  func testDatabasePersistableEnumRecognizesExistingRecord() {
    let value = HatType.Feathered
    assert(value.serialize, equals: SerializableValue.Integer(1))
  }
  
  func testDatabasePersistableEnumCreatesNewRecord() {
    _ = HatType.Feathered.id
    let value = HatType.WideBrim
    assert(value.serialize, equals: SerializableValue.Integer(2))
    let value2 = value
    assert(value2.serialize, equals: SerializableValue.Integer(2))
  }
  
  func testDatabasePersistableEnumWithProblemInsertingRecordReturnsZero() {
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE hat_types")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE hat_types (id integer PRIMARY KEY, name string CHECK(length(name)>10))")
    let value = HatType.Feathered
    assert(value.serialize, equals: SerializableValue.Integer(0))
  }
  
  func testDatabasePersistableEnumWithBadStructureReturnsZero() {
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE hat_types")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE hat_types (id integer PRIMARY KEY)")
    let value = HatType.Feathered
    assert(value.serialize, equals: SerializableValue.Integer(0))
    
  }
  
  func testDatabasePersistableEnumCanGenerateValueFromId() {
    let value1 = HatType.Feathered.serialize
    let value2 = HatType.WideBrim.serialize
    
    assert(HatType.fromSerializableValue(value1), equals: HatType.Feathered)
    assert(HatType.fromSerializableValue(value2), equals: HatType.WideBrim)
  }
  
  func testDatabasePersistableEnumGetsNilForInvalidId() {
    _ = HatType.Feathered.serialize
    _ = HatType.WideBrim.serialize
    
    assert(HatType.fromSerializableValue(3.serialize) == nil)
  }

  func testDatabasePersistableEnumGetsValuesToPersistWithCaseName() {
    let record = HatType.WideBrim
    let values = record.valuesToPersist()
    assert(Array(values.keys), equals: ["name"])
    assert(values["name"] as? String, equals: record.caseName)
  }
  
  func testDatabasePersistableEnumCanBeInitializedFromDatabaseRowWithCaseName() {
    let record = try? HatType(deserialize: SerializableValue.Dictionary(["name": "wide_brim".serialize]))
    assert(record, equals: HatType.WideBrim)
  }
}
