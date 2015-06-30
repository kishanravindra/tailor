@testable import Tailor
import TailorTesting
import XCTest
import mysql

class MysqlBindParameterTests: TailorTestCase {
  var connection: MysqlConnection { return Application.sharedDatabaseConnection() as! MysqlConnection }
  var parameterSet: MysqlBindParameterSet!
  var parameter: MysqlBindParameter! {
    if let parameters = parameterSet?.parameters {
      if parameters.count > 0 {
        return parameters[0]
      }
    }
    return nil
  }
  
  override func setUp() {
    super.setUp()
    loadMysqlConnection()
  }
  
  func runQuery(query: String) {
    let statement = mysql_stmt_init(connection.connection)
    
    let encodedQuery = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
    
    mysql_stmt_prepare(statement, UnsafePointer<Int8>(encodedQuery.bytes), UInt(encodedQuery.length))
    
    let resultSet = MysqlResultSet(statement: statement)
    parameterSet = MysqlBindParameterSet(resultSet: resultSet)
    parameterSet.bindToOutputOfStatement(statement)
    mysql_stmt_execute(statement)
    mysql_stmt_fetch(statement)
    mysql_stmt_close(statement)
  }
  
  override func tearDown() {
    loadSqliteConnection()
    super.tearDown()
  }
  
  //MARK: - Creation
  
  func testDefaultInitializerCreatesEmptyParameter() {
    let bindParameter = MysqlBindParameter()
    self.assert(bindParameter.parameter.buffer_length, equals: 0)
  }
  
  func testInitializeWithFieldSetsBufferInformation() {
    runQuery("SELECT color FROM hats")
    self.assert(parameter.parameter.buffer_type.rawValue, equals: MYSQL_TYPE_VAR_STRING.rawValue)
    self.assert(parameter.parameter.buffer_length, equals: 1024)
  }
  
  func testInitializeWithStringValueCreatesStringBuffer() {
    let string = "hello"
    let bindParameter = MysqlBindParameter(value: string.databaseValue)
    self.assert(bindParameter.parameter.buffer_length, equals: 5)
    self.assert(bindParameter.parameter.buffer_type.rawValue, equals: MYSQL_TYPE_STRING.rawValue)
    
    let buffer = UnsafeMutablePointer<CChar>(bindParameter.parameter.buffer)
    assert(buffer[0], equals: 104)
    assert(buffer[1], equals: 101)
    assert(buffer[2], equals: 108)
    assert(buffer[3], equals: 108)
    assert(buffer[4], equals: 111)
  }
  
  func testInitializeWithIntegerCreatesStringBuffer() {
    let bindParameter = MysqlBindParameter(value: 5.databaseValue)
    self.assert(bindParameter.parameter.buffer_length, equals: 1)
    self.assert(bindParameter.parameter.buffer_type.rawValue, equals: MYSQL_TYPE_STRING.rawValue)
    
    let buffer = UnsafeMutablePointer<CChar>(bindParameter.parameter.buffer)
    assert(buffer[0], equals: 53)
  }
  
  func testInitializeWithBooleanCreatesStringBufferWithIntegerValue() {
    let bindParameter = MysqlBindParameter(value: true.databaseValue)
    self.assert(bindParameter.parameter.buffer_length, equals: 1)
    self.assert(bindParameter.parameter.buffer_type.rawValue, equals: MYSQL_TYPE_STRING.rawValue)
    
    let buffer = UnsafeMutablePointer<CChar>(bindParameter.parameter.buffer)
    assert(buffer[0], equals: 49)
  }
  
  func testInitializeWithDoubleCreatesStringBuffer() {
    let bindParameter = MysqlBindParameter(value: 27.8.databaseValue)
    self.assert(bindParameter.parameter.buffer_length, equals: 4)
    self.assert(bindParameter.parameter.buffer_type.rawValue, equals: MYSQL_TYPE_STRING.rawValue)
    
    let buffer = UnsafeMutablePointer<CChar>(bindParameter.parameter.buffer)
    assert(buffer[0], equals: 50)
    assert(buffer[1], equals: 55)
    assert(buffer[2], equals: 46)
    assert(buffer[3], equals: 56)

  }
  
  func testInitializeWithNullCreatesEmptyBuffer() {
    let bindParameter = MysqlBindParameter(value: DatabaseValue.Null)
    self.assert(bindParameter.parameter.buffer_length, equals: 0)
    self.assert(bindParameter.parameter.buffer_type.rawValue, equals: MYSQL_TYPE_STRING.rawValue)
  }
  
  func testInitializeWithDataCreatesDataBuffer() {
    let data = NSData(bytes: [
      123,
      95,
      87,
      193
    ])
    let bindParameter = MysqlBindParameter(value: data.databaseValue)
    self.assert(bindParameter.parameter.buffer_length, equals: 4)
    self.assert(bindParameter.parameter.buffer_type.rawValue, equals: MYSQL_TYPE_STRING.rawValue)
    
    let buffer = UnsafeMutablePointer<UInt8>(bindParameter.parameter.buffer)
    assert(buffer[0], equals: 123)
    assert(buffer[1], equals: 95)
    assert(buffer[2], equals: 87)
    assert(buffer[3], equals: 193)
  }
  
  func testInitializeWithTimestampValueCreatesStringBufferWithFormattedString() {
    let timestamp = Timestamp(
      year: 2009,
      month: 2,
      day: 18,
      hour: 11,
      minute: 7,
      second: 14,
      nanosecond: 123456789.5,
      timeZone: Application.sharedDatabaseConnection().timeZone
    )
    let bindParameter = MysqlBindParameter(value: timestamp.databaseValue)
    self.assert(bindParameter.parameter.buffer_length, equals: 1)
    self.assert(bindParameter.parameter.buffer_type.rawValue, equals: MYSQL_TYPE_TIMESTAMP.rawValue)
    
    let data = UnsafeMutablePointer<MYSQL_TIME>(bindParameter.parameter.buffer).memory
    assert(data.year, equals: 2009)
    assert(data.month, equals: 2)
    assert(data.day, equals: 18)
    assert(data.hour, equals: 11)
    assert(data.minute, equals: 7)
    assert(data.second, equals: 14)
    assert(data.second_part, equals: 123456)
    assert(data.neg, equals: 0)
    assert(data.time_type.rawValue, equals: MYSQL_TIMESTAMP_DATETIME.rawValue)
  }
  
  func testInitializeWithTimestampValueInOtherTimeZoneConvertsTimeZone() {
    let timestamp1 = Timestamp(
      year: 2009,
      month: 2,
      day: 18,
      hour: 11,
      minute: 7,
      second: 14,
      nanosecond: 123456789.5,
      timeZone: Application.sharedDatabaseConnection().timeZone
    )
    let policy = timestamp1.timeZone.policy(timestamp: timestamp1.epochSeconds)
    let timeZone2 = TimeZone(offset: policy.offset + 3600)
    let timestamp2 = timestamp1.inTimeZone(timeZone2)
    let bindParameter = MysqlBindParameter(value: timestamp2.databaseValue)
    self.assert(bindParameter.parameter.buffer_length, equals: 1)
    self.assert(bindParameter.parameter.buffer_type.rawValue, equals: MYSQL_TYPE_TIMESTAMP.rawValue)
    
    let data = UnsafeMutablePointer<MYSQL_TIME>(bindParameter.parameter.buffer).memory
    assert(data.year, equals: 2009)
    assert(data.month, equals: 2)
    assert(data.day, equals: 18)
    assert(data.hour, equals: 11)
    assert(data.minute, equals: 7)
    assert(data.second, equals: 14)
    assert(data.second_part, equals: 123456)
    assert(data.neg, equals: 0)
    assert(data.time_type.rawValue, equals: MYSQL_TIMESTAMP_DATETIME.rawValue)
  }
  
  func testInitializeWithDateValueCreatesMysqlTimeBufferWithDateInfo() {
    let date = Date(year: 1998, month: 7, day: 11)
    let bindParameter = MysqlBindParameter(value: date.databaseValue)
    self.assert(bindParameter.parameter.buffer_length, equals: 1)
    self.assert(bindParameter.parameter.buffer_type.rawValue, equals: MYSQL_TYPE_DATE.rawValue)
    
    let data = UnsafeMutablePointer<MYSQL_TIME>(bindParameter.parameter.buffer).memory
    assert(data.year, equals: 1998)
    assert(data.month, equals: 7)
    assert(data.day, equals: 11)
    assert(data.hour, equals: 0)
    assert(data.minute, equals: 0)
    assert(data.second, equals: 0)
    assert(data.second_part, equals: 0)
    assert(data.neg, equals: 0)
    assert(data.time_type.rawValue, equals: MYSQL_TIMESTAMP_DATE.rawValue)
  }
  
  func testInitializeWithTimeValueCreatesMysqlTimeBufferWithTimeInfo() {
    let time = Time(hour: 13, minute: 44, second: 23, nanosecond: 123456789.5)
    let bindParameter = MysqlBindParameter(value: time.databaseValue)
    self.assert(bindParameter.parameter.buffer_length, equals: 1)
    self.assert(bindParameter.parameter.buffer_type.rawValue, equals: MYSQL_TYPE_TIME.rawValue)
    
    let data = UnsafeMutablePointer<MYSQL_TIME>(bindParameter.parameter.buffer).memory
    assert(data.year, equals: 0)
    assert(data.month, equals: 0)
    assert(data.day, equals: 0)
    assert(data.hour, equals: 13)
    assert(data.minute, equals: 44)
    assert(data.second, equals: 23)
    assert(data.second_part, equals: 123456)
    assert(data.neg, equals: 0)
    assert(data.time_type.rawValue, equals: MYSQL_TIMESTAMP_TIME.rawValue)
  }
  
  //MARK: - Field Information
  
  func testIsNullWhenParameterIsNull() {
    connection.executeQuery("INSERT INTO hats (brim_size) VALUES (10)")
    runQuery("SELECT color FROM hats")
    XCTAssertTrue(parameter.isNull)
  }
  
  func testIsNotNullWhenParameterIsNotNull() {
    connection.executeQuery("INSERT INTO hats (color) VALUES ('green')")
    runQuery("SELECT color FROM hats")
    XCTAssertFalse(parameter.isNull)
  }
  
  func testBufferReturnsParameterBuffer() {
    connection.executeQuery("INSERT INTO hats (color) VALUES ('green')")
    runQuery("SELECT color FROM hats")
    assert(parameter.buffer, equals: parameter.parameter.buffer)
  }
  
  func testLengthReturnsParameterLength() {
    connection.executeQuery("INSERT INTO hats (color) VALUES ('green')")
    runQuery("SELECT color FROM hats")
    assert(parameter.length, equals: 5)
  }
  
  //MARK: - Getting Data
  
  func testDataWithStringReturnsString() {
    connection.executeQuery("INSERT INTO hats (color) VALUES ('green')")
    runQuery("SELECT color FROM hats")
    let result = parameter.data().stringValue
    assert(result, equals: "green")
  }
  
  func testDataWithTinyIntReturnsInteger() {
    connection.executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size tinyint")
    connection.executeQuery("INSERT INTO hats (brim_size) VALUES (25)")
    runQuery("SELECT brim_size FROM hats")
    let result = parameter.data().intValue
    assert(result, equals: 25)
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size int(11)")
  }
  
  func testDataWithBitReturnsNumber() {
    connection.executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size bit")
    connection.executeQuery("INSERT INTO hats (brim_size) VALUES (1)")
    runQuery("SELECT brim_size FROM hats")
    let result = parameter.data().intValue
    assert(result, equals: 1)
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size int(11)")
  }
  
  func testDataWithShortIntReturnsNumber() {
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size smallint")
    connection.executeQuery("INSERT INTO hats (brim_size) VALUES (500)")
    runQuery("SELECT brim_size FROM hats")
    let result = parameter.data().intValue
    assert(result, equals: 500)
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size int(11)")
  }
  
  func testDataWithIntReturnsNumber() {
    connection.executeQuery("INSERT INTO hats (brim_size) VALUES (512345)")
    runQuery("SELECT brim_size FROM hats")
    let result = parameter.data().intValue
    assert(result, equals: NSNumber(int: 512345))
  }
  
  func testDataWithLongIntReturnsNumber() {
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size bigint")
    connection.executeQuery("INSERT INTO hats (brim_size) VALUES (123451234545)")
    runQuery("SELECT brim_size FROM hats")
    let result = parameter.data().intValue
    assert(result, equals: 123451234545)
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size int(11)")
  }
  
  func testDataWithFloatReturnsNumber() {
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size float")
    connection.executeQuery("INSERT INTO hats (brim_size) VALUES (10.5)")
    runQuery("SELECT brim_size FROM hats")
    let result = parameter.data().doubleValue
    assert(result, equals: 10.5)
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size int(11)")
    
  }
  
  func testDataWithDoubleReturnsNumber() {
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size double")
    connection.executeQuery("INSERT INTO hats (brim_size) VALUES (10.5)")
    runQuery("SELECT brim_size FROM hats")
    let result = parameter.data().doubleValue
    assert(result, equals: 10.5)
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size int(11)")
    
  }
  
  func testDataWithDecimalReturnsNumber() {
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size decimal(10,2)")
    connection.executeQuery("INSERT INTO hats (brim_size) VALUES (123.45)")
    runQuery("SELECT brim_size FROM hats")
    let result = parameter.data().doubleValue
    assert(result, equals: 123.45)
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size int(11)")
    
  }
  
  func testDataWithDateReturnsDate() {
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN updated_at updated_at date")
    connection.executeQuery("INSERT INTO hats (updated_at) VALUES ('2015-03-14')")
    runQuery("SELECT updated_at FROM hats")
    switch(parameter.data()) {
    case .Date:
      break
    default:
      assert(false, message: "should be date value")
    }
    if let result = parameter.data().dateValue {
      assert(result.year, equals: 2015)
      assert(result.month, equals: 3)
      assert(result.day, equals: 14)
    }
    else {
      XCTFail()
    }
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN updated_at updated_at timestamp")
    
  }
  
  func testDataWithTimeReturnsTime() {
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN updated_at updated_at time")
    connection.executeQuery("INSERT INTO hats (updated_at) VALUES ('09:30:15')")
    runQuery("SELECT updated_at FROM hats")
    switch(parameter.data()) {
    case .Time:
      break
    default:
      assert(false, message: "should be time value")
    }
    if let result = parameter.data().timeValue {
      assert(result.hour, equals: 9)
      assert(result.minute, equals: 30)
      assert(result.second, equals: 15)
      assert(result.timeZone, equals: Application.sharedDatabaseConnection().timeZone)
    }
    else {
      XCTFail()
    }
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN updated_at updated_at timestamp")
    
  }
  
  func testDataWithDatetimeReturnsTimestamp() {
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN updated_at updated_at datetime")
    connection.executeQuery("INSERT INTO hats (updated_at) VALUES ('2015-04-01 09:30:00')")
    runQuery("SELECT updated_at FROM hats")
    
    switch(parameter.data()) {
    case .Timestamp:
      break
    default:
      assert(false, message: "should be timestamp value")
    }
    if let result = parameter.data().timestampValue {
      assert(result.year, equals: 2015)
      assert(result.month, equals: 4)
      assert(result.day, equals: 1)
      assert(result.hour, equals: 9)
      assert(result.minute, equals: 30)
      assert(result.second, equals: 0)
    }
    else {
      XCTFail()
    }
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN updated_at updated_at timestamp")
  }
  
  func testDataWithTimestampReturnsTimestamp() {
    connection.executeQuery("INSERT INTO hats (updated_at) VALUES ('2015-04-01 09:30:00')")
    runQuery("SELECT updated_at FROM hats")
    
    switch(parameter.data()) {
    case .Timestamp:
      break
    default:
      assert(false, message: "should be timestamp value")
    }
    if let result = parameter.data().timestampValue {
      assert(result.year, equals: 2015)
      assert(result.month, equals: 4)
      assert(result.day, equals: 1)
      assert(result.hour, equals: 9)
      assert(result.minute, equals: 30)
      assert(result.second, equals: 0)
    }
    else {
      XCTFail()
    }
  }
  
  func testDataWithBlobReturnsValue() {
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN color color blob")
    var bytes = [1,2,3,4,5]
    let data = NSData(bytes: &bytes, length: 5)
    connection.executeQuery("INSERT INTO hats (color) VALUES (?)", parameters: [data.databaseValue])
    runQuery("SELECT color FROM hats")
    let result = parameter.data().dataValue
    assert(result, equals: data)
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN color color varchar(255)")
    
  }
  
  func testDataWithTextReturnsValue() {
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN color color text")
    connection.executeQuery("INSERT INTO hats (color) VALUES ('red')")
    runQuery("SELECT color FROM hats")
    let result = parameter.data().stringValue
    assert(result, equals: "red")
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN color color varchar(255)")
    
  }
  
  func testCanSendAndReceiveTimestamp() {
    let timestamp = 20.minutes.ago.inTimeZone(Application.sharedDatabaseConnection().timeZone)
    let connection = Application.sharedDatabaseConnection()
    connection.executeQuery("INSERT INTO `hats` (`updated_at`) VALUES (?)", timestamp)
    let rows = connection.executeQuery("SELECT * FROM `hats`")
    if rows.count > 0 {
      let result = rows[0].data["updated_at"]?.timestampValue
      assert(result?.epochSeconds, within: 0.5, of: timestamp.epochSeconds)
    }
    else {
      assert(false)
    }
  }
  
  func testCanSendAndReceiveTime() {
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN updated_at updated_at time")
    let time = 45.minutes.ago.inTimeZone(Application.sharedDatabaseConnection().timeZone).change(nanosecond: 0).time
    let connection = Application.sharedDatabaseConnection()
    connection.executeQuery("INSERT INTO `hats` (`updated_at`) VALUES (?)", time)
    let rows = connection.executeQuery("SELECT * FROM `hats`")
    if rows.count > 0 {
      let result = rows[0].data["updated_at"]?.timeValue
      assert(result, equals: time)
    }
    else {
      assert(false)
    }
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN updated_at updated_at timestamp")
  }
  
  func testCanSendAndReceiveDate() {
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN updated_at updated_at date")
    let date = 3.months.ago.date
    let connection = Application.sharedDatabaseConnection()
    connection.executeQuery("INSERT INTO `hats` (`updated_at`) VALUES (?)", date)
    let rows = connection.executeQuery("SELECT * FROM `hats`")
    if rows.count > 0 {
      let result = rows[0].data["updated_at"]?.dateValue
      assert(result, equals: date)
    }
    else {
      assert(false)
    }
    Application.sharedDatabaseConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN updated_at updated_at timestamp")
  }
  
  //MARK: - Comparison
  
  func generateParameter(buffer buffer: UnsafeMutablePointer<Void>, length: UInt, type: enum_field_types) -> MYSQL_BIND {
    var parameter = MYSQL_BIND()
    parameter.buffer = buffer
    parameter.length = UnsafeMutablePointer<UInt>(calloc(1, sizeof(UInt)))
    parameter.length.memory = length
    parameter.buffer_type = type
    return parameter
  }
  
  func testBindParametersAreEqualWithSameInformation() {
    let buffer = malloc(10)
    let field1 = MysqlBindParameter(parameter: generateParameter(buffer: buffer, length: 10, type: MYSQL_TYPE_VARCHAR))
    let field2 = MysqlBindParameter(parameter: generateParameter(buffer: buffer, length: 10, type: MYSQL_TYPE_VARCHAR))
    assert(field1, equals: field2)
    free(buffer)
    free(field1.parameter.length)
    free(field2.parameter.length)
  }
  
  func testBindParametersAreUnequalWitDifferentBuffers() {
    let buffer1 = malloc(10)
    let buffer2 = malloc(10)
    let field1 = MysqlBindParameter(parameter: generateParameter(buffer: buffer1, length: 10, type: MYSQL_TYPE_VARCHAR))
    let field2 = MysqlBindParameter(parameter: generateParameter(buffer: buffer2, length: 10, type: MYSQL_TYPE_VARCHAR))
    assert(field1, doesNotEqual: field2)
    free(buffer1)
    free(buffer2)
    free(field1.parameter.length)
    free(field2.parameter.length)
  }
  
  func testBindParametersAreUnequalWithDifferentLengths() {
    let buffer = malloc(10)
    let field1 = MysqlBindParameter(parameter: generateParameter(buffer: buffer, length: 10, type: MYSQL_TYPE_VARCHAR))
    let field2 = MysqlBindParameter(parameter: generateParameter(buffer: buffer, length: 9, type: MYSQL_TYPE_VARCHAR))
    assert(field1, doesNotEqual: field2)
    free(buffer)
    free(field1.parameter.length)
    free(field2.parameter.length)
  }
  
  func testBindParametersAreUnequalWithDifferentTypes() {
    let buffer = malloc(10)
    let field1 = MysqlBindParameter(parameter: generateParameter(buffer: buffer, length: 10, type: MYSQL_TYPE_VARCHAR))
    let field2 = MysqlBindParameter(parameter: generateParameter(buffer: buffer, length: 10, type: MYSQL_TYPE_STRING))
    assert(field1, doesNotEqual: field2)
    free(buffer)
    free(field1.parameter.length)
    free(field2.parameter.length)
  }
}