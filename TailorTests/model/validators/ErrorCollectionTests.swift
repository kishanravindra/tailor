import XCTest

class ErrorCollectionTests: XCTestCase {
  let errors = ErrorCollection()
  
  func testAddKeyPutsEntryInErrors() {
    errors.add("name", "blank")
    errors.add("name", "too short")
    errors.add("color", "blank")
    
    XCTAssertEqual(errors.errors, ["name": ["blank", "too short"], "color": ["blank"]], "puts all the error messages in the hash")
  }
  
  func testIsEmptyIsTrueWhenCollectionHasNoErrors() {
    XCTAssertTrue(errors.isEmpty(), "is empty with no errors")
    errors.add("name", "blank")
    XCTAssertFalse(errors.isEmpty(), "is not empty once error is added")
  }
}
