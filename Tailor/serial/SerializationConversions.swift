/**
  This protocol describes a data structure that can be encoded as a serializable
  value.
  */
public protocol SerializationEncodable {
  /**
   This method gets a JSON primitive representing this value.
   */
  func serialize() -> SerializableValue
}

/**
  This protocol describes a data structure that can be initialized from a
  serializable value.
 */
public protocol SerializationInitializable {
  /**
   This method creates an instance from a serializable value.
   
   - parameter value:   The primitive value.
   */
  init(value: SerializableValue) throws
}

/**
  This protocol describes a data structure that can be converted to and from
  JSON.
  */
public protocol SerializationConvertible: SerializationEncodable,SerializationInitializable {
}

extension String: SerializationConvertible {
  /**
   This method creates an instance from a serializable primitive.
   
   - parameter value:   The primitive value.
   */
  public init(value: SerializableValue) throws {
    try self.init(value.read() as String)
  }
  
  /**
   This method gets a serializable primitive representing this value.
   */
  public func serialize() -> SerializableValue {
    return .String(self)
  }
}

extension Int: SerializationConvertible {
  /**
   This method creates an instance from a serializable primitive.
   
   - parameter json:   The primitive value.
   */
  public init(value: SerializableValue) throws {
    try self.init(value.read() as Int)
  }
  
  /**
   This method gets a serializable primitive representing this value.
   */
  public func serialize() -> SerializableValue {
    return .Integer(self)
  }
}

extension UInt: SerializationConvertible {
  /**
   This method creates an instance from a serializable primitive.
   
   - parameter json:   The primitive value.
   */
  public init(value: SerializableValue) throws {
    try self.init(value.read() as Int)
  }
  
  /**
   This method gets a serializable primitive representing this value.
   */
  public func serialize() -> SerializableValue {
    return .Integer(Int(self))
  }
}

extension Bool: SerializationConvertible {
  /**
   This method creates an instance from a serializable primitive.
   
   - parameter json:   The primitive value.
   */
  public init(value: SerializableValue) throws {
    try self.init(value.read() as Int)
  }
  
  /**
   This method gets a serializable primitive representing this value.
   */
  public func serialize() -> SerializableValue {
    return .Boolean(self)
  }
}


/**
 This extension provides a helper for converting a date into a serializable
 value
 */
extension NSDate: SerializationEncodable {
  /** The wrapped database value. */
  public func serialize() -> SerializableValue {
    return .Timestamp(Timestamp(foundationDate: self))
  }
}

/**
 This extension provides a helper for converting a timestamp into a wrapped
 database value.
 */
extension Timestamp: SerializationEncodable {
  /** The wrapped database value. */
  public func serialize() -> SerializableValue {
    return .Timestamp(self)
  }
}


/**
 This extension provides a helper for converting a timestamp into a wrapped
 database value.
 */
extension Time: SerializationEncodable {
  /** The wrapped database value. */
  public func serialize() -> SerializableValue {
    return .Time(self)
  }
}

/**
 This extension provides a helper for converting a date into a wrapped
 database value.
 */
extension Date: SerializationEncodable {
  /** The wrapped database value. */
  public func serialize() -> SerializableValue {
    return SerializableValue.Date(self)
  }
}

extension SerializableValue: SerializationConvertible {
  /**
   This method creates an instance from another serializable primitive.
   
   - parameter value:   The primitive value.
   */
  public init(value: SerializableValue) {
    self = value
  }
  
  /**
   This method gets a serializable value representing this value.
   */
  public func serialize() -> SerializableValue {
    return self
  }
}

extension CollectionType where Generator.Element: SerializationEncodable {
  /**
   This method gets a JSON primitive representing this value.
   */
  public func serialize() -> SerializableValue {
    return SerializableValue.Array(self.map { $0.serialize() })
  }
}

extension Dictionary where Value: SerializationEncodable {
  /**
   This method gets a JSON primitive representing this value.
   */
  public func serialize() -> SerializableValue {
    var dictionary = [String:SerializableValue]()
    for (key,value) in self {
      dictionary[String(key)] = value.serialize()
    }
    return .Dictionary(dictionary)
  }
}