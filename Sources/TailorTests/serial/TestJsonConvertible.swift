import Tailor
import TailorTesting
import XCTest
import Foundation

struct TestJsonConvertible: XCTestCase, TailorTestable {
  @available(*, deprecated)
  var allTests: [(String, () throws -> Void)] { return [
    ("testStringCanInitializeFromJsonPrimitive", testStringCanInitializeFromJsonPrimitive),
    ("testStringInitializedWithJsonArrayThrowsException", testStringInitializedWithJsonArrayThrowsException),
    ("testStringConvertsToJsonAsJsonPrimitive", testStringConvertsToJsonAsJsonPrimitive),
    ("testIntegerCanInitializeFromJsonPrimitive", testIntegerCanInitializeFromJsonPrimitive),
    ("testIntegerInitializedWithJsonArrayThrowsException", testIntegerInitializedWithJsonArrayThrowsException),
    ("testIntConvertsToJsonAsJsonPrimitive", testIntConvertsToJsonAsJsonPrimitive),
    ("testBooleanCanInitializeFromJsonPrimitive", testBooleanCanInitializeFromJsonPrimitive),
    ("testBooleanInitializedWithJsonArrayThrowsException", testBooleanInitializedWithJsonArrayThrowsException),
    ("testBooleanConvertsToJsonAsJsonPrimitive", testBooleanConvertsToJsonAsJsonPrimitive),
    ("testPrimitiveConvertsToJsonAsItself", testPrimitiveConvertsToJsonAsItself),
    ("testPrimitiveInitializesWithJsonByCopying", testPrimitiveInitializesWithJsonByCopying),
    ("testArrayOfConvertiblesConvertsToJsonAsArrayOfPrimitives", testArrayOfConvertiblesConvertsToJsonAsArrayOfPrimitives),
    ("testDictionaryOfConvertiblesProvidesJsonWithDictionaryValues", testDictionaryOfConvertiblesProvidesJsonWithDictionaryValues),
    ("testDictionaryOfConvertiblesProvidesJsonDataWithDictionaryValues", testDictionaryOfConvertiblesProvidesJsonDataWithDictionaryValues),
    ("testDictionaryConvertibleProvidesJsonImplementation", testDictionaryConvertibleProvidesJsonImplementation),
  ]}

  func setUp() {
    setUpTestCase()
  }

  @available(*, deprecated)  
  func testStringCanInitializeFromJsonPrimitive() {
    let primitive = JsonPrimitive.String("Hello")
    do {
      let string = try String(json: primitive)
      assert(string, equals: "Hello")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testStringInitializedWithJsonArrayThrowsException() {
    let primitive = JsonPrimitive.Array([
      .String("A"),
      .String("B")
    ])
    do {
      _ = try String(json: primitive)
      assert(false, message: "should throw an exception")
    }
    catch JsonParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "root")
      assert(type == String.self)
      assert(caseType == [JsonPrimitive].self)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testStringConvertsToJsonAsJsonPrimitive() {
    let string = "Test"
    assert(string.toJson(), equals: .String("Test"))
  }
  
  @available(*, deprecated)
  func testIntegerCanInitializeFromJsonPrimitive() {
    let primitive = JsonPrimitive.Integer(5)
    do {
      let int = try Int(json: primitive)
      assert(int, equals: 5)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testIntegerInitializedWithJsonArrayThrowsException() {
    let primitive = JsonPrimitive.Array([
      .String("A"),
      .String("B")
      ])
    do {
      _ = try Int(json: primitive)
      assert(false, message: "should throw an exception")
    }
    catch JsonParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "root")
      assert(type == Int.self)
      assert(caseType == [JsonPrimitive].self)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testIntConvertsToJsonAsJsonPrimitive() {
    let int = 19
    assert(int.toJson(), equals: .Integer(19))
  }
  
  @available(*, deprecated)
  func testBooleanCanInitializeFromJsonPrimitive() {
    let primitive1 = JsonPrimitive.Integer(5)
    let primitive2 = JsonPrimitive.Integer(1)
    let primitive3 = JsonPrimitive.Integer(0)
    do {
      let flag1 = try Bool(json: primitive1)
      let flag2 = try Bool(json: primitive2)
      let flag3 = try Bool(json: primitive3)
      assert(flag1)
      assert(flag2)
      assert(!flag3)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testBooleanInitializedWithJsonArrayThrowsException() {
    let primitive = JsonPrimitive.Array([
      .String("A"),
      .String("B")
      ])
    do {
      _ = try Int(json: primitive)
      assert(false, message: "should throw an exception")
    }
    catch JsonParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "root")
      assert(type == Int.self)
      assert(caseType == [JsonPrimitive].self)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  @available(*, deprecated)
  func testBooleanConvertsToJsonAsJsonPrimitive() {
    assert(true.toJson(), equals: .Boolean(true))
    assert(false.toJson(), equals: .Boolean(false))
  }
  
  @available(*, deprecated)
  func testPrimitiveConvertsToJsonAsItself() {
    let primitive = JsonPrimitive.Integer(19)
    assert(primitive.toJson(), equals: primitive)
  }
  
  @available(*, deprecated)
  func testPrimitiveInitializesWithJsonByCopying() {
    let primitive = JsonPrimitive.Integer(19)
    let primitive2 = JsonPrimitive(json: primitive)
    assert(primitive, equals: primitive2)
  }
  
  @available(*, deprecated)
  func testArrayOfConvertiblesConvertsToJsonAsArrayOfPrimitives() {
    let array = ["A", "B", "C"]
    let converted = array.toJson()
    assert(converted, equals: .Array([
      .String("A"),
      .String("B"),
      .String("C")
    ]))
  }
  
  @available(*, deprecated)
  func testDictionaryOfConvertiblesProvidesJsonWithDictionaryValues() {
    let value = ["key1": "A", "key2": "B"]
    let primitive = value.toJson()
    assert(primitive, equals: JsonPrimitive.Dictionary([
      "key1": JsonPrimitive.String("A"),
      "key2": JsonPrimitive.String("B")
      ])
    )
  }
  
  @available(*, deprecated)
  func testDictionaryOfConvertiblesProvidesJsonDataWithDictionaryValues() {
    let value = ["key1": "A", "key2": "B"]
    let data = value.toJsonData()
    let expectedString = "{\"key1\":\"A\",\"key2\":\"B\"}"
    assert(data, equals: NSData(bytes: expectedString.utf8))
  }
  
  @available(*, deprecated)
  func testDictionaryConvertibleProvidesJsonImplementation() {
    struct MyStruct: JsonDictionaryConvertible {
      let key1: String
      let key2: String
      let key3: [String:String]
      
      init(key1: String, key2: String, key3: [String:String]) {
        self.key1 = key1
        self.key2 = key2
        self.key3 = key3
      }
      
      init(json: JsonPrimitive) throws {
        self.key1 = try json.read("key1")
        self.key2 = try json.read("key2")
        
        let dictionary = try json.read("key3") as [String:JsonPrimitive]
        self.key3 = try dictionary.map { try $0.read() }
      }
      
      func toJsonDictionary() -> [String : JsonConvertible] {
        return [
          "key1": key1,
          "key2": key2,
          "key3": JsonPrimitive.Dictionary(key3.map { $0.toJson() })
        ]
      }
    }
    let value = MyStruct(key1: "A", key2: "B", key3: ["key4": "C", "key5": "D"])
    let primitive = value.toJson()
    
    assert(primitive, equals: .Dictionary([
      "key1": JsonPrimitive.String("A"),
      "key2": JsonPrimitive.String("B"),
      "key3": JsonPrimitive.Dictionary([
        "key4": JsonPrimitive.String("C"),
        "key5": JsonPrimitive.String("D")
      ])
    ]))
  }
}
