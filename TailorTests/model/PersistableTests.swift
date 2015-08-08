import XCTest
@testable import Tailor
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
    assert(Hat.foreignKeyName(), equals: "hat_id")
  }
  
  func testToManyFetchesRecordsByForeignKey() {
    let shelf = Shelf(name: "").save()!
    let query : Query<Hat> = shelf.toMany()
    let clause = query.whereClause
    assert(clause.query, equals: "hats.shelf_id=?", message: "has the shelf ID in the query")
    assert(clause.parameters, equals: [DatabaseValue.Integer(shelf.id!)], message: "has the id as the parameter")
  }
  
  func testToManyWithSpecificForeignKeyUsesThatForeignKey() {
    let shelf = Shelf(name: "").save()!
    let query : Query<Hat> = shelf.toMany(foreignKey: "shelfId")
    let clause = query.whereClause
    assert(clause.query, equals: "hats.shelfId=?", message: "has the shelf ID in the query")
    assert(clause.parameters, equals: [shelf.id!.databaseValue], message: "has the id as the parameter")
  }
  
  func testToManyThroughFetchesManyRecordsByForeignKey() {
    let store = Store(name: "New Store").save()!
    let shelfQuery : Query<Shelf> = store.toMany()
    let query : Query<Hat> = store.toMany(through: shelfQuery, joinToMany: true)
    
    let whereClause = query.whereClause
    assert(whereClause.query, equals: "shelfs.store_id=?")
    assert(whereClause.parameters, equals: [store.id!.databaseValue], message: "has the id as the parameter")
    
    let joinClause = query.joinClause
    assert(joinClause.query, equals: "INNER JOIN shelfs ON shelfs.id = hats.shelf_id", message: "joins between shelves and hats in the join clause")
    assert(joinClause.parameters.count, equals: 0, message: "has no parameters in the join clause")
  }
  
  func testToManyThroughFetchesOneRecordsByForeignKey() {
    let hat = Hat(shelfId: 1).save()!
    let shelfQuery = Shelfs.filter(["id": hat.shelfId])
    let query : Query<Store> = hat.toMany(through: shelfQuery, joinToMany: false)
    
    let whereClause = query.whereClause
    assert(whereClause.query, equals: "shelfs.id=?")
    assert(whereClause.parameters, equals: [hat.shelfId!.databaseValue], message: "has the id as the parameter")
    
    let joinClause = query.joinClause
    assert(joinClause.query, equals: "INNER JOIN shelfs ON shelfs.store_id = stores.id", message: "joins between shelves and stores in the join clause")
    assert(joinClause.parameters.count, equals: 0, message: "has no parameters in the join clause")
  }
  
  @available(*, deprecated) func testForeignKeyNameFromFreeFunctionIsModelNamePlusId() {
    assert(foreignKeyName(Hat.self), equals: "hat_id")
  }
  
  @available(*, deprecated) func testToManyFromFreeFunctionFetchesRecordsByForeignKey() {
    let shelf = Shelf(name: "").save()!
    let query : Query<Hat> = toManyRecords(shelf)
    let clause = query.whereClause
    assert(clause.query, equals: "hats.shelf_id=?", message: "has the shelf ID in the query")
    assert(clause.parameters, equals: [DatabaseValue.Integer(shelf.id!)], message: "has the id as the parameter")
  }
  
  @available(*, deprecated) func testToManyFromFreeFunctionWithSpecificForeignKeyUsesThatForeignKey() {
    let shelf = Shelf(name: "").save()!
    let query : Query<Hat> = toManyRecords(shelf, foreignKey: "shelfId")
    let clause = query.whereClause
    assert(clause.query, equals: "hats.shelfId=?", message: "has the shelf ID in the query")
    assert(clause.parameters, equals: [shelf.id!.databaseValue], message: "has the id as the parameter")
  }
  
  @available(*, deprecated) func testToManyThroughFromFreeFunctionFetchesManyRecordsByForeignKey() {
    let store = Store(name: "New Store").save()!
    let shelfQuery : Query<Shelf> = toManyRecords(store)
    let query : Query<Hat> = toManyRecords(through: shelfQuery, joinToMany: true)
    
    let whereClause = query.whereClause
    assert(whereClause.query, equals: "shelfs.store_id=?")
    assert(whereClause.parameters, equals: [store.id!.databaseValue], message: "has the id as the parameter")
    
    let joinClause = query.joinClause
    assert(joinClause.query, equals: "INNER JOIN shelfs ON shelfs.id = hats.shelf_id", message: "joins between shelves and hats in the join clause")
    assert(joinClause.parameters.count, equals: 0, message: "has no parameters in the join clause")
  }
  
  @available(*, deprecated) func testToManyThroughFromFreeFunctionFetchesOneRecordsByForeignKey() {
    let hat = Hat(shelfId: 1).save()!
    let shelfQuery = Shelfs.filter(["id": hat.shelfId])
    let query : Query<Store> = toManyRecords(through: shelfQuery, joinToMany: false)
    
    let whereClause = query.whereClause
    assert(whereClause.query, equals: "shelfs.id=?")
    assert(whereClause.parameters, equals: [hat.shelfId!.databaseValue], message: "has the id as the parameter")
    
    let joinClause = query.joinClause
    assert(joinClause.query, equals: "INNER JOIN shelfs ON shelfs.store_id = stores.id", message: "joins between shelves and stores in the join clause")
    assert(joinClause.parameters.count, equals: 0, message: "has no parameters in the join clause")
  }
  
  //MARK: - Persisting
  
  func testSaveSetsTimestampsForNewRecord() {
    var hat = Hat()
    hat = hat.save() ?? hat
    
    let currentTime = Timestamp.now().epochSeconds
    assert(hat.createdAt?.epochSeconds, within: 2, of: currentTime, message: "sets createdAt to current time")
    assert(hat.updatedAt?.epochSeconds, within: 2, of: currentTime, message: "sets updatedAt to current time")
  }
  
  func testSaveSetsTimestampsForUpdatedRecord() {
    var hat = Hat()
    hat.createdAt = 30.minutes.ago
    hat.updatedAt = 10.minutes.ago
    hat = hat.save() ?? hat
    
    let currentTime = Timestamp.now().epochSeconds
    assert(hat.createdAt!.epochSeconds, within: 2, of: currentTime-1800, message: "leaves createdAt unchanged")
    
    
    assert(hat.updatedAt!.epochSeconds, within: 2, of: currentTime, message: "sets updatedAt to currentTime")
  }
  
  func testSaveInsertsNewRecord() {
    Application.sharedDatabaseConnection()
    
    assert(Hats.count(), equals: 0, message: "starts out with 0 records")
    let hat = Hat()
    hat.save()
    assert(Hats.count(), equals: 1, message: "ends with 1 record")
  }
  
  func testSaveUpdatesExistingRecord() {
    var hat = Hat(color: "black")
    
    hat = hat.save()!
    assert(Hats.count(), equals: 1, message: "starts out with 1 record")
    assert(Hats.first()?.color, equals: "black", message: "starts out with a black hat")
    hat.color = "tan"
    hat = hat.save()!
    
    assert(Hats.count(), equals: 1, message: "ends with 1 record")
    assert(Hats.first()?.color, equals: "tan", message: "ends with a tan hat")
  }
  
  func testSaveInsertConstructsInsertQuery() {
    TestConnection.withTestConnection {
      connection in
      let store = Store(name: "Little Shop")
      connection.response = [DatabaseRow(rawData: ["id": 2])]
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
      connection.response = [DatabaseRow(rawData: ["id": 2])]
      store = store.save() ?? store
      self.assert(store.id, equals: NSNumber(int: 2), message: "sets the id based on the database response")
    }
  }
  
  func testSaveInsertWithIdReturnsRecordWithId() {
    TestConnection.withTestConnection {
      connection in
      let store = Store(name: "Little Shop")
      connection.response = [DatabaseRow(rawData: ["id": 2])]
      let result = store.save()
      self.assert(result?.id, equals: 2)
    }
  }
  
  func testSaveInsertWithErrorReturnsNil() {
    TestConnection.withTestConnection {
      connection in
      let store = Store(name: "Little Shop")
      connection.response = [DatabaseRow(error: "Lost Connection")]
      let result = store.save()
      XCTAssertTrue(result == nil)
    }
  }
  
  func testSaveInsertCreatesSparseInsertQuery() {
    TestConnection.withTestConnection {
      connection in
      self.assert(connection.queries.count, equals: 0)
      connection.response = [DatabaseRow(rawData: ["id": 2])]
      var hat = Hat(brimSize: 10, color: "red")
      hat.shelfId = nil
      hat.save()
      self.assert(connection.queries.count, equals: 1, message: "executes one query")
      if connection.queries.count > 0 {
        let (query, parameters) = connection.queries[0]
        self.assert(query, equals: "INSERT INTO hats (brim_size, color, created_at, updated_at) VALUES (?, ?, ?, ?)", message: "has the query to insert the record")
        
        let expectedParameters = [
          10.databaseValue,
          "red".databaseValue,
          Timestamp.now().databaseValue,
          Timestamp.now().databaseValue
        ]
        
        self.assert(parameters[0], equals: expectedParameters[0], message: "has the brim size parameter")
        self.assert(parameters[1], equals: expectedParameters[1], message: "has the color parameter")
        
        let currentTimestamp = Timestamp.now().epochSeconds
        let timestamp1 = parameters[2].timestampValue?.epochSeconds ?? 0
        let timestamp2 = parameters[3].timestampValue?.epochSeconds ?? 0
        assert(timestamp1, within:1, of: currentTimestamp)
        assert(timestamp2, within:1, of: currentTimestamp)
      }
    }
  }
  
  func testSaveUpdateCreatesUpdateQuery() {
    var shelf = Shelf(name: "Top Shelf", storeId: 1)
    shelf = shelf.save() ?? shelf
    TestConnection.withTestConnection {
      connection in
      shelf.name = "Bottom Shelf"
      shelf.storeId = 2
      shelf = shelf.save() ?? shelf
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
    shelf = shelf.save() ?? shelf
    TestConnection.withTestConnection {
      connection in
      shelf.name = nil
      shelf = shelf.save() ?? shelf
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
    var shelf = Shelf(name: "Top Shelf", storeId: 1).save()!
    TestConnection.withTestConnection {
      connection in
      shelf.name = nil
      connection.response = [DatabaseRow(error: "Connection Error")]
      let result = shelf.save()
      XCTAssertTrue(result == nil)
    }
  }
  
  func testDestroyExecutesDeleteQuery() {
    let shelf = Shelf(name: "Shelf").save()!
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
  
  @available(*, deprecated) func testSaveFromFreeFunctionInsertsNewRecord() {
    Application.sharedDatabaseConnection()
    
    assert(Hats.count(), equals: 0, message: "starts out with 0 records")
    let hat = Hat()
    saveRecord(hat)
    assert(Hats.count(), equals: 1, message: "ends with 1 record")
  }
  
  @available(*, deprecated) func testSaveFromFreeFunctionUpdatesExistingRecord() {
    var hat = Hat(color: "black")
    
    saveRecord(hat)
    assert(Hats.count(), equals: 1, message: "starts out with 1 record")
    assert(Hats.first()?.color, equals: "black", message: "starts out with a black hat")
    hat = Hats.first()!
    hat.color = "tan"
    saveRecord(hat)
    
    assert(Hats.count(), equals: 1, message: "ends with 1 record")
    assert(Hats.first()?.color, equals: "tan", message: "ends with a tan hat")
  }
  
  @available(*, deprecated) func testDestroyFromFreeFunctionExecutesDeleteQuery() {
    let shelf = Shelf(name: "Shelf").save()!
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
  
  func testBuildWithNoErrorBuildsRecord() {
    let hat = Hat.build(DatabaseRow(data: ["brim_size": 10.databaseValue, "color": "red".databaseValue]))
    assert(isNotNil: hat)
  }
  
  func testBuildWithGeneralErrorIsNil() {
    let shelf = Shelf.build(DatabaseRow(data: ["name": "hi".databaseValue, "throwError": true.databaseValue]))
    assert(isNil: shelf)
  }
  
  func testBuildWithMissingFieldReturnsNil() {
    let hat = Hat.build(DatabaseRow(data: ["brim_size": 10.databaseValue]))
    assert(isNil: hat)
  }
  
  func testBuildWithWrongFieldTypeReturnsNil() {
    let hat = Hat.build(DatabaseRow(data: ["brim_size": 10.databaseValue, "color": 5.databaseValue]))
    assert(isNil: hat)
  }
  
  func testToJsonCreatesJsonDictionaryBasedOnDataMapping() {
    let hat = Hat(brimSize: 10, color: "red", shelfId: nil, owner: "John", id: 5)
    let json = hat.toJson()
    assert(json, equals: .Dictionary([
      "brim_size": JsonPrimitive.Number(10),
      "color": JsonPrimitive.String("red"),
      "shelf_id": JsonPrimitive.Null,
      "id": JsonPrimitive.Number(5),
      "created_at": JsonPrimitive.Null,
      "updated_at": JsonPrimitive.Null
    ]))
  }
}