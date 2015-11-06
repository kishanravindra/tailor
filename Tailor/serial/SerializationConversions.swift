/**
  This protocol describes a data structure that can be encoded as a serializable
  value.
  */
public protocol SerializationEncodable {
  /**
   This method gets a JSON primitive representing this value.
   */
  var serialize: SerializableValue { get }
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
    switch(value) {
    case let .String(string):
      self.init(string)
    default:
      throw SerializationParsingError.WrongFieldType(field: "root", type: Swift.String.self, caseType: value.wrappedType)
    }
  }
  
  /**
   This method gets a serializable primitive representing this value.
   */
  public var serialize: SerializableValue {
    return .String(self)
  }
}

extension Int: SerializationConvertible {
  /**
   This method creates an instance from a serializable primitive.
   
   - parameter json:   The primitive value.
   */
  public init(value: SerializableValue) throws {
    switch(value) {
    case let .Integer(int):
      self.init(int)
    case let .Double(double):
      self.init(double)
    case let .String(string):
      if let int = Int(string) {
        self.init(int)
      }
      else {
        throw SerializationParsingError.WrongFieldType(field: "root", type: Int.self, caseType: value.wrappedType)
      }
    default:
      throw SerializationParsingError.WrongFieldType(field: "root", type: Int.self, caseType: value.wrappedType)
    }
  }
  
  /**
   This method gets a serializable primitive representing this value.
   */
  public var serialize: SerializableValue {
    return .Integer(self)
  }
}

extension UInt: SerializationConvertible {
  /**
   This method creates an instance from a serializable primitive.
   
   - parameter json:   The primitive value.
   */
  public init(value: SerializableValue) throws {
    self.init(try Int(value: value))
  }
  
  /**
   This method gets a serializable primitive representing this value.
   */
  public var serialize: SerializableValue {
    return .Integer(Int(self))
  }
}

extension Bool: SerializationConvertible {
  /**
   This method creates an instance from a serializable primitive.
   
   - parameter json:   The primitive value.
   */
  public init(value: SerializableValue) throws {
    switch(value) {
    case let .Boolean(bool):
      self.init(bool)
    case let .Integer(int):
      self.init(int == 1)
    case .String("true"): self.init(true)
    case .String("false"): self.init(false)
    default:
      throw SerializationParsingError.WrongFieldType(field: "root", type: Bool.self, caseType: value.wrappedType)
    }

  }
  
  /**
   This method gets a serializable primitive representing this value.
   */
  public var serialize: SerializableValue {
    return .Boolean(self)
  }
}


/**
 This extension provides a helper for converting a date into a serializable
 value
 */
extension NSDate: SerializationEncodable {
  /** The wrapped database value. */
  public var serialize: SerializableValue {
    return .Timestamp(Timestamp(foundationDate: self))
  }
}

/**
 This extension provides a helper for converting a timestamp into a wrapped
 database value.
 */
extension Timestamp: SerializationConvertible {
  public init(value: SerializableValue) throws {
    switch(value) {
    case let .Timestamp(timestamp):
      self.init(epochSeconds: timestamp.epochSeconds, timeZone: timestamp.timeZone, calendar: timestamp.calendar)
    case let .String(string):
      guard let timestamp = TimeFormat.Database.parseTime(string, timeZone: Application.sharedDatabaseConnection().timeZone, calendar: SystemCalendar()) else {
        
        throw SerializationParsingError.WrongFieldType(field: "root", type: Timestamp.self, caseType: value.wrappedType)
      }
      self.init(epochSeconds: timestamp.epochSeconds, timeZone: timestamp.timeZone, calendar: timestamp.calendar)
    default:
      throw SerializationParsingError.WrongFieldType(field: "root", type: Timestamp.self, caseType: value.wrappedType)
    }

  }
  /** The wrapped database value. */
  public var serialize: SerializableValue {
    return .Timestamp(self)
  }
}


/**
 This extension provides a helper for converting a timestamp into a wrapped
 database value.
 */
extension Time: SerializationConvertible {
  public init(value: SerializableValue) throws {
    switch(value) {
    case let .Time(time):
      self.init(hour: time.hour, minute: time.minute, second: time.second, nanosecond: time.nanosecond, timeZone: time.timeZone)
    case let .Timestamp(timestamp):
      self.init(hour: timestamp.hour, minute: timestamp.minute, second: timestamp.second, nanosecond: timestamp.nanosecond, timeZone: timestamp.timeZone)
    case let .String(string):
      guard let timestamp = TimeFormat.DatabaseTime.parseTime(string, timeZone: Application.sharedDatabaseConnection().timeZone, calendar: SystemCalendar()) else {
        
        throw SerializationParsingError.WrongFieldType(field: "root", type: Time.self, caseType: value.wrappedType)
      }
      self.init(hour: timestamp.hour, minute: timestamp.minute, second: timestamp.second, nanosecond: timestamp.nanosecond, timeZone: timestamp.timeZone)
    default:
      throw SerializationParsingError.WrongFieldType(field: "root", type: Date.self, caseType: value.wrappedType)
    }
  }
  /** The wrapped database value. */
  public var serialize: SerializableValue {
    return .Time(self)
  }
}

/**
 This extension provides a helper for converting a date into a wrapped
 database value.
 */
extension Date: SerializationConvertible {
  public init(value: SerializableValue) throws {
    switch(value) {
    case let .Date(date):
      self.init(year: date.year, month: date.month, day: date.day, calendar: date.calendar)
    case let .Timestamp(timestamp):
      self.init(year: timestamp.year, month: timestamp.month, day: timestamp.day, calendar: timestamp.calendar)
    case let .String(string):
      guard let timestamp = TimeFormat.DatabaseDate.parseTime(string, timeZone: Application.sharedDatabaseConnection().timeZone, calendar: SystemCalendar()) else {
        
        throw SerializationParsingError.WrongFieldType(field: "root", type: Date.self, caseType: value.wrappedType)
      }
      self.init(year: timestamp.year, month: timestamp.month, day: timestamp.day, calendar: timestamp.calendar)
      
    default:
      throw SerializationParsingError.WrongFieldType(field: "root", type: Date.self, caseType: value.wrappedType)
    }
  }
  /** The wrapped database value. */
  public var serialize: SerializableValue {
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
  public var serialize: SerializableValue {
    return self
  }
}

extension Double: SerializationConvertible {
  public init(value: SerializableValue) throws {
    switch(value) {
    case let .Double(double):
      self.init(double)
    case let .Integer(int):
      self.init(int)
    case let .String(string):
      if let double = Double(string) {
        self.init(double)
      }
      else {
        throw SerializationParsingError.WrongFieldType(field: "root", type: Double.self, caseType: value.wrappedType)
      }
    default:
      throw SerializationParsingError.WrongFieldType(field: "root", type: Double.self, caseType: value.wrappedType)
    }
  }
  
  public var serialize: SerializableValue {
    return .Double(self)
  }
}

extension CollectionType where Generator.Element: SerializationEncodable {
  /**
   This method gets a JSON primitive representing this value.
   */
  public var serialize: SerializableValue {
    return SerializableValue.Array(self.map { $0.serialize })
  }
}

extension Dictionary where Value: SerializationEncodable {
  /**
   This method gets a JSON primitive representing this value.
   */
  public var serialize: SerializableValue {
    var dictionary = [String:SerializableValue]()
    for (key,value) in self {
      dictionary[String(key)] = value.serialize
    }
    return .Dictionary(dictionary)
  }
}