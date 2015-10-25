import Tailor
import TailorTesting
import XCTest

class JsonConvertibleTests: XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
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
  
  func testStringConvertsToJsonAsJsonPrimitive() {
    let string = "Test"
    assert(string.toJson(), equals: .String("Test"))
  }
  
  func testIntegerCanInitializeFromJsonPrimitive() {
    let primitive = JsonPrimitive.Number(5)
    do {
      let int = try Int(json: primitive)
      assert(int, equals: 5)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
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
  
  func testIntConvertsToJsonAsJsonPrimitive() {
    let int = 19
    assert(int.toJson(), equals: .Number(19))
  }
  
  func testBooleanCanInitializeFromJsonPrimitive() {
    let primitive1 = JsonPrimitive.Number(5)
    let primitive2 = JsonPrimitive.Number(1)
    let primitive3 = JsonPrimitive.Number(0)
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
  
  func testBooleanConvertsToJsonAsJsonPrimitive() {
    assert(true.toJson(), equals: .Number(1))
    assert(false.toJson(), equals: .Number(0))
  }
  
  func testPrimitiveConvertsToJsonAsItself() {
    let primitive = JsonPrimitive.Number(19)
    assert(primitive.toJson(), equals: primitive)
  }
  
  func testPrimitiveInitializesWithJsonByCopying() {
    let primitive = JsonPrimitive.Number(19)
    let primitive2 = JsonPrimitive(json: primitive)
    assert(primitive, equals: primitive2)
  }
  
  func testArrayOfConvertiblesConvertsToJsonAsArrayOfPrimitives() {
    let array = ["A", "B", "C"]
    let converted = array.toJson()
    assert(converted, equals: .Array([
      .String("A"),
      .String("B"),
      .String("C")
    ]))
  }
  
  func testDictionaryOfConvertiblesProvidesJsonWithDictionaryValues() {
    let value = ["key1": "A", "key2": "B"]
    let primitive = value.toJson()
    assert(primitive, equals: JsonPrimitive.Dictionary([
      "key1": JsonPrimitive.String("A"),
      "key2": JsonPrimitive.String("B")
      ])
    )
  }
  
  func testDictionaryOfConvertiblesProvidesJsonDataWithDictionaryValues() {
    let value = ["key1": "A", "key2": "B"]
    let data = value.toJsonData()
    let expectedString = "{\"key1\":\"A\",\"key2\":\"B\"}"
    assert(data, equals: NSData(bytes: expectedString.utf8))
  }
  
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
