/**
  This protocol describes a data structure that can be encoded as JSON.
  */
public protocol JsonEncodable {
  /**
    This method gets a JSON primitive representing this value.
    */
  func toJson() -> JsonPrimitive
}
/**
  This protocol describes a data structure that can be converted to and from
  JSON.
  */
public protocol JsonConvertible: JsonEncodable {
  /**
    This method creates an instance from a JSON primitive.

    - parameter json:   The JSON primitive value.
    */
  init(json: JsonPrimitive) throws
}

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
    return JsonPrimitive.Number(self)
  }
}


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

extension CollectionType where Generator.Element: JsonEncodable {
  /**
    This method gets a JSON primitive representing this value.
    */
  public func toJson() -> JsonPrimitive {
    return JsonPrimitive.Array(self.map { $0.toJson() })
  }
}

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
}
/**
  This protocol describes a structure that can be converted into a dictionary
  mapping strings to JSON-convertible values.

  This protocol provides a default implementation of toJson based on the
  dictionary.
  */
public protocol JsonDictionaryConvertible: JsonConvertible {
  /**
    This method gets a dictionary of JSON values that represents this value.
    */
  func toJsonDictionary() -> [String:JsonConvertible]
}

extension JsonDictionaryConvertible {
  /**
    This method gets a JSON primitive representing this value.
    */
  public func toJson() -> JsonPrimitive {
    return .Dictionary(self.toJsonDictionary().map { $0.toJson() } )
  }
}