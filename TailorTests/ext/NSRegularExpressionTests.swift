@testable import Tailor
import Tailor
import TailorTesting
import XCTest

class NSRegularExpressionTests : XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
  func testCanCreateExpressionWithStartAnchor() {
    assertNoExceptions {
      let expression = try NSRegularExpression(pattern: "^bc")
      let result1 = expression.matchesInString("bcd", options: [], range: NSMakeRange(0,3))
      assert(result1.count, equals: 1)
      assert(result1.first?.range.location, equals: 0)
      assert(result1.first?.range.length, equals: 2)
      let result2 = expression.matchesInString("abc", options: [], range: NSMakeRange(0,2))
      assert(result2.count, equals: 0)
    }
  }
  
  func testCanCreateExpressionWithEndAnchor() {
    assertNoExceptions {
      let expression = try NSRegularExpression(pattern: "bc$")
      let result1 = expression.matchesInString("abc", options: [], range: NSMakeRange(0,3))
      assert(result1.count, equals: 1)
      assert(result1.first?.range.location, equals: 1)
      assert(result1.first?.range.length, equals: 2)
      let result2 = expression.matchesInString("bcd", options: [], range: NSMakeRange(0,2))
      assert(result2.count, equals: 0)
    }
  }
  
  func testCanCreateExpressionWithOptionalCharacter() {
    assertNoExceptions {
      let expression = try NSRegularExpression(pattern: "bc?")
      let result1 = expression.matchesInString("abcc", options: [], range: NSMakeRange(0,4))
      assert(result1.count, equals: 1)
      assert(result1.first?.range.location, equals: 1)
      assert(result1.first?.range.length, equals: 2)
      let result2 = expression.matchesInString("abd", options: [], range: NSMakeRange(0,2))
      assert(result2.count, equals: 1)
      assert(result2.first?.range.location, equals: 1)
      assert(result2.first?.range.length, equals: 1)
      let result3 = expression.matchesInString("ad", options: [], range: NSMakeRange(0,2))
      assert(result3.count, equals: 0)
    }
  }
  
  func testCanCreateExpressionWithMetaclassWithRange() {
    assertNoExceptions {
      let expression = try NSRegularExpression(pattern: "a[0-5]", options: [])
      let result1 = expression.matchesInString("a2b", options: [], range: NSMakeRange(0,3))
      assert(result1.count, equals: 1)
      assert(result1.first?.range.location, equals: 0)
      assert(result1.first?.range.length, equals: 2)
      let result2 = expression.matchesInString("a6", options: [], range: NSMakeRange(0,2))
      assert(result2.count, equals: 0)
    }
  }
}