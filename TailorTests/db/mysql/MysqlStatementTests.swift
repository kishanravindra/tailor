import TailorTesting
import Tailor
import XCTest

class MysqlStatementTests: TailorTestCase {
  var connection: MysqlConnection { return DatabaseConnection.sharedConnection() as! MysqlConnection }
  
  func testInitializationWithGoodQueryDoesNotPutErrorOnStatement() {
    let statement = MysqlStatement(connection: connection, query: "SELECT * FROM stores")
    XCTAssertNil(statement.error)
  }
  
  func testInitializationWithMalformedQueryPutsErrorOnStatement() {
    let statement = MysqlStatement(connection: connection, query: "SELECT * FROM store")
    self.assert(statement.error, equals: "Table 'tailor_tests.store' doesn't exist")
  }
  
  func testExecuteWithGoodQueryCanMapResultsToDictionary() {
    Store(name: "Store 1").save()
    Store(name: "Store 2").save()
    
    let statement = MysqlStatement(connection: connection, query: "SELECT * FROM stores")
    let results = statement.execute([])
    self.assert(results.count, equals: 2)
    
    XCTAssertNil(statement.insertId, "does not get an insert ID from a select statement")
    XCTAssertNil(statement.error, "does not have an error on a valid query")
    if results.count == 2 {
      let result1 = results[0]
      let result2 = results[1]
      
      let keys1 = result1.keys.array.sort()
      self.assert(keys1, equals: ["id", "name"])
      if let id = result1["id"]?.intValue {
        self.assert(id, equals: 1)
      }
      else {
        XCTFail()
      }
      if let name = result1["name"]?.stringValue {
        self.assert(name, equals: "Store 1")
      }
      else {
        XCTFail()
      }
      
      let keys2 = result2.keys.array.sort()
      self.assert(keys2, equals: ["id", "name"])
      if let id = result2["id"]?.intValue {
        self.assert(id, equals: 2)
      }
      else {
        XCTFail()
      }
      if let name = result2["name"]?.stringValue {
        self.assert(name, equals: "Store 2")
      }
      else {
        XCTFail()
      }
    }
  }
  
  func testExecuteWithBadQueryReturnsEmptyRows() {
    Store(name: "Store 1").save()
    let statement = MysqlStatement(connection: connection, query: "INSERT INTO stores VALUES (?,?)")
    let param1 = "1".databaseValue
    let param2 = "Store 1".databaseValue
    let results = statement.execute([param1, param2])
    self.assert(results.count, equals: 0)
  }
  
  func testExecuteWithParametersAppliesParametersInQuery() {
    Store(name: "Store 1").save()
    Store(name: "Store 2").save()
    
    let statement = MysqlStatement(connection: connection, query: "SELECT * FROM stores WHERE id = ?")
    let param = "2".databaseValue
    let results = statement.execute([param])
    self.assert(results.count, equals: 1)
    
    XCTAssertNil(statement.insertId, "does not get an insert ID from a select statement")
    XCTAssertNil(statement.error, "does not have an error on a valid query")
    if results.count == 1 {
      let result = results[0]
      
      let keys = result.keys.array.sort()
      self.assert(keys, equals: ["id", "name"])
      if let id = result["id"]?.intValue {
        self.assert(id, equals: 2)
      }
      else {
        XCTFail()
      }
      if let name = result["name"]?.stringValue {
        self.assert(name, equals: "Store 2")
      }
      else {
        XCTFail()
      }
    }
  }
  
  func testExecuteWithInsertStatementReturnsEmptyResults() {
    let statement = MysqlStatement(connection: connection, query: "INSERT INTO stores (name) VALUES (?)")
    let param = "1".databaseValue
    let results = statement.execute([param])
    XCTAssertNil(statement.error, "does not put an error on a valid query")
    assert(results.count, equals: 0)
  }
  
  func testExecuteWithInsertStatementPutsInsertIdOnStatement() {
    let statement = MysqlStatement(connection: connection, query: "INSERT INTO stores (name) VALUES (?)")
    let param = "1".databaseValue
    statement.execute([param])
    assert(statement.insertId, equals: 1, message: "has the ID for the new row as the insertId")
  }
  
  func testExecuteWithBadQueryPutsErrorOnStatement() {
    Store(name: "Store 1").save()
    let statement = MysqlStatement(connection: connection, query: "INSERT INTO stores VALUES (?,?)")
    let param1 = "1".databaseValue
    let param2 = "Store 1".databaseValue
    statement.execute([param1, param2])
    self.assert(statement.error, equals: "Duplicate entry '1' for key 'PRIMARY'")
  }
}
