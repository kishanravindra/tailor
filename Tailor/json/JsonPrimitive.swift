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
  
  /** A null value. */
  case Null
  
  /** A numeric value. */
  case Number(NSNumber)
  
  //MARK: - Converting to JSON
  
  /**
    This method gets the type that this case wraps around.
    */
  public var wrappedType: Any.Type {
    switch(self) {
    case .String: return Swift.String.self
    case .Array: return [JsonPrimitive].self
    case .Dictionary: return Swift.Dictionary<Swift.String,JsonPrimitive>.self
    case .Null: return NSNull.self
    case .Number: return NSNumber.self
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
    case Null:
      return NSNull()
    case let Number(number):
      return number
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
    case _ as NSNull:
      self = Null
    case let n as NSNumber:
      self = Number(n)
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
    case .Null:
      if let value = NSNull() as? OutputType { return value }
    case let .Number(number):
      if let value = number as? OutputType { return value }
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
    let value: JsonPrimitive = try self.read(key)
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
  
  /**
    This method reads a primitive from a key in a JSON dictionary.

    If this is not a dictionary type, this will throw a
    `JsonParsingError.WrongFieldType` error. If there is no field on the
    dictionary for the desired key, this will throw a
    `JsonParsingError.MissingField` error.
    
    - parameter key:    The name of the key to read.
    - returns:          The primitive at that key.
    */
  public func read(key: Swift.String) throws -> JsonPrimitive {
    let dictionary = try self.read() as [Swift.String:JsonPrimitive]
    guard let value = dictionary[key] else {
      throw JsonParsingError.MissingField(field: key)
    }
    return value
  }
  
  /**
    This method takes a value from a key in a JSON dictionary and uses it to
    populate an instance of a JSON-convertible type.

    If the output type throws a parsing error when building itself, this will
    add the key as a prefix to the field name in the parsing error. So if the
    key here is "hat", and the Hat constructor throws an error over a missing
    "size" variable, this call will throw a MissingField error with a field
    of "hat.size". This allows us to build full key paths as we push errors up
    a parsing call stack.
  
    - parameter key:    The key to fetch
    - parameter into:   The type that we should build with the value at that
                        key.
    - returns:          The newly constructed value in the output type.  
    */
  public func read<T: JsonConvertible>(key: Swift.String, into: T.Type) throws -> T {
    let value: JsonPrimitive = try self.read(key)
    return try JsonParsingError.withFieldPrefix(key) { return try T(json: value) }
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
  case .Null:
    if case .Null = rhs {
      return true
    }
  case let .Number(number1):
    if case let .Number(number2) = rhs {
      return number1 == number2
    }
  }
  
  return false
}
