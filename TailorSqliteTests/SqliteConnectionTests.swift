import Tailor
import TailorTesting
import TailorSqlite

class SqliteConnectionTests: TailorTestCase {
  lazy var connection: SqliteConnection = Application.sharedDatabaseConnection() as! SqliteConnection
  
  override func setUp() {
    super.setUp()
    connection.executeQuery("DELETE FROM hats")
  }
  func testCanExecuteInsertQuery() {
    let results = connection.executeQuery("INSERT INTO `hats` (`color`) VALUES ('red')")
    assert(results.count, equals: 1)
    if results.count == 1 {
      let result = results[0]
      assert(result.data["id"], equals: 1.databaseValue)
      assert(isNil: result.error)
    }
  }
  
  func testCanGetSingleRowFromSelect() {
    connection.executeQuery("INSERT INTO `hats` (`color`, `brim_size`) VALUES ('red', 10)")
    let results = connection.executeQuery("SELECT * FROM hats")
    assert(results.count, equals: 1)
    if results.count == 1 {
      let result = results[0]
      assert(result.data["id"], equals: 1.databaseValue)
      assert(result.data["color"], equals: "red".databaseValue)
      assert(result.data["brim_size"], equals: 10.databaseValue)
      assert(result.data["shelf_id"], equals: DatabaseValue.Null)
      assert(result.data["created_at"], equals: DatabaseValue.Null)
      assert(result.data["updated_at"], equals: DatabaseValue.Null)
    }
  }
  
  func testCanGetMultipleRowsFromSelect() {
    connection.executeQuery("INSERT INTO `hats` (`color`, `brim_size`) VALUES ('red', 10), ('tan', 15)")
    let results = connection.executeQuery("SELECT * FROM hats")
    assert(results.count, equals: 2)
    if results.count == 2 {
      var result = results[0]
      assert(result.data["id"], equals: 1.databaseValue)
      assert(result.data["color"], equals: "red".databaseValue)
      assert(result.data["brim_size"], equals: 10.databaseValue)
      assert(result.data["shelf_id"], equals: DatabaseValue.Null)
      assert(result.data["created_at"], equals: DatabaseValue.Null)
      assert(result.data["updated_at"], equals: DatabaseValue.Null)
      
      result = results[1]
      assert(result.data["id"], equals: 2.databaseValue)
      assert(result.data["color"], equals: "tan".databaseValue)
      assert(result.data["brim_size"], equals: 15.databaseValue)
      assert(result.data["shelf_id"], equals: DatabaseValue.Null)
      assert(result.data["created_at"], equals: DatabaseValue.Null)
      assert(result.data["updated_at"], equals: DatabaseValue.Null)
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
      assert(result.data["brim_size"], equals: 12.databaseValue)
    }
  }
  
  func testCanExecuteInsertQueryWithBoundParameters() {
    let results = connection.executeQuery("INSERT INTO `hats` (`color`, `brim_size`) VALUES (?, ?)", "red",10)
    assert(results.count, equals: 1)
    if results.count == 1 {
      let result = results[0]
      assert(result.data["id"], equals: 1.databaseValue)
      assert(isNil: result.error)
    }

    let selectResults = connection.executeQuery("SELECT * FROM `hats`")
    assert(selectResults.count, equals: 1)
    
    if selectResults.count == 1 {
      let result = selectResults[0]
      assert(result.data["color"], equals: "red".databaseValue)
      assert(result.data["brim_size"], equals: 10.databaseValue)
    }
  }
  
  func testCanHandleTimestampParameter() {
    let timestamp = Timestamp.now()
    let results = connection.executeQuery("INSERT INTO `hats` (`created_at`) VALUES (?)", timestamp)
    assert(results.count, equals: 1)
    if results.count == 1 {
      let result = results[0]
      assert(result.data["id"], equals: 1.databaseValue)
      assert(isNil: result.error)
    }
    
    let selectResults = connection.executeQuery("SELECT * FROM `hats`")
    assert(selectResults.count, equals: 1)
    
    if selectResults.count == 1 {
      let result = selectResults[0]
      let timestamp2 = result.data["created_at"]?.timestampValue
      assert(timestamp2?.epochSeconds, within: 1, of: timestamp.epochSeconds)
    }
  }
}
