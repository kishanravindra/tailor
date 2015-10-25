@testable import Tailor
import Tailor
import TailorTesting
import XCTest

class CollectionTypeTests : XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
  func testUniqueGetsUniqueElements() {
    let list1 = ["A", "B", "A", "C", "B", "E"]
    let list2 = list1.unique
    assert(list2, equals: ["A", "B", "C", "E"])
  }
}