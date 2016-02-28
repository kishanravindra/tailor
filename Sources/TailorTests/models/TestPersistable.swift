import XCTest
@testable import Tailor
import TailorTesting

struct TestPersistable: XCTestCase, TailorTestable {

  @available(*, deprecated)
  var allTests: [(String, () throws -> Void)] { return [
    ("testRecordsWithSameIdAreEqual", testRecordsWithSameIdAreEqual),
    ("testRecordsWithSameIdAreUnequal", testRecordsWithSameIdAreUnequal),
    ("testForeignKeyNameIsModelNamePlusId", testForeignKeyNameIsModelNamePlusId),
    ("testToManyFetchesRecordsByForeignKey", testToManyFetchesRecordsByForeignKey),
    ("testToManyWithSpecificForeignKeyUsesThatForeignKey", testToManyWithSpecificForeignKeyUsesThatForeignKey),
    ("testToManyThroughFetchesManyRecordsByForeignKey", testToManyThroughFetchesManyRecordsByForeignKey),
    ("testToManyThroughFetchesOneRecordByForeignKey", testToManyThroughFetchesOneRecordByForeignKey),
    ("testToManyThroughCanRespectExistingJoinClause", testToManyThroughCanRespectExistingJoinClause),
    ("testSaveSetsTimestampsForNewRecord", testSaveSetsTimestampsForNewRecord),
    ("testSaveSetsTimestampsForUpdatedRecord", testSaveSetsTimestampsForUpdatedRecord),
    ("testSaveInsertsNewRecord", testSaveInsertsNewRecord),
    ("testSaveUpdatesExistingRecord", testSaveUpdatesExistingRecord),
    ("testSaveInsertConstructsInsertQuery", testSaveInsertConstructsInsertQuery),
    ("testSaveInsertSetsId", testSaveInsertSetsId),
    ("testSaveInsertWithIdReturnsRecordWithId", testSaveInsertWithIdReturnsRecordWithId),
    ("testSaveInsertWithErrorReturnsNil", testSaveInsertWithErrorReturnsNil),
    ("testSaveInsertCreatesSparseInsertQuery", testSaveInsertCreatesSparseInsertQuery),
    ("testSaveInsertCanSaveRecordWithNoFieldsTwo", testSaveInsertCanSaveRecordWithNoFieldsTwo),
    ("testSaveUpdateCreatesUpdateQuery", testSaveUpdateCreatesUpdateQuery),
    ("testSaveUpdateCanCreateUpdateQueryWithNull", testSaveUpdateCanCreateUpdateQueryWithNull),
    ("testSaveUpdateWithDatabaseErrorReturnsNil", testSaveUpdateWithDatabaseErrorReturnsNil),
    ("testDestroyExecutesDeleteQuery", testDestroyExecutesDeleteQuery),
    ("testBuildWithNoErrorBuildsRecord", testBuildWithNoErrorBuildsRecord),
    ("testBuildWithGeneralErrorIsNil", testBuildWithGeneralErrorIsNil),
    ("testBuildWithMissingFieldReturnsNil", testBuildWithMissingFieldReturnsNil),
    ("testBuildWithWrongFieldTypeReturnsNil", testBuildWithWrongFieldTypeReturnsNil),
    ("testTableNameIsPluralModelName", testTableNameIsPluralModelName),
    ("testToJsonCreatesJsonDictionaryBasedOnDataMapping", testToJsonCreatesJsonDictionaryBasedOnDataMapping),
    ("testSerializeCreatesSerializedDictionaryBasedOnDataMapping", testSerializeCreatesSerializedDictionaryBasedOnDataMapping),
    ("testCanFetchResultsFromQueryOnClass", testCanFetchResultsFromQueryOnClass),
  ]}

  func setUp() {
    setUpTestCase()
  }
  
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
  
  //MARK: - Association
  
  func testForeignKeyNameIsModelNamePlusId() {
    assert(Hat.foreignKeyName(), equals: "hat_id")
  }
  
  func testToManyFetchesRecordsByForeignKey() {
    let shelf = Shelf(name: "").save()!
    let query : Query<Hat> = shelf.toMany()
    let clause = query.whereClause
    assert(clause.query, equals: "hats.shelf_id=?", message: "has the shelf ID in the query")
    assert(clause.parameters, equals: [SerializableValue.Integer(Int(shelf.id))], message: "has the id as the parameter")
  }
  
  func testToManyWithSpecificForeignKeyUsesThatForeignKey() {
    let shelf = Shelf(name: "").save()!
    let query : Query<Hat> = shelf.toMany(foreignKey: "shelfId")
    let clause = query.whereClause
    assert(clause.query, equals: "hats.shelfId=?", message: "has the shelf ID in the query")
    assert(clause.parameters, equals: [shelf.id.serialize], message: "has the id as the parameter")
  }
  
  func testToManyThroughFetchesManyRecordsByForeignKey() {
    let store = Store(name: "New Store").save()!
    let shelfQuery : Query<Shelf> = store.toMany()
    let query : Query<Hat> = store.toMany(through: shelfQuery, joinToMany: true)
    
    let whereClause = query.whereClause
    assert(whereClause.query, equals: "shelfs.store_id=?")
    assert(whereClause.parameters, equals: [store.id.serialize], message: "has the id as the parameter")
    
    let joinClause = query.joinClause
    assert(joinClause.query, equals: "INNER JOIN shelfs ON shelfs.id = hats.shelf_id", message: "joins between shelves and hats in the join clause")
    assert(joinClause.parameters.count, equals: 0, message: "has no parameters in the join clause")
  }
  
  func testToManyThroughFetchesOneRecordByForeignKey() {
    let hat = Hat(shelfId: 1).save()!
    let shelfQuery = Shelf.query.filter(["id": hat.shelfId])
    let query : Query<Store> = hat.toMany(through: shelfQuery, joinToMany: false)
    
    let whereClause = query.whereClause
    assert(whereClause.query, equals: "shelfs.id=?")
    assert(whereClause.parameters, equals: [hat.shelfId!.serialize], message: "has the id as the parameter")
    
    let joinClause = query.joinClause
    assert(joinClause.query, equals: "INNER JOIN shelfs ON shelfs.store_id = stores.id", message: "joins between shelves and stores in the join clause")
    assert(joinClause.parameters.count, equals: 0, message: "has no parameters in the join clause")
  }
  
  func testToManyThroughCanRespectExistingJoinClause() {
    let hat = Hat(shelfId: 1).save()!
    var shelfQuery = Shelf.query.filter(["id": hat.shelfId])
    shelfQuery = shelfQuery.join("INNER JOIN foo ON foo.bar = shelfs.id AND foo.baz = ?", [1])
    let query : Query<Store> = hat.toMany(through: shelfQuery, joinToMany: false)
    
    let whereClause = query.whereClause
    assert(whereClause.query, equals: "shelfs.id=?")
    assert(whereClause.parameters, equals: [hat.shelfId!.serialize], message: "has the id as the parameter")
    
    let joinClause = query.joinClause
    assert(joinClause.query, equals: "INNER JOIN shelfs ON shelfs.store_id = stores.id INNER JOIN foo ON foo.bar = shelfs.id AND foo.baz = ?", message: "adds the new join clause to the existing one")
    assert(joinClause.parameters.first, equals: SerializableValue.Integer(1), message: "has the existing parameters from the join clause")
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
    
    assert(Hat.query.count(), equals: 0, message: "starts out with 0 records")
    let hat = Hat()
    hat.save()
    assert(Hat.query.count(), equals: 1, message: "ends with 1 record")
  }
  
  func testSaveUpdatesExistingRecord() {
    var hat = Hat(color: "black")
    
    hat = hat.save()!
    assert(Hat.query.count(), equals: 1, message: "starts out with 1 record")
    assert(Hat.query.first()?.color, equals: "black", message: "starts out with a black hat")
    hat.color = "tan"
    hat = hat.save()!
    
    assert(Hat.query.count(), equals: 1, message: "ends with 1 record")
    assert(Hat.query.first()?.color, equals: "tan", message: "ends with a tan hat")
  }
  
  func testSaveInsertConstructsInsertQuery() {
    StubbedDatabaseConnection.withTestConnection {
      connection in
      let store = Store(name: "Little Shop")
      connection.response = [DatabaseRow(rawData: ["id": 2])]
      store.save()
      self.assert(connection.queries.count, equals: 1, message: "executes 1 query")
      if connection.queries.count > 0 {
        let (query, parameters) = connection.queries[0]
        self.assert(query, equals: "INSERT INTO stores (name) VALUES (?)", message: "has the query to insert the record")
        
        self.assert(parameters, equals: ["Little Shop".serialize], message: "has the name as the parameter")
      }
    }
  }
  
  func testSaveInsertSetsId() {
    StubbedDatabaseConnection.withTestConnection {
      connection in
      var store = Store(name: "Little Shop")
      connection.response = [DatabaseRow(rawData: ["id": 2])]
      store = store.save() ?? store
      self.assert(store.id, equals: 2, message: "sets the id based on the database response")
    }
  }
  
  func testSaveInsertWithIdReturnsRecordWithId() {
    StubbedDatabaseConnection.withTestConnection {
      connection in
      let store = Store(name: "Little Shop")
      connection.response = [DatabaseRow(rawData: ["id": 2])]
      let result = store.save()
      self.assert(result?.id, equals: 2)
    }
  }
  
  func testSaveInsertWithErrorReturnsNil() {
    StubbedDatabaseConnection.withTestConnection {
      connection in
      let store = Store(name: "Little Shop")
      connection.response = [DatabaseRow(error: "Lost Connection")]
      let result = store.save()
      XCTAssertTrue(result == nil)
    }
  }
  
  func testSaveInsertCreatesSparseInsertQuery() {
    StubbedDatabaseConnection.withTestConnection {
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
          10.serialize,
          "red".serialize,
          Timestamp.now().serialize,
          Timestamp.now().serialize
        ]
        
        self.assert(parameters[0], equals: expectedParameters[0], message: "has the brim size parameter")
        self.assert(parameters[1], equals: expectedParameters[1], message: "has the color parameter")
        
        let currentTimestamp = Timestamp.now().epochSeconds
        
        do {
          let timestamp1 = try Timestamp(deserialize: parameters[2]).epochSeconds
          let timestamp2 = try Timestamp(deserialize: parameters[3]).epochSeconds
          assert(timestamp1, within:1, of: currentTimestamp)
          assert(timestamp2, within:1, of: currentTimestamp)
        }
        catch {
          assert(false, message: "threw unexpected error")
        }
      }
    }
  }
  
  func testSaveInsertCanSaveRecordWithNoFieldsTwo() {
    struct TestHat: Persistable {
      let id: UInt
      init() { self.id = 0 }
      init(deserialize values: SerializableValue) throws {
        self.id = try values.read("id")
      }
      func valuesToPersist() -> [String : SerializationEncodable?] {
        return [:]
      }
      static let tableName = "hats"
    }
    StubbedDatabaseConnection.withTestConnection {
      connection in
      self.assert(connection.queries.count, equals: 0)
      let hat = TestHat()
      hat.save()
      self.assert(connection.queries.count, equals: 1, message: "executes one query")
      if connection.queries.count > 0 {
        let (query, parameters) = connection.queries[0]
        self.assert(query, equals: "INSERT INTO hats (id) VALUES (NULL)", message: "has the query to insert the record")
        self.assert(parameters.isEmpty, message: "ha no parameters for the query")
      }
      
    }
    let hat = TestHat().save()
    assert(isNotNil: hat, message: "can save a record with no fields")
    assert(isNotNil: hat?.id, message: "still sets the primary key with no fields")
  }
  
  func testSaveUpdateCreatesUpdateQuery() {
    var shelf = Shelf(name: "Top Shelf", storeId: 1)
    shelf = shelf.save() ?? shelf
    StubbedDatabaseConnection.withTestConnection {
      connection in
      shelf.name = "Bottom Shelf"
      shelf.storeId = 2
      shelf = shelf.save() ?? shelf
      self.assert(connection.queries.count, equals: 1, message: "executes one query")
      if connection.queries.count > 0 {
        let (query, parameters) = connection.queries[0]
        self.assert(query, equals: "UPDATE shelfs SET name = ?, store_id = ? WHERE id = ?", message: "has the update query")
        
        let expectedParameters = [
          "Bottom Shelf".serialize,
          2.serialize,
          shelf.id.serialize
        ]
        self.assert(parameters, equals: expectedParameters, message: "has the name, store ID, and id as parameters")
      }
    }
  }
  
  func testSaveUpdateCanCreateUpdateQueryWithNull() {
    var shelf = Shelf(name: "Top Shelf", storeId: 1)
    shelf = shelf.save() ?? shelf
    StubbedDatabaseConnection.withTestConnection {
      connection in
      shelf.name = nil
      shelf = shelf.save() ?? shelf
      self.assert(connection.queries.count, equals: 1, message: "executes one query")
      if connection.queries.count > 0 {
        let (query, parameters) = connection.queries[0]
        self.assert(query, equals: "UPDATE shelfs SET name = NULL, store_id = ? WHERE id = ?", message: "has the update query")
        
        let expectedParameters = [
          1.serialize,
          shelf.id.serialize
        ]
        self.assert(parameters, equals: expectedParameters, message: "has the storeId and id as parameters")
      }
    }
  }
  
  func testSaveUpdateWithDatabaseErrorReturnsNil() {
    var shelf = Shelf(name: "Top Shelf", storeId: 1).save()!
    StubbedDatabaseConnection.withTestConnection {
      connection in
      shelf.name = nil
      connection.response = [DatabaseRow(error: "Connection Error")]
      let result = shelf.save()
      XCTAssertTrue(result == nil)
    }
  }
  
  func testDestroyExecutesDeleteQuery() {
    let shelf = Shelf(name: "Shelf").save()!
    StubbedDatabaseConnection.withTestConnection {
      connection in
      shelf.destroy()
      self.assert(connection.queries.count, equals: 1, message: "executes one query")
      if connection.queries.count == 1 {
        let (query, parameters) = connection.queries[0]
        self.assert(query, equals: "DELETE FROM shelfs WHERE id = ?", message: "executes a destroy query")
        let data = shelf.id.serialize
        self.assert(parameters, equals: [data], message: "has the id as the parameter for the query")
      }
    }
  }
  
  func testBuildWithNoErrorBuildsRecord() {
    let hat = Hat.build(SerializableValue.Dictionary(["brim_size": 10.serialize, "color": "red".serialize, "id": 1.serialize]))
    assert(isNotNil: hat)
  }
  
  func testBuildWithGeneralErrorIsNil() {
    let shelf = Shelf.build(SerializableValue.Dictionary(["name": "hi".serialize, "throwError": true.serialize, "id": 1.serialize]))
    assert(isNil: shelf)
  }
  
  func testBuildWithMissingFieldReturnsNil() {
    let hat = Hat.build(SerializableValue.Dictionary(["brim_size": 10.serialize, "id": 1.serialize]))
    assert(isNil: hat)
  }
  
  func testBuildWithWrongFieldTypeReturnsNil() {
    let hat = Hat.build(SerializableValue.Dictionary(["brim_size": 10.serialize, "color": 5.serialize, "id": 1.serialize]))
    assert(isNil: hat)
  }
  
  func testTableNameIsPluralModelName() {
    assert(TopHat.tableName, equals: "top_hats")
  }
  
  @available(*, deprecated)
  func testToJsonCreatesJsonDictionaryBasedOnDataMapping() {
    let hat = Hat(brimSize: 10, color: "red", shelfId: nil, owner: "John", id: 5)
    let json = hat.toJson()
    assert(json, equals: .Dictionary([
      "brim_size": JsonPrimitive.Integer(10),
      "color": JsonPrimitive.String("red"),
      "shelf_id": JsonPrimitive.Null,
      "id": JsonPrimitive.Integer(5),
      "created_at": JsonPrimitive.Null,
      "updated_at": JsonPrimitive.Null
    ]))
  }
  
  func testSerializeCreatesSerializedDictionaryBasedOnDataMapping() {
    let hat = Hat(brimSize: 10, color: "red", shelfId: nil, owner: "John", id: 5)
    let json = hat.serialize
    assert(json, equals: .Dictionary([
      "brim_size": SerializableValue.Integer(10),
      "color": SerializableValue.String("red"),
      "shelf_id": SerializableValue.Null,
      "id": SerializableValue.Integer(5),
      "created_at": SerializableValue.Null,
      "updated_at": SerializableValue.Null
      ]))
  }
  
  func testCanFetchResultsFromQueryOnClass() {
    class TestShelf: Persistable {
      let id: UInt
      var name: String?
      var storeId: Int
      
      init(name: String?, storeId: Int = 0, id: UInt = 0) {
        self.name = name
        self.storeId = storeId
        self.id = id
      }
      
      static var tableName: String { return "shelfs" }
      
      func valuesToPersist() -> [String: SerializationEncodable?] {
        return [
          "name": name,
          "store_id": storeId
        ]
      }
      
      required init(deserialize values: SerializableValue) {
        self.name = try! values.read("name")
        self.id = try! values.read("id")
        self.storeId = try! values.read("store_id") ?? 0
      }
    }
    let shelf = TestShelf(name: "Top Shelf").save()!
    let results = TestShelf.query.allRecords()
    assert(results.count, equals: 1)
    if results.count > 0 {
      let shelf2 = results[0] as? TestShelf
      assert(shelf2?.id, equals: shelf.id)
    }
  }
}
