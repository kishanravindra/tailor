import XCTest
import Tailor
import TailorTesting

class PersistableTests: TailorTestCase {
  //MARK: - Comparison
  
  func testRecordsWithSameIdAreEqual() {
    let lhs = Hat(id: 5)
    let rhs = Hat(id: 5)
    assert(lhs, equals: rhs, message: "records are equal")
  }
  
  func testRecordsWithSameIdAreUnequal() {
    let lhs = Hat(id: 5)
    let rhs = Hat(id: 7)
    XCTAssertNotEqual(lhs, rhs, "records are not equal")
  }
  
  func testRecordsWithNilIdsAreUnequal() {
    let lhs = Hat()
    let rhs = Hat()
    XCTAssertNotEqual(lhs, rhs, "records are not equal")
  }
  
  //MARK: - Association
  
  func testForeignKeyNameIsModelNamePlusId() {
    assert(foreignKeyName(Hat.self), equals: "hat_id")
  }
  
  func testToManyFetchesRecordsByForeignKey() {
    let shelf = saveRecord(Shelf(name: ""))!
    let query : Query<Hat> = toManyRecords(shelf)
    let clause = query.whereClause
    assert(clause.query, equals: "hats.shelf_id=?", message: "has the shelf ID in the query")
    assert(clause.parameters, equals: [DatabaseValue.Integer(shelf.id!)], message: "has the id as the parameter")
  }
  
  func testToManyWithSpecificForeignKeyUsesThatForeignKey() {
    let shelf = saveRecord(Shelf(name: ""))!
    let query : Query<Hat> = toManyRecords(shelf, foreignKey: "shelfId")
    let clause = query.whereClause
    assert(clause.query, equals: "hats.shelfId=?", message: "has the shelf ID in the query")
    assert(clause.parameters, equals: [shelf.id!.databaseValue], message: "has the id as the parameter")
  }
  
  func testToManyThroughFetchesManyRecordsByForeignKey() {
    let store = saveRecord(Store(name: "New Store"))!
    let shelfQuery : Query<Shelf> = toManyRecords(store)
    let query : Query<Hat> = toManyRecords(through: shelfQuery, joinToMany: true)
    
    let whereClause = query.whereClause
    assert(whereClause.query, equals: "shelfs.store_id=?")
    assert(whereClause.parameters, equals: [store.id!.databaseValue], message: "has the id as the parameter")
    
    let joinClause = query.joinClause
    assert(joinClause.query, equals: "INNER JOIN shelfs ON shelfs.id = hats.shelf_id", message: "joins between shelves and hats in the join clause")
    assert(joinClause.parameters.count, equals: 0, message: "has no parameters in the join clause")
  }
  
  func testToManyThroughFetchesOneRecordsByForeignKey() {
    let hat = saveRecord(Hat(shelfId: 1))!
    let shelfQuery = Query<Shelf>().filter(["id": hat.shelfId])
    let query : Query<Store> = toManyRecords(through: shelfQuery, joinToMany: false)
    
    let whereClause = query.whereClause
    assert(whereClause.query, equals: "shelfs.id=?")
    assert(whereClause.parameters, equals: [hat.shelfId.databaseValue], message: "has the id as the parameter")
    
    let joinClause = query.joinClause
    assert(joinClause.query, equals: "INNER JOIN shelfs ON shelfs.store_id = stores.id", message: "joins between shelves and stores in the join clause")
    assert(joinClause.parameters.count, equals: 0, message: "has no parameters in the join clause")
  }
  
  //MARK: - Persisting
  
  func testSaveSetsTimestampsForNewRecord() {
    var hat = Hat()
    hat = saveRecord(hat) ?? hat
    
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
    hat = saveRecord(hat) ?? hat
    
    XCTAssertEqualWithAccuracy(hat.createdAt!.timeIntervalSinceNow, -100, 2, "leaves createdAt unchanged")
    
    XCTAssertEqualWithAccuracy(hat.updatedAt!.timeIntervalSinceNow, 0, 2, "sets updatedAt to current time")
  }
  
  func testSaveInsertsNewRecord() {
    let connection = DatabaseConnection.sharedConnection()
    
    assert(Query<Hat>().count(), equals: 0, message: "starts out with 0 records")
    var hat = Hat()
    saveRecord(hat)
    assert(Query<Hat>().count(), equals: 1, message: "ends with 1 record")
  }
  
  func testSaveUpdatesExistingRecord() {
    let connection = DatabaseConnection.sharedConnection()
    var hat = Hat(color: "black")
    
    hat = saveRecord(hat)!
    assert(Query<Hat>().count(), equals: 1, message: "starts out with 1 record")
    assert(Query<Hat>().first()?.color, equals: "black", message: "starts out with a black hat")
    hat.color = "tan"
    hat = saveRecord(hat)!
    
    assert(Query<Hat>().count(), equals: 1, message: "ends with 1 record")
    assert(Query<Hat>().first()?.color, equals: "tan", message: "ends with a tan hat")
  }
  
  func testSaveInsertConstructsInsertQuery() {
    TestConnection.withTestConnection {
      connection in
      var store = Store(name: "Little Shop")
      connection.response = [DatabaseConnection.Row(rawData: ["id": 2])]
      saveRecord(store)
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
      store = saveRecord(store) ?? store
      self.assert(store.id, equals: NSNumber(int: 2), message: "sets the id based on the database response")
    }
  }
  
  func testSaveInsertWithIdReturnsRecordWithId() {
    TestConnection.withTestConnection {
      connection in
      var store = Store(name: "Little Shop")
      connection.response = [DatabaseConnection.Row(rawData: ["id": 2])]
      let result = saveRecord(store)
      self.assert(result?.id, equals: 2)
    }
  }
  
  func testSaveInsertWithErrorReturnsNil() {
    TestConnection.withTestConnection {
      connection in
      var store = Store(name: "Little Shop")
      connection.response = [DatabaseConnection.Row(error: "Lost Connection")]
      let result = saveRecord(store)
      XCTAssertTrue(result == nil)
    }
  }
  
  func testSaveInsertCreatesSparseInsertQuery() {
    TestConnection.withTestConnection {
      connection in
      self.assert(connection.queries.count, equals: 0)
      connection.response = [DatabaseConnection.Row(rawData: ["id": 2])]
      var hat = Hat(brimSize: 10, color: "red")
      hat.shelfId = nil
      saveRecord(hat)
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
        let date1 = parameters[2].foundationDateValue?.timeIntervalSince1970 ?? 0
        let date2 = parameters[3].foundationDateValue?.timeIntervalSince1970 ?? 0
        XCTAssertEqualWithAccuracy(date1, currentTimestamp, 1)
        XCTAssertEqualWithAccuracy(date2, currentTimestamp, 1)
      }
    }
  }
  
  func testSaveUpdateCreatesUpdateQuery() {
    var shelf = Shelf(name: "Top Shelf", storeId: 1)
    shelf = saveRecord(shelf) ?? shelf
    TestConnection.withTestConnection {
      connection in
      shelf.name = "Bottom Shelf"
      shelf.storeId = 2
      shelf = saveRecord(shelf) ?? shelf
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
    var shelf = Shelf(name: "Top Shelf", storeId: 1)
    shelf = saveRecord(shelf) ?? shelf
    TestConnection.withTestConnection {
      connection in
      shelf.name = nil
      shelf = saveRecord(shelf) ?? shelf
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
  
  func testSaveUpdateWithDatabaseErrorReturnsNil() {
    var shelf = saveRecord(Shelf(name: "Top Shelf", storeId: 1))!
    TestConnection.withTestConnection {
      connection in
      shelf.name = nil
      connection.response = [DatabaseConnection.Row(error: "Connection Error")]
      let result = saveRecord(shelf)
      XCTAssertTrue(result == nil)
    }
  }
  
  func testDestroyExecutesDeleteQuery() {
    let shelf = saveRecord(Shelf(name: "Shelf"))!
    TestConnection.withTestConnection {
      connection in
      destroyRecord(shelf)
      self.assert(connection.queries.count, equals: 1, message: "executes one query")
      if connection.queries.count == 1 {
        let (query, parameters) = connection.queries[0]
        self.assert(query, equals: "DELETE FROM shelfs WHERE id = ?", message: "executes a destroy query")
        let data = shelf.id!.databaseValue
        self.assert(parameters, equals: [data], message: "has the id as the parameter for the query")
      }
    }
  }
}