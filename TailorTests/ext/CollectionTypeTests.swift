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
  
  func testSlicesDividesListIntoSlices() {
    let list = ["A", "B", "A", "C", "B", "E", "F", "HI", "JK", "V", "Z"]
    let slices = list.slices(3)
    assert(slices.count, equals: 4, message: "gets enough slices to include all the elements")
    if slices.count == 4 {
      assert(Array(slices[0]), equals: ["A", "B", "A"])
      assert(Array(slices[1]), equals: ["C", "B", "E"])
      assert(Array(slices[2]), equals: ["F", "HI", "JK"])
      assert(Array(slices[3]), equals: ["V", "Z"])
    }
  }
}