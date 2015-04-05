import Tailor
import TailorTesting
import XCTest

class MysqlFieldTests : TailorTestCase {
  func getField(query: String) -> MYSQL_FIELD {
    let connection = DatabaseConnection.sharedConnection() as! MysqlConnection
    let statement = mysql_stmt_init(connection.connection)
    
    let encodedQuery = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
    
    mysql_stmt_prepare(statement, UnsafePointer<Int8>(encodedQuery.bytes), UInt(encodedQuery.length))
    let result = mysql_stmt_result_metadata(statement)
    let field = mysql_fetch_field_direct(result, UInt32(0)).memory
    mysql_stmt_close(statement)
    mysql_free_result(result)
    return field
  }
  
  func testInitializationSetsFieldInformation() {
    let field = MysqlField(field: getField("SELECT brim_size FROM hats"))
    self.assert(field.name, equals: "brim_size")
    self.assert(field.bufferType.value, equals: MYSQL_TYPE_LONG.value)
    self.assert(field.bufferLength, equals: 1)
    self.assert(field.bufferSize, equals: UInt(sizeof(CInt)))
  }
  
  func testInitializationWithIntTypeIsNonBinary() {
    let field = MysqlField(field: getField("SELECT brim_size FROM hats"))
    XCTAssertFalse(field.isBinary)
  }
  
  func testInitializationWithBlobTypeIsNonBinary() {
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE users ADD column avatar blob")
    let field = MysqlField(field: getField("SELECT avatar FROM users"))
    XCTAssertTrue(field.isBinary)
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE users DROP column avatar")
  }
  
  func testBufferSizeForTinyIntIsOneChar() {
    let result = MysqlField.bufferSize(MYSQL_TYPE_TINY)
    assert(result.0, equals: UInt(sizeof(CChar)))
    assert(result.1, equals: 1)
  }
  
  func testBufferSizeForSmallIntIsOneShort() {
    let result = MysqlField.bufferSize(MYSQL_TYPE_SHORT)
    assert(result.0, equals: UInt(sizeof(CShort)))
    assert(result.1, equals: 1)
  }
  
  func testBufferSizeForNormalIntIsOneInt() {
    let result = MysqlField.bufferSize(MYSQL_TYPE_LONG)
    assert(result.0, equals: UInt(sizeof(CInt)))
    assert(result.1, equals: 1)
  }
  
  func testBufferSizeForMediumIntIsOneInt() {
    let result = MysqlField.bufferSize(MYSQL_TYPE_INT24)
    assert(result.0, equals: UInt(sizeof(CInt)))
    assert(result.1, equals: 1)
  }
  
  func testBufferSizeForBigIntIsOneLongLong() {
    let result = MysqlField.bufferSize(MYSQL_TYPE_LONGLONG)
    assert(result.0, equals: UInt(sizeof(CLongLong)))
    assert(result.1, equals: 1)
  }
  
  func testBufferSizeForFloatIsOneFloat() {
    let result = MysqlField.bufferSize(MYSQL_TYPE_FLOAT)
    assert(result.0, equals: UInt(sizeof(CFloat)))
    assert(result.1, equals: 1)
  }
  
  func testBufferSizeForDoubleIsOneInt() {
    let result = MysqlField.bufferSize(MYSQL_TYPE_DOUBLE)
    assert(result.0, equals: UInt(sizeof(CDouble)))
    assert(result.1, equals: 1)
  }
  
  func testBufferSizeForDecimalIs1024Chars() {
    let result = MysqlField.bufferSize(MYSQL_TYPE_NEWDECIMAL)
    assert(result.0, equals: UInt(sizeof(CChar)))
    assert(result.1, equals: 1024)
  }
  
  func testBufferSizeForTimeIsOneMysqlTime() {
    let result = MysqlField.bufferSize(MYSQL_TYPE_TIME)
    assert(result.0, equals: UInt(sizeof(MYSQL_TIME)))
    assert(result.1, equals: 1)
  }
  
  func testBufferSizeForDateIsOneMysqlTime() {
    let result = MysqlField.bufferSize(MYSQL_TYPE_DATE)
    assert(result.0, equals: UInt(sizeof(MYSQL_TIME)))
    assert(result.1, equals: 1)
  }
  
  func testBufferSizeForDateTimeIsOneMysqlTime() {
    let result = MysqlField.bufferSize(MYSQL_TYPE_DATETIME)
    assert(result.0, equals: UInt(sizeof(MYSQL_TIME)))
    assert(result.1, equals: 1)
  }
  
  func testBufferSizeForTimestampIsOneMysqlTime() {
    let result = MysqlField.bufferSize(MYSQL_TYPE_TIMESTAMP)
    assert(result.0, equals: UInt(sizeof(MYSQL_TIME)))
    assert(result.1, equals: 1)
  }
  
  func testBufferSizeForCharIs1Kilobyte() {
    let result = MysqlField.bufferSize(MYSQL_TYPE_STRING)
    assert(result.0, equals: 1)
    assert(result.1, equals: 1024)
  }
  
  func testBufferSizeForVarCharIs1Kilobyte() {
    let result = MysqlField.bufferSize(MYSQL_TYPE_VAR_STRING)
    assert(result.0, equals: 1)
    assert(result.1, equals: 1024)
  }
  
  func testBufferSizeForTinyBlobIs256Bytes() {
    let result = MysqlField.bufferSize(MYSQL_TYPE_TINY_BLOB)
    assert(result.0, equals: 1)
    assert(result.1, equals: 256)
  }
  
  func testBufferSizeForBlobIs64Kilobytes() {
    let result = MysqlField.bufferSize(MYSQL_TYPE_BLOB)
    assert(result.0, equals: 1)
    assert(result.1, equals: 65536)
  }
  
  func testBufferSizeForMediumBlobIs16Megabytes() {
    let result = MysqlField.bufferSize(MYSQL_TYPE_MEDIUM_BLOB)
    assert(result.0, equals: 1)
    assert(result.1, equals: 16777216)
  }
  
  func testBufferSizeForLongBlobIs2Gigabytes() {
    let result = MysqlField.bufferSize(MYSQL_TYPE_LONG_BLOB)
    assert(result.0, equals: 1)
    assert(result.1, equals: 2147483648)
  }
}