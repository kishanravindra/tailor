import XCTest

class StringTests: XCTestCase {
  func testLowercaseInitialLowercasesFirstLetter() {
    let input = "Test_Astring"
    let output = input.lowercaseInitial
    XCTAssertEqual(output, "test_Astring", "capitalizes the first character")
  }

  func testCapitalizeInitialCapitalizesFirstLetter() {
    let input = "test_aString"
    let output = input.capitalizeInitial
    XCTAssertEqual(output, "Test_aString", "lowercases the first character")
  }
  
  func testPluralizedGetsPluralValueForSimpleString() {
    XCTAssertEqual("hat".pluralized, "hats", "gets plural string")
  }
  
  func testPluralizedStringWithOEndsInOes() {
    XCTAssertEqual("potato".pluralized, "potatoes", "gets plural string")
  }
  
  func testPluralizedStringWithSEndsInSes() {
    XCTAssertEqual("diss".pluralized, "disses", "gets plural string")
  }
  
  func testContainsDeterminesIfStringContainsOtherString() {
    XCTAssertTrue("happiness".contains("pin"), "contains string in middle")
    XCTAssertTrue("happiness".contains("hap"), "contains string at beginning")
    XCTAssertTrue("happiness".contains("ess"), "contains string at end")
    XCTAssertFalse("happiness".contains("sad"), "does not contain unrelated string")
  }
  
  func testMatchesIsTrueWithMatchingPattern() {
    let string = "johnbrownlee.com"
    let pattern = "[a-z]*\\.[a-z]{3}"
    XCTAssertTrue(string.matches(pattern), "finds a match")
  }
  
  func testMatchesIsFalseWithNonMatchingPattern() {
    let string = "johnbrownlee.com"
    let pattern = "z[a-z]*\\.[a-z]{3}"
    XCTAssertFalse(string.matches(pattern), "does not find a match")
  }
  
  func testMatchesIsFalseWithInvalidPattern() {
    let string = "johnbrownlee.com"
    let pattern = "[a-z]*\\.[a-z]{3"
    XCTAssertFalse(string.matches(pattern), "does not find a match")
  }
  
  func testMatchesIsFalseWithPartialMatch() {
    let string = "johnbrownlee.com/en"
    let pattern = "[a-z]*\\.[a-z]{3}"
    XCTAssertFalse(string.matches(pattern), "does not find a match")
  }
  
  func testMatchesIsTrueWithPartialMatchAndAllowPartialFlag() {
    let string = "johnbrownlee.com/en"
    let pattern = "[a-z]*\\.[a-z]{3}"
    XCTAssertTrue(string.matches(pattern, allowPartial: true), "finds a match")
  }
}
