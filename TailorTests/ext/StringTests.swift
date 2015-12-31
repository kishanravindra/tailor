import XCTest
import TailorTesting

class StringTests: XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
  func testLowercaseInitialLowercasesFirstLetter() {
    let input = "Test_Astring"
    let output = input.lowercaseInitial
    assert(output, equals: "test_Astring", message: "capitalizes the first character")
  }

  func testCapitalizeInitialCapitalizesFirstLetter() {
    let input = "test_aString"
    let output = input.capitalizeInitial
    assert(output, equals: "Test_aString", message: "lowercases the first character")
  }
  
  func testPluralizedGetsPluralValueForSimpleString() {
    assert("hat".pluralized, equals: "hats", message: "gets plural string")
  }
  
  func testPluralizedStringWithOEndsInOes() {
    assert("potato".pluralized, equals: "potatoes", message: "gets plural string")
  }
  
  func testPluralizedStringWithSEndsInSes() {
    assert("diss".pluralized, equals: "disses", message: "gets plural string")
  }
  
  func testContainsDeterminesIfStringContainsOtherString() {
    XCTAssertTrue("happiness".contains("pin"), "contains string in middle")
    XCTAssertTrue("happiness".contains("hap"), "contains string at beginning")
    XCTAssertTrue("happiness".contains("ess"), "contains string at end")
    XCTAssertFalse("happiness".contains("sad"), "does not contain unrelated string")
  }
  
  func testMatchesIsTrueWithMatchingPattern() {
    let string = "johnbrownlee.com"
    let pattern = "[a-z]*\\.[a-z][a-z][a-z]"
    XCTAssertTrue(string.matches(pattern), "finds a match")
  }
  
  func testMatchesIsFalseWithNonMatchingPattern() {
    let string = "johnbrownlee.com"
    let pattern = "z[a-z]*\\.[a-z]"
    XCTAssertFalse(string.matches(pattern), "does not find a match")
  }
  
  func testMatchesIsFalseWithInvalidPattern() {
    let string = "johnbrownlee.com"
    let pattern = "[a-z]*\\.[a-z][a-z][a"
    XCTAssertFalse(string.matches(pattern), "does not find a match")
  }
  
  func testMatchesIsFalseWithPartialMatch() {
    let string = "johnbrownlee.com/en"
    let pattern = "[a-z]*\\.[a-z][a-z][a-z]"
    XCTAssertFalse(string.matches(pattern), "does not find a match")
  }
  
  func testMatchesIsTrueWithPartialMatchAndAllowPartialFlag() {
    let string = "johnbrownlee.com/en"
    let pattern = "[a-z]*\\.[a-z]"
    XCTAssertTrue(string.matches(pattern, allowPartial: true), "finds a match")
  }
  
  func testLastComponentWithMultipleMatchesGetsLastMatch() {
    let string = "abc123def123gef"
    assert(string.lastComponent(separator: "123"), equals: "gef")
  }
  
  func testLastComponentWithMultipleMatchesWithNoMatchesGetsEntireString() {
    let string = "abcdef"
    assert(string.lastComponent(separator: "123"), equals: "abcdef")
  }
  
  func testLastComponentWithEmptyStringGetsEmptyString() {
    let string = ""
    assert(string.lastComponent(separator: "123"), equals: "")
  }
  
  func testRangeOfSelfGetsRangeOfString() {
    let string = "abcdef"
    let range = string.rangeOfSelf
    assert(range.location, equals: 0)
    assert(range.length, equals: 6)
  }
  
  func testStringByReplacingCharactersInSetReplacesCharacters() {
    let string1 = "abc 123\ndef"
    let string2 = string1.stringByEscapingCharacters(.alphanumericCharacterSet(), with: "_")
    assert(string2, equals: "abc_123_def")
  }
}
