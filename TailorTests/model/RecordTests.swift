import XCTest
import Tailor
import TailorTesting

class RecordTests: TailorTestCase {
  override func setUp() {
    Application.start()
    DatabaseConnection.sharedConnection().executeQuery("TRUNCATE TABLE `hats`")
    DatabaseConnection.sharedConnection().executeQuery("TRUNCATE TABLE `shelfs`")
    DatabaseConnection.sharedConnection().executeQuery("TRUNCATE TABLE `stores`")
  }
  
  override func tearDown() {
    
  }
  
  //MARK: - Initialization
  
  func testInitializerSetsAttributesFromData() {
    let hat = Hat(data: ["id": 5, "brimSize": 10, "color": "black"])
    assert(hat.id, equals: NSNumber(integer: 5), message: "sets the id")
    assert(hat.brimSize, equals: NSNumber(integer: 10), message: "sets the brim size")
    assert(hat.color, equals: "black", message: "sets the color")
  }
  
  func testInitializerCanTakeAttributesFromDatabaseNames() {
    let hat = Hat(data: ["id": 3, "brim_size": 12, "color": "red"], fromDatabase: true)
    assert(hat.id, equals: NSNumber(integer: 3), message: "sets the id")
    assert(hat.brimSize, equals: NSNumber(integer: 12), message: "sets the brim size")
    assert(hat.color, equals: "red", message: "sets the color")
  }
  
  func testInitializerDoesNotSetUnpersistedProperty() {
    let hat = Hat(data: ["id": 4, "owner": "Jim"])
    XCTAssertNil(hat.owner, "does not set owner")
  }
  
  //MARK: - Structure
  
  func testTableNameIsPluralizedModelName() {
    assert(Hat.tableName(), equals: "hats", message: "gets table name")
  }
  
  func testForeignKeyNameIsModelNamePlusId() {
    assert(Hat.foreignKeyName(), equals: "hatId", message: "gets foreign key")
  }
  
  func testColumnNameIsUnderscoredName() {
    if let columnName = Hat.columnNameForField("brimSize") {
      assert(columnName, equals: "brim_size", message: "gets underscored name")
    }
    else {
      XCTFail("gets underscored name")
    }
  }
  
  func testColumnNameIsNilForUnpersistedProperty() {
    XCTAssertNil(Hat.columnNameForField("owner"), "column name is nil")
  }
  
  func testToOneFetchesRecordsById() {
    let shelf1 = Shelf.create(["name": "First Shelf"])
    let shelf2 = Shelf.create(["name": "Second Shelf"])
    let hat = Hat.create(["shelfId": shelf2.id])
    if let result : Shelf = hat.toOne() {
      assert(shelf2.name, equals: result.name, message: "fetches the second shelf")
    }
    else {
      XCTFail("fetches the second shelf")
    }
  }
  
  func testToManyFetchesRecordsByForeignKey() {
    let shelf = Shelf.create([:])
    let query : Query<Hat> = shelf.toMany()
    let clause = query.whereClause
    assert(clause.query, equals: "hats.shelf_id=?", message: "has the shelfId in the query")
    assert(clause.parameters, equals: [shelf.id.stringValue], message: "has the id as the parameter")
  }
  
  func testToManyThroughFetchesManyRecordsByForeignKey() {
    let store = Store.create([:])
    let shelfQuery : Query<Shelf> = store.toMany()
    let query : Query<Hat> = store.toMany(through: shelfQuery, joinToMany: true)

    let whereClause = query.whereClause
    assert(whereClause.query, equals: "shelfs.store_id=?")
    assert(whereClause.parameters, equals: [store.id.stringValue], message: "has the id as the parameter")
    
    let joinClause = query.joinClause
    assert(joinClause.query, equals: "INNER JOIN shelfs ON shelfs.id = hats.shelf_id", message: "joins between shelves and hats in the join clause")
    assert(joinClause.parameters.count, equals: 0, message: "has no parameters in the join clause")
  }
  
  func testToManyThroughFetchesOneRecordsByForeignKey() {
    let hat = Hat.create(["shelfId": 1])
    let shelfQuery = Query<Shelf>().filter(["id": hat.shelfId])
    let query : Query<Store> = hat.toMany(through: shelfQuery, joinToMany: false)
    
    let whereClause = query.whereClause
    assert(whereClause.query, equals: "shelfs.id=?")
    assert(whereClause.parameters, equals: [hat.shelfId.stringValue], message: "has the id as the parameter")
    
    let joinClause = query.joinClause
    assert(joinClause.query, equals: "INNER JOIN shelfs ON shelfs.store_id = stores.id", message: "joins between shelves and stores in the join clause")
    assert(joinClause.parameters.count, equals: 0, message: "has no parameters in the join clause")
  }
  
  //MARK: - Creating
  
  func testSerializeValueSerializesStringValue() {
    let input = "testString"
    let (string,data) = Record.serializeValueForQuery(input, key: "key")
    
    XCTAssertNotNil(string, "has a string version")
    if(string != nil) {
      assert(string!, equals: input, message: "has the input string as the string version")
    }
    
    XCTAssertNotNil(data, "has a data version")
    if(data != nil) {
      assert(data!, equals: input.dataUsingEncoding(NSUTF8StringEncoding)!, message: "has the input string encoded as the data version")
    }
  }
  
  func testSerializeValueSerializesDateValue() {
    //DatabaseConnection.sharedConnection().timeZone = NSTimeZone(name: "UTC")!
    let input = NSDate(timeIntervalSince1970: 1231234125)
    let formattedString = "2009-01-06 09:28:45"
    let (string,data) = Record.serializeValueForQuery(input, key: "key")
    
    XCTAssertNotNil(string, "has a string version")
    if(string != nil) {
      assert(string!, equals: formattedString, message: "has the formatted date as the string version")
    }
    
    XCTAssertNotNil(data, "has a data version")
    if(data != nil) {
      assert(data!, equals: formattedString.dataUsingEncoding(NSUTF8StringEncoding)!, message: "has the formatted date encoded as the data version")
    }
  }
  
  func testSerializeValueSerializesNumberValue() {
    let input = NSNumber(int: 15)
    let (string,data) = Record.serializeValueForQuery(input, key: "key")
    
    XCTAssertNotNil(string, "has a string version")
    if(string != nil) {
      assert(string!, equals: "15", message: "has the number as the string version")
    }
    
    XCTAssertNotNil(data, "has a data version")
    if(data != nil) {
      let expectedData = "15".dataUsingEncoding(NSUTF8StringEncoding)!
      assert(data!, equals: expectedData, message: "has the number string encoded as the data version")
    }
  }

  func testSerializeValueSerializesDataValue() {
    let bytes = [1,2,3,4]
    let input = NSData(bytes: UnsafePointer<Int>(bytes), length: bytes.count * sizeof(Int))
    let (string,data) = Record.serializeValueForQuery(input, key: "key")
    
    XCTAssertNil(string, "has no string version")
    XCTAssertNotNil(data, "has a data version")
    if(data != nil) {
      assert(data!, equals: input, message: "has the number string encoded as the data version")
    }
  }
  
  func testCreateMethodSetsValuesOnRecord() {
    let hat = Hat.create(["brimSize": 12, "color": "black"])
    assert(hat.brimSize, equals: NSNumber(int: 12), message: "sets number on hat")
    assert(hat.color, equals: "black", message: "sets color on hat")
  }
  
  func testCreateMethodSavesRecord() {
    let hat = Hat.create(["brimSize": 12, "color": "black"])
    XCTAssertNotNil(hat.id, "sets an id")
  }
  
  //MARK: - Persisting
  
  func testValuesToPersistGetsDataForPeroprties() {
    let hat = Hat()
    hat.color = "tan"
    hat.brimSize = NSNumber(int: 10)
    hat.owner = "me"
    
    let properties = hat.valuesToPersist()
    
    if let property = properties["color"] {
      let data = "tan".dataUsingEncoding(NSUTF8StringEncoding)!
      assert(property, equals: data, message: "has the color")
    }
    else {
      XCTFail("has the color")
    }
    
    if let property = properties["brimSize"] {
      let data = "10".dataUsingEncoding(NSUTF8StringEncoding)!
      assert(property, equals: data, message: "has the brim size")
    }
    else {
      XCTFail("has the brim size")
    }
    
    XCTAssertNil(properties["owner"], "does not have an entry for an unpersisted property")
  }
  
  func testSaveRunsValidations() {
    class TestHat : Hat {
      var validated = false

      override func validate() -> Bool {
        self.validated = true
        return false
      }
    }
    
    let hat = TestHat()
    let result = hat.save()
    XCTAssertTrue(hat.validated, "runs validations")
    XCTAssertFalse(result, "returns false when validations fails")
  }
  
  func testSaveSetsTimestampsForNewRecord() {
    let hat = Hat()
    hat.save()
    XCTAssertNotNil(hat.createdAt, "sets createdAt")
    if(hat.createdAt != nil) {
      XCTAssertEqualWithAccuracy(hat.createdAt.timeIntervalSinceNow, 0, 2, "sets createdAt to current time")
    }
    
    XCTAssertNotNil(hat.updatedAt, "sets updatedAt")
    if(hat.updatedAt != nil) {
      XCTAssertEqualWithAccuracy(hat.updatedAt.timeIntervalSinceNow, 0, 2, "sets updatedAt to current time")
    }
  }
  
  func testSaveSetsTimestampsForUpdatedRecord() {
    let hat = Hat.create(["createdAt": NSDate(timeIntervalSinceNow: -100), "updatedAt": NSDate(timeIntervalSinceNow: -100)])
    hat.save()
    
    XCTAssertEqualWithAccuracy(hat.createdAt.timeIntervalSinceNow, -100, 2, "leaves createdAt unchanged")
    
    XCTAssertEqualWithAccuracy(hat.updatedAt.timeIntervalSinceNow, 0, 2, "sets updatedAt to current time")
  }
  
  func testSaveInsertsNewRecord() {
    let connection = DatabaseConnection.sharedConnection()
    
    assert(Query<Hat>().count(), equals: 0, message: "starts out with 0 records")
    var hat = Hat()
    hat.save()
    assert(Query<Hat>().count(), equals: 1, message: "ends with 1 record")
  }
  
  func testSaveUpdatesExistingRecord() {
    let connection = DatabaseConnection.sharedConnection()
    var hat = Hat.create(["color": "black"])
    assert(Query<Hat>().count(), equals: 1, message: "starts out with 1 record")
    assert(Query<Hat>().first()!.color, equals: "black", message: "starts out with a black hat")
    hat.color = "tan"
    hat.save()
    
    assert(Query<Hat>().count(), equals: 1, message: "ends with 1 record")
    assert(Query<Hat>().first()!.color, equals: "tan", message: "ends with a tan hat")
  }
  
  func testSaveInsertConstructsInsertQuery() {
    TestConnection.withTestConnection {
      connection in
      var store = Store(data: ["name": "Little Shop"])
      connection.response = [DatabaseConnection.Row(data: ["id": 2])]
      store.save()
      self.assert(connection.queries.count, equals: 1, message: "executes 1 query")
      if connection.queries.count > 0 {
        let (query, parameters) = connection.queries[0]
        self.assert(query, equals: "INSERT INTO stores (name) VALUES (?)", message: "has the query to insert the record")
        
        self.assert(parameters, equals: ["Little Shop".dataUsingEncoding(NSUTF8StringEncoding)!], message: "has the name as the parameter")
      }
    }
  }
  
  func testSaveInsertSetsId() {
    TestConnection.withTestConnection {
      connection in
      var store = Store(data: ["name": "Little Shop"])
      connection.response = [DatabaseConnection.Row(data: ["id": 2])]
      store.save()
      self.assert(store.id, equals: NSNumber(int: 2), message: "sets the id based on the database response")
    }
  }
  
  func testSaveInsertReturnsTrueWithNoError() {
    TestConnection.withTestConnection {
      connection in
      var store = Store(data: ["name": "Little Shop"])
      connection.response = [DatabaseConnection.Row(data: ["id": 2])]
      let result = store.save()
      XCTAssertTrue(result, "returns true")
    }
  }
  
  func testSaveInsertReturnsFalseWithError() {
    TestConnection.withTestConnection {
      connection in
      var store = Store(data: ["name": "Little Shop"])
      connection.response = [DatabaseConnection.Row(error: "Lost Connection")]
      let result = store.save()
      XCTAssertFalse(result, "returns false")
      
      if !store.errors.isEmpty {
        let error = store.errors.errors[0]
        self.assert(error.message, equals: "Lost Connection", message: "sets an error on the record")
      }
      else {
        XCTFail("Sets an error on the record")
      }
    }
  }
  
  func testSaveInsertCreatesSparseInsertQuery() {
    TestConnection.withTestConnection {
      connection in
      self.assert(connection.queries.count, equals: 0)
      connection.response = [DatabaseConnection.Row(data: ["id": 2])]
      var hat = Hat(data: ["brimSize": 10, "color": "red"])
      hat.save()
      self.assert(connection.queries.count, equals: 1, message: "executes one query")
      if connection.queries.count > 0 {
        let (query, parameters) = connection.queries[0]
        self.assert(query, equals: "INSERT INTO hats (brim_size, color, created_at, updated_at) VALUES (?, ?, ?, ?)", message: "has the query to insert the record")
        
        let expectedParameters = [
          "10".dataUsingEncoding(NSUTF8StringEncoding)!,
          "red".dataUsingEncoding(NSUTF8StringEncoding)!,
          hat.createdAt.format("db", timeZone: connection.timeZone)!.dataUsingEncoding(NSUTF8StringEncoding)!,
          hat.updatedAt.format("db", timeZone: connection.timeZone)!.dataUsingEncoding(NSUTF8StringEncoding)!
        ]
        self.assert(parameters, equals: expectedParameters, message: "has the brim size, color, creation date, and update date as parameters")
      }
    }
  }
  
  func testSaveUpdateCreatesUpdateQuery() {
    let shelf = Shelf.create(["name": "Top Shelf", "storeId": 1])
    TestConnection.withTestConnection {
      connection in
      shelf.name = "Bottom Shelf"
      shelf.storeId = NSNumber(int: 2)
      shelf.save()
      self.assert(connection.queries.count, equals: 1, message: "executes one query")
      if connection.queries.count > 0 {
        let (query, parameters) = connection.queries[0]
        self.assert(query, equals: "UPDATE shelfs SET name = ?, store_id = ? WHERE id = ?", message: "has the update query")
        
        let expectedParameters = [
          "Bottom Shelf".dataUsingEncoding(NSUTF8StringEncoding)!,
          "2".dataUsingEncoding(NSUTF8StringEncoding)!,
          shelf.id.stringValue.dataUsingEncoding(NSUTF8StringEncoding)!
        ]
        self.assert(parameters, equals: expectedParameters, message: "has the name, store ID, and id as parameters")
      }
    }
  }
  
  func testSaveUpdateCanCreateUpdateQueryWithNull() {
    let shelf = Shelf.create(["name": "Top Shelf", "storeId": 1])
    TestConnection.withTestConnection {
      connection in
      shelf.name = nil
      shelf.save()
      self.assert(connection.queries.count, equals: 1, message: "executes one query")
      if connection.queries.count > 0 {
        let (query, parameters) = connection.queries[0]
        self.assert(query, equals: "UPDATE shelfs SET name = NULL, store_id = ? WHERE id = ?", message: "has the update query")
        
        let expectedParameters = [
          "1".dataUsingEncoding(NSUTF8StringEncoding)!,
          shelf.id.stringValue.dataUsingEncoding(NSUTF8StringEncoding)!
        ]
        self.assert(parameters, equals: expectedParameters, message: "has the storeId and id as parameters")
      }
    }
  }
  
  func testSaveUpdatePutsErrorOnRecord() {
    let shelf = Shelf.create(["name": "Top Shelf", "storeId": 1])
    TestConnection.withTestConnection {
      connection in
      shelf.name = nil
      connection.response = [DatabaseConnection.Row(error: "Connection Error")]
      shelf.save()
      if !shelf.errors.isEmpty {
        let error = shelf.errors.errors[0]
        self.assert(error.message, equals: "Connection Error", message: "puts an error on the record")
      }
      else {
        XCTFail("puts an error on the record")
      }
    }
  }
  
  func testDestroyExecutesDeleteQuery() {
    let shelf = Shelf.create([:])
    TestConnection.withTestConnection {
      connection in
      shelf.destroy()
      self.assert(connection.queries.count, equals: 1, message: "executes one query")
      if connection.queries.count == 1 {
        let (query, parameters) = connection.queries[0]
        self.assert(query, equals: "DELETE FROM shelfs WHERE id = ?", message: "executes a destroy query")
        let data = shelf.id.stringValue.dataUsingEncoding(NSUTF8StringEncoding)!
        self.assert(parameters, equals: [data], message: "has the id as the parameter for the query")
      }
    }
  }
  
  //MARK: - Serialization
  
  func testToPropertyListHasPropertiesForKeys() {
    let hat = Hat()
    hat.id = 5
    hat.color = "red"
    let properties = hat.toPropertyList()
    assert(properties.keys.array, equals: ["id", "color"], message: "has keys for id and color")
    
    if let id = properties["id"] as? NSNumber {
      assert(id, equals: 5, message: "has the id")
    }
    else {
      XCTFail("has the id")
    }
    
    if let color = properties["color"] as? String {
      assert(color, equals: "red", message: "has the color")
    }
    else {
      XCTFail("has the color")
    }
  }

  //MARK: - Comparison
  
  func testRecordsWithSameIdAreEqual() {
    let lhs = Hat(data: ["id": 5])
    let rhs = Hat(data: ["id": 5])
    assert(lhs, equals: rhs, message: "records are equal")
  }
  
  func testRecordsWithNilIdsAreUnequal() {
    let lhs = Hat()
    let rhs = Hat()
    XCTAssertNotEqual(lhs, rhs, "records are not equal")
  }
  
  func testRecordsWithDifferentTypesAreUnequal() {
    let lhs = Hat(data: ["id": 5])
    let rhs = Store(data: ["id": 5])
    XCTAssertNotEqual(lhs, rhs, "records are not equal")
  }
}