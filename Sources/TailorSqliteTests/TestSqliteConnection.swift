import Tailor
import TailorTesting
import TailorSqlite
import XCTest
import Foundation

final class TestSqliteConnection: XCTestCase, TailorTestable {
  var allTests: [(String, () throws -> Void)] { return [
    ("testCanExecuteInsertQuery", testCanExecuteInsertQuery),
    ("testCanGetSingleRowFromSelect", testCanGetSingleRowFromSelect),
    ("testCanGetUnicodeDataFromSelect", testCanGetUnicodeDataFromSelect),
    ("testCanGetMultipleRowsFromSelect", testCanGetMultipleRowsFromSelect),
    ("testCanExecuteUpdateQuery", testCanExecuteUpdateQuery),
    ("testCanExecuteInsertQueryWithBoundParameters", testCanExecuteInsertQueryWithBoundParameters),
    ("testCanInsertEmptyString", testCanInsertEmptyString),
    ("testCanHandleTimestampParameter", testCanHandleTimestampParameter),
    ("testCanHandleTimeParameter", testCanHandleTimeParameter),
    ("testCanHandleDateParameter", testCanHandleDateParameter),
    ("testCanHandleNullParameter", testCanHandleNullParameter),
    ("testCanHandleDoubleParameter", testCanHandleDoubleParameter),
    ("testCanHandleDataParameter", testCanHandleDataParameter),
    ("testCanHandleEmptyDataParameter", testCanHandleEmptyDataParameter),
    ("testCanHandleBooleanParameter", testCanHandleBooleanParameter),
    ("testTablesCanGetTableSql", testTablesCanGetTableSql),
    ]}

  func setUp() {
    setUpTestCase()
    Application.truncateTables()
  }
  
  lazy var connection: SqliteConnection = Application.sharedDatabaseConnection() as! SqliteConnection
  
  //MARK: - Executing Query
  
  func testCanExecuteInsertQuery() {
    let results = connection.executeQuery("INSERT INTO `hats` (`color`) VALUES ('red')")
    assert(results.count, equals: 1)
    if results.count == 1 {
      let result = results[0]
      assert(result.data["id"], equals: 1.serialize)
      assert(isNil: result.error)
    }
  }
  
  func testCanGetSingleRowFromSelect() {
    connection.executeQuery("INSERT INTO `hats` (`color`, `brim_size`) VALUES ('red', 10)")
    let results = connection.executeQuery("SELECT * FROM hats")
    assert(results.count, equals: 1)
    if results.count == 1 {
      let result = results[0]
      assert(result.data["id"], equals: 1.serialize)
      assert(result.data["color"], equals: "red".serialize)
      assert(result.data["brim_size"], equals: 10.serialize)
      assert(result.data["shelf_id"], equals: SerializableValue.Null)
      assert(result.data["created_at"], equals: SerializableValue.Null)
      assert(result.data["updated_at"], equals: SerializableValue.Null)
    }
  }
  
  func testCanGetUnicodeDataFromSelect() {
    connection.executeQuery("INSERT INTO `hats` (`color`, `brim_size`) VALUES ('red 🎊', 10)")
    let results = connection.executeQuery("SELECT * FROM hats")
    assert(results.count, equals: 1)
    if results.count == 1 {
      let result = results[0]
      assert(result.data["id"], equals: 1.serialize)
      assert(result.data["color"], equals: "red 🎊".serialize)
      assert(result.data["color"].flatMap { try? String(deserialize: $0) }, equals: "red 🎊")
      assert(result.data["brim_size"], equals: 10.serialize)
      assert(result.data["shelf_id"], equals: SerializableValue.Null)
      assert(result.data["created_at"], equals: SerializableValue.Null)
      assert(result.data["updated_at"], equals: SerializableValue.Null)
    }
  }
  
  func testCanGetMultipleRowsFromSelect() {
    connection.executeQuery("INSERT INTO `hats` (`color`, `brim_size`) VALUES ('red', 10), ('tan', 15)")
    let results = connection.executeQuery("SELECT * FROM hats")
    assert(results.count, equals: 2)
    if results.count == 2 {
      var result = results[0]
      assert(result.data["id"], equals: 1.serialize)
      assert(result.data["color"], equals: "red".serialize)
      assert(result.data["brim_size"], equals: 10.serialize)
      assert(result.data["shelf_id"], equals: SerializableValue.Null)
      assert(result.data["created_at"], equals: SerializableValue.Null)
      assert(result.data["updated_at"], equals: SerializableValue.Null)
      
      result = results[1]
      assert(result.data["id"], equals: 2.serialize)
      assert(result.data["color"], equals: "tan".serialize)
      assert(result.data["brim_size"], equals: 15.serialize)
      assert(result.data["shelf_id"], equals: SerializableValue.Null)
      assert(result.data["created_at"], equals: SerializableValue.Null)
      assert(result.data["updated_at"], equals: SerializableValue.Null)
    }
  }
  
  func testCanExecuteUpdateQuery() {
    connection.executeQuery("INSERT INTO `hats` (`color`, `brim_size`) VALUES ('red', 10), ('tan', 15)")
    let updateResults = connection.executeQuery("UPDATE `hats` SET `brim_size`=12 WHERE `id`=2")
    assert(updateResults.count, equals: 0)
    let selectResults = connection.executeQuery("SELECT `brim_size` FROM `hats` WHERE `id`=2")
    assert(selectResults.count, equals: 1)
    if selectResults.count == 1 {
      let result = selectResults[0]
      assert(result.data["brim_size"], equals: 12.serialize)
    }
  }
  
  func testCanExecuteInsertQueryWithBoundParameters() {
    let results = connection.executeQuery("INSERT INTO `hats` (`color`, `brim_size`) VALUES (?, ?)", "red",10)
    assert(results.count, equals: 1)
    if results.count == 1 {
      let result = results[0]
      assert(result.data["id"], equals: 1.serialize)
      assert(isNil: result.error)
    }

    let selectResults = connection.executeQuery("SELECT * FROM `hats`")
    assert(selectResults.count, equals: 1)
    
    if selectResults.count == 1 {
      let result = selectResults[0]
      assert(result.data["color"], equals: "red".serialize)
      assert(result.data["brim_size"], equals: 10.serialize)
    }
  }
  
  func testCanInsertEmptyString() {
    connection.executeQuery("INSERT INTO `hats` (`color`, `brim_size`) VALUES (?,?)", "", 10)
    let results = connection.executeQuery("SELECT * FROM hats")
    assert(results.count, equals: 1)
    if results.count == 1 {
      let result = results[0]
      assert(result.data["color"], equals: SerializableValue.String(""))
    }
  }
  
  func testCanHandleTimestampParameter() {
    let timestamp = 20.minutes.ago
    let results = connection.executeQuery("INSERT INTO `hats` (`created_at`) VALUES (?)", timestamp)
    assert(results.count, equals: 1)
    if results.count == 1 {
      let result = results[0]
      assert(result.data["id"], equals: 1.serialize)
      assert(isNil: result.error)
    }
    
    let selectResults = connection.executeQuery("SELECT * FROM `hats`")
    assert(selectResults.count, equals: 1)
    
    if selectResults.count == 1 {
      let result = selectResults[0]
      let timestamp2 = result.data["created_at"].flatMap { try? Timestamp(deserialize: $0) }
      assert(timestamp2?.epochSeconds, within: 1, of: timestamp.epochSeconds)
    }
  }
  
  func testCanHandleTimeParameter() {
    let time = 40.minutes.ago.time
    connection.executeQuery("CREATE TABLE `temp_table` (`id` integer NOT NULL PRIMARY KEY, `start_time` time)")
    let results = connection.executeQuery("INSERT INTO `temp_table` (`start_time`) VALUES (?)", time)
    assert(results.count, equals: 1)
    if results.count == 1 {
      let result = results[0]
      assert(result.data["id"], equals: 1.serialize)
      assert(isNil: result.error)
    }
    
    let selectResults = connection.executeQuery("SELECT * FROM `temp_table`")
    assert(selectResults.count, equals: 1)
    
    if selectResults.count == 1 {
      let result = selectResults[0]
      let time2 = result.data["start_time"].flatMap { try? Time(deserialize: $0) }
      assert(time2?.hour, equals: time.hour)
      assert(time2?.minute, equals: time.minute)
      assert(time2?.second, equals: time.second)
    }
    
    connection.executeQuery("DROP TABLE `temp_table`")
  }
  
  func testCanHandleDateParameter() {
    let date = 3.days.ago.date
    connection.executeQuery("CREATE TABLE `temp_table` (`id` integer NOT NULL PRIMARY KEY, `start_date` date)")
    let results = connection.executeQuery("INSERT INTO `temp_table` (`start_date`) VALUES (?)", date)
    assert(results.count, equals: 1)
    if results.count == 1 {
      let result = results[0]
      assert(result.data["id"], equals: 1.serialize)
      assert(isNil: result.error)
    }
    
    let selectResults = connection.executeQuery("SELECT * FROM `temp_table`")
    assert(selectResults.count, equals: 1)
    
    if selectResults.count == 1 {
      let result = selectResults[0]
      let date2 = result.data["start_date"].flatMap { try? Date(deserialize: $0) }
      assert(date2?.year, equals: date.year)
      assert(date2?.month, equals: date.month)
      assert(date2?.day, equals: date.day)
    }
    
    connection.executeQuery("DROP TABLE `temp_table`")
  }
  
  func testCanHandleNullParameter() {
    connection.executeQuery("INSERT INTO `hats` (`color`) VALUES (\"red\")")
    connection.executeQuery("UPDATE `hats` SET `color`=?", parameters: [SerializableValue.Null])
    let results = connection.executeQuery("SELECT * FROM hats")
    assert(results.count, equals: 1)
    
    if results.count == 1 {
      let result = results[0]
      let field = result.data["color"]
      assert(field, equals: SerializableValue.Null)
    }
  }
  
  func testCanHandleDoubleParameter() {
    let value = 3.14159
    connection.executeQuery("CREATE TABLE `temp_table` (`id` integer NOT NULL PRIMARY KEY, `size` double)")
    let results = connection.executeQuery("INSERT INTO `temp_table` (`size`) VALUES (?)", value)
    assert(results.count, equals: 1)
    if results.count == 1 {
      let result = results[0]
      assert(result.data["id"], equals: 1.serialize)
      assert(isNil: result.error)
    }
    
    let selectResults = connection.executeQuery("SELECT * FROM `temp_table`")
    assert(selectResults.count, equals: 1)
    
    if selectResults.count == 1 {
      let result = selectResults[0]
      let value2 = result.data["size"].flatMap { try? Double(deserialize: $0) }
      assert(value2, within: 0.1, of: value)
    }
    
    connection.executeQuery("DROP TABLE `temp_table`")
  }
  
  func testCanHandleDataParameter() {
    let data = NSData(bytes: [1,2,3,4,5])
    connection.executeQuery("CREATE TABLE `temp_table` (`id` integer NOT NULL PRIMARY KEY, `image` blob)")
    let results = connection.executeQuery("INSERT INTO `temp_table` (`image`) VALUES (?)", data)
    assert(results.count, equals: 1)
    if results.count == 1 {
      let result = results[0]
      assert(result.data["id"], equals: 1.serialize)
      assert(isNil: result.error)
    }
    
    let selectResults = connection.executeQuery("SELECT * FROM `temp_table`")
    assert(selectResults.count, equals: 1)
    
    if selectResults.count == 1 {
      let result = selectResults[0]
      guard let value = result.data["image"],
        case let .Data(data2) = value else {
          return assert(false, message: "Did not have data")
      }
      assert(data2, equals: data)
    }
    
    connection.executeQuery("DROP TABLE `temp_table`")
  }
  
  func testCanHandleEmptyDataParameter() {
    let data = NSData()
    connection.executeQuery("CREATE TABLE `temp_table` (`id` integer NOT NULL PRIMARY KEY, `image` blob)")
    let results = connection.executeQuery("INSERT INTO `temp_table` (`image`) VALUES (?)", data)
    assert(results.count, equals: 1)
    if results.count == 1 {
      let result = results[0]
      assert(result.data["id"], equals: 1.serialize)
      assert(isNil: result.error)
    }
    
    let selectResults = connection.executeQuery("SELECT * FROM `temp_table`")
    assert(selectResults.count, equals: 1)
    
    if selectResults.count == 1 {
      let result = selectResults[0]
      guard let value = result.data["image"],
        case let .Data(data2) = value else {
          return assert(false, message: "Did not have data")
      }
      assert(data2, equals: data)
    }
    
    connection.executeQuery("DROP TABLE `temp_table`")
  }
  
  func testCanHandleBooleanParameter() {
    let flag = true
    connection.executeQuery("CREATE TABLE `temp_table` (`id` integer NOT NULL PRIMARY KEY, `flag` int(1))")
    let results = connection.executeQuery("INSERT INTO `temp_table` (`flag`) VALUES (?)", flag)
    assert(results.count, equals: 1)
    if results.count == 1 {
      let result = results[0]
      assert(result.data["id"], equals: 1.serialize)
      assert(isNil: result.error)
    }
    
    let selectResults = connection.executeQuery("SELECT * FROM `temp_table`")
    assert(selectResults.count, equals: 1)
    
    if selectResults.count == 1 {
      let result = selectResults[0]
      let flag2 = result.data["flag"].flatMap { try? Bool(deserialize: $0) }
      assert(flag2, equals: flag)
    }
    
    connection.executeQuery("DROP TABLE `temp_table`")
  }

  //MARK: - Metadata
  
  func testTablesCanGetTableSql() {
    let tables = connection.tables()
    assert(Array(tables.keys).sort(), equals: ["hats", "shelfs", "stores", "tailor_alterations", "users"])
    assert(tables["hats"], equals: "CREATE TABLE `hats` ( `id` integer NOT NULL PRIMARY KEY, `color` varchar(255), `brim_size` int(11), shelf_id int(11), `created_at` timestamp, `updated_at` timestamp)")
    assert(tables["shelfs"], equals: "CREATE TABLE `shelfs` ( `id` integer NOT NULL PRIMARY KEY, `name` varchar(255), `store_id` int(11))")
    assert(tables["stores"], equals: "CREATE TABLE `stores` ( `id` integer NOT NULL PRIMARY KEY, `name` varchar(255))")
    assert(tables["users"], equals: "CREATE TABLE `users` ( `id` integer NOT NULL PRIMARY KEY, `email_address` varchar(255), `encrypted_password` varchar(255))")
    assert(tables["tailor_alterations"], equals: "CREATE TABLE tailor_alterations ( id varchar(255) PRIMARY KEY )")
  }
}
