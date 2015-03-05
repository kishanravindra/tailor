import XCTest

class ConfigurationSettingTests: XCTestCase {
  var setting: ConfigurationSetting!
  
  override func setUp() {
    setting = ConfigurationSetting(dictionary: ["a": ["b": "5"]])
  }
  
  //MARK: - Initialization
  
  func testInitializerSetsValue() {
    setting = ConfigurationSetting(value: "test")
    XCTAssertNotNil(setting.value)
    if setting.value != nil {
      XCTAssertEqual(setting.value!, "test")
    }
  }
  
  func testInitializerWithDictionaryCreatesNestedSettings() {
    let dictionary = [
      "role": "Manager",
      "name": [
        "first": "John",
        "last": "Smith",
        "comments": ["a", "b", "c"]
      ]
    ]
    
    setting = ConfigurationSetting(dictionary: dictionary)
    
    let child1 = setting.child("role")
    XCTAssertNotNil(child1.value, "has a value for the role child")
    if child1.value != nil {
      XCTAssertEqual(child1.value!, "Manager", "has the right value for the role child")
    }
    
    let child2 = setting.child("name")
    XCTAssertNil(child2.value, "has no direct value for the name child")
    
    let child3 = child2.child("first")
    XCTAssertNotNil(child3.value, "has a value for the first name")
    if child3.value != nil {
      XCTAssertEqual(child3.value!, "John", "has the right value for the first name")
    }
    
    let child4 = child2.child("last")
    XCTAssertNotNil(child4.value, "has a value for the last name")
    if child4.value != nil {
      XCTAssertEqual(child4.value!, "Smith", "has the right value for the last name")
    }
    
    let child5 = child2.child("comments")
    XCTAssertTrue(child5.isEmpty, "has no value for a key that maps to an array")
  }
  
  func testInitializerWithPathGetsContentsOfFile() {
    setting = ConfigurationSetting(contentsOfFile: "./TailorTests/Info.plist")
    
    let child = setting.child("CFBundlePackageType")
    XCTAssertNotNil(child.value, "has a value for the key from the file")
    if child.value != nil {
      XCTAssertEqual(child.value!, "BNDL", "has the value from the file")
    }
  }
  
  func testInitializerWithBadPathCreatesEmptySetting() {
    setting = ConfigurationSetting(contentsOfFile: "./badPath")
    XCTAssertTrue(setting.isEmpty, "creates an empty setting")
  }
  
  func testInitializerWithNonPropertyListPathCreatesEmptySetting() {
    setting = ConfigurationSetting(contentsOfFile: "./TailorTests/TailorTests.h")
    XCTAssertTrue(setting.isEmpty, "creates an empty setting")
  }
  
  //MARK: - Children
  
  func testChildMethodCreatesNewChild() {
    let child = setting.child("test key")
    XCTAssertTrue(child.isEmpty, "creates an empty setting")
  }
  
  func testChildMethodReusesChildren() {
    let child1 = setting.child("test key")
    child1.value = "test value"
    let child2 = setting.child("test key")
    XCTAssertNotNil(child2.value)
    if child2.value != nil {
      XCTAssertEqual(child2.value!, "test value")
    }
  }
  
  func testChildMethodCanTakeKeyPath() {
    let child = setting.child("a.b")
    XCTAssertNotNil(child.value, "has the value")
    if child.value != nil {
      XCTAssertEqual(child.value!, "5", "has the value")
    }
  }
  
  func testChildMethodWithMissingPathCreatesNewChildren() {
    let child = setting.child(keys: ["a", "c"])
    XCTAssertTrue(child.isEmpty, "creates an empty child")
  }
  
  func testChildMethodGetsChildAtEndOfPath() {
    let child = setting.child(keys: ["a", "b"])
    XCTAssertNotNil(child.value, "has a value for the child")
    if child.value != nil {
      XCTAssertEqual(child.value!, "5", "has the right value")
    }
  }
  
  //MARK: - Data Access
  
  func testSettingWithNoValueOrChildrenIsEmpty() {
    setting = ConfigurationSetting()
    XCTAssertTrue(setting.isEmpty)
  }
  
  func testSettingWithValueIsNotEmpty() {
    setting = ConfigurationSetting(value: "test")
    XCTAssertFalse(setting.isEmpty)
  }
  
  func testSettingWithChildrenIsNotEmpty() {
    setting = ConfigurationSetting(dictionary: ["a": "b"])
    XCTAssertFalse(setting.isEmpty)
  }
  
  func testFetchWithKeyPathGetsValue() {
    let result = setting.fetch("a.b")
    XCTAssertNotNil(result, "has a result")
    if result != nil {
      XCTAssertEqual(result!, "5", "has the correct result")
    }
  }
  
  func testFetchWithMissingKeyPathIsNil() {
    let result = setting.fetch("a.c")
    XCTAssertNil(result, "does not have a result")
  }
  
  func testFetchWithKeysGetsValue() {
    let result = setting.fetch(keys: ["a", "b"])
    XCTAssertNotNil(result, "has a result")
    if result != nil {
      XCTAssertEqual(result!, "5", "has the correct result")
    }
  }
  
  func testFetchWithMissingKeysIsNil() {
    let result = setting.fetch(keys: ["a", "c"])
    XCTAssertNil(result, "does not have a result")
  }
  
  func testSetMethodCanSetKeyOnNode() {
    setting.set("a", value: "4")
    let result = setting.fetch("a")
    XCTAssertNotNil(result, "has a result")
    if result != nil {
      XCTAssertEqual(result!, "4", "has the value that was set")
    }
  }
  
  func testSetMethodCanSetKeyWithPath() {
    setting.set("a.c", value: "6")
    let result = setting.fetch("a.c")
    XCTAssertNotNil(result, "has a result")
    if result != nil {
      XCTAssertEqual(result!, "6", "has the value that was set")
    }
  }
  
  func testSubscriptCanFetchValue() {
    let result = setting["a.b"]
    XCTAssertNotNil(result, "has a result")
    if result != nil {
      XCTAssertEqual(result!, "5", "has the right value")
    }
  }
  
  func testSubscriptFetchesNilForMissingPath() {
    let result = setting["a.c"]
    XCTAssertNil(result, "has a nil result")
  }
  
  func testSubscriptCanSetValue() {
    setting["a.b"] = "7"
    let result = setting["a.b"]
    XCTAssertNotNil(result, "has a result")
    if result != nil {
      XCTAssertEqual(result!, "7", "has the value that was set")
    }
  }
  
  func testToDictionaryGetsNestedDictionary() {
    setting["a.c"] = "6"
    setting["d"] = "9"
    setting.child("e")
    let dictionary = setting.toDictionary()
    
    if let child1 = dictionary["a"] as? [String:String] {
      let b = child1["b"]
      let c = child1["c"]
      
      XCTAssertNotNil(b, "has the key for b")
      if b != nil {
        XCTAssertEqual(b!, "5", "has the value for b")
      }
      
      XCTAssertNotNil(c, "has the key for c")
      if c != nil {
        XCTAssertEqual(c!, "6", "has the value for c")
      }
    }
    else {
      XCTFail("Has a nested dictionary")
    }
    
    let d = dictionary["d"] as? String
    XCTAssertNotNil(d, "has the key for d")
    if d != nil {
      XCTAssertEqual(d!, "9", "has the value for d")
    }
    
    XCTAssertNil(dictionary["e"], "has no key for an empty child")
  }
  
  func testAddDictionaryAddsKeysFromDictionary() {
    setting["c.d"] = "3"
    setting.addDictionary(["c": ["d": "1", "e": "2"]])
    
    let value1 = setting["c.d"]
    XCTAssertNotNil(value1, "has a value for the first key")
    if value1 != nil {
      XCTAssertEqual(value1!, "1", "has the value for the first key")
    }
    
    let value2 = setting["c.e"]
    XCTAssertNotNil(value2, "has a value for the second key")
    if value2 != nil {
      XCTAssertEqual(value2!, "2", "has the value for the second key")
    }
    
    let value3 = setting["a.b"]
    XCTAssertNotNil(value3, "has the old value as well")
    if value3 != nil {
      XCTAssertEqual(value3!, "5", "has the value for the third key")
    }
  }

  func testSetDefaultValueCanCreateNewValue() {
    setting.setDefaultValue("c.d", value: "6")
    let value = setting["c.d"]
    XCTAssertNotNil(value, "sets a value")
    if value != nil {
      XCTAssertEqual(value!, "6", "sets the new value")
    }
  }
  
  func testSetDefaultValueDoesNotChangeExistingValue() {
    setting.setDefaultValue("a.b", value: "6")
    let value = setting["a.b"]
    XCTAssertNotNil(value, "has a value")
    if value != nil {
      XCTAssertEqual(value!, "5", "leaves the old value")
    }
  }
  
  func testComparisonIsEqualWithSameValues() {
    let setting1 = ConfigurationSetting(dictionary: ["a": ["b": "5", "c": "6"]])
    let setting2 = ConfigurationSetting(dictionary: ["a": ["b": "5", "c": "6"]])
    XCTAssertEqual(setting1, setting2)
  }
  
  func testComparisonIsNotEqualWithExtraKeyInLeftHandSide() {
    let setting1 = ConfigurationSetting(dictionary: ["a": ["b": "5", "c": "6"], "d": "7"])
    let setting2 = ConfigurationSetting(dictionary: ["a": ["b": "5", "c": "6"]])
    XCTAssertNotEqual(setting1, setting2)
  }
  
  func testComparisonIsNotEqualWithExtraKeyInRightHandSide() {
    let setting1 = ConfigurationSetting(dictionary: ["a": ["b": "5", "c": "6"]])
    let setting2 = ConfigurationSetting(dictionary: ["a": ["b": "5", "c": "6"], "d": "7"])
    XCTAssertNotEqual(setting1, setting2)
  }
  
  func testComparisonIsNotEqualWithDifferentValuesForKeys() {
    let setting1 = ConfigurationSetting(dictionary: ["a": ["b": "5", "c": "6"]])
    let setting2 = ConfigurationSetting(dictionary: ["a": ["b": "5", "c": "7"]])
    XCTAssertNotEqual(setting1, setting2)
  }
  
  func testComparisonIsNotEqualWithDifferentValuesOnNode() {
    let setting1 = ConfigurationSetting(value: "a")
    let setting2 = ConfigurationSetting(value: "b")
    XCTAssertNotEqual(setting1, setting2)
  }
  
  func testComparisonIsNotEqualWithNilOnOnlyLeftSide() {
    let setting1 = ConfigurationSetting()
    let setting2 = ConfigurationSetting(value: "b")
    XCTAssertNotEqual(setting1, setting2)
  }
  
  func testComparisonIsNotEqualWithNilOnOnlyRightSide() {
    let setting1 = ConfigurationSetting(value: "a")
    let setting2 = ConfigurationSetting()
    XCTAssertNotEqual(setting1, setting2)
  }
}
