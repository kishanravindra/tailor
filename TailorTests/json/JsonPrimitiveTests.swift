import Tailor
import TailorTesting

class JsonPrimitiveTests: TailorTestCase {
  //MARK: - Converting to JSON
  
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
}
