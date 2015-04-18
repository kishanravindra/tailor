import XCTest
import Tailor
import TailorTesting

class RecordTests: TailorTestCase {
  //MARK: - Structure
  
  func testTableNameIsPluralizedModelName() {
    assert(Hat.tableName(), equals: "hats", message: "gets table name")
  }
  
  func testForeignKeyNameIsModelNamePlusId() {
    assert(Hat.foreignKeyName(), equals: "hat_id", message: "gets foreign key")
  }
  
  func testToOneFetchesRecordsById() {
    let shelf1 = Shelf(name: "First Shelf")
    let shelf2 = Shelf(name: "Second Shelf")
    shelf1.save()
    shelf2.save()
    let hat = Hat(shelfId: shelf2.id!)
    hat.save()
    if let result : Shelf = hat.toOne() {
      assert(shelf2.name, equals: result.name!, message: "fetches the second shelf")
    }
    else {
      XCTFail("fetches the second shelf")
    }
  }
  
  func testToManyFetchesRecordsByForeignKey() {
    let shelf = Shelf(name: "")
    shelf.save()
    let query : Query<Hat> = shelf.toMany()
    let clause = query.whereClause
    assert(clause.query, equals: "hats.shelf_id=?", message: "has the shelfId in the query")
    assert(clause.parameters, equals: [String(shelf.id!)], message: "has the id as the parameter")
  }
  
  func testToManyThroughFetchesManyRecordsByForeignKey() {
    let store = Store(name: "New Store")
    store.save()
    let shelfQuery : Query<Shelf> = store.toMany()
    let query : Query<Hat> = store.toMany(through: shelfQuery, joinToMany: true)

    let whereClause = query.whereClause
    assert(whereClause.query, equals: "shelfs.store_id=?")
    assert(whereClause.parameters, equals: [String(store.id!)], message: "has the id as the parameter")
    
    let joinClause = query.joinClause
    assert(joinClause.query, equals: "INNER JOIN shelfs ON shelfs.id = hats.shelf_id", message: "joins between shelves and hats in the join clause")
    assert(joinClause.parameters.count, equals: 0, message: "has no parameters in the join clause")
  }
  
  func testToManyThroughFetchesOneRecordsByForeignKey() {
    let hat = Hat(shelfId: 1)
    hat.save()
    let shelfQuery = Query<Shelf>().filter(["id": hat.shelfId])
    let query : Query<Store> = hat.toMany(through: shelfQuery, joinToMany: false)
    
    let whereClause = query.whereClause
    assert(whereClause.query, equals: "shelfs.id=?")
    assert(whereClause.parameters, equals: [String(hat.shelfId)], message: "has the id as the parameter")
    
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
  
  //MARK: - Persisting
  
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
    var hat = Hat()
    hat.save()
    
    hat = Query<Hat>().find(hat.id!)!
    XCTAssertNotNil(hat.createdAt, "sets createdAt")
    if(hat.createdAt != nil) {
      XCTAssertEqualWithAccuracy(hat.createdAt!.timeIntervalSinceNow, 0, 2, "sets createdAt to current time")
    }
    
    XCTAssertNotNil(hat.updatedAt, "sets updatedAt")
    if(hat.updatedAt != nil) {
      XCTAssertEqualWithAccuracy(hat.updatedAt!.timeIntervalSinceNow, 0, 2, "sets updatedAt to current time")
    }
  }
  
  func testSaveSetsTimestampsForUpdatedRecord() {
    var hat = Hat()
    hat.createdAt = NSDate(timeIntervalSinceNow: -100)
    hat.updatedAt = NSDate(timeIntervalSinceNow: -100)
    hat.save()
    
    hat = Query<Hat>().find(hat.id!)!
    XCTAssertEqualWithAccuracy(hat.createdAt!.timeIntervalSinceNow, -100, 2, "leaves createdAt unchanged")
    
    XCTAssertEqualWithAccuracy(hat.updatedAt!.timeIntervalSinceNow, 0, 2, "sets updatedAt to current time")
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
    var hat = Hat(color: "black")
    hat.save()
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
      var store = Store(name: "Little Shop")
      connection.response = [DatabaseConnection.Row(rawData: ["id": 2])]
      store.save()
      self.assert(connection.queries.count, equals: 1, message: "executes 1 query")
      if connection.queries.count > 0 {
        let (query, parameters) = connection.queries[0]
        self.assert(query, equals: "INSERT INTO stores (name) VALUES (?)", message: "has the query to insert the record")
        
        self.assert(parameters, equals: ["Little Shop".databaseValue], message: "has the name as the parameter")
      }
    }
  }
  
  func testSaveInsertSetsId() {
    TestConnection.withTestConnection {
      connection in
      var store = Store(name: "Little Shop")
      connection.response = [DatabaseConnection.Row(rawData: ["id": 2])]
      store.save()
      self.assert(store.id, equals: NSNumber(int: 2), message: "sets the id based on the database response")
    }
  }
  
  func testSaveInsertReturnsTrueWithNoError() {
    TestConnection.withTestConnection {
      connection in
      var store = Store(name: "Little Shop")
      connection.response = [DatabaseConnection.Row(rawData: ["id": 2])]
      let result = store.save()
      XCTAssertTrue(result, "returns true")
    }
  }
  
  func testSaveInsertReturnsFalseWithError() {
    TestConnection.withTestConnection {
      connection in
      var store = Store(name: "Little Shop")
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
      connection.response = [DatabaseConnection.Row(rawData: ["id": 2])]
      var hat = Hat(brimSize: 10, color: "red")
      hat.save()
      self.assert(connection.queries.count, equals: 1, message: "executes one query")
      if connection.queries.count > 0 {
        let (query, parameters) = connection.queries[0]
        self.assert(query, equals: "INSERT INTO hats (brim_size, color, created_at, updated_at) VALUES (?, ?, ?, ?)", message: "has the query to insert the record")
        
        let expectedParameters = [
          10.databaseValue,
          "red".databaseValue,
          NSDate().databaseValue,
          NSDate().databaseValue
        ]
        
        self.assert(parameters[0], equals: expectedParameters[0], message: "has the brim size parameter")
        self.assert(parameters[1], equals: expectedParameters[1], message: "has the color parameter")
        
        let currentTimestamp = NSDate().timeIntervalSince1970
        let date1 = parameters[3].dateValue?.timeIntervalSince1970 ?? 0
        let date2 = parameters[3].dateValue?.timeIntervalSince1970 ?? 0
        XCTAssertEqualWithAccuracy(date1, currentTimestamp, 1)
        XCTAssertEqualWithAccuracy(date2, currentTimestamp, 1)
      }
    }
  }
  
  func testSaveUpdateCreatesUpdateQuery() {
    let shelf = Shelf(name: "Top Shelf", storeId: 1)
    shelf.save()
    TestConnection.withTestConnection {
      connection in
      shelf.name = "Bottom Shelf"
      shelf.storeId = 2
      shelf.save()
      self.assert(connection.queries.count, equals: 1, message: "executes one query")
      if connection.queries.count > 0 {
        let (query, parameters) = connection.queries[0]
        self.assert(query, equals: "UPDATE shelfs SET name = ?, store_id = ? WHERE id = ?", message: "has the update query")
        
        let expectedParameters = [
          "Bottom Shelf".databaseValue,
          2.databaseValue,
          shelf.id!.databaseValue
        ]
        self.assert(parameters, equals: expectedParameters, message: "has the name, store ID, and id as parameters")
      }
    }
  }
  
  func testSaveUpdateCanCreateUpdateQueryWithNull() {
    let shelf = Shelf(name: "Top Shelf", storeId: 1)
    shelf.save()
    TestConnection.withTestConnection {
      connection in
      shelf.name = nil
      shelf.save()
      self.assert(connection.queries.count, equals: 1, message: "executes one query")
      if connection.queries.count > 0 {
        let (query, parameters) = connection.queries[0]
        self.assert(query, equals: "UPDATE shelfs SET name = NULL, store_id = ? WHERE id = ?", message: "has the update query")
        
        let expectedParameters = [
          1.databaseValue,
          shelf.id!.databaseValue
        ]
        self.assert(parameters, equals: expectedParameters, message: "has the storeId and id as parameters")
      }
    }
  }
  
  func testSaveUpdatePutsErrorOnRecord() {
    let shelf = Shelf(name: "Top Shelf", storeId: 1)
    shelf.save()
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
    let shelf = Shelf(name: "Shelf")
    shelf.save()
    TestConnection.withTestConnection {
      connection in
      shelf.destroy()
      self.assert(connection.queries.count, equals: 1, message: "executes one query")
      if connection.queries.count == 1 {
        let (query, parameters) = connection.queries[0]
        self.assert(query, equals: "DELETE FROM shelfs WHERE id = ?", message: "executes a destroy query")
        let data = shelf.id!.databaseValue
        self.assert(parameters, equals: [data], message: "has the id as the parameter for the query")
      }
    }
  }
  
  //MARK: - Serialization
  
  func testToPropertyListHasPropertiesForKeys() {
    let hat = Hat(id: 5)
    hat.color = "red"
    let properties = hat.toPropertyList()
    assert(sorted(properties.keys), equals: ["brim_size", "color", "created_at", "id", "shelf_id", "updated_at"], message: "has keys for id and color")
    
    if let id = properties["id"] as? Int {
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
    let lhs = Hat(id: 5)
    let rhs = Hat(id: 5)
    assert(lhs, equals: rhs, message: "records are equal")
  }
  
  func testRecordsWithNilIdsAreUnequal() {
    let lhs = Hat()
    let rhs = Hat()
    XCTAssertNotEqual(lhs, rhs, "records are not equal")
  }
  
  func testRecordsWithDifferentTypesAreUnequal() {
    let lhs = Hat(id: 5)
    let rhs = Store(name: "My Store", id: 5)
    XCTAssertNotEqual(lhs, rhs, "records are not equal")
  }
}