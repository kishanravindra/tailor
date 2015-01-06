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
}
