import XCTest
import Tailor
import TailorTesting
import TailorSqlite

@available(*, deprecated) class ConfigurationSettingTests: TailorTestCase {
  var setting: ConfigurationSetting!
  
  override func setUp() {
    super.setUp()
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
  
  //MARK: - Specially Mapped Valuers
  
  func testApplicationPortGetsGlobalConfiguration() {
    let setting = ConfigurationSetting()
    Application.configuration.port = 1234
    let node = setting.child("application.port")
    assert(node.value, equals: "1234")
  }
  
  func testApplicationPortSetsGlobalConfiguration() {
    let setting = ConfigurationSetting()
    setting.child("application.garbage1").value = "hi"
    let node = setting.child("application.port")
    setting.child("application.garbage2").value = "bye"
    node.value = "1010"
    assert(Application.configuration.port, equals: 1010)
  }
  
  func testApplicationPortWithNilValueSetsGlobalValueToDefaultValue() {
    Application.configuration.port = 123
    let setting = ConfigurationSetting()
    setting.set("application.port", value: nil)
    assert(Application.configuration.port, equals: 8080)
  }
  
  func testApplicationPortWithNonIntegerValueSetsGlobalValueToDefaultValue() {
    Application.configuration.port = 123
    let setting = ConfigurationSetting()
    setting.set("application.port", value: "bad")
    assert(Application.configuration.port, equals: 8080)
  }
  
  func testLocalizationClassGetsClassFromLocalization() {
    Application.configuration.localization = { DatabaseLocalization(locale: $0) }
    let setting = ConfigurationSetting()
    assert(setting.fetch("localization.class"), equals: "Tailor.DatabaseLocalization")
  }
  
  func testLocalizationClassSetsLocalizationWithClassName() {
    Application.configuration.localization = { PropertyListLocalization(locale: $0) }
    let setting = ConfigurationSetting()
    setting.set("localization.class", value: "Tailor.DatabaseLocalization")
    assert(Application.configuration.localization("en") is DatabaseLocalization)
  }
  
  func testLocalizationClassWithNilValueSetsPropertyListLocalization() {
    Application.configuration.localization = { DatabaseLocalization(locale: $0) }
    let setting = ConfigurationSetting()
    setting.set("localization.class", value: nil)
    assert(Application.configuration.localization("en") is PropertyListLocalization)
  }
  
  func testLocalizationContentGetsContentFromStaticContent() {
    Application.configuration.staticContent["en.test.token"] = "Hello"
    let setting = ConfigurationSetting()
    
    assert(setting.fetch("localization.content.en.test.token"), equals: "Hello")
  }
  
  func testLocalizationContentSetsContentInStaticContent() {
    Application.configuration.staticContent["en.test.token"] = "Hello"
    let setting = ConfigurationSetting()
    setting.set("localization.content.en.test.token", value: "Goodbye")
    assert(Application.configuration.staticContent["en.test.token"], equals: "Goodbye")
  }
  
  func testDatabaseClassGetsClassFromConfiguration() {
    Application.configuration.databaseDriver = { SqliteConnection(config: ["path": "/tmp/databaseTest.sqlite"]) }
    let setting = ConfigurationSetting()
    assert(setting.fetch("database.class"), equals: "TailorSqlite.SqliteConnection")
  }
  
  func testDatabaseClassWithNoConfigurationSettingIsNil() {
    Application.configuration.databaseDriver = nil
    let setting = ConfigurationSetting()
    assert(isNil: setting.fetch("database.class"))
  }
  
  func testDatabaseClassSetsInitializerInConfiguration() {
    Application.configuration.databaseDriver = nil
    
    setting.child("database").addDictionary([
      "class": "TailorSqlite.SqliteConnection",
      "path": "/tmp/databaseTest2.sqlite"
      ])
    guard let _ = Application.configuration.databaseDriver?() as? SqliteConnection else {
      assert(false, message: "Did not have a driver")
      return
    }
  }
  
  func testCacheClassGetsClassFromConfiguration() {
    Application.configuration.cacheStore = { return CacheStore() }
    let setting = ConfigurationSetting()
    assert(setting.fetch("cache.class"), equals: "Tailor.CacheStore")
  }
  
  func testCacheClassSetsClassInConfiguration() {
    Application.configuration.cacheStore = { return MemoryCacheStore() }
    let setting = ConfigurationSetting()
    setting.set("cache.class", value: "Tailor.CacheStore")
    assert(Application.configuration.cacheStore() is CacheStore)
  }
  
  func testCacheClassWithNilValueSetsMemoryCacheStoreInConfiguration() {
    Application.configuration.cacheStore = { return CacheStore() }
    let setting = ConfigurationSetting()
    setting.set("cache.class", value: nil)
    assert(Application.configuration.cacheStore() is MemoryCacheStore)
  }
  
  func testSessionsEncryptionKeyGetsEncryptionKey() {
    let key = AesEncryptor.generateKey()
    Application.configuration.sessionEncryptionKey = key
    let setting = ConfigurationSetting()
    assert(setting.fetch("sessions.encryptionKey"), equals: key)
  }

  func testSessionsEncryptionKeySetsEncryptionKey() {
    let key = AesEncryptor.generateKey()
    Application.configuration.sessionEncryptionKey = "abc123"
    let setting = ConfigurationSetting()
    setting.set("sessions.encryptionKey", value: key)
    assert(Application.configuration.sessionEncryptionKey, equals: key)
  }
  
  func testSessionsEncryptionKeyWithNilValueSetsBlankEncryptionKey() {
    Application.configuration.sessionEncryptionKey = "abc123"
    let setting = ConfigurationSetting()
    setting.set("sessions.encryptionKey", value: nil)
    assert(Application.configuration.sessionEncryptionKey, equals: "")
  }
  
  
  func testSetValueOnEmptyNodeSetsValue() {
    let setting = ConfigurationSetting()
    setting.value = "Hi"
    assert(setting.value, equals: "Hi")
  }

  //MARK: - Comparison
  
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
