import Tailor
import TailorTesting

class JsonPrimitiveTests: TailorTestCase {
  //MARK: - Converting to JSON
  
  var complexJsonDictionary: [String:JsonPrimitive] = [
    "key1": JsonPrimitive.String("value1"),
    "key2": JsonPrimitive.Array([
      JsonPrimitive.String("value2"),
      JsonPrimitive.String("value3")
      ]),
    "key3": JsonPrimitive.Dictionary([
      "bKey1": JsonPrimitive.String("value4"),
      "bKey2": JsonPrimitive.String("value5")
      ])
  ]
  func testFoundationJsonObjectForStringIsString() {
    let primitive = JsonPrimitive.String("Hello")
    assert(primitive.toFoundationJsonObject as? String, equals: "Hello")
  }
  
  func testFoundationJsonObjectForArrayOfStringsIsArrayOfStrings() {
    let primitive = JsonPrimitive.Array([
      JsonPrimitive.String("A"),
      JsonPrimitive.String("B")
    ])
    let object = primitive.toFoundationJsonObject
    if let strings = object as? [String] {
      assert(strings, equals: ["A", "B"])
    }
    else {
      assert(false, message: "Gets an array of strings")
    }
  }
  
  func testFoundationJsonObjectForDictionaryOfStringsIsDictionaryOfStrings() {
    let primitive = JsonPrimitive.Dictionary([
      "key1": JsonPrimitive.String("value1"),
      "key2": JsonPrimitive.String("value2")
    ])
    
    let object = primitive.toFoundationJsonObject
    if let dictionary = object as? [String:String] {
      assert(dictionary, equals: ["key1": "value1", "key2": "value2"])
    }
    else {
      assert(false, message: "Gets a dictionary of strings")
    }
  }
  
  func testFoundationJsonObjectForHeterogeneousArrayMapsInnerArray() {
    let primitive = JsonPrimitive.Array([
      JsonPrimitive.String("A"),
      JsonPrimitive.Array([
        JsonPrimitive.String("B"),
        JsonPrimitive.String("C")
      ])
    ])
    let object = primitive.toFoundationJsonObject
    if let array = object as? [AnyObject] {
      assert(array.count, equals: 2)
      assert(array[0] as? String, equals: "A")
      if let innerArray = array[1] as? [String] {
        assert(innerArray, equals: ["B", "C"])
      }
      else {
        assert(false, message: "gets an inner array of strings")
      }
    }
    else {
      assert(false, message: "Gets an array")
    }
  }
  
  func testFoundationJsonObjectForHeterogeneousDictionaryMapsInnerDictionary() {
    let primitive = JsonPrimitive.Dictionary([
      "aKey1": JsonPrimitive.String("value1"),
      "aKey2": JsonPrimitive.Array([
        JsonPrimitive.String("value2"),
        JsonPrimitive.String("value3")
      ]),
      "aKey3": JsonPrimitive.Dictionary([
        "bKey1": JsonPrimitive.String("value4"),
        "bKey2": JsonPrimitive.String("value5")
      ])
    ])
    let object = primitive.toFoundationJsonObject
    if let dictionary = object as? [String:AnyObject] {
      assert(dictionary["aKey1"] as? String, equals: "value1")
      if let innerArray = dictionary["aKey2"] as? [String] {
        assert(innerArray, equals: ["value2", "value3"])
      }
      else {
        assert(false, message: "gets an inner array")
      }
      if let innerDictionary = dictionary["aKey3"] as? [String:String] {
        assert(innerDictionary, equals: ["bKey1": "value4", "bKey2": "value5"])
      }
      else {
        assert(false, message: "gets an inner dictionary")
      }
    }
    else {
      assert(false, message: "Gets a dictionary")
    }
  }
  
  func testJsonDataForStringGetsThrowsException() {
    let primitive = JsonPrimitive.String("Hello")
    do {
      _ = try primitive.jsonData()
      assert(false, message: "should throw error before it gets here")
    }
    catch {
    }
  }
  
  func testJsonDataForDictionaryOfStringsGetsData() {
    let primitive = JsonPrimitive.Dictionary([
      "key1": JsonPrimitive.String("value1"),
      "key2": JsonPrimitive.String("value2")
    ])
    let expectedData = "{\"key1\":\"value1\",\"key2\":\"value2\"}".dataUsingEncoding(NSUTF8StringEncoding)!
    do {
      let data = try primitive.jsonData()
      assert(data, equals: expectedData)
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testJsonDataForArrayOfStringsGetsData() {
    let primitive = JsonPrimitive.Array([
      JsonPrimitive.String("value1"),
      JsonPrimitive.String("value2")
      ])
    let expectedData = "[\"value1\",\"value2\"]".dataUsingEncoding(NSUTF8StringEncoding)!
    do {
      let data = try primitive.jsonData()
      assert(data, equals: expectedData)
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testJsonDataForHeterogeneousDictionaryGetsData() {
    
    let primitive = JsonPrimitive.Dictionary([
      "aKey1": JsonPrimitive.String("value1"),
      "aKey2": JsonPrimitive.Dictionary([
        "bKey1": JsonPrimitive.String("value2"),
        "bKey2": JsonPrimitive.String("value3")
        ])
      ])

    let expectedData = "{\"aKey1\":\"value1\",\"aKey2\":{\"bKey1\":\"value2\",\"bKey2\":\"value3\"}}".dataUsingEncoding(NSUTF8StringEncoding)!
    do {
      let data = try primitive.jsonData()
      assert(data, equals: expectedData)
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  //MARK: - Parsing from JSON
  
  func testInitWithJsonStringBuildsString() {
    let object = "Hello"
    do {
      let primitive = try JsonPrimitive(jsonObject: object)
      assert(primitive, equals: JsonPrimitive.String("Hello"))
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testInitWithJsonDictionaryOfStringsBuildsDictionaryOfStrings() {
    let object = [
      "key1": "value1",
      "key2": "value2"
    ]
    do {
      let primitive = try JsonPrimitive(jsonObject: object)
      assert(primitive, equals: JsonPrimitive.Dictionary([
        "key1": JsonPrimitive.String("value1"),
        "key2": JsonPrimitive.String("value2")
      ]))
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testInitWithJsonArrayOfStringsBuildsArrayOfStrings() {
    let object = ["value1", "value2"]
    
    do {
      let primitive = try JsonPrimitive(jsonObject: object)
      assert(primitive, equals: JsonPrimitive.Array([
        JsonPrimitive.String("value1"),
        JsonPrimitive.String("value2")
      ]))
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testInitWithJsonObjectWithUnsupportedTypeThrowsException() {
    let object = NSObject()
    
    do {
      _ = try JsonPrimitive(jsonObject: object)
      assert(false, message: "should throw an exception")
    }
    catch JsonParsingError.UnsupportedType(let type) {
      assert(type == NSObject.self)
    }
    catch {
      assert(false, message: "threw an unexpected error type")
    }
  }
  
  func testInitWithJsonDataForDictionaryCreatesDictionary() {
    
    let data = "{\"aKey1\":\"value1\",\"aKey2\":{\"bKey1\":\"value2\",\"bKey2\":\"value3\"}}".dataUsingEncoding(NSUTF8StringEncoding)!
    do {
      let primitive = try JsonPrimitive(jsonData: data)
      let expectedPrimitive = JsonPrimitive.Dictionary([
        "aKey1": JsonPrimitive.String("value1"),
        "aKey2": JsonPrimitive.Dictionary([
          "bKey1": JsonPrimitive.String("value2"),
          "bKey2": JsonPrimitive.String("value3")
          ])
        ])
      assert(primitive, equals: expectedPrimitive)
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testReadStringWithStringGetsString() {
    let primitive = JsonPrimitive.String("Hello")
    do {
      let value: String = try primitive.read()
      assert(value, equals: "Hello")
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testReadStringWithArrayThrowsException() {
    let primitive = JsonPrimitive.Array([JsonPrimitive.String("A"), JsonPrimitive.String("B")])
    do {
      _ = try primitive.read() as String
      assert(false, message: "should throw some kind of exception")
    }
    catch JsonParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "root")
      assert(type == String.self)
      assert(caseType == [JsonPrimitive].self)
    }
    catch {
      assert(false, message: "threw unexpected exception type")
    }
  }
  
  func testReadArrayWithArrayGetsArray() {
    let array = [
      JsonPrimitive.String("A"),
      JsonPrimitive.Array([JsonPrimitive.String("B"), JsonPrimitive.String("C")])
    ]
    let primitive = JsonPrimitive.Array(array)
    do {
      let value: [JsonPrimitive] = try primitive.read()
      assert(value, equals: array)
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testReadArrayWithDictionaryThrowsError() {
    let primitive = JsonPrimitive.Dictionary([
      "key1": JsonPrimitive.String("value1"),
      "key2": JsonPrimitive.String("value2")
    ])
    do {
      _  = try primitive.read() as [JsonPrimitive]
      assert(false, message: "should show some kind of exception")
    }
    catch JsonParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "root")
      assert(type == [JsonPrimitive].self)
      assert(caseType == [String:JsonPrimitive].self)
    }
    catch {
      assert(false, message: "threw unexpected exception type")
    }
  }
  
  func testReadDictionaryWithDictionaryGetsDictionary() {
    let dictionary = [
      "key1": JsonPrimitive.String("value1"),
      "key2": JsonPrimitive.Array([JsonPrimitive.String("B"), JsonPrimitive.String("C")])
    ]
    let primitive = JsonPrimitive.Dictionary(dictionary)
    do {
      let value = try primitive.read() as [String:JsonPrimitive]
      assert(value, equals: dictionary)
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testReadDictionaryWithStringThrowsError() {
    let primitive = JsonPrimitive.String("test")
    do {
      _  = try primitive.read() as [String:JsonPrimitive]
      assert(false, message: "should show some kind of exception")
    }
    catch JsonParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "root")
      assert(type == Dictionary<String,JsonPrimitive>.self)
      assert(caseType == String.self)
    }
    catch {
      assert(false, message: "threw unexpected exception type")
    }
  }
  
  func testReadStringValueWithStringGetsString() {
    let primitive = JsonPrimitive.Dictionary(complexJsonDictionary)
    do {
      let value: String = try primitive.read("key1")
      assert(value, equals: try complexJsonDictionary["key1"]!.read())
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testReadStringValueWithArrayThrowsException() {
    let primitive = JsonPrimitive.Dictionary(complexJsonDictionary)
    do {
      _ = try primitive.read("key2") as String
      assert(false, message: "should throw some kind of exception")
    }
    catch JsonParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "key2")
      assert(type == String.self)
      assert(caseType == [JsonPrimitive].self)
    }
    catch {
      assert(false, message: "threw unexpected exception type")
    }
  }
  
  func testReadArrayValueWithArrayGetsArray() {
    let primitive = JsonPrimitive.Dictionary(complexJsonDictionary)
    do {
      let value: [JsonPrimitive] = try primitive.read("key2")
      assert(value, equals: try complexJsonDictionary["key2"]!.read())
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testReadArrayValueWithDictionaryThrowsException() {
    let primitive = JsonPrimitive.Dictionary(complexJsonDictionary)
    do {
      _ = try primitive.read("key3") as [JsonPrimitive]
      assert(false, message: "should throw some kind of exception")
    }
    catch JsonParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "key3")
      assert(type == [JsonPrimitive].self)
      assert(caseType == [String:JsonPrimitive].self)
    }
    catch {
      assert(false, message: "threw unexpected exception type")
    }
  }
  
  func testReadDictionaryValueWithDictionaryReturnsDictionary() {
    let primitive = JsonPrimitive.Dictionary(complexJsonDictionary)
    do {
      let value: [String:JsonPrimitive] = try primitive.read("key3")
      assert(value, equals: try complexJsonDictionary["key3"]!.read())
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testReadDictionaryValueWithStringThrowsException() {
    let primitive = JsonPrimitive.Dictionary(complexJsonDictionary)
    do {
      _ = try primitive.read("key1") as [String:JsonPrimitive]
      assert(false, message: "should throw some kind of exception")
    }
    catch JsonParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "key1")
      assert(type == [String:JsonPrimitive].self)
      assert(caseType == String.self)
    }
    catch {
      assert(false, message: "threw unexpected exception type")
    }
  }
  
  func testReadValueWithNonDictionaryPrimitiveThrowsException() {
    let primitive = JsonPrimitive.String("Hello")
    do {
      _ = try primitive.read("key1") as String
      assert(false, message: "should throw some kind of exception")
    }
    catch JsonParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "root")
      assert(type == [String:JsonPrimitive].self)
      assert(caseType == String.self)
    }
    catch {
      assert(false, message: "threw unexpected exception type")
    }
  }
  
  func testReadValueWithMissingKeyThrowsException() {
    let primitive = JsonPrimitive.Dictionary(complexJsonDictionary)
    
    do {
      _ = try primitive.read("key4") as String
      assert(false, message: "should throw some kind of exception")
    }
    catch JsonParsingError.MissingField(field: let field) {
      assert(field, equals: "key4")
    }
    catch {
      assert(false, message: "threw unexpected exception type")
    }
  }
  
  func testReadValueWithJsonPrimitiveGetsPrimitive() {
    let primitive = JsonPrimitive.Dictionary(complexJsonDictionary)
    
    do {
      let innerPrimitive = try primitive.read("key2") as JsonPrimitive
      assert(innerPrimitive, equals: complexJsonDictionary["key2"]!)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadValueWithJsonPrimitiveWithMissingKeyThrowsException() {
    let primitive = JsonPrimitive.Dictionary(complexJsonDictionary)
    
    do {
      _ = try primitive.read("key4") as JsonPrimitive
      assert(false, message: "should throw some kind of exception")
    }
    catch JsonParsingError.MissingField(field: let field) {
      assert(field, equals: "key4")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadIntoConvertiblePopulatesValues() {
    struct MyStruct: JsonConvertible {
      let value1: String
      let value2: String
      
      init(json: JsonPrimitive) throws {
        self.value1 = try json.read("bKey1")
        self.value2 = try json.read("bKey2")
      }
      
      func toJson() -> JsonPrimitive {
        return JsonPrimitive.Dictionary([
          "bKey1": JsonPrimitive.String(value1),
          "bKey2": JsonPrimitive.String(value2)
        ])
      }
    }
    
    let primitive = JsonPrimitive.Dictionary(complexJsonDictionary)
    do {
      let value = try primitive.read("key3", into: MyStruct.self)
      assert(value.value1, equals: "value4")
      assert(value.value2, equals: "value5")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadIntoConvertibleWithErrorAddsOuterKeyToError() {
    struct MyStruct: JsonConvertible {
      let value1: String
      let value2: String
      
      init(json: JsonPrimitive) throws {
        self.value1 = try json.read("bKey1")
        self.value2 = try json.read("bKey3")
      }
      
      func toJson() -> JsonPrimitive {
        return JsonPrimitive.Dictionary([
          "bKey1": JsonPrimitive.String(value1),
          "bKey3": JsonPrimitive.String(value2)
          ])
      }
    }
    
    let primitive = JsonPrimitive.Dictionary(complexJsonDictionary)
    do {
      _ = try primitive.read("key3", into: MyStruct.self)
      assert(false, message: "should throw some kind of exception")
    }
    catch JsonParsingError.MissingField(field: let field) {
      assert(field, equals: "key3.bKey3")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  //MARK: - Equality
  
  func testStringsWithSameContentsAreEqual() {
    let value1 = JsonPrimitive.String("Hello")
    let value2 = JsonPrimitive.String("Hello")
    assert(value1, equals: value2)
  }
  
  func testStringsWithDifferentContentsAreNotEqual() {
    let value1 = JsonPrimitive.String("Hello")
    let value2 = JsonPrimitive.String("Goodbye")
    assert(value1, doesNotEqual: value2)
  }
  
  func testStringDoesNotEqualDictionary() {
    let value1 = JsonPrimitive.String("Hello")
    let value2 = JsonPrimitive.Dictionary(["key1": JsonPrimitive.String("value1"), "key2": JsonPrimitive.String("value2")])
    assert(value1, doesNotEqual: value2)
  }
  
  func testDictionaryWithSameContentsAreEqual() {
    let value1 = JsonPrimitive.Dictionary(["key1": JsonPrimitive.String("value1"), "key2": JsonPrimitive.String("value2")])
    let value2 = JsonPrimitive.Dictionary(["key1": JsonPrimitive.String("value1"), "key2": JsonPrimitive.String("value2")])
    assert(value1, equals: value2)
  }
  
  func testDictionaryWithDifferentKeysAreNotEqual() {
    let value1 = JsonPrimitive.Dictionary(["key1": JsonPrimitive.String("value1"), "key2": JsonPrimitive.String("value2")])
    let value2 = JsonPrimitive.Dictionary(["key1": JsonPrimitive.String("value1"), "key3": JsonPrimitive.String("value2")])
    assert(value1, doesNotEqual: value2)
  }
  
  func testDictionaryWithDifferentValuesAreNotEqual() {
    let value1 = JsonPrimitive.Dictionary(["key1": JsonPrimitive.String("value1"), "key2": JsonPrimitive.String("value2")])
    let value2 = JsonPrimitive.Dictionary(["key1": JsonPrimitive.String("value1"), "key2": JsonPrimitive.String("value3")])
    assert(value1, doesNotEqual: value2)
  }
  
  func testDictionaryDoesNotEqualArray() {
    let value1 = JsonPrimitive.Dictionary(["key1": JsonPrimitive.String("value1"), "key2": JsonPrimitive.String("value2")])
    let value2 = JsonPrimitive.Array([JsonPrimitive.String("value1"), JsonPrimitive.String("value2")])
    assert(value1, doesNotEqual: value2)
  }
  
  func testArrayWithSameContentsAreEqual() {
    let value1 = JsonPrimitive.Array([JsonPrimitive.String("value1"), JsonPrimitive.String("value2")])
    let value2 = JsonPrimitive.Array([JsonPrimitive.String("value1"), JsonPrimitive.String("value2")])
    assert(value1, equals: value2)
  }
  
  func testArrayWithDifferentContentsAreNotEqual() {
    let value1 = JsonPrimitive.Array([JsonPrimitive.String("value1"), JsonPrimitive.String("value2")])
    let value2 = JsonPrimitive.Array([JsonPrimitive.String("value1"), JsonPrimitive.String("value3")])
    assert(value1, doesNotEqual: value2)
  }
  
  func testArrayDoesNotEqualString() {
    let value1 = JsonPrimitive.Array([JsonPrimitive.String("value1"), JsonPrimitive.String("value2")])
    let value2 = JsonPrimitive.String("[value1,value2]")
    assert(value1, doesNotEqual: value2)
  }
}
