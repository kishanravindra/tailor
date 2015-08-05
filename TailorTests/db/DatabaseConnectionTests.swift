import XCTest
import Tailor
import TailorTesting

@available(*, deprecated) class DatabaseConnectionTests: TailorTestCase {
  class TestApplication : Application {
    var connectionCount = 0
    
    override func openDatabaseConnection() -> DatabaseConnection {
      connectionCount += 1
      return DatabaseConnection(config: [:])
    }
  }
  
  override func tearDown() {
    Application.removeSharedDatabaseConnection()
    NSThread.currentThread().threadDictionary.removeObjectForKey("SHARED_APPLICATION")
    super.tearDown()
  }
  
  //MARK: - Initialization
  
  func testSharedConnectionOpensWithApplication() {
    let application = TestApplication.init()
    application.start()
    NSThread.currentThread().threadDictionary["SHARED_APPLICATION"] = application
    Application.removeSharedDatabaseConnection()
    DatabaseConnection.openSharedConnection()
    assert(NSStringFromClass(DatabaseConnection.sharedConnection().dynamicType), equals: NSStringFromClass(DatabaseConnection.self), message: "has a database connection as the shared connection")
    assert(application.connectionCount, equals: 2, message: "increments the connection count every time one is opened")
    NSThread.currentThread().threadDictionary.removeObjectForKey("SHARED_APPLICATION")
  }
  
  func testSharedConnectionOpensWhenConnectionIsUnset() {
    let application = TestApplication.init()
    application.start()
    NSThread.currentThread().threadDictionary["SHARED_APPLICATION"] = application
    
    Application.removeSharedDatabaseConnection()
    assert(NSStringFromClass(DatabaseConnection.sharedConnection().dynamicType), equals: NSStringFromClass(DatabaseConnection.self), message: "has a database connection as the shared connection")
    assert(application.connectionCount, equals: 1, message: "increments the connection count")
    NSThread.currentThread().threadDictionary.removeObjectForKey("SHARED_APPLICATION")
  }
  
  func testRowInitializationWithConvertibleValuesWrapsValues() {
    let row = DatabaseConnection.Row(rawData: ["name": "John", "height": 200])
    let name = row.data["name"]?.stringValue
    assert(name, equals: "John")
    let height = row.data["height"]?.intValue
    assert(height, equals: 200)
  }
  
  //MARK: - Queries
  
  func testExecuteQueryWithVariadicArgumentsConvertsToData() {
    TestConnection.withTestConnection {
      connection in
      connection.executeQuery("SELECT * FROM hats WHERE color=? AND brimSize=?", "red", "10")
      if connection.queries.count > 0 {
        let (query,parameters) = connection.queries[0]
        self.assert(query, equals: "SELECT * FROM hats WHERE color=? AND brimSize=?")
        if parameters.count == 2 {
          var data = "red".databaseValue
          self.assert(parameters[0], equals: data, message: "has data for the first parameters")
          data = "10".databaseValue
          self.assert(parameters[1], equals: data, message: "has data for the second parameter")
        }
        else {
          XCTFail("has two bind parameters")
        }
      }
      else {
        XCTFail("stores a query in the list")
      }
    }
  }
  
  func testExecuteQueryWithStringArgumentsConvertsToData() {
    TestConnection.withTestConnection {
      connection in
      connection.executeQuery("SELECT * FROM hats WHERE color=? AND brim_size=?", parameterValues: ["red", "10"])
      if connection.queries.count > 0 {
        let (query,parameters) = connection.queries[0]
        self.assert(query, equals: "SELECT * FROM hats WHERE color=? AND brim_size=?")
        if parameters.count == 2 {
          var data = "red".databaseValue
          self.assert(parameters[0], equals: data, message: "has data for the first parameters")
          data = "10".databaseValue
          self.assert(parameters[1], equals: data, message: "has data for the second parameter")
        }
        else {
          XCTFail("has two bind parameters")
        }
      }
      else {
        XCTFail("stores a query in the list")
      }
    }
  }
  
  func testExecuteQueryReturnsEmptyArray() {
    let connection = DatabaseConnection(config: [:])
    assert(connection.executeQuery("SELECT * FROM hats", parameters: []).count, equals: 0)
  }
  
  func testSanitizeColumnNameRemovesSpecialCharacters() {
    let sanitizedName = DatabaseConnection.sanitizeColumnName("color;brim_size")
    assert(sanitizedName, equals: "colorbrim_size", message: "removes special characters from column name")
  }
  
  func testTransactionExecutesTransactionQueries() {
    TestConnection.withTestConnection {
      connection in
      connection.transaction {
        connection.executeQuery("UPDATE hats SET brim_size=10 WHERE id=5")
        connection.executeQuery("SELECT * FROM hats")
      }
      if connection.queries.count == 4 {
        self.assert(connection.queries[0].0, equals: "START TRANSACTION;")
        self.assert(connection.queries[1].0, equals: "UPDATE hats SET brim_size=10 WHERE id=5")
        self.assert(connection.queries[2].0, equals: "SELECT * FROM hats")
        self.assert(connection.queries[3].0, equals: "COMMIT;")
      }
      else {
        XCTFail("executes four queries")
      }
    }
  }
  
  func testTableNamesAreEmpty() {
    let connection = DatabaseConnection(config: [:])
    assert(connection.tableNames(), equals: [])
  }
}
