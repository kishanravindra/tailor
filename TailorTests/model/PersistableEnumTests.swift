import Tailor
import TailorTesting
import XCTest

class PersistableEnumTests: XCTestCase, TailorTestable {
  enum Color: String, StringPersistableEnum {
    case Red
    case DarkBlue
    
    static var cases = [Color.Red, Color.DarkBlue]
  }
  
  enum HatType: String, TablePersistableEnum {
    case Feathered
    case WideBrim
    
    static var cases = [HatType.Feathered, HatType.WideBrim]
  }
  
  override func setUp() {
    super.setUp()
    setUpTestCase()
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE IF EXISTS hat_types")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE hat_types (id integer PRIMARY KEY, name string)")
    Application.sharedDatabaseConnection().executeQuery("INSERT INTO hat_types VALUES (1,'feathered')")
  }
  
  override func tearDown() {
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE hat_types")
    super.tearDown()
  }
  
  func testStringPersistableEnumGetsStringFromFromCaseName() {
    assert(Color.Red.databaseValue, equals: DatabaseValue.String("red"))
    assert(Color.DarkBlue.databaseValue, equals: DatabaseValue.String("dark_blue"))
  }
  
  func testStringPersistableEnumCanGenerateValueFromString() {
    assert(Color.fromDatabaseValue(DatabaseValue.String("red")), equals: Color.Red)
    assert(Color.fromDatabaseValue(DatabaseValue.String("dark_blue")), equals: Color.DarkBlue)
  }
  
  func testStringPersistableEnumGetsNilForInvalidCaseName() {
    assert(isNil: Color.fromDatabaseValue(DatabaseValue.String("blue")))
  }
  
  func testStringPersistableEnumGetsNilForIntegerValue() {
    assert(isNil: Color.fromDatabaseValue(DatabaseValue.Integer(5)))
  }
  
  func testDatabasePersistableEnumRecognizesExistingRecord() {
    let value = HatType.Feathered
    assert(value.databaseValue, equals: DatabaseValue.Integer(1))
  }
  
  func testDatabasePersistableEnumCreatesNewRecord() {
    let value = HatType.WideBrim
    assert(value.databaseValue, equals: DatabaseValue.Integer(2))
    let value2 = value
    assert(value2.databaseValue, equals: DatabaseValue.Integer(2))
  }
  
  func testDatabasePersistableEnumWithProblemInsertingRecordReturnsNull() {
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE hat_types")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE hat_types (id integer PRIMARY KEY, name string CHECK(length(name)>10))")
    let value = HatType.Feathered
    assert(value.databaseValue, equals: DatabaseValue.Null)
  }
  
  func testDatabasePersistableEnumWithBadStructureReturnsNull() {
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE hat_types")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE hat_types (id integer PRIMARY KEY)")
    let value = HatType.Feathered
    assert(value.databaseValue, equals: DatabaseValue.Null)
  }
  
  func testDatabasePersistableEnumCanGenerateValueFromId() {
    let value1 = HatType.Feathered.databaseValue
    let value2 = HatType.WideBrim.databaseValue
    
    assert(HatType.fromDatabaseValue(value1), equals: HatType.Feathered)
    assert(HatType.fromDatabaseValue(value2), equals: HatType.WideBrim)
  }
  
  func testDatabasePersistableEnumGetsNilForInvalidId() {
    _ = HatType.Feathered.databaseValue
    _ = HatType.WideBrim.databaseValue
    
    assert(HatType.fromDatabaseValue(3.databaseValue) == nil)
  }

  func testDatabasePersistableEnumGetsValuesToPersistWithCaseName() {
    let record = HatType.WideBrim
    let values = record.valuesToPersist()
    assert(Array(values.keys), equals: ["name"])
    assert(values["name"] as? String, equals: record.caseName)
  }
  
  func testDatabasePersistableEnumCanBeInitializedFromDatabaseRowWithCaseName() {
    let record = try? HatType(databaseRow: DatabaseRow(rawData: ["name": "wide_brim"]))
    assert(record, equals: HatType.WideBrim)
  }
}