import XCTest

class MysqlConnectionTests: XCTestCase {
  var connection: MysqlConnection { get { return DatabaseConnection.sharedConnection() as! MysqlConnection } }
  
  override func setUp() {
    TestApplication.start()
    connection.executeQuery("TRUNCATE TABLE `hats`")
    connection.executeQuery("INSERT INTO `hats` (`color`, `brim_size`) VALUES ('red', 10)")
  }
  
  func testInitializationGetsTimeZoneFromDatabaseSettings() {
    let initialZone = connection.executeQuery("SELECT @@global.time_zone AS time_zone")[0].data["time_zone"] as! String
    
    connection.executeQuery("SET GLOBAL time_zone='UTC'")
    DatabaseConnection.openSharedConnection()
    XCTAssertEqual(connection.timeZone.secondsFromGMT, 0, "gets a time zone of UTC from the database")

    connection.executeQuery("SET GLOBAL time_zone='America/Recife'")
    DatabaseConnection.openSharedConnection()
    XCTAssertEqual(connection.timeZone.secondsFromGMT, -10800, "gets a named time zone from the database")
    
    connection.executeQuery("SET GLOBAL time_zone='+05:00'")
    DatabaseConnection.openSharedConnection()
    XCTAssertEqual(connection.timeZone.secondsFromGMT, 18000, "gets a time zone with an offset from the database")

    connection.executeQuery("SET GLOBAL time_zone=?", initialZone)
    DatabaseConnection.openSharedConnection()
  }
  
  func testQueryCanGetResults() {
    let results = connection.executeQuery("SELECT * FROM hats")
    XCTAssertEqual(results.count, 1, "gets one row")
    if results.count == 1 {
      let result = results[0]
      XCTAssertNil(result.error, "does not have an error on the result")
      
      if let color = result.data["color"] as? String {
        XCTAssertEqual(color, "red", "gets a string field")
      }
      else {
        XCTFail("gets a string value")
      }
      
      if let brimSize = result.data["brim_size"] as? Int {
        XCTAssertEqual(brimSize, 10, "gets a numeric field")
      }
      else {
        XCTFail("gets a numeric value")
      }
    }
    else {
      XCTFail("gets results")
    }
  }
  
  func testQueryCanGetTimestampValue() {
    connection.executeQuery("UPDATE `hats` SET `updated_at` = '2014-10-18 09:30:00'")
    let results = connection.executeQuery("SELECT * FROM hats")
    
    if results.count == 1 {
      let result = results[0]
      
      if let date = result.data["updated_at"] as? NSDate {
        let calendar = NSCalendar.currentCalendar()
        let oldTimeZone = calendar.timeZone
        calendar.timeZone = NSTimeZone(name: "UTC")!
        let components = calendar.components(.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit | .HourCalendarUnit | .MinuteCalendarUnit | .SecondCalendarUnit,
          fromDate: date)
        XCTAssertEqual(components.year, 2014, "gets the year from the date")
        XCTAssertEqual(components.month, 10, "gets the month from the date")
        XCTAssertEqual(components.day, 18, "gets the day from the date")
        XCTAssertEqual(components.hour, 9, "gets the hour from the date")
        XCTAssertEqual(components.minute, 30, "gets the minute from the date")
        XCTAssertEqual(components.second, 0, "gets the second from the date")
        calendar.timeZone = oldTimeZone
      }
      else {
        XCTFail("gets a date value")
      }
    }
    else {
      XCTFail("gets results")
    }
  }
  
  func testQueryCanGetBlobValue() {
    connection.executeQuery("ALTER TABLE `hats` ADD COLUMN `image` BLOB")
    let bytes = [1,2,3,4]
    let byteCount = bytes.count * sizeof(Int)
    let data = NSData(bytes: UnsafePointer<Int>(bytes), length: byteCount)
    connection.executeQuery("UPDATE `hats` SET `image`=?", parameters: [data])
    let results = connection.executeQuery("SELECT * FROM hats")
    XCTAssertEqual(results.count, 1, "gets one row")
    if results.count == 1 {
      let result = results[0]
      XCTAssertNil(result.error, "does not have an error on the result")
      
      var fetchedBytes = [Int](count: 4, repeatedValue: 0)
      XCTAssertEqual(data.length, byteCount, "has sixteen bytes from the blob")
      data.getBytes(&fetchedBytes, length: byteCount)
      if let data = result.data["image"] as? NSData {
        XCTAssertEqual(fetchedBytes, [1,2,3,4], "gets bytes from blob")
      }
      else {
        XCTFail("gets a data value")
      }
    }
    connection.executeQuery("ALTER TABLE `hats` REMOVE COLUMN `image`")
  }
  
  func testQueryCanGetNullValue() {
    connection.executeQuery("UPDATE `hats` SET `brim_size`=NULL")
    let results = connection.executeQuery("SELECT * FROM `hats`")
    XCTAssertEqual(results.count, 1, "gets one row")
    if results.count == 1 {
      let result = results[0]
      XCTAssertNil(result.error, "does not have an error on the result")
      let brimSize = result.data["brim_size"]
      XCTAssertTrue(brimSize == nil, "has a nil brim size")
    }
  }
  
  func testQueryCanUseBindParameters() {
    connection.executeQuery("INSERT INTO `hats` (`color`, `brim_size`) VALUES ('black', 12)")
    let results = connection.executeQuery("SELECT * FROM `hats` WHERE color = ?", "black")
    XCTAssertEqual(results.count, 1, "gets one row")
    if results.count == 1 {
      let result = results[0]
      if let brimSize = result.data["brim_size"] as? Int {
        XCTAssertEqual(brimSize, 12, "gets the correct record")
      }
      else {
        XCTFail("Gets the correct brim size")
      }
    }
  }
  
  func testQueryCanReturnMultipleRows() {
    connection.executeQuery("INSERT INTO `hats` (`color`, `brim_size`) VALUES ('black', 12)")
    let results = connection.executeQuery("SELECT * FROM `hats` ORDER BY `id` ASC")
    XCTAssertEqual(results.count, 2, "gets two rows")
    if results.count == 2 {
      if let color = results[0].data["color"] as? String {
        XCTAssertEqual(color, "red", "gets the first row's color")
      }
      else {
        XCTFail("Gets the first row's color")
      }
      if let color = results[1].data["color"] as? String {
        XCTAssertEqual(color, "black", "gets the second row's color")
      }
      else {
        XCTFail("Gets the second row's color")
      }
    }
  }
  
  func testQueryReturnsIdOnInsert() {
    let results = connection.executeQuery("INSERT INTO `hats` (`color`, `brim_size`) VALUES ('black', 12)")
    XCTAssertEqual(results.count, 1, "gets one row")
    if results.count == 1 {
      if let id = results[0].data["id"] as? Int {
        XCTAssertEqual(id, 2, "gets the id of the new row")
      }
      else {
        XCTFail("gets the id of the new row")
      }
    }
  }
  
  func testQueryCanGetErrorValue() {
    let results = connection.executeQuery("SELECT `name` FROM `hats`")
    XCTAssertEqual(results.count, 1, "gets one row")
    if results.count == 1 {
      let result = results[0]
      XCTAssertNotNil(result.error, "has an error on the result")
      if result.error != nil {
        XCTAssertEqual(result.error!, "Unknown column 'name' in 'field list'")
      }
    }
  }
}
