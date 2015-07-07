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

/**
  This enum holds errors that can occur when parsing JSON data, or extracting
  values from a JSON primitive.
  */
public enum JsonParsingError : ErrorType {
  /**
    This error occurs when trying to initialize a primitive with an
    unsupported type, or read into an unsupported type.
    */
  case UnsupportedType(Any.Type)
}

/**
  This enum holds errors that can occur when converting a data structure into
  JSON.
  */
public enum JsonConversionError: ErrorType {
  /**
    This error is thrown when trying to get JSON data from a foundation object
    that is not a valid JSON object, per the rules in NSJSONSerialization.
    */
  case NotValidJsonObject
}