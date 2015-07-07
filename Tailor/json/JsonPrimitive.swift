/**
  This enum represents a simple value that can be natively represented in JSON.
  */
public enum JsonPrimitive: Equatable {
  /** A JSON String. */
  case String(Swift.String)
  
  /** A JSON Array, containing other JSON primitives. */
  case Array([JsonPrimitive])
  
  /** A JSON dictionary, mapping Swift strings to other JSON primitives. */
  case Dictionary([Swift.String: JsonPrimitive])
  
  //MARK: - Converting to JSON
  
  /**
    This method gets the type that this case wraps around.
    */
  public var wrappedType: Any.Type {
    switch(self) {
    case .String: return Swift.String.self
    case .Array: return [JsonPrimitive].self
    case .Dictionary: return Swift.Dictionary<Swift.String,JsonPrimitive>.self
    }
  }
  
  /**
    This method gets the object that this enum case wraps around.

    This is designed to be fed into the methods in NSJSONSerialization, though
    the return value may not be a valid JSON object by that class's rules.
    */
  public var toFoundationJsonObject: AnyObject {
    switch(self) {
    case let String(string):
      return string
    case let Array(array):
      return array.map { $0.toFoundationJsonObject }
    case let Dictionary(dictionary):
      var results : [Swift.String:AnyObject] = [:]
      for (key,value) in dictionary {
        results[key] = value.toFoundationJsonObject
      }
      return results
    }
  }
  
  /**
    This method gets the encoded JSON data.

    This can throw a `JsonConversionError`, or anything that
    `NSJSONSerialization.dataWithJSONObject can throw.
    */
  public func jsonData() throws -> NSData {
    let object = self.toFoundationJsonObject
    if !NSJSONSerialization.isValidJSONObject(object) {
      throw JsonConversionError.NotValidJsonObject
    }
    return try NSJSONSerialization.dataWithJSONObject(object, options: [])
  }
  
  //MARK: - Parsing from JSON
  
  /**
    This method initializes a JSON primitive with JSON data.

    This method can throw whatever `NSJSONSerialization.JSONObjectWithData`
    throws. It can also throw a method if the decoded JSON object has a type
    that we do not yet support.
  
    - parameter jsonData:   The JSON data.
    */
  public init(jsonData: NSData) throws {
    let object = try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
    try self.init(jsonObject: object)
  }
  
  /**
    This method initializes a JSON primitive with a raw JSON object.
    
    This can be a String, Dictionary, Array, or anything else that has a
    designated JsonPrimitive wrapper. In the case of dictionaries or arrays,
    the values contained within them should be raw JSON objects themselves,
    rather than JsonPrimitives.
  
    This will throw a `JsonParsingError` if the object is not a type that we
    can use to build a primitive.
  
    - parameter jsonObject:   The JSON object.
    */
  public init(jsonObject: AnyObject) throws {
    switch(jsonObject) {
    case let s as Swift.String:
      self = String(s)
    case let d as [Swift.String:AnyObject]:
      var mappedDictionary: [Swift.String: JsonPrimitive] = [:]
      for (key,value) in d {
        mappedDictionary[key] = try JsonPrimitive(jsonObject: value)
      }
      self = Dictionary(mappedDictionary)
    case let a as [AnyObject]:
      var mappedArray = [JsonPrimitive]()
      for value in a {
        try mappedArray.append(JsonPrimitive(jsonObject: value))
      }
      self = Array(mappedArray)
    default:
      throw JsonParsingError.UnsupportedType(jsonObject.dynamicType)
    }
  }
  
  /**
    This method reads the value that this primitive wraps around.
  
    This infers the desired output type from the caller context. If that desired
    type doesn't match what this wraps around, this will throw a
    `JsonParsingError.WrongFieldType` error.
  
    - returns:    The unwrapped value.
    */
  public func read<OutputType>() throws -> OutputType {
    switch(self) {
    case let .String(string):
      if let value = string as? OutputType { return value }
    case let .Array(array):
      if let value = array as? OutputType { return value }
    case let .Dictionary(dictionary):
      if let value = dictionary as? OutputType { return value }
    }
    throw JsonParsingError.WrongFieldType(field: "root", type: OutputType.self, caseType: self.wrappedType)
  }
  
  /**
    This method reads the value from a key in a JSON dictionary.
  
    This will infer the desired return type from the caller context.
    
    If this is not a dictionary type, this will throw a
    `JsonParsingError.WrongFieldType` error. If the value that the dictionary
    has for that key does not match the desired type, this will throw a
    `JsonParsingError.WrongFieldType` error. If there is no field on the
    dictionary for the desired key, this will throw a
    `JsonParsingError.MissingField` error.

    - parameter key:    The name of the key to read.
    - returns:          The unwrapped value.
    */
  public func read<OutputType>(key: Swift.String) throws -> OutputType {
    let dictionary = try self.read() as [Swift.String:JsonPrimitive]
    guard let value = dictionary[key] else {
      throw JsonParsingError.MissingField(field: key)
    }
    do {
      return try value.read()
    }
    catch JsonParsingError.WrongFieldType(field: _, type: let type, caseType: let caseType) {
      throw JsonParsingError.WrongFieldType(field: key, type: type, caseType: caseType)
    }
    catch let e {
      throw e
    }
  }
}

/**
  This method determines if two JSON primitives are equal.

  - parameter lhs:    The left-hand side of the operator.
  - parameter rhs:    The right-hand side of the operator.
  - returns:          Whether the two are equal.
  */
public func ==(lhs: JsonPrimitive, rhs: JsonPrimitive) -> Bool {
  switch(lhs) {
  case let .Dictionary(dictionary1):
    if case let .Dictionary(dictionary2) = rhs {
      return dictionary1 == dictionary2
    }
  case let .Array(array1):
    if case let .Array(array2) = rhs {
      return array1 == array2
    }
  case let .String(string1):
    if case let .String(string2) = rhs {
      return string1 == string2
    }
  }
  
  return false
}