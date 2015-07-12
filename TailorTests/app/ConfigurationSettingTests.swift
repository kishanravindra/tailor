import XCTest
import Tailor
import TailorTesting

class ConfigurationSettingTests: TailorTestCase {
  var setting: ConfigurationSetting!
  
  override func setUp() {
    setting = ConfigurationSetting(dictionary: ["a": ["b": "5"]])
  }
  
  //MARK: - Initialization
  
  func testInitializerSetsValue() {
    setting = ConfigurationSetting(value: "test")
    XCTAssertNotNil(setting.value)
    if setting.value != nil {
      assert(setting.value!, equals: "test")
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
    assert(child1.value, equals: "Manager", message: "has the right value for the role child")
    
    let child2 = setting.child("name")
    XCTAssertNil(child2.value, "has no direct value for the name child")
    
    let child3 = child2.child("first")
    assert(child3.value, equals: "John", message: "has the right value for the first name")
    
    let child4 = child2.child("last")
    assert(child4.value, equals: "Smith", message: "has the right value for the last name")
    
    let child5 = child2.child("comments")
    XCTAssertTrue(child5.isEmpty, "has no value for a key that maps to an array")
  }
  
  func testInitializerWithPathGetsContentsOfFile() {
    let folderPath = NSBundle(forClass: self.dynamicType).resourcePath ?? "."
    let fullPath = folderPath + "/TestConfig.plist"
    setting = ConfigurationSetting(contentsOfFile: fullPath)
    
    let child = setting.child("test_key")
    assert(child.value, equals: "test_value", message: "has the value from the file")
  }
  
  func testInitializerWithBadPathCreatesEmptySetting() {
    setting = ConfigurationSetting(contentsOfFile: "./badPath")
    assert(setting.isEmpty, message: "creates an empty setting")
  }
  
  func testInitializerWithArrayPropertyListCreatesEmptySetting() {
    let folderPath = NSBundle(forClass: self.dynamicType).resourcePath ?? "."
    let fullPath = folderPath + "/TestConfig2.plist"
    setting = ConfigurationSetting(contentsOfFile: fullPath)
    assert(setting.isEmpty, message: "creates an empty setting")
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
    assert(child2.value, equals: "test value")
  }
  
  func testChildMethodCanTakeKeyPath() {
    let child = setting.child("a.b")
    XCTAssertNotNil(child.value, "has the value")
    if child.value != nil {
      assert(child.value!, equals: "5", message: "has the value")
    }
  }
  
  func testChildMethodWithMissingPathCreatesNewChildren() {
    let child = setting.child(keys: ["a", "c"])
    XCTAssertTrue(child.isEmpty, "creates an empty child")
  }
  
  func testChildMethodGetsChildAtEndOfPath() {
    let child = setting.child(keys: ["a", "b"])
    assert(child.value, equals: "5", message: "has the right value")
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
    assert(result, equals: "5", message: "has the correct result")
  }
  
  func testFetchWithMissingKeyPathIsNil() {
    let result = setting.fetch("a.c")
    XCTAssertNil(result, "does not have a result")
  }
  
  func testFetchWithKeysGetsValue() {
    let result = setting.fetch(keys: ["a", "b"])
    assert(result, equals: "5", message: "has the correct result")
  }
  
  func testFetchWithMissingKeysIsNil() {
    let result = setting.fetch(keys: ["a", "c"])
    XCTAssertNil(result, "does not have a result")
  }
  
  func testSetMethodCanSetKeyOnNode() {
    setting.set("a", value: "4")
    let result = setting.fetch("a")
    assert(result, equals: "4", message: "has the value that was set")
  }
  
  func testSetMethodCanSetKeyWithPath() {
    setting.set("a.c", value: "6")
    let result = setting.fetch("a.c")
    assert(result, equals: "6", message: "has the value that was set")
  }
  
  func testSetMethodCanSetKeyPathWithList() {
    setting.set(keys: ["a", "c"], value: "6")
    let result = setting.fetch("a.c")
    assert(result, equals: "6", message: "has the value that was set")
  }
  
  func testSubscriptCanFetchValue() {
    let result = setting["a.b"]
    assert(result, equals: "5", message: "has the right value")
  }
  
  func testSubscriptFetchesNilForMissingPath() {
    let result = setting["a.c"]
    XCTAssertNil(result, "has a nil result")
  }
  
  func testSubscriptCanSetValue() {
    setting["a.b"] = "7"
    let result = setting["a.b"]
    assert(result, equals: "7", message: "has the value that was set")
  }
  
  func testToDictionaryGetsNestedDictionary() {
    setting["a.c"] = "6"
    setting["d"] = "9"
    setting.child("e")
    let dictionary = setting.toDictionary()
    
    if let child1 = dictionary["a"] as? [String:String] {
      let b = child1["b"]
      let c = child1["c"]
      
      assert(b, equals: "5", message: "has the value for b")
      assert(c, equals: "6", message: "has the value for c")
    }
    else {
      XCTFail("Has a nested dictionary")
    }
    
    let d = dictionary["d"] as? String
    assert(d, equals: "9", message: "has the value for d")
    
    XCTAssertNil(dictionary["e"], "has no key for an empty child")
  }
  
  func testAddDictionaryAddsKeysFromDictionary() {
    setting["c.d"] = "3"
    setting.addDictionary(["c": ["d": "1", "e": "2"]])
    
    let value1 = setting["c.d"]
    assert(value1, equals: "1", message: "has the value for the first key")
    
    let value2 = setting["c.e"]
    assert(value2, equals: "2", message: "has the value for the second key")
    
    let value3 = setting["a.b"]
    assert(value3, equals: "5", message: "has the value for the third key")
  }
  
  func testAddDictionarySkipsArrayKey() {
    setting.addDictionary(["c": ["d": "1", "e": "2", "f": ["3","4"]]])
    let value1 = setting["c.d"]
    assert(value1, equals: "1", message: "has the value for the first key")
    
    let value2 = setting["c.e"]
    assert(value2, equals: "2", message: "has the value for the second key")
    
    let value3 = setting["c.f"]
    assert(isNil: value3, message: "has no value for the third key")
  }

  func testSetDefaultValueCanCreateNewValue() {
    setting.setDefaultValue("c.d", value: "6")
    let value = setting["c.d"]
    assert(value, equals: "6", message: "sets the new value")
  }
  
  func testSetDefaultValueDoesNotChangeExistingValue() {
    setting.setDefaultValue("a.b", value: "6")
    let value = setting["a.b"]
    assert(value!, equals: "5", message: "leaves the old value")
  }
  
  func testComparisonIsEqualWithSameValues() {
    let setting1 = ConfigurationSetting(dictionary: ["a": ["b": "5", "c": "6"]])
    let setting2 = ConfigurationSetting(dictionary: ["a": ["b": "5", "c": "6"]])
    assert(setting1, equals: setting2)
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
