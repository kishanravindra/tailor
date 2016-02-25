import Foundation

/**
  This protocol describes a data structure that can be encoded as JSON.
 
  This has been deprecated in favor of the SerializationEncodable protocol.
  */
@available(*, deprecated, message="Use SerializationEncodable instead")
public protocol JsonEncodable: SerializationEncodable {
  /**
    This method gets a JSON primitive representing this value.
    */
  func toJson() -> JsonPrimitive
}
/**
  This protocol describes a data structure that can be converted to and from
  JSON.
 
  This has been deprecated in favor of the SerializationConvertible protocol.
  */
@available(*, deprecated, message="Use SerializationConvertible instead")
public protocol JsonConvertible: JsonEncodable, SerializationConvertible {
  /**
    This method creates an instance from a JSON primitive.

    - parameter json:   The JSON primitive value.
    */
  init(json: JsonPrimitive) throws
}

@available(*, deprecated)
extension JsonEncodable {
  public var serialize: SerializableValue {
    return self.toJson()
  }
}

@available(*, deprecated)
extension JsonConvertible {
  public init(deserialize value: SerializableValue) throws {
    try self.init(json: value)
  }
}

@available(*, deprecated)
extension String: JsonConvertible {
  /**
    This method creates an instance from a JSON primitive.

    - parameter json:   The JSON primitive value.
  */
  public init(json: JsonPrimitive) throws {
    try self.init(json.read() as String)
  }
  
  /**
    This method gets a JSON primitive representing this value.
    */
  public func toJson() -> JsonPrimitive {
    return JsonPrimitive.String(self)
  }
}

@available(*, deprecated)
extension Int: JsonConvertible {
  /**
  This method creates an instance from a JSON primitive.
  
  - parameter json:   The JSON primitive value.
  */
  public init(json: JsonPrimitive) throws {
    try self.init(json.read() as Int)
  }
  
  /**
  This method gets a JSON primitive representing this value.
  */
  public func toJson() -> JsonPrimitive {
    return JsonPrimitive.Integer(self)
  }
}

@available(*, deprecated)
extension UInt: JsonConvertible {
  /**
  This method creates an instance from a JSON primitive.
  
  - parameter json:   The JSON primitive value.
  */
  public init(json: JsonPrimitive) throws {
    try self.init(json.read() as Int)
  }
  
  /**
  This method gets a JSON primitive representing this value.
  */
  public func toJson() -> JsonPrimitive {
    return JsonPrimitive.Integer(Int(self))
  }
}

@available(*, deprecated)
extension Bool: JsonConvertible {
  /**
   This method creates an instance from a JSON primitive.
   
   - parameter json:   The JSON primitive value.
   */
  public init(json: JsonPrimitive) throws {
    try self.init(NSNumber(integer: json.read()))
  }
  
  /**
   This method gets a JSON primitive representing this value.
   */
  public func toJson() -> JsonPrimitive {
    return JsonPrimitive.Boolean(self)
  }
}

@available(*, deprecated)
extension JsonPrimitive: JsonConvertible {
  /**
  This method creates an instance from another JSON primitive.

  - parameter json:   The JSON primitive value.
  */
  public init(json: JsonPrimitive) {
    self = json
  }
  
  /**
    This method gets a JSON primitive representing this value.
    */
  public func toJson() -> JsonPrimitive {
    return self
  }
}

@available(*, deprecated)
extension CollectionType where Generator.Element: JsonEncodable {
  /**
    This method gets a JSON primitive representing this value.
    */
  public func toJson() -> JsonPrimitive {
    return JsonPrimitive.Array(self.map { $0.toJson() })
  }
}

@available(*, deprecated)
extension Dictionary where Value: JsonEncodable {
  /**
    This method gets a JSON primitive representing this value.
    */
  public func toJson() -> JsonPrimitive {
    var dictionary = [String:JsonPrimitive]()
    for (key,value) in self {
      dictionary[String(key)] = value.toJson()
    }
    return .Dictionary(dictionary)
  }
  
  /**
    This method gets the JSON data for a dictionary.
    */
  public func toJsonData() -> NSData {
    do {
      return try self.toJson().jsonData()
    }
    catch {
      fatalError("Could not convert JSON dictionary to JSON. Something has changed in the JSON serialization rules")
    }
  }
}

/**
  This protocol describes a structure that can be converted into a dictionary
  mapping strings to JSON-convertible values.

  This protocol provides a default implementation of toJson based on the
  dictionary.
  */
@available(*, deprecated)
public protocol JsonDictionaryConvertible: JsonConvertible {
  /**
    This method gets a dictionary of JSON values that represents this value.
    */
  func toJsonDictionary() -> [String:JsonConvertible]
}

@available(*, deprecated)
extension JsonDictionaryConvertible {
  /**
    This method gets a JSON primitive representing this value.
    */
  public func toJson() -> JsonPrimitive {
    return .Dictionary(self.toJsonDictionary().map { $0.toJson() } )
  }
}