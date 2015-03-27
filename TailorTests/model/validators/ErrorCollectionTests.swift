import XCTest
import Tailor
import TailorTesting

class ErrorCollectionTests: TailorTestCase {
  var errors = ErrorCollection(modelType: Hat.self)
  
  func testAddKeyPutsEntryInErrors() {
    errors.add("name", "blank")
    errors.add("name", "too_short", data: ["min": "5"])
    errors.add("color", "blank")
    
    assert(errors.errors, equals: [
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
    
    assert(errors["name"], equals: list1, message: "gets multiple keys for the name")
    assert(errors["color"], equals: list2, message: "gets a single key for the color")
    assert(errors["brimSize"], equals: [], message: "gets an empty list for a key with no errors")
  }
}
