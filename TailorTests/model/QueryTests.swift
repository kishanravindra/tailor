import XCTest

class QueryTests: XCTestCase {
  let baseQuery = Query<Hat>(
    selectClause: "hats.id,hats.color,hats.brim_size",
    whereClause: ("hats.store_id=?", ["5"]),
    orderClause: ("hats.created_at ASC", []),
    limitClause: ("5", []),
    joinClause: ("INNER JOIN shelfs ON shelfs.id = hats.shelf_id", []),
    conditions: ["storeId": NSNumber(int: 5)]
  )
  
  override func setUp() {
    TestApplication.start()
    let connection = DatabaseConnection.sharedConnection()
    connection.executeQuery("TRUNCATE TABLE hats")
    connection.executeQuery("TRUNCATE TABLE shelfs")
    connection.executeQuery("TRUNCATE TABLE stores")
  }
  
  //MARK: - Initialization
  
  func testInitializationWithNoParametersHasDefaultClauses() {
    let query = Query<Hat>()
    XCTAssertEqual(query.selectClause, "hats.*", "selects all fields")
    XCTAssertEqual(query.whereClause.query, "", "has an empty where clause")
    XCTAssertEqual(query.whereClause.parameters, [], "has an empty where clause")
    XCTAssertEqual(query.orderClause.query, "", "has an empty order clause")
    XCTAssertEqual(query.orderClause.parameters, [], "has an empty order clause")
    XCTAssertEqual(query.limitClause.query, "", "has an empty limit clause")
    XCTAssertEqual(query.limitClause.parameters, [], "has an empty limit clause")
    XCTAssertEqual(query.joinClause.query, "", "has an empty join clause")
    XCTAssertEqual(query.joinClause.parameters, [], "has an empty join clause")
    XCTAssertTrue(query.conditions.isEmpty, "has no conditions")
  }
  
  func testInitializationWithCopyFromCopiesAllFields() {
    let query = Query<Hat>(copyFrom: baseQuery)
    XCTAssertEqual(query.selectClause, baseQuery.selectClause, "copies select clause")
    XCTAssertEqual(query.whereClause.query, baseQuery.whereClause.query, "copies where clause")
    XCTAssertEqual(query.whereClause.parameters, baseQuery.whereClause.parameters, "copies where clause")
    XCTAssertEqual(query.orderClause.query, baseQuery.orderClause.query, "copies order clause")
    XCTAssertEqual(query.orderClause.parameters, baseQuery.orderClause.parameters, "copies order clause")
    XCTAssertEqual(query.limitClause.query, baseQuery.limitClause.query, "copies limit clause")
    XCTAssertEqual(query.limitClause.parameters, baseQuery.limitClause.parameters, "copies limit clause")
    XCTAssertEqual(query.joinClause.query, baseQuery.joinClause.query, "copies join clause")
    XCTAssertEqual(query.joinClause.parameters, baseQuery.joinClause.parameters, "copies join clause")
    
    if let storeId = query.conditions["storeId"] as? NSNumber {
      XCTAssertEqual(storeId, NSNumber(int: 5), "copies conditions")
    }
    else {
      XCTFail("copies conditions")
    }
  }

  //MARK: - Query Building
  
  func testFilterWithNoClauseSetsClause() {
    let query1 = Query<Hat>(copyFrom: baseQuery, whereClause: ("", []))
    let query2 = query1.filter("hats.color=?", ["red"])
    
    XCTAssertEqual(query2.selectClause, baseQuery.selectClause, "copies select clause")
    XCTAssertEqual(query2.whereClause.query, "hats.color=?", "sets where clause")
    XCTAssertEqual(query2.whereClause.parameters, ["red"], "sets where clause")
    XCTAssertEqual(query2.orderClause.query, baseQuery.orderClause.query, "copies order clause")
    XCTAssertEqual(query2.orderClause.parameters, baseQuery.orderClause.parameters, "copies order clause")
    XCTAssertEqual(query2.limitClause.query, baseQuery.limitClause.query, "copies limit clause")
    XCTAssertEqual(query2.limitClause.parameters, baseQuery.limitClause.parameters, "copies limit clause")
    XCTAssertEqual(query2.joinClause.query, baseQuery.joinClause.query, "copies join clause")
    XCTAssertEqual(query2.joinClause.parameters, baseQuery.joinClause.parameters, "copies join clause")
  }
  
  func testFilterWithExistingClauseCombinesClauses() {
    let query = baseQuery.filter("hats.color=?", ["red"])
    
    XCTAssertEqual(query.selectClause, baseQuery.selectClause, "copies select clause")
    XCTAssertEqual(query.whereClause.query, "hats.store_id=? AND hats.color=?", "sets where clause")
    XCTAssertEqual(query.whereClause.parameters, ["5", "red"], "sets where clause")
    XCTAssertEqual(query.orderClause.query, baseQuery.orderClause.query, "copies order clause")
    XCTAssertEqual(query.orderClause.parameters, baseQuery.orderClause.parameters, "copies order clause")
    XCTAssertEqual(query.limitClause.query, baseQuery.limitClause.query, "copies limit clause")
    XCTAssertEqual(query.limitClause.parameters, baseQuery.limitClause.parameters, "copies limit clause")
    XCTAssertEqual(query.joinClause.query, baseQuery.joinClause.query, "copies join clause")
    XCTAssertEqual(query.joinClause.parameters, baseQuery.joinClause.parameters, "copies join clause")
  }
  
  func testFilterWithConditionsCombinesClauses() {
    let query = baseQuery.filter(["color": "red"])
    
    XCTAssertEqual(query.selectClause, baseQuery.selectClause, "copies select clause")
    XCTAssertEqual(query.whereClause.query, "hats.store_id=? AND hats.color=?", "sets where clause")
    XCTAssertEqual(query.whereClause.parameters, ["5", "red"], "sets where clause")
    XCTAssertEqual(query.orderClause.query, baseQuery.orderClause.query, "copies order clause")
    XCTAssertEqual(query.orderClause.parameters, baseQuery.orderClause.parameters, "copies order clause")
    XCTAssertEqual(query.limitClause.query, baseQuery.limitClause.query, "copies limit clause")
    XCTAssertEqual(query.limitClause.parameters, baseQuery.limitClause.parameters, "copies limit clause")
    XCTAssertEqual(query.joinClause.query, baseQuery.joinClause.query, "copies join clause")
    XCTAssertEqual(query.joinClause.parameters, baseQuery.joinClause.parameters, "copies join clause")
    
    XCTAssertEqual(query.conditions.keys.array, ["storeId", "color"], "combines conditions")
  }
  
  func testFilterWithNilConditionPutsNullInConditions() {
    let query = baseQuery.filter(["color": nil])
    
    XCTAssertEqual(query.selectClause, baseQuery.selectClause, "copies select clause")
    XCTAssertEqual(query.whereClause.query, "hats.store_id=? AND hats.color IS NULL", "sets where clause")
    XCTAssertEqual(query.whereClause.parameters, ["5"], "sets where clause")
    XCTAssertEqual(query.orderClause.query, baseQuery.orderClause.query, "copies order clause")
    XCTAssertEqual(query.orderClause.parameters, baseQuery.orderClause.parameters, "copies order clause")
    XCTAssertEqual(query.limitClause.query, baseQuery.limitClause.query, "copies limit clause")
    XCTAssertEqual(query.limitClause.parameters, baseQuery.limitClause.parameters, "copies limit clause")
    XCTAssertEqual(query.joinClause.query, baseQuery.joinClause.query, "copies join clause")
    XCTAssertEqual(query.joinClause.parameters, baseQuery.joinClause.parameters, "copies join clause")
    
    XCTAssertEqual(query.conditions.keys.array, ["storeId", "color"], "combines conditions")
  }
  
  func testFilterWithInvalidConditionLeavesExistingWhereClause() {
    let query = baseQuery.filter(["colour": "red"])
    
    XCTAssertEqual(query.selectClause, baseQuery.selectClause, "copies select clause")
    XCTAssertEqual(query.whereClause.query, baseQuery.whereClause.query, "copies where clause")
    XCTAssertEqual(query.whereClause.parameters, baseQuery.whereClause.parameters, "copies where clause")
    XCTAssertEqual(query.orderClause.query, baseQuery.orderClause.query, "copies order clause")
    XCTAssertEqual(query.orderClause.parameters, baseQuery.orderClause.parameters, "copies order clause")
    XCTAssertEqual(query.limitClause.query, baseQuery.limitClause.query, "copies limit clause")
    XCTAssertEqual(query.limitClause.parameters, baseQuery.limitClause.parameters, "copies limit clause")
    XCTAssertEqual(query.joinClause.query, baseQuery.joinClause.query, "copies join clause")
    XCTAssertEqual(query.joinClause.parameters, baseQuery.joinClause.parameters, "copies join clause")
    
    XCTAssertEqual(query.conditions.keys.array, ["colour", "storeId"], "combines conditions")
  }
  
  func testOrderAppendsNewOrdering() {
    let query = baseQuery.order("color", .OrderedAscending)
    
    XCTAssertEqual(query.selectClause, baseQuery.selectClause, "copies select clause")
    XCTAssertEqual(query.whereClause.query, baseQuery.whereClause.query, "copies where clause")
    XCTAssertEqual(query.whereClause.parameters, baseQuery.whereClause.parameters, "copies where clause")
    XCTAssertEqual(query.orderClause.query, "hats.created_at ASC, hats.color ASC", "sets order clause")
    XCTAssertEqual(query.orderClause.parameters, [], "sets order clause")
    XCTAssertEqual(query.limitClause.query, baseQuery.limitClause.query, "copies limit clause")
    XCTAssertEqual(query.limitClause.parameters, baseQuery.limitClause.parameters, "copies limit clause")
    XCTAssertEqual(query.joinClause.query, baseQuery.joinClause.query, "copies join clause")
    XCTAssertEqual(query.joinClause.parameters, baseQuery.joinClause.parameters, "copies join clause")
  }
  
  func testOrderWithInvalidParameterLeavesExistingOrdering() {
    let query = baseQuery.order("colour", .OrderedAscending)
    
    XCTAssertEqual(query.selectClause, baseQuery.selectClause, "copies select clause")
    XCTAssertEqual(query.whereClause.query, baseQuery.whereClause.query, "copies where clause")
    XCTAssertEqual(query.whereClause.parameters, baseQuery.whereClause.parameters, "copies where clause")
    XCTAssertEqual(query.orderClause.query, baseQuery.orderClause.query, "copies order clause")
    XCTAssertEqual(query.orderClause.parameters, baseQuery.orderClause.parameters, "copies order clause")
    XCTAssertEqual(query.limitClause.query, baseQuery.limitClause.query, "copies limit clause")
    XCTAssertEqual(query.limitClause.parameters, baseQuery.limitClause.parameters, "copies limit clause")
    XCTAssertEqual(query.joinClause.query, baseQuery.joinClause.query, "copies join clause")
    XCTAssertEqual(query.joinClause.parameters, baseQuery.joinClause.parameters, "copies join clause")
  }
  
  func testLimitWithLowerLimitSetsLimitClause() {
    let query = baseQuery.limit(3)
    XCTAssertEqual(query.selectClause, baseQuery.selectClause, "copies select clause")
    XCTAssertEqual(query.whereClause.query, baseQuery.whereClause.query, "copies where clause")
    XCTAssertEqual(query.whereClause.parameters, baseQuery.whereClause.parameters, "copies where clause")
    XCTAssertEqual(query.orderClause.query, baseQuery.orderClause.query, "copies order clause")
    XCTAssertEqual(query.orderClause.parameters, baseQuery.orderClause.parameters, "copies order clause")
    XCTAssertEqual(query.limitClause.query, "3", "sets limit clause")
    XCTAssertEqual(query.limitClause.parameters, [], "sets limit clause")
    XCTAssertEqual(query.joinClause.query, baseQuery.joinClause.query, "copies join clause")
    XCTAssertEqual(query.joinClause.parameters, baseQuery.joinClause.parameters, "copies join clause")
  }
  
  func testLimitWithHigherLimitLeavesLimitClause() {
    let query = baseQuery.limit(7)
    XCTAssertEqual(query.selectClause, baseQuery.selectClause, "copies select clause")
    XCTAssertEqual(query.whereClause.query, baseQuery.whereClause.query, "copies where clause")
    XCTAssertEqual(query.whereClause.parameters, baseQuery.whereClause.parameters, "copies where clause")
    XCTAssertEqual(query.orderClause.query, baseQuery.orderClause.query, "copies order clause")
    XCTAssertEqual(query.orderClause.parameters, baseQuery.orderClause.parameters, "copies order clause")
    XCTAssertEqual(query.limitClause.query, baseQuery.limitClause.query, "leaves limit clause")
    XCTAssertEqual(query.limitClause.parameters, baseQuery.limitClause.parameters, "leaves limit clause")
    XCTAssertEqual(query.joinClause.query, baseQuery.joinClause.query, "copies join clause")
    XCTAssertEqual(query.joinClause.parameters, baseQuery.joinClause.parameters, "copies join clause")
  }
  
  func testLimitWithNoExistingLimitSetsLimitClause() {
    let query2 = Query<Hat>(copyFrom: baseQuery, limitClause: ("", []))
    let query = query2.limit(7)
    XCTAssertEqual(query.selectClause, baseQuery.selectClause, "copies select clause")
    XCTAssertEqual(query.whereClause.query, baseQuery.whereClause.query, "copies where clause")
    XCTAssertEqual(query.whereClause.parameters, baseQuery.whereClause.parameters, "copies where clause")
    XCTAssertEqual(query.orderClause.query, baseQuery.orderClause.query, "copies order clause")
    XCTAssertEqual(query.orderClause.parameters, baseQuery.orderClause.parameters, "copies order clause")
    XCTAssertEqual(query.limitClause.query, "7", "sets limit clause")
    XCTAssertEqual(query.limitClause.parameters, [], "sets limit clause")
    XCTAssertEqual(query.joinClause.query, baseQuery.joinClause.query, "copies join clause")
    XCTAssertEqual(query.joinClause.parameters, baseQuery.joinClause.parameters, "copies join clause")
  }
  
  func testSelectReplacesSelectClause() {
    let query = baseQuery.select("count(*)")
    XCTAssertEqual(query.selectClause, "count(*)", "sets select clause")
    XCTAssertEqual(query.whereClause.query, baseQuery.whereClause.query, "copies where clause")
    XCTAssertEqual(query.whereClause.parameters, baseQuery.whereClause.parameters, "copies where clause")
    XCTAssertEqual(query.orderClause.query, baseQuery.orderClause.query, "copies order clause")
    XCTAssertEqual(query.orderClause.parameters, baseQuery.orderClause.parameters, "copies order clause")
    XCTAssertEqual(query.limitClause.query, baseQuery.limitClause.query, "copies limit clause")
    XCTAssertEqual(query.limitClause.parameters, baseQuery.limitClause.parameters, "copies limit clause")
    XCTAssertEqual(query.joinClause.query, baseQuery.joinClause.query, "copies join clause")
    XCTAssertEqual(query.joinClause.parameters, baseQuery.joinClause.parameters, "copies join clause")
  }
  
  func testJoinWithQueryStringAppendsToJoinClause() {
    let query = baseQuery.join("INNER JOIN stores ON stores.id = shelfs.store_id")
    XCTAssertEqual(query.selectClause, baseQuery.selectClause, "copies select clause")
    XCTAssertEqual(query.whereClause.query, baseQuery.whereClause.query, "copies where clause")
    XCTAssertEqual(query.whereClause.parameters, baseQuery.whereClause.parameters, "copies where clause")
    XCTAssertEqual(query.orderClause.query, baseQuery.orderClause.query, "copies order clause")
    XCTAssertEqual(query.orderClause.parameters, baseQuery.orderClause.parameters, "copies order clause")
    XCTAssertEqual(query.limitClause.query, baseQuery.limitClause.query, "copies limit clause")
    XCTAssertEqual(query.limitClause.parameters, baseQuery.limitClause.parameters, "copies limit clause")
    XCTAssertEqual(query.joinClause.query, "INNER JOIN shelfs ON shelfs.id = hats.shelf_id INNER JOIN stores ON stores.id = shelfs.store_id", "sets join clause")
    XCTAssertEqual(query.joinClause.parameters, [], "sets join clause")
  }
  
  func testJoinWithValidColumnNamesSetsJoinClause() {
    let query = baseQuery.join(Store.self, fromField: "id", toField: "shelfId")
    XCTAssertEqual(query.selectClause, baseQuery.selectClause, "copies select clause")
    XCTAssertEqual(query.whereClause.query, baseQuery.whereClause.query, "copies where clause")
    XCTAssertEqual(query.whereClause.parameters, baseQuery.whereClause.parameters, "copies where clause")
    XCTAssertEqual(query.orderClause.query, baseQuery.orderClause.query, "copies order clause")
    XCTAssertEqual(query.orderClause.parameters, baseQuery.orderClause.parameters, "copies order clause")
    XCTAssertEqual(query.limitClause.query, baseQuery.limitClause.query, "copies limit clause")
    XCTAssertEqual(query.limitClause.parameters, baseQuery.limitClause.parameters, "copies limit clause")
    XCTAssertEqual(query.joinClause.query, "INNER JOIN shelfs ON shelfs.id = hats.shelf_id INNER JOIN stores ON stores.id = hats.shelf_id", "sets join clause")
    XCTAssertEqual(query.joinClause.parameters, [], "sets join clause")
  }
  
  func testJoinWithValidColumnNamesLeavesJoinClauseIntact() {
    let query = baseQuery.join(Store.self, fromField: "id", toField: "storeId")
    XCTAssertEqual(query.selectClause, baseQuery.selectClause, "copies select clause")
    XCTAssertEqual(query.whereClause.query, baseQuery.whereClause.query, "copies where clause")
    XCTAssertEqual(query.whereClause.parameters, baseQuery.whereClause.parameters, "copies where clause")
    XCTAssertEqual(query.orderClause.query, baseQuery.orderClause.query, "copies order clause")
    XCTAssertEqual(query.orderClause.parameters, baseQuery.orderClause.parameters, "copies order clause")
    XCTAssertEqual(query.limitClause.query, baseQuery.limitClause.query, "copies limit clause")
    XCTAssertEqual(query.limitClause.parameters, baseQuery.limitClause.parameters, "copies limit clause")
    XCTAssertEqual(query.joinClause.query, baseQuery.joinClause.query, "copies join clause")
    XCTAssertEqual(query.joinClause.parameters, baseQuery.joinClause.parameters, "copies join clause")
  }

  //MARK: - Running Query
  
  func testToSqlCombinesPartsOfQuery() {
    let (query, parameters) = baseQuery.toSql()
    XCTAssertEqual(query, "SELECT hats.id,hats.color,hats.brim_size FROM hats INNER JOIN shelfs ON shelfs.id = hats.shelf_id WHERE hats.store_id=? ORDER BY hats.created_at ASC LIMIT 5", "combines all parts of the query")
    XCTAssertEqual(parameters, ["5"], "combines all parameters")
  }
  
  func testAllFetchesRecordsUsingQuery() {
    let hat1 = Hat.create(["color": "black"])
    let hat2 = Hat.create(["color": "black"])
    let hat3 = Hat.create(["color": "red"])
    let hat4 = Hat.create(["color": "black"])
    let results = Query<Hat>().filter(["color": "black"]).order("id", .OrderedDescending).limit(2).all()
    XCTAssertEqual(results, [hat4, hat2], "fetches the correct records")
  }
  
  func testFirstGetsFirstMatchingRecord() {
    let hat1 = Hat.create(["color": "red"])
    let hat2 = Hat.create(["color": "black"])
    let hat3 = Hat.create(["color": "black"])
    let query = Query<Hat>().filter(["color": "black"]).order("id", .OrderedAscending)
    if let record = query.first() {
      XCTAssertEqual(record, hat2, "fetches the correct record")
    }
    else {
      XCTFail("fetches the correct record")
    }
  }
  
  func testFirstReturnsNilWithNoMatch() {
    let hat1 = Hat.create(["color": "red"])
    let hat2 = Hat.create(["color": "black"])
    let hat3 = Hat.create(["color": "black"])
    let query = Query<Hat>().filter(["color": "green"])
    XCTAssertNil(query.first(), "returns nil")
  }
  
  func testFindGetsRecordById() {
    let hat1 = Hat.create(["color": "red"])
    let hat2 = Hat.create(["color": "black"])
    
    if let record = Query<Hat>().find(hat2.id.integerValue) {
      XCTAssertEqual(record, hat2, "fetches the correct record")
    }
    else {
      XCTFail("fetches the correct record")
    }
  }
  
  func testFindReturnsNilWithNoMatchingRecord() {
    let hat1 = Hat.create(["color": "red"])
    let hat2 = Hat.create(["color": "black"])
    
    XCTAssertNil(Query<Hat>().find(hat2.id.integerValue + 1), "returns nil with no matching id")
    XCTAssertNil(Query<Hat>().filter(["color": "red"]).find(hat2.id.integerValue), "returns nil when id fails other constraints")
  }
  
  func testCountGetsNumberOfMatchingRecords() {
    let hat1 = Hat.create(["color": "red"])
    let hat2 = Hat.create(["color": "black"])
    let hat3 = Hat.create(["color": "black"])
    let count = Query<Hat>().filter(["color": "black"]).count()
    XCTAssertEqual(count, 2, "finds two records")
  }
  
  func testIsEmptyIsTrueWithMatchingRecords() {
    let hat1 = Hat.create(["color": "red"])
    let hat2 = Hat.create(["color": "black"])
    let hat3 = Hat.create(["color": "black"])
    var query = Query<Hat>().filter(["color": "black"])
    XCTAssertFalse(query.isEmpty(), "is false when there are matches")
    query = Query<Hat>().filter(["color": "green"])
    XCTAssertTrue(query.isEmpty(), "is true when there are no matches")
  }
  
  //MARK: - Building Records
  
  func testBuildSetsConditionsOnRecord() {
    var query = Query<Hat>().filter(["color": "black", "shelfId": NSNumber(int: 5)])
    let hat = query.build(["brimSize": 10, "shelfId": 6])
    
    XCTAssertNil(hat.id, "does not save the record")
    
    XCTAssertNotNil(hat.brimSize)
    if hat.brimSize != nil {
      XCTAssertEqual(hat.brimSize, NSNumber(int: 10), "sets field from input to build call")
    }
    
    XCTAssertNotNil(hat.color)
    if hat.color != nil {
      XCTAssertEqual(hat.color, "black", "sets field from query conditions")
    }
    
    XCTAssertNotNil(hat.shelfId)
    if hat.shelfId != nil {
      XCTAssertEqual(hat.shelfId, NSNumber(int: 5), "picks query conditions over input parameters")
    }
  }
  
  func testCreateSetsConditionsOnRecord() {
    var query = Query<Hat>().filter(["color": "black"])
    let hat = query.create(["brimSize": 10])
    
    XCTAssertNotNil(hat.id, "saves the record")
    
    XCTAssertNotNil(hat.brimSize)
    if hat.brimSize != nil {
      XCTAssertEqual(hat.brimSize, NSNumber(int: 10), "sets field from input to build call")
    }
    
    XCTAssertNotNil(hat.color)
    if hat.color != nil {
      XCTAssertEqual(hat.color, "black", "sets field from query conditions")
    }
  }
}
