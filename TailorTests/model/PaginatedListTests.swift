@testable import Tailor
import Tailor
import TailorTesting
import XCTest

class PaginatedListTests : XCTestCase, TailorTestable {
  var query = Query<Hat>().filter(["brim_size": 10])
  var list = PaginatedList<Hat>(query: Query<Hat>().filter(["brim_size": 10]), page: 1, pageSize: 10)
  var hats: [Hat] = []
  override func setUp() {
    super.setUp()
    setUpTestCase()
    
    Hat(brimSize: 12).save()
    Hat(brimSize: 13).save()
    for _ in 0..<15 {
      hats.append(Hat(brimSize: 10).save()!)
    }
  }
  
  func testAllGetsPageOfMatchingRecords() {
    let slice = Array(hats[0..<10])
    assert(list.all(), equals: slice)
  }
  
  func testAllWithLastPageGetsSubsetOfRecords() {
    list = PaginatedList<Hat>(query: query, page: 2, pageSize: 10)
    let slice = Array(hats[10..<15])
    assert(list.all(), equals: slice)
  }
  
  func testAllBeyondLastPageGetsEmptyList() {
    list = PaginatedList<Hat>(query: query, page: 3, pageSize: 10)
    assert(list.all().isEmpty)
  }
  
  func testNumberOfPagesGetsPagesRoundedUp() {
    assert(list.numberOfPages, equals: 2)
  }
  
  func testNumberOfPagesWithExactFitGetsCorrectNumberOfPages() {
    list = PaginatedList<Hat>(query: query, page: 1, pageSize: 5)
    assert(list.numberOfPages, equals: 3)
  }
  
  func testNumberOfPagesWithEmptyResultsIsOne() {
    list = PaginatedList<Hat>(query: query.filter(["color": "red"]), page: 1, pageSize: 10)
    assert(list.numberOfPages, equals: 1)
  }
  
  func testListsWithSameInformationAreEqual() {
    let list1 = PaginatedList<Hat>(query: query, page: 1, pageSize: 10)
    let list2 = PaginatedList<Hat>(query: query, page: 1, pageSize: 10)
    self.assert(list1, equals: list2)
  }
  
  func testListsWithDifferentQueryAreNotEqual() {
    let list1 = PaginatedList<Hat>(query: query, page: 1, pageSize: 10)
    let list2 = PaginatedList<Hat>(query: query.filter(["color": "red"]), page: 1, pageSize: 10)
    self.assert(list1, doesNotEqual: list2)
  }
  
  func testListsWithDifferentPageAreNotEqual() {
    let list1 = PaginatedList<Hat>(query: query, page: 1, pageSize: 10)
    let list2 = PaginatedList<Hat>(query: query, page: 2, pageSize: 10)
    self.assert(list1, doesNotEqual: list2)
  }
  
  func testListsWithDifferentPageSizeAreNotEqual() {
    let list1 = PaginatedList<Hat>(query: query, page: 1, pageSize: 10)
    let list2 = PaginatedList<Hat>(query: query, page: 1, pageSize: 5)
    self.assert(list1, doesNotEqual: list2)
  }
}