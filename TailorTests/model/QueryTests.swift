import XCTest
import Tailor
import TailorTesting

class QueryTests: TailorTestCase {
  let baseQuery = Query<Hat>(
    selectClause: "hats.id,hats.color,hats.brim_size",
    whereClause: ("hats.store_id=?", ["5"]),
    orderClause: ("hats.created_at ASC", []),
    limitClause: ("5", []),
    joinClause: ("INNER JOIN shelfs ON shelfs.id = hats.shelf_id", []),
    conditions: ["storeId": NSNumber(int: 5)],
    cacheResults: true
  )
  
  override func setUp() {
    super.setUp()
    let connection = DatabaseConnection.sharedConnection()
    connection.executeQuery("TRUNCATE TABLE hats")
    connection.executeQuery("TRUNCATE TABLE shelfs")
    connection.executeQuery("TRUNCATE TABLE stores")
  }
  
  //MARK: - Initialization
  
  func testInitializationWithNoParametersHasDefaultClauses() {
    let query = Query<Hat>()
    assert(query.selectClause, equals: "hats.*", message: "selects all fields")
    assert(query.whereClause.query, equals: "", message: "has an empty where clause")
    assert(query.whereClause.parameters, equals: [], message: "has an empty where clause")
    assert(query.orderClause.query, equals: "", message: "has an empty order clause")
    assert(query.orderClause.parameters, equals: [], message: "has an empty order clause")
    assert(query.limitClause.query, equals: "", message: "has an empty limit clause")
    assert(query.limitClause.parameters, equals: [], message: "has an empty limit clause")
    assert(query.joinClause.query, equals: "", message: "has an empty join clause")
    assert(query.joinClause.parameters, equals: [], message: "has an empty join clause")
    XCTAssertTrue(query.conditions.isEmpty, "has no conditions")
    XCTAssertFalse(query.cacheResults, "has cacheResults set to false")
  }
  
  func testInitializationWithCopyFromCopiesAllFields() {
    let query = Query<Hat>(copyFrom: baseQuery)
    assert(query.selectClause, equals: baseQuery.selectClause, message: "copies select clause")
    assert(query.whereClause.query, equals: baseQuery.whereClause.query, message: "copies where clause")
    assert(query.whereClause.parameters, equals: baseQuery.whereClause.parameters, message: "copies where clause")
    assert(query.orderClause.query, equals: baseQuery.orderClause.query, message: "copies order clause")
    assert(query.orderClause.parameters, equals: baseQuery.orderClause.parameters, message: "copies order clause")
    assert(query.limitClause.query, equals: baseQuery.limitClause.query, message: "copies limit clause")
    assert(query.limitClause.parameters, equals: baseQuery.limitClause.parameters, message: "copies limit clause")
    assert(query.joinClause.query, equals: baseQuery.joinClause.query, message: "copies join clause")
    assert(query.joinClause.parameters, equals: baseQuery.joinClause.parameters, message: "copies join clause")
    assert(query.cacheResults, equals: true, message: "copies cacheResults field")
    
    if let storeId = query.conditions["storeId"] as? NSNumber {
      assert(storeId, equals: NSNumber(int: 5), message: "copies conditions")
    }
    else {
      XCTFail("copies conditions")
    }
  }

  //MARK: - Query Building
  
  func testFilterWithNoClauseSetsClause() {
    let query1 = Query<Hat>(copyFrom: baseQuery, whereClause: ("", []))
    let query2 = query1.filter("hats.color=?", ["red"])
    
    assert(query2.selectClause, equals: baseQuery.selectClause, message: "copies select clause")
    assert(query2.whereClause.query, equals: "hats.color=?", message: "sets where clause")
    assert(query2.whereClause.parameters, equals: ["red"], message: "sets where clause")
    assert(query2.orderClause.query, equals: baseQuery.orderClause.query, message: "copies order clause")
    assert(query2.orderClause.parameters, equals: baseQuery.orderClause.parameters, message: "copies order clause")
    assert(query2.limitClause.query, equals: baseQuery.limitClause.query, message: "copies limit clause")
    assert(query2.limitClause.parameters, equals: baseQuery.limitClause.parameters, message: "copies limit clause")
    assert(query2.joinClause.query, equals: baseQuery.joinClause.query, message: "copies join clause")
    assert(query2.joinClause.parameters, equals: baseQuery.joinClause.parameters, message: "copies join clause")
  }
  
  func testFilterWithExistingClauseCombinesClauses() {
    let query = baseQuery.filter("hats.color=?", ["red"])
    
    assert(query.selectClause, equals: baseQuery.selectClause, message: "copies select clause")
    assert(query.whereClause.query, equals: "hats.store_id=? AND hats.color=?", message: "sets where clause")
    assert(query.whereClause.parameters, equals: ["5", "red"], message: "sets where clause")
    assert(query.orderClause.query, equals: baseQuery.orderClause.query, message: "copies order clause")
    assert(query.orderClause.parameters, equals: baseQuery.orderClause.parameters, message: "copies order clause")
    assert(query.limitClause.query, equals: baseQuery.limitClause.query, message: "copies limit clause")
    assert(query.limitClause.parameters, equals: baseQuery.limitClause.parameters, message: "copies limit clause")
    assert(query.joinClause.query, equals: baseQuery.joinClause.query, message: "copies join clause")
    assert(query.joinClause.parameters, equals: baseQuery.joinClause.parameters, message: "copies join clause")
  }
  
  func testFilterWithConditionsCombinesClauses() {
    let query = baseQuery.filter(["color": "red"])
    
    assert(query.selectClause, equals: baseQuery.selectClause, message: "copies select clause")
    assert(query.whereClause.query, equals: "hats.store_id=? AND hats.color=?", message: "sets where clause")
    assert(query.whereClause.parameters, equals: ["5", "red"], message: "sets where clause")
    assert(query.orderClause.query, equals: baseQuery.orderClause.query, message: "copies order clause")
    assert(query.orderClause.parameters, equals: baseQuery.orderClause.parameters, message: "copies order clause")
    assert(query.limitClause.query, equals: baseQuery.limitClause.query, message: "copies limit clause")
    assert(query.limitClause.parameters, equals: baseQuery.limitClause.parameters, message: "copies limit clause")
    assert(query.joinClause.query, equals: baseQuery.joinClause.query, message: "copies join clause")
    assert(query.joinClause.parameters, equals: baseQuery.joinClause.parameters, message: "copies join clause")
    
    assert(query.conditions.keys.array, equals: ["storeId", "color"], message: "combines conditions")
  }
  
  func testFilterWithNilConditionPutsNullInConditions() {
    let query = baseQuery.filter(["color": nil])
    
    assert(query.selectClause, equals: baseQuery.selectClause, message: "copies select clause")
    assert(query.whereClause.query, equals: "hats.store_id=? AND hats.color IS NULL", message: "sets where clause")
    assert(query.whereClause.parameters, equals: ["5"], message: "sets where clause")
    assert(query.orderClause.query, equals: baseQuery.orderClause.query, message: "copies order clause")
    assert(query.orderClause.parameters, equals: baseQuery.orderClause.parameters, message: "copies order clause")
    assert(query.limitClause.query, equals: baseQuery.limitClause.query, message: "copies limit clause")
    assert(query.limitClause.parameters, equals: baseQuery.limitClause.parameters, message: "copies limit clause")
    assert(query.joinClause.query, equals: baseQuery.joinClause.query, message: "copies join clause")
    assert(query.joinClause.parameters, equals: baseQuery.joinClause.parameters, message: "copies join clause")
    
    assert(query.conditions.keys.array, equals: ["storeId", "color"], message: "combines conditions")
  }
  
  func testOrderAppendsNewOrdering() {
    let query = baseQuery.order("color", .OrderedAscending)
    
    assert(query.selectClause, equals: baseQuery.selectClause, message: "copies select clause")
    assert(query.whereClause.query, equals: baseQuery.whereClause.query, message: "copies where clause")
    assert(query.whereClause.parameters, equals: baseQuery.whereClause.parameters, message: "copies where clause")
    assert(query.orderClause.query, equals: "hats.created_at ASC, hats.color ASC", message: "sets order clause")
    assert(query.orderClause.parameters, equals: [], message: "sets order clause")
    assert(query.limitClause.query, equals: baseQuery.limitClause.query, message: "copies limit clause")
    assert(query.limitClause.parameters, equals: baseQuery.limitClause.parameters, message: "copies limit clause")
    assert(query.joinClause.query, equals: baseQuery.joinClause.query, message: "copies join clause")
    assert(query.joinClause.parameters, equals: baseQuery.joinClause.parameters, message: "copies join clause")
  }
  
  func testLimitWithLowerLimitSetsLimitClause() {
    let query = baseQuery.limit(3)
    assert(query.selectClause, equals: baseQuery.selectClause, message: "copies select clause")
    assert(query.whereClause.query, equals: baseQuery.whereClause.query, message: "copies where clause")
    assert(query.whereClause.parameters, equals: baseQuery.whereClause.parameters, message: "copies where clause")
    assert(query.orderClause.query, equals: baseQuery.orderClause.query, message: "copies order clause")
    assert(query.orderClause.parameters, equals: baseQuery.orderClause.parameters, message: "copies order clause")
    assert(query.limitClause.query, equals: "3", message: "sets limit clause")
    assert(query.limitClause.parameters, equals: [], message: "sets limit clause")
    assert(query.joinClause.query, equals: baseQuery.joinClause.query, message: "copies join clause")
    assert(query.joinClause.parameters, equals: baseQuery.joinClause.parameters, message: "copies join clause")
  }
  
  func testLimitWithHigherLimitLeavesLimitClause() {
    let query = baseQuery.limit(7)
    assert(query.selectClause, equals: baseQuery.selectClause, message: "copies select clause")
    assert(query.whereClause.query, equals: baseQuery.whereClause.query, message: "copies where clause")
    assert(query.whereClause.parameters, equals: baseQuery.whereClause.parameters, message: "copies where clause")
    assert(query.orderClause.query, equals: baseQuery.orderClause.query, message: "copies order clause")
    assert(query.orderClause.parameters, equals: baseQuery.orderClause.parameters, message: "copies order clause")
    assert(query.limitClause.query, equals: baseQuery.limitClause.query, message: "leaves limit clause")
    assert(query.limitClause.parameters, equals: baseQuery.limitClause.parameters, message: "leaves limit clause")
    assert(query.joinClause.query, equals: baseQuery.joinClause.query, message: "copies join clause")
    assert(query.joinClause.parameters, equals: baseQuery.joinClause.parameters, message: "copies join clause")
  }
  
  func testLimitWithNoExistingLimitSetsLimitClause() {
    let query2 = Query<Hat>(copyFrom: baseQuery, limitClause: ("", []))
    let query = query2.limit(7)
    assert(query.selectClause, equals: baseQuery.selectClause, message: "copies select clause")
    assert(query.whereClause.query, equals: baseQuery.whereClause.query, message: "copies where clause")
    assert(query.whereClause.parameters, equals: baseQuery.whereClause.parameters, message: "copies where clause")
    assert(query.orderClause.query, equals: baseQuery.orderClause.query, message: "copies order clause")
    assert(query.orderClause.parameters, equals: baseQuery.orderClause.parameters, message: "copies order clause")
    assert(query.limitClause.query, equals: "7", message: "sets limit clause")
    assert(query.limitClause.parameters, equals: [], message: "sets limit clause")
    assert(query.joinClause.query, equals: baseQuery.joinClause.query, message: "copies join clause")
    assert(query.joinClause.parameters, equals: baseQuery.joinClause.parameters, message: "copies join clause")
  }
  
  func testSelectReplacesSelectClause() {
    let query = baseQuery.select("count(*)")
    assert(query.selectClause, equals: "count(*)", message: "sets select clause")
    assert(query.whereClause.query, equals: baseQuery.whereClause.query, message: "copies where clause")
    assert(query.whereClause.parameters, equals: baseQuery.whereClause.parameters, message: "copies where clause")
    assert(query.orderClause.query, equals: baseQuery.orderClause.query, message: "copies order clause")
    assert(query.orderClause.parameters, equals: baseQuery.orderClause.parameters, message: "copies order clause")
    assert(query.limitClause.query, equals: baseQuery.limitClause.query, message: "copies limit clause")
    assert(query.limitClause.parameters, equals: baseQuery.limitClause.parameters, message: "copies limit clause")
    assert(query.joinClause.query, equals: baseQuery.joinClause.query, message: "copies join clause")
    assert(query.joinClause.parameters, equals: baseQuery.joinClause.parameters, message: "copies join clause")
  }
  
  func testJoinWithQueryStringAppendsToJoinClause() {
    let query = baseQuery.join("INNER JOIN stores ON stores.id = shelfs.store_id")
    assert(query.selectClause, equals: baseQuery.selectClause, message: "copies select clause")
    assert(query.whereClause.query, equals: baseQuery.whereClause.query, message: "copies where clause")
    assert(query.whereClause.parameters, equals: baseQuery.whereClause.parameters, message: "copies where clause")
    assert(query.orderClause.query, equals: baseQuery.orderClause.query, message: "copies order clause")
    assert(query.orderClause.parameters, equals: baseQuery.orderClause.parameters, message: "copies order clause")
    assert(query.limitClause.query, equals: baseQuery.limitClause.query, message: "copies limit clause")
    assert(query.limitClause.parameters, equals: baseQuery.limitClause.parameters, message: "copies limit clause")
    assert(query.joinClause.query, equals: "INNER JOIN shelfs ON shelfs.id = hats.shelf_id INNER JOIN stores ON stores.id = shelfs.store_id", message: "sets join clause")
    assert(query.joinClause.parameters, equals: [], message: "sets join clause")
  }
  
  func testJoinWithValidColumnNamesSetsJoinClause() {
    let query = baseQuery.join(Store.self, fromColumn: "id", toColumn: "shelf_id")
    assert(query.selectClause, equals: baseQuery.selectClause, message: "copies select clause")
    assert(query.whereClause.query, equals: baseQuery.whereClause.query, message: "copies where clause")
    assert(query.whereClause.parameters, equals: baseQuery.whereClause.parameters, message: "copies where clause")
    assert(query.orderClause.query, equals: baseQuery.orderClause.query, message: "copies order clause")
    assert(query.orderClause.parameters, equals: baseQuery.orderClause.parameters, message: "copies order clause")
    assert(query.limitClause.query, equals: baseQuery.limitClause.query, message: "copies limit clause")
    assert(query.limitClause.parameters, equals: baseQuery.limitClause.parameters, message: "copies limit clause")
    assert(query.joinClause.query, equals: "INNER JOIN shelfs ON shelfs.id = hats.shelf_id INNER JOIN stores ON stores.id = hats.shelf_id", message: "sets join clause")
    assert(query.joinClause.parameters, equals: [], message: "sets join clause")
  }
  
  func testReverseWithNoOrderOrdersByIdDesc() {
    let query = baseQuery.dynamicType.init(copyFrom: baseQuery, orderClause: ("", [])).reverse()
    assert(query.orderClause.query, equals: "id DESC", message: "adds an order clause in descending order by id")
    assert(query.orderClause.parameters, equals: [], message: "has no parameters for the order clause")
  }
  
  func testReverseWithNormalQueryReversesAscendingAndDescending() {
    let query = baseQuery.dynamicType.init(copyFrom: baseQuery, orderClause: ("name ASC, created_at DESC", [])).reverse()
    assert(query.orderClause.query, equals: "name DESC, created_at ASC", message: "reverses the order")
    assert(query.orderClause.parameters, equals: [], message: "has no parameters for the order clause")
    
  }
  
  func testReverseWithLowercaseOrderReversesAscendingAndDescending() {
    let query = baseQuery.dynamicType.init(copyFrom: baseQuery, orderClause: ("name asc, created_at desc", [])).reverse()
    assert(query.orderClause.query, equals: "name DESC, created_at ASC", message: "reverses the order")
    assert(query.orderClause.parameters, equals: [], message: "has no parameters for the order clause")
    
  }
  
  func testReverseWithOrderWordsInFieldNamesLeavesFieldNamesIntact() {
    let query = baseQuery.dynamicType.init(copyFrom: baseQuery, orderClause: ("incandescence ASC, ascent_time DESC", [])).reverse()
    assert(query.orderClause.query, equals: "incandescence DESC, ascent_time ASC", message: "reverses the order")
    assert(query.orderClause.parameters, equals: [], message: "has no parameters for the order clause")
    
  }
  
  func testCachedSetsCachedFlagToTrue() {
    let query = Query<Hat>().cached()
    XCTAssertTrue(query.cacheResults, "sets the cacheResults flag to true")
  }

  //MARK: - Running Query
  
  func testToSqlCombinesPartsOfQuery() {
    let (query, parameters) = baseQuery.toSql()
    assert(query, equals: "SELECT hats.id,hats.color,hats.brim_size FROM hats INNER JOIN shelfs ON shelfs.id = hats.shelf_id WHERE hats.store_id=? ORDER BY hats.created_at ASC LIMIT 5", message: "combines all parts of the query")
    assert(parameters, equals: ["5"], message: "combines all parameters")
  }
  
  func testAllFetchesRecordsUsingQuery() {
    let hat1 = Hat(color: "black")
    let hat2 = Hat(color: "black")
    let hat3 = Hat(color: "red")
    let hat4 = Hat(color: "black")
    hat1.save()
    hat2.save()
    hat3.save()
    hat4.save()
    let results = Query<Hat>().filter(["color": "black"]).order("id", .OrderedDescending).limit(2).all()
    assert(results, equals: [hat4, hat2], message: "fetches the correct records")
  }
  
  func testFirstGetsFirstMatchingRecord() {
    let hat1 = Hat(color: "red")
    let hat2 = Hat(color: "black")
    let hat3 = Hat(color: "black")
    hat1.save()
    hat2.save()
    hat3.save()
    let query = Query<Hat>().filter(["color": "black"]).order("id", .OrderedAscending)
    if let record = query.first() {
      assert(record, equals: hat2, message: "fetches the correct record")
    }
    else {
      XCTFail("fetches the correct record")
    }
  }
  
  func testFirstReturnsNilWithNoMatch() {
    let hat1 = Hat(color: "red")
    let hat2 = Hat(color: "black")
    let hat3 = Hat(color: "black")
    hat1.save()
    hat2.save()
    hat3.save()
    let query = Query<Hat>().filter(["color": "green"])
    XCTAssertNil(query.first(), "returns nil")
  }
  
  func testLastGetsLastRecordBasedOnOrdering() {
    let hat1 = Hat(color: "black")
    let hat2 = Hat(color: "red")
    let hat3 = Hat(color: "blue")
    hat1.save()
    hat2.save()
    hat3.save()
    let query = Query<Hat>().order("color", .OrderedAscending)
    let record = query.last()
    XCTAssertNotNil(record, "gets a record")
    if record != nil {
      assert(record!, equals: hat2, message: "gets the last one by the ordering criteria")
    }
  }
  
  func testFindGetsRecordById() {
    let hat1 = Hat(color: "red")
    let hat2 = Hat(color: "black")
    hat1.save()
    hat2.save()
    
    if let id=hat2.id, let record = Query<Hat>().find(id) {
      assert(record, equals: hat2, message: "fetches the correct record")
    }
    else {
      XCTFail("fetches the correct record")
    }
  }
  
  func testFindReturnsNilWithNoMatchingRecord() {
    let hat1 = Hat(color: "red")
    let hat2 = Hat(color: "black")
    hat1.save()
    hat2.save()
    
    XCTAssertNil(Query<Hat>().find(hat2.id! + 1), "returns nil with no matching id")
    XCTAssertNil(Query<Hat>().filter(["color": "red"]).find(hat2.id!), "returns nil when id fails other constraints")
  }
  
  func testCountGetsNumberOfMatchingRecords() {
    let hat1 = Hat(color: "red")
    let hat2 = Hat(color: "black")
    let hat3 = Hat(color: "black")
    hat1.save()
    hat2.save()
    hat3.save()
    let count = Query<Hat>().filter(["color": "black"]).count()
    assert(count, equals: 2, message: "finds two records")
  }
  
  func testIsEmptyIsTrueWithMatchingRecords() {
    let hat1 = Hat(color: "red")
    let hat2 = Hat(color: "black")
    let hat3 = Hat(color: "black")
    hat1.save()
    hat2.save()
    hat3.save()
    var query = Query<Hat>().filter(["color": "black"])
    XCTAssertFalse(query.isEmpty(), "is false when there are matches")
    query = Query<Hat>().filter(["color": "green"])
    XCTAssertTrue(query.isEmpty(), "is true when there are no matches")
  }
  
  func testFetchAllWithCachingOnCachesResults() {
    let hat1 = Hat(color: "red")
    let hat2 = Hat(color: "black")
    let hat3 = Hat(color: "black")
    hat1.save()
    hat2.save()
    hat3.save()
    
    CacheStore.shared().clear()
    let query = Query<Hat>().filter(["color": "black"]).cached()
    let firstResults = query.all()
    assert(firstResults.count, equals: 2, message: "gets two results")
    let hat4 = Hat(color: "black")
    hat4.save()
    let secondResults = query.all()
    assert(secondResults.count, equals: 2, message: "still gets two results after one is created")
  }
  
  func testFetchAllWithCachingOnPreservesOriginalOrder() {
    let hat1 = Hat(color: "red")
    let hat2 = Hat(color: "black", brimSize: 10)
    let hat3 = Hat(color: "black", brimSize: 11)
    hat1.save()
    hat2.save()
    hat3.save()
    
    CacheStore.shared().clear()
    let query = Query<Hat>().order("brim_size", .OrderedDescending).filter(["color": "black"]).cached()
    let firstResults = query.all()
    assert(firstResults, equals: [hat3, hat2], message: "uses the specified ordering")
    let secondResults = query.all()
    assert(secondResults, equals: [hat3, hat2], message: "preserves the ordering")
    
  }
  
  func testFetchAllWithInjectionInCacheDoesNotCacheResults() {
    let hat1 = Hat(color: "red")
    let hat2 = Hat(color: "black")
    let hat3 = Hat(color: "black")
    hat1.save()
    hat2.save()
    hat3.save()
    
    CacheStore.shared().clear()
    let query = Query<Hat>().filter(["color": "black"]).cached()
    let firstResults = query.all()
    assert(firstResults.count, equals: 2, message: "gets two results")
    
    let cacheKey = "SELECT hats.* FROM hats WHERE hats.color=?(black)"
    XCTAssertNotNil(CacheStore.shared().read(cacheKey))
    CacheStore.shared().write(cacheKey, value: "0); DROP TABLE `hats`; SELECT (0")
    let hat4 = Hat(color: "black")
    hat4.save()
    let secondResults = query.all()
    assert(secondResults.count, equals: 3, message: "gets three results after one is created")
    assert(Query<Hat>().count(), equals: 4, message: "finds four total results")
  }
  
  func testFetchAllWithCachingOffDoesNotCacheResults() {
    let hat1 = Hat(color: "red")
    let hat2 = Hat(color: "black")
    let hat3 = Hat(color: "black")
    hat1.save()
    hat2.save()
    hat3.save()
    
    CacheStore.shared().clear()
    let query = Query<Hat>().filter(["color": "black"])
    let firstResults = query.all()
    assert(firstResults.count, equals: 2, message: "gets two results")
    let hat4 = Hat(color: "black")
    hat4.save()
    let secondResults = query.all()
    assert(secondResults.count, equals: 3, message: "gets three results after one is created")
  }
}
