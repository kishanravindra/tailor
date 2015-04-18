import Tailor
import TailorTesting
import XCTest

class MysqlBindParameterTests: TailorTestCase {
  var connection: MysqlConnection { return DatabaseConnection.sharedConnection() as! MysqlConnection }
  var parameterSet: MysqlBindParameterSet!
  var parameter: MysqlBindParameter! {
    if let parameters = parameterSet?.parameters {
      if parameters.count > 0 {
        return parameters[0]
      }
    }
    return nil
  }
  
  func runQuery(query: String) {
    let statement = mysql_stmt_init(connection.connection)
    
    let encodedQuery = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
    
    mysql_stmt_prepare(statement, UnsafePointer<Int8>(encodedQuery.bytes), UInt(encodedQuery.length))
    
    let resultSet = MysqlResultSet(statement: statement)
    parameterSet = MysqlBindParameterSet(resultSet: resultSet)
    NSLog("Query is %@", query)
    parameterSet.bindToOutputOfStatement(statement)
    mysql_stmt_execute(statement)
    mysql_stmt_fetch(statement)
    mysql_stmt_close(statement)
  }
  
  func dateComponents(date: NSDate) -> NSDateComponents {
    let calendar = NSCalendar(calendarIdentifier: NSCalendar.currentCalendar().calendarIdentifier)!
    calendar.timeZone = DatabaseConnection.sharedConnection().timeZone
    return calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond, fromDate: date)
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  //MARK: - Creation
  
  func testDefaultInitializerCreatesEmptyParameter() {
    let bindParameter = MysqlBindParameter()
    self.assert(bindParameter.parameter.buffer_length, equals: 0)
  }
  
  func testInitializeWithFieldSetsBufferInformation() {
    runQuery("SELECT color FROM hats")
    self.assert(parameter.parameter.buffer_type.value, equals: MYSQL_TYPE_VAR_STRING.value)
    self.assert(parameter.parameter.buffer_length, equals: 1024)
  }
  
  func testInitializeWithStringValueCreatesStringBuffer() {
    let string = "hello"
    let bindParameter = MysqlBindParameter(value: string.databaseValue)
    self.assert(bindParameter.parameter.buffer_length, equals: 5)
    self.assert(bindParameter.parameter.buffer_type.value, equals: MYSQL_TYPE_STRING.value)
    
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
    self.assert(bindParameter.parameter.buffer_type.value, equals: MYSQL_TYPE_STRING.value)
    
    let buffer = UnsafeMutablePointer<CChar>(bindParameter.parameter.buffer)
    assert(buffer[0], equals: 53)
  }
  
  func testInitializeWithBooleanCreatesStringBufferWithIntegerValue() {
    let bindParameter = MysqlBindParameter(value: true.databaseValue)
    self.assert(bindParameter.parameter.buffer_length, equals: 1)
    self.assert(bindParameter.parameter.buffer_type.value, equals: MYSQL_TYPE_STRING.value)
    
    let buffer = UnsafeMutablePointer<CChar>(bindParameter.parameter.buffer)
    assert(buffer[0], equals: 49)
  }
  
  func testInitializeWithDoubleCreatesStringBuffer() {
    let bindParameter = MysqlBindParameter(value: 27.8.databaseValue)
    self.assert(bindParameter.parameter.buffer_length, equals: 4)
    self.assert(bindParameter.parameter.buffer_type.value, equals: MYSQL_TYPE_STRING.value)
    
    let buffer = UnsafeMutablePointer<CChar>(bindParameter.parameter.buffer)
    assert(buffer[0], equals: 50)
    assert(buffer[1], equals: 55)
    assert(buffer[2], equals: 46)
    assert(buffer[3], equals: 56)

  }
  
  func testInitializeWithNullCreatesEmptyBuffer() {
    let bindParameter = MysqlBindParameter(value: DatabaseValue.Null)
    self.assert(bindParameter.parameter.buffer_length, equals: 0)
    self.assert(bindParameter.parameter.buffer_type.value, equals: MYSQL_TYPE_STRING.value)
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
    self.assert(bindParameter.parameter.buffer_type.value, equals: MYSQL_TYPE_STRING.value)
    
    let buffer = UnsafeMutablePointer<UInt8>(bindParameter.parameter.buffer)
    assert(buffer[0], equals: 123)
    assert(buffer[1], equals: 95)
    assert(buffer[2], equals: 87)
    assert(buffer[3], equals: 193)
  }
  
  func testInitializeWithDateValueCreatesStringBufferWithFormattedString() {
    // 2009-02-18 11:07:14
    let date = NSDate(timeIntervalSince1970: 1234973234)
    NSLog("Date is %@", date.format("db")!)
      let bindParameter = MysqlBindParameter(value: date.databaseValue)
    self.assert(bindParameter.parameter.buffer_length, equals: 19)
    self.assert(bindParameter.parameter.buffer_type.value, equals: MYSQL_TYPE_STRING.value)
    
    let buffer = UnsafeMutablePointer<CChar>(bindParameter.parameter.buffer)
    assert(buffer[0], equals: 50)
    assert(buffer[1], equals: 48)
    assert(buffer[2], equals: 48)
    assert(buffer[3], equals: 57)
    assert(buffer[4], equals: 45)
    assert(buffer[5], equals: 48)
    assert(buffer[6], equals: 50)
    assert(buffer[7], equals: 45)
    assert(buffer[8], equals: 49)
    assert(buffer[9], equals: 56)
    assert(buffer[10], equals: 32)
    assert(buffer[11], equals: 49)
    assert(buffer[12], equals: 54)
    assert(buffer[13], equals: 58)
    assert(buffer[14], equals: 48)
    assert(buffer[15], equals: 55)
    assert(buffer[16], equals: 58)
    assert(buffer[17], equals: 49)
    assert(buffer[18], equals: 52)
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
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size int(11)")
  }
  
  func testDataWithBitReturnsNumber() {
    connection.executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size bit")
    connection.executeQuery("INSERT INTO hats (brim_size) VALUES (1)")
    runQuery("SELECT brim_size FROM hats")
    let result = parameter.data().intValue
    assert(result, equals: 1)
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size int(11)")
  }
  
  func testDataWithShortIntReturnsNumber() {
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size smallint")
    connection.executeQuery("INSERT INTO hats (brim_size) VALUES (500)")
    runQuery("SELECT brim_size FROM hats")
    let result = parameter.data().intValue
    assert(result, equals: 500)
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size int(11)")
  }
  
  func testDataWithIntReturnsNumber() {
    connection.executeQuery("INSERT INTO hats (brim_size) VALUES (512345)")
    runQuery("SELECT brim_size FROM hats")
    let result = parameter.data().intValue
    assert(result, equals: NSNumber(int: 512345))
  }
  
  func testDataWithLongIntReturnsNumber() {
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size bigint")
    connection.executeQuery("INSERT INTO hats (brim_size) VALUES (123451234545)")
    runQuery("SELECT brim_size FROM hats")
    let a = sizeof(CInt)
    let b = sizeof(CShort)
    let c = sizeof(CLongLong)
    let result = parameter.data().intValue
    assert(result, equals: 123451234545)
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size int(11)")
  }
  
  func testDataWithFloatReturnsNumber() {
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size float")
    connection.executeQuery("INSERT INTO hats (brim_size) VALUES (10.5)")
    runQuery("SELECT brim_size FROM hats")
    let result = parameter.data().doubleValue
    assert(result, equals: 10.5)
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size int(11)")
    
  }
  
  func testDataWithDoubleReturnsNumber() {
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size double")
    connection.executeQuery("INSERT INTO hats (brim_size) VALUES (10.5)")
    runQuery("SELECT brim_size FROM hats")
    let result = parameter.data().doubleValue
    assert(result, equals: 10.5)
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size int(11)")
    
  }
  
  func testDataWithDecimalReturnsNumber() {
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size decimal(10,2)")
    connection.executeQuery("INSERT INTO hats (brim_size) VALUES (123.45)")
    runQuery("SELECT brim_size FROM hats")
    let result = parameter.data().doubleValue
    assert(result, equals: 123.45)
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN brim_size brim_size int(11)")
    
  }
  
  func testDataWithTimeReturnsDateWithThatDate() {
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN updated_at updated_at date")
    connection.executeQuery("INSERT INTO hats (updated_at) VALUES ('2015-03-14')")
    runQuery("SELECT updated_at FROM hats")
    if let result = parameter.data().dateValue {
      let components = dateComponents(result)
      assert(components.year, equals: 2015)
      assert(components.month, equals: 3)
      assert(components.day, equals: 14)
    }
    else {
      XCTFail()
    }
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN updated_at updated_at timestamp")
    
  }
  
  func testDataWithDateTimeReturnsDateWithThatDateTime() {
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN updated_at updated_at datetime")
    connection.executeQuery("INSERT INTO hats (updated_at) VALUES ('2015-04-01 09:30:00')")
    runQuery("SELECT updated_at FROM hats")
    if let result = parameter.data().dateValue {
      let components = dateComponents(result)
      assert(components.year, equals: 2015)
      assert(components.month, equals: 4)
      assert(components.day, equals: 1)
      assert(components.hour, equals: 9)
      assert(components.minute, equals: 30)
      assert(components.second, equals: 0)
    }
    else {
      XCTFail()
    }
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN updated_at updated_at timestamp")
  }
  
  func testDataWithTimestampReturnsDateWithThatTimestamp() {
    connection.executeQuery("INSERT INTO hats (updated_at) VALUES ('2015-04-01 09:30:00')")
    runQuery("SELECT updated_at FROM hats")
    if let result = parameter.data().dateValue {
      let components = dateComponents(result)
      assert(components.year, equals: 2015)
      assert(components.month, equals: 4)
      assert(components.day, equals: 1)
      assert(components.hour, equals: 9)
      assert(components.minute, equals: 30)
      assert(components.second, equals: 0)
    }
    else {
      XCTFail()
    }
  }
  
  func testDataWithTimestampReturnsDateWithThatTime() {
    connection.executeQuery("INSERT INTO hats (updated_at) VALUES ('2015-04-01 09:30:00')")
    runQuery("SELECT updated_at FROM hats")
    if let result = parameter.data().dateValue {
      let components = dateComponents(result)
      assert(components.year, equals: 2015)
      assert(components.month, equals: 4)
      assert(components.day, equals: 1)
      assert(components.hour, equals: 9)
      assert(components.minute, equals: 30)
      assert(components.second, equals: 0)
    }
    else {
      XCTFail()
    }
  }

  func testDataWithBlobReturnsValue() {
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN color color blob")
    var bytes = [1,2,3,4,5]
    let data = NSData(bytes: &bytes, length: 5)
    connection.executeQuery("INSERT INTO hats (color) VALUES (?)", parameters: [data.databaseValue])
    runQuery("SELECT color FROM hats")
    let result = parameter.data().dataValue
    assert(result, equals: data)
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN color color varchar(255)")
    
  }
  
  func testDataWithTextReturnsValue() {
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN color color text")
    connection.executeQuery("INSERT INTO hats (color) VALUES ('red')")
    runQuery("SELECT color FROM hats")
    let data = NSData(bytes: parameter.buffer, length: Int(parameter.length))
    NSLog("Raw data: %@", data)
    let result = parameter.data().stringValue
    assert(result, equals: "red")
    DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE hats CHANGE COLUMN color color varchar(255)")
    
  }
}