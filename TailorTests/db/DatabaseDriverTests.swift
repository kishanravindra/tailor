import XCTest
import Tailor
import TailorTesting
import TailorSqlite

class DatabaseDriverTests: TailorTestCase {
  //MARK: - Initialization
  
  override func tearDown() {
    
    Application.removeSharedDatabaseConnection()
    super.tearDown()
  }
  
  func testSharedConnectionOpensWithDriverFromConfiguration() {
    TestConnection.connectionCount = 0
    Application.configuration.databaseDriver = { return TestConnection(config: [:]) }
    
    Application.removeSharedDatabaseConnection()
    assert(NSStringFromClass(Application.sharedDatabaseConnection().dynamicType), equals: NSStringFromClass(TestConnection.self), message: "has a test connection as the shared connection")
    assert(TestConnection.connectionCount, equals: 1, message: "increments the connection count")
  }
  
  func testSharedConnectionReusesConnectionInSameThread() {
    TestConnection.connectionCount = 0
    Application.configuration.databaseDriver = { return TestConnection(config: [:]) }
    
    Application.removeSharedDatabaseConnection()
    Application.sharedDatabaseConnection()
    assert(TestConnection.connectionCount, equals: 1, message: "increments the connection count")
    Application.sharedDatabaseConnection()
    assert(TestConnection.connectionCount, equals: 1, message: "does not increment the connection count on a subsequent call")
  }
  
  func testSharedConnectionOpensSeparateConnectionInNewThread() {
    TestConnection.connectionCount = 0
    Application.configuration.databaseDriver = { return TestConnection(config: [:]) }
    
    Application.removeSharedDatabaseConnection()
    Application.sharedDatabaseConnection()
    let expectation = expectationWithDescription("executes block in thread")
    dispatch_async(dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)) {
      expectation.fulfill()
      Application.sharedDatabaseConnection()
      self.assert(TestConnection.connectionCount, equals: 2, message: "creates two connections")
    }
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }
  
  func testRowInitializationWithConvertibleValuesWrapsValues() {
    let row = DatabaseRow(rawData: ["name": "John", "height": 200])
    let name = row.data["name"]?.stringValue
    assert(name, equals: "John")
    let height = row.data["height"]?.intValue
    assert(height, equals: 200)
  }
  
  func testRowInitializationWithErrorSetsError() {
    let row = DatabaseRow(error: "my error")
    assert(row.error, equals: "my error")
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
  
  func testSanitizeColumnNameRemovesSpecialCharacters() {
    let sanitizedName = Application.sharedDatabaseConnection().sanitizeColumnName("color;brim_size")
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
  
  //MARK: - Database Row
  
  func testDatabaseRowReadWithStringValueCanReadStringValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.String("value1")])
    do {
      let value = try row.read("key1") as String
      assert(value, equals: "value1")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDatabaseRowReadWithStringValueThrowsExceptionOnIntegerValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Integer(5)])
    do {
      _ = try row.read("key1") as String
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "Integer")
      assert(desiredType, equals: "String")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDatabaseRowReadWithStringValueThrowsExceptionOnTimestampValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Timestamp(Timestamp.now())])
    do {
      _ = try row.read("key1") as String
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "Timestamp")
      assert(desiredType, equals: "String")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDatabaseRowReadWithStringValueThrowsExceptionForMissingValue() {
    let row = DatabaseRow(data: ["key2": DatabaseValue.Integer(5)])
    do {
      _ = try row.read("key1") as String
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.MissingField(name) {
      assert(name, equals: "key1")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDatabaseRowReadWithIntegerValueCanReadIntegerValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Integer(12)])
    do {
      let value = try row.read("key1") as Int
      assert(value, equals: 12)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDatabaseRowReadWithIntegerValueThrowsExceptionForStringValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.String("hello")])
    do {
      _ = try row.read("key1") as Int
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "String")
      assert(desiredType, equals: "Int")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDatabaseRowReadWithTimestampValueCanReadTimestampValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Timestamp(Timestamp.now())])
    do {
      let value = try row.read("key1") as Timestamp
      assert(value, equals: Timestamp.now())
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDatabaseRowReadWithTimestampValueCanReadStringWithValidTimestamp() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.String("2015-12-14 09:30:00")])
    do {
      let value = try row.read("key1") as Timestamp
      assert(value, equals: Timestamp(year: 2015, month: 12, day: 14, hour: 9, minute: 30, second: 0, nanosecond: 0))
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDatabaseRowReadWithTimestampValueThrowsExceptionForIntegerValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Integer(14)])
    do {
      _ = try row.read("key1") as Timestamp
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "Integer")
      assert(desiredType, equals: "Timestamp")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }

  func testDatabaseRowReadWithTimestampValueThrowsExceptionForStringValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.String("hello")])
    do {
      _ = try row.read("key1") as Timestamp
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "String")
      assert(desiredType, equals: "Timestamp")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDatabaseRowReadWithDateValueCanReadDateValue() {
    let date = Date.today()
    let row = DatabaseRow(data: ["key1": DatabaseValue.Date(date)])
    do {
      let value = try row.read("key1") as Date
      assert(value, equals: date)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDatabaseRowReadWithDateValueThrowsExceptionForIntegerValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Integer(5)])
    do {
      _ = try row.read("key1") as Date
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "Integer")
      assert(desiredType, equals: "Date")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDatabaseRowReadWithTimeValueCanReadTimeValue() {
    let time = Timestamp.now().time
    let row = DatabaseRow(data: ["key1": DatabaseValue.Time(time)])
    do {
      let value = try row.read("key1") as Time
      assert(value, equals: time)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDatabaseRowReadWithTimeValueThrowsExceptionForIntegerValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Integer(5)])
    do {
      _ = try row.read("key1") as Time
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "Integer")
      assert(desiredType, equals: "Time")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDatabaseRowReadWithBoolValueCanReadBoolValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Boolean(true), "key2": DatabaseValue.Boolean(false)])
    do {
      let value1 = try row.read("key1") as Bool
      let value2 = try row.read("key2") as Bool
      assert(value1, equals: true)
      assert(value2, equals: false)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDatabaseRowReadWithBoolValueCanReadIntegerValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Integer(1), "key2": DatabaseValue.Integer(0)])
    do {
      let value1 = try row.read("key1") as Bool
      let value2 = try row.read("key2") as Bool
      assert(value1, equals: true)
      assert(value2, equals: false)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDatabaseRowReadWithBooleanValueThrowsExceptionForStringValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.String("true")])
    do {
      _ = try row.read("key1") as Bool
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "String")
      assert(desiredType, equals: "Bool")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDatabaseRowReadWithDataValueCanReadDataValue() {
    let data = NSData(bytes: [1,2,3,4])
    let row = DatabaseRow(data: ["key1": DatabaseValue.Data(data)])
    do {
      let value = try row.read("key1") as NSData
      assert(value, equals: data)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDatabaseRowReadWithDataValueThrowsExceptionForIntegerValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Integer(5)])
    do {
      _ = try row.read("key1") as NSData
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "Integer")
      assert(desiredType, equals: "NSData")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDatabaseRowReadWithDoubleValueCanReadDoubleValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Double(1.5)])
    do {
      let value = try row.read("key1") as Double
      assert(value, equals: 1.5)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDatabaseRowReadWithDoubleValueThrowsExceptionForIntegerValue() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Integer(5)])
    do {
      _ = try row.read("key1") as Double
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "Integer")
      assert(desiredType, equals: "Double")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testDatabaseRowReadWithUnsupportedTypeThrowsException() {
    let row = DatabaseRow(data: ["key1": DatabaseValue.Integer(5)])
    do {
      _ = try row.read("key1") as Hat
      assert(false, message: "threw unexpected exception")
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      assert(name, equals: "key1")
      assert(actualType, equals: "Integer")
      assert(desiredType, equals: "Hat")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
}
