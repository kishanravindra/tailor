import XCTest

class LocalizationTests: XCTestCase {
  override func setUp() {
    TestApplication.start()
  }
  
  func testInitializeSetsStringsFromLocale() {
    let localization1 = Localization(locale: "en")
    let string1 = localization1.strings["localization_test"]
    XCTAssertNotNil(string1, "gets English string")
    if string1 != nil { XCTAssertEqual(string1!, "Yes", "gets English string") }
    
    let localization2 = Localization(locale: "es")
    let string2 = localization2.strings["localization_test"]
    XCTAssertNotNil(string2, "gets Spanish string")
    if string2 != nil { XCTAssertEqual(string2!, "Si", "gets Spanish string") }
  }
  
  func testInitializationCollapsesNestedStrings() {
    let localization = Localization(locale: "en")
    let string = localization.strings["controller.test.message"]
    XCTAssertNotNil(string, "gets string")
    if string != nil { XCTAssertEqual(string!, "Hello", "gets string") }
  }
  
  func testFetchGetsValueFromStrings() {
    let localization = Localization(locale: "en")
    let string = localization.fetch("localization_test")
    XCTAssertNotNil(string, "gets a string")
    if string != nil { XCTAssertEqual(string!, "Yes", "gets a string") }
  }
  
  func testFetchGetsNilValueForMissingKey() {
    let localization = Localization(locale: "en")
    let string = localization.fetch("invalid_key")
    XCTAssertNil(string)
  }
  
  func testFlattenDictionaryCombinesKeys() {
    let dictionary = Localization.flattenDictionary([
      "hats": [
        "index": [
          "title": "Hats",
          "add": "Add a Hat"
        ],
        "show": [
          "index": "Hat Details"
        ]
      ]
    ])
    let keys = sorted(dictionary.keys.array)
    let expectedKeys = ["hats.index.add", "hats.index.title", "hats.show.index"]
    XCTAssertEqual(keys, expectedKeys, "flattens the keys")
    if keys == expectedKeys {
      XCTAssertEqual(dictionary["hats.index.add"]!, "Add a Hat", "gets the right value for the keys")
      XCTAssertEqual(dictionary["hats.index.title"]!, "Hats", "gets the right value for the keys")
      XCTAssertEqual(dictionary["hats.show.index"]!, "Hat Details", "gets the right value for the keys")
    }
  }
  
  func testFlattenDictionaryIgnoresKeysWithNonStringValues() {
    let dictionary = Localization.flattenDictionary([
      "hats": [
        "index": [
          "title": "Hats",
          "add": "Add a Hat"
        ],
        "show": [
          "index": NSDate()
        ]
      ]
      ])
    let keys = sorted(dictionary.keys.array)
    let expectedKeys = ["hats.index.add", "hats.index.title"]
    XCTAssertEqual(keys, expectedKeys, "only has keys that map to strings")
  }
}
