import TailorTesting
import Tailor
import XCTest

class MysqlResultSetTests: TailorTestCase {
  
  var connection: MysqlConnection { return DatabaseConnection.sharedConnection() as! MysqlConnection }
  
  var statement: UnsafeMutablePointer<MYSQL_STMT> = nil
  
  override func tearDown() {
    if statement != nil {
      mysql_stmt_close(statement)
    }
  }
  
  func prepareStatement(query: String) {
    self.statement = mysql_stmt_init(connection.connection)
    
    let encodedQuery = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
    
    mysql_stmt_prepare(statement, UnsafePointer<Int8>(encodedQuery.bytes), UInt(encodedQuery.length))
  }
  
  func testInitializationCreatesFieldsForResultSetsFieldsForQuery() {
    prepareStatement("SELECT * FROM hats")
    
    let resultSet = MysqlResultSet(statement: statement)
    let fields = resultSet.fields
    self.assert(fields.count, equals: 6)
    
    if fields.count == 6 {
      self.assert(fields[0].name, equals: "id")
      self.assert(fields[0].bufferType.value, equals: MYSQL_TYPE_LONG.value)
      self.assert(fields[1].name, equals: "color")
      self.assert(fields[1].bufferType.value, equals: MYSQL_TYPE_VAR_STRING.value)
      self.assert(fields[2].name, equals: "brim_size")
      self.assert(fields[2].bufferType.value, equals: MYSQL_TYPE_LONG.value)
      self.assert(fields[3].name, equals: "shelf_id")
      self.assert(fields[3].bufferType.value, equals: MYSQL_TYPE_LONG.value)
      self.assert(fields[4].name, equals: "created_at")
      self.assert(fields[4].bufferType.value, equals: MYSQL_TYPE_TIMESTAMP.value)
      self.assert(fields[5].name, equals: "updated_at")
      self.assert(fields[5].bufferType.value, equals: MYSQL_TYPE_TIMESTAMP.value)
    }
  }
  
  func testIsEmptyIsFalseForSelectStatement() {
    prepareStatement("SELECT * FROM hats")
    let resultSet = MysqlResultSet(statement: statement)
    XCTAssertFalse(resultSet.isEmpty)
  }
  
  func testIsEmptyIsTrueForInsertStatement() {
    prepareStatement("INSERT INTO hats (color,brim_size,shelf_id) VALUES (?,?,?)")
    let resultSet = MysqlResultSet(statement: statement)
    XCTAssertTrue(resultSet.isEmpty)
  }
}
