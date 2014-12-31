import XCTest

class DatabaseConnectionTests: XCTestCase {  
  class TestApplication : TailorTests.TestApplication {
    var connectionCount = 0
    
    override func openDatabaseConnection() -> DatabaseConnection {
      connectionCount += 1
      return super.openDatabaseConnection()
    }
  }
  
  override func setUp() {
    TailorTests.TestApplication.start()
  }
  
  //MARK: - Initialization
  
  func testInitializationSetsTimeZone() {
    let connection = DatabaseConnection(config: [:])
    XCTAssertEqual(connection.timeZone, NSTimeZone.systemTimeZone(), "sets time zone to system time zone")
  }

  func testSharedConnectionOpensWithApplication() {
    SHARED_APPLICATION = nil
    TestApplication.start()
    DatabaseConnection.openSharedConnection()
    let application = SHARED_APPLICATION as TestApplication
    XCTAssertEqual(NSStringFromClass(DatabaseConnection.sharedConnection().dynamicType), NSStringFromClass(MysqlConnection.self), "has a mysql connection as the shared connection")
    XCTAssertEqual(application.connectionCount, 1, "increments the connection count")
    SHARED_APPLICATION = nil
  }
  
  func testSharedConnectionOpensSeparateConnectionInNewThread() {
    SHARED_APPLICATION = nil
    TestApplication.start()
    DatabaseConnection.openSharedConnection()
    let application = SHARED_APPLICATION as TestApplication
    let expectation = expectationWithDescription("executes block in thread")
    DatabaseConnection.sharedConnection()
    NSOperationQueue().addOperationWithBlock {
      expectation.fulfill()
      DatabaseConnection.sharedConnection()
      XCTAssertEqual(application.connectionCount, 2, "creates two connections")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
    SHARED_APPLICATION = nil
  }
  
  //MARK: - Queries
  
  func testExecuteQueryWithVariadicArgumentsConvertsToData() {
    TestConnection.withTestConnection {
      connection in
      connection.executeQuery("SELECT * FROM hats WHERE color=? AND brimSize=?", "red", "10")
      if connection.queries.count > 0 {
        let (query,parameters) = connection.queries[0]
        XCTAssertEqual(query, "SELECT * FROM hats WHERE color=? AND brimSize=?")
        if parameters.count == 2 {
          var data = "red".dataUsingEncoding(NSUTF8StringEncoding)!
          XCTAssertEqual(parameters[0], data, "has data for the first parameters")
          data = "10".dataUsingEncoding(NSUTF8StringEncoding)!
          XCTAssertEqual(parameters[1], data, "has data for the second parameter")
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
      connection.executeQuery("SELECT * FROM hats WHERE color=? AND brim_size=?", stringParameters: ["red", "10"])
      if connection.queries.count > 0 {
        let (query,parameters) = connection.queries[0]
        XCTAssertEqual(query, "SELECT * FROM hats WHERE color=? AND brim_size=?")
        if parameters.count == 2 {
          var data = "red".dataUsingEncoding(NSUTF8StringEncoding)!
          XCTAssertEqual(parameters[0], data, "has data for the first parameters")
          data = "10".dataUsingEncoding(NSUTF8StringEncoding)!
          XCTAssertEqual(parameters[1], data, "has data for the second parameter")
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
  
  func testSanitizeColumnNameRemovesSpecialCharacters() {
    let sanitizedName = DatabaseConnection.sanitizeColumnName("color;brim_size")
    XCTAssertEqual(sanitizedName, "colorbrim_size", "removes special characters from column name")
  }
  
  func testTransactionExecutesTransactionQueries() {
    TestConnection.withTestConnection {
      connection in
      connection.transaction {
        connection.executeQuery("UPDATE hats SET brim_size=10 WHERE id=5")
        connection.executeQuery("SELECT * FROM hats")
      }
      if connection.queries.count == 4 {
        XCTAssertEqual(connection.queries[0].0, "START TRANSACTION;")
        XCTAssertEqual(connection.queries[1].0, "UPDATE hats SET brim_size=10 WHERE id=5")
        XCTAssertEqual(connection.queries[2].0, "SELECT * FROM hats")
        XCTAssertEqual(connection.queries[3].0, "COMMIT;")
      }
      else {
        XCTFail("executes four queries")
      }
    }
  }
}
