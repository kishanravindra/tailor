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
  
  func testCanCreateExpressionWithWildcard() {
    assertNoExceptions {
      let expression = try NSRegularExpression(pattern: "a.b")
      let result1 = expression.matchesInString("acb", options: [], range: NSMakeRange(0,3))
      assert(result1.count, equals: 1)
      assert(result1.first?.range.location, equals: 0)
      assert(result1.first?.range.length, equals: 3)
      let result2 = expression.matchesInString("ab", options: [], range: NSMakeRange(0,2))
      assert(result2.count, equals: 0)
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
  
  func testCanCaptureSubgroups() {
    assertNoExceptions {
      let expression = try NSRegularExpression(pattern: "a(bc*)")
      let results = expression.matchesInString("abccd", options: [], range: NSMakeRange(0,5))
      assert(results.count, equals: 1)
      if results.count < 1 { return }
      let result = results[0]
      assert(result.range.location, equals: 0)
      assert(result.range.length, equals: 4)
      assert(result.numberOfRanges, equals: 2)
      if result.numberOfRanges < 2 { return }
      assert(result.rangeAtIndex(0).location, equals: 0)
      assert(result.rangeAtIndex(0).length, equals: 4)
      assert(result.rangeAtIndex(1).location, equals: 1)
      assert(result.rangeAtIndex(1).length, equals: 3)
    }
  }
  
  func testCanCaptureNestedSubgroups() {
    assertNoExceptions {
      let expression = try NSRegularExpression(pattern: "a(bc(d|e)f)")
      let results = expression.matchesInString("abcdfg", options: [], range: NSMakeRange(0,6))
      assert(results.count, equals: 1)
      if results.count < 1 { return }
      let result = results[0]
      assert(result.range.location, equals: 0)
      assert(result.range.length, equals: 5)
      assert(result.numberOfRanges, equals: 3)
      if result.numberOfRanges < 3 { return }
      assert(result.rangeAtIndex(0).location, equals: 0)
      assert(result.rangeAtIndex(0).length, equals: 5)
      assert(result.rangeAtIndex(1).location, equals: 1)
      assert(result.rangeAtIndex(1).length, equals: 4)
      assert(result.rangeAtIndex(2).location, equals: 3)
      assert(result.rangeAtIndex(2).length, equals: 1)
    }
  }
  
  func testCanCaptureSubgroupsWithRepetition() {
    assertNoExceptions {
      let expression = try NSRegularExpression(pattern: "a(bc)*d")
      let results = expression.matchesInString("abcbcbcdefg", options: [], range: NSMakeRange(0,11))
      assert(results.count, equals: 1)
      if results.count < 1 { return }
      let result = results[0]
      assert(result.range.location, equals: 0)
      assert(result.range.length, equals: 8)
      assert(result.numberOfRanges, equals: 2)
      if result.numberOfRanges < 2 { return }
      assert(result.rangeAtIndex(0).location, equals: 0)
      assert(result.rangeAtIndex(0).length, equals: 8)
      assert(result.rangeAtIndex(1).location, equals: 5)
      assert(result.rangeAtIndex(1).length, equals: 2)
    }
    
  }
}