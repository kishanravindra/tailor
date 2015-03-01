import XCTest

class ErrorCollectionTests: XCTestCase {
  var errors = ErrorCollection(modelType: Hat.self, errors: [])
  
  func testAddKeyPutsEntryInErrors() {
    errors.add("name", "blank")
    errors.add("name", "too_short", data: ["min": "5"])
    errors.add("color", "blank")
    
    XCTAssertEqual(errors.errors, [
      ValidationError(modelType: Hat.self, key: "name", message: "blank", data: [:]),
      ValidationError(modelType: Hat.self, key: "name", message: "too_short", data: ["min": "5"]),
      ValidationError(modelType: Hat.self, key: "color", message: "blank", data: [:])
    ])
  }
  
  func testIsEmptyIsTrueWhenCollectionHasNoErrors() {
    XCTAssertTrue(errors.isEmpty, "is empty with no errors")
    errors.add("name", "blank")
    XCTAssertFalse(errors.isEmpty, "is not empty once error is added")
  }
  
  func testSubscriptGetsErrorsWithMatchingKey() {
    let list1 = [
      ValidationError(modelType: Hat.self, key: "name", message: "blank", data: [:]),
      ValidationError(modelType: Hat.self, key: "name", message: "too_short", data: ["min": "5"])
    ]
    
    let list2 = [
      ValidationError(modelType: Hat.self, key: "color", message: "blank", data: [:])
    ]

    errors.add("name", "blank")
    errors.add("name", "too_short", data: ["min": "5"])
    errors.add("color", "blank")
    
    XCTAssertEqual(errors["name"], list1, "gets multiple keys for the name")
    XCTAssertEqual(errors["color"], list2, "gets a single key for the color")
    XCTAssertEqual(errors["brimSize"], [], "gets an empty list for a key with no errors")
  }
}
