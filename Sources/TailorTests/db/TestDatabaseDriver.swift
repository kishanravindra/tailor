import XCTest
import Tailor
import TailorTesting
import TailorSqlite
import Foundation
import Glibc

struct TestDatabaseDriver: XCTestCase, TailorTestable {
  var allTests: [(String, () throws -> Void)] { return [
    ("testSharedConnectionOpensWithDriverFromConfiguration", testSharedConnectionOpensWithDriverFromConfiguration),
    ("testSharedConnectionReusesConnectionInSameThread", testSharedConnectionReusesConnectionInSameThread),
    ("testSharedConnectionOpensSeparateConnectionInNewThread", testSharedConnectionOpensSeparateConnectionInNewThread),
    ("testExecuteQueryWithVariadicArgumentsConvertsToData", testExecuteQueryWithVariadicArgumentsConvertsToData),
    ("testExecuteQueryWithStringArgumentsConvertsToData", testExecuteQueryWithStringArgumentsConvertsToData),
    ("testSanitizeColumnNameRemovesSpecialCharacters", testSanitizeColumnNameRemovesSpecialCharacters),
    ("testTransactionExecutesTransactionQueries", testTransactionExecutesTransactionQueries),
  ]}

  func setUp() {
    setUpTestCase()
  }
  
  func tearDown() {
    Application.removeSharedDatabaseConnection()
  }
  
  //MARK: - Initialization
  
  func testSharedConnectionOpensWithDriverFromConfiguration() {
    StubbedDatabaseConnection.connectionCount = 0
    Application.configuration.databaseDriver = { return StubbedDatabaseConnection(config: [:]) }
    
    Application.removeSharedDatabaseConnection()
    assert(NSStringFromClass(Application.sharedDatabaseConnection().dynamicType), equals: NSStringFromClass(StubbedDatabaseConnection.self), message: "has a test connection as the shared connection")
    assert(StubbedDatabaseConnection.connectionCount, equals: 1, message: "increments the connection count")
  }
  
  func testSharedConnectionReusesConnectionInSameThread() {
    StubbedDatabaseConnection.connectionCount = 0
    Application.configuration.databaseDriver = { return StubbedDatabaseConnection(config: [:]) }
    
    Application.removeSharedDatabaseConnection()
    Application.sharedDatabaseConnection()
    assert(StubbedDatabaseConnection.connectionCount, equals: 1, message: "increments the connection count")
    Application.sharedDatabaseConnection()
    assert(StubbedDatabaseConnection.connectionCount, equals: 1, message: "does not increment the connection count on a subsequent call")
  }
  
  func testSharedConnectionOpensSeparateConnectionInNewThread() {
    StubbedDatabaseConnection.connectionCount = 0
    Application.configuration.databaseDriver = { return StubbedDatabaseConnection(config: [:]) }
    
    Application.removeSharedDatabaseConnection()
    Application.sharedDatabaseConnection()
    var expectation = expectationWithDescription("executes block in thread")
    var thread = pthread_t()
    pthread_create(&thread, nil, TestDatabaseDriverCheckOpenConnectionInNewThread, &expectation)
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

  //MARK: - Queries
  
  func testExecuteQueryWithVariadicArgumentsConvertsToData() {
    StubbedDatabaseConnection.withTestConnection {
      connection in
      connection.executeQuery("SELECT * FROM hats WHERE color=? AND brimSize=?", "red", "10")
      if connection.queries.count > 0 {
        let (query,parameters) = connection.queries[0]
        self.assert(query, equals: "SELECT * FROM hats WHERE color=? AND brimSize=?")
        if parameters.count == 2 {
          var data = "red".serialize
          self.assert(parameters[0], equals: data, message: "has data for the first parameters")
          data = "10".serialize
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
    StubbedDatabaseConnection.withTestConnection {
      connection in
      connection.executeQuery("SELECT * FROM hats WHERE color=? AND brim_size=?", parameterValues: ["red", "10"])
      if connection.queries.count > 0 {
        let (query,parameters) = connection.queries[0]
        self.assert(query, equals: "SELECT * FROM hats WHERE color=? AND brim_size=?")
        if parameters.count == 2 {
          var data = "red".serialize
          self.assert(parameters[0], equals: data, message: "has data for the first parameters")
          data = "10".serialize
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
  
  func testSanitizeColumnNameRemovesSpecialCharacters() {
    let sanitizedName = Application.sharedDatabaseConnection().sanitizeColumnName("color;brim_size")
    assert(sanitizedName, equals: "colorbrim_size", message: "removes special characters from column name")
  }
  
  func testTransactionExecutesTransactionQueries() {
    StubbedDatabaseConnection.withTestConnection {
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
}

func TestDatabaseDriverCheckOpenConnectionInNewThread(pointer: UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<Void> {
  let expectationPointer = UnsafeMutablePointer<XCTestExpectation>(pointer)
  let expectation = expectationPointer.memory
  expectation.fulfill()
  Application.sharedDatabaseConnection()
  XCTAssertEqual(StubbedDatabaseConnection.connectionCount, 2,"creates two connections")
  return nil
}

