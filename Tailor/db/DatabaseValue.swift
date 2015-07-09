import Foundation

/**
  This enum wraps around the value coming out of a SQL database.

  This allows us to pass a database value of an unknown type in a way that still
  puts type constraints on what it can be.
  */
public enum DatabaseValue: Equatable, CustomStringConvertible {
  /** A null value */
  case Null
  
  /** A string */
  case String(Swift.String)

  /** A tiny int with a length of 1. */
  case Boolean(Bool)

  /** A data blob. */
  case Data(NSData)
  
  /** Any integer type. */
  case Integer(Int)
  
  /** Any floating-point type. */
  case Double(Swift.Double)
  
  /** A full timestamp type */
  case Timestamp(Tailor.Timestamp)
  
  /** A standalone date. */
  case Date(Tailor.Date)
  
  /** A standalone time. */
  case Time(Tailor.Time)
  
  //MARK: - Casting
  
  /**
    This method attempts to extract a string value from this value's contents.
    */
  public var stringValue: Swift.String? {
    switch(self) {
    case let .String(string):
      return string
    default:
      return nil
    }
  }
  
  /**
    This method attempts to extract a boolean value from this value's contents.
    */
  public var boolValue: Bool? {
    switch(self) {
    case let .Boolean(bool):
      return bool
    case let .Integer(int):
      return int == 1
    default:
      return nil
    }
  }
  
  /**
    This method attempts to extract an integer value from this value's contents.
    */
  public var intValue: Int? {
    switch(self) {
    case let .Integer(int):
      return int
    default:
      return nil
    }
  }
  
  /**
    This method attempts to extract a data value from this value's contents.
    */
  public var dataValue: NSData? {
    switch(self) {
    case let .Data(data):
      return data
    default:
      return nil
    }
  }
  
  /**
    This method attempts to extract a double value from this value's contents.
    */
  public var doubleValue: Swift.Double? {
    switch(self) {
    case let .Double(double):
      return double
    default:
      return nil
    }
  }
  
  /**
    This method attempts to extract a foundation date value from this value's 
    contents.
    */
  public var foundationDateValue: NSDate? {
    return self.timestampValue?.foundationDateValue
  }
  
  /**
    This method attempts to extract a timestamp value from this value's
    contents.
    */
  public var timestampValue: Tailor.Timestamp? {
    switch(self) {
    case let .Timestamp(timestamp):
      return timestamp
    case let .String(string):
      return TimeFormat.Database.parseTime(string, timeZone: Application.sharedDatabaseConnection().timeZone, calendar: SystemCalendar())
    default:
      return nil
    }
  }
  
  /**
    This method attempts to extract a date value from this value's contents.
    */
  public var dateValue: Tailor.Date? {
    switch(self) {
    case let .Date(date):
      return date
    case let .Timestamp(timestamp):
      return timestamp.date
    case let .String(string):
      return TimeFormat(.Year, "-", .Month, "-", .Day).parseTime(string, timeZone: Application.sharedDatabaseConnection().timeZone, calendar: SystemCalendar())?.date
    default:
      return nil
    }
  }
  
  /**
    This method attempts to extract a time value from this value's contents.
    */
  public var timeValue: Tailor.Time? {
    switch(self) {
    case let .Time(time):
      return time
    case let .Timestamp(timestamp):
      return timestamp.time
    case let .String(string):
      return TimeFormat(.Hour, ":", .Minute, ":", .Seconds).parseTime(string, timeZone: Application.sharedDatabaseConnection().timeZone, calendar: SystemCalendar())?.time
    default:
      return nil
    }
  }
  
  /**
    This method gets a description of the underlying value for debugging.
    */
  public var description: Swift.String {
    switch(self) {
    case let .String(string):
      return string
    case let .Boolean(bool):
      return bool.description
    case let .Data(data):
      return data.description
    case let .Integer(int):
      return Swift.String(int)
    case let .Double(double):
      return double.description
    case let .Timestamp(timestamp):
      return timestamp.format(TimeFormat.Database)
    case let .Date(date):
      return date.description
    case let .Time(time):
      return time.description
    case .Null:
      return "NULL"
    }
  }
}

//MARK: - Comparison

/**
  This method determines if two database values are equal.

  They are equal if they have the same type and their wrapped values are equal.

  - parameter lhs:    The left-hand of the equality
  - parameter rhs:    The right-hand of the equality
  - returns:          Whether they are equal.
  */
public func ==(lhs: DatabaseValue, rhs: DatabaseValue) -> Bool {
  switch(lhs,rhs) {
  case (let .String(string1), let .String(string2)):
    return string1 == string2
  case (let .Integer(int1), let .Integer(int2)):
    return int1 == int2
  case (let .Boolean(bool1), let .Boolean(bool2)):
    return bool1 == bool2
  case (let .Double(double1), let .Double(double2)):
    return double1 == double2
  case (let .Data(data1), let .Data(data2)):
    return data1 == data2
  case (let .Timestamp(timestamp1), let .Timestamp(timestamp2)):
    return timestamp1 == timestamp2
  case (.Null, .Null):
    return true
  default:
    return false
  }
}

//MARK: - Conversion

/**
  This protocol expresses that a type can be provided to a database value to
  wrap it.
  */
public protocol DatabaseValueConvertible {
  /**
    This method must provide a database value that wraps this value.
    */
  var databaseValue: DatabaseValue { get }
}

/**
  This extension provides a helper for converting a string into a wrapped
  database value.
  */
extension String: DatabaseValueConvertible {
  /** The wrapped database value. */
  public var databaseValue: DatabaseValue { return DatabaseValue.String(self) }
}

/**
  This extension provides a helper for converting a boolean into a wrapped
  database value.
  */
extension Bool: DatabaseValueConvertible {
  /** The wrapped database value. */
  public var databaseValue: DatabaseValue { return DatabaseValue.Boolean(self) }
}

/**
  This extension provides a helper for converting a data blob into a wrapped
  database value.
  */
extension NSData: DatabaseValueConvertible {
  /** The wrapped database value. */
  public var databaseValue: DatabaseValue { return DatabaseValue.Data(self) }
}

/**
  This extension provides a helper for converting an integer into a wrapped
  database value.
  */
extension Int: DatabaseValueConvertible {
  /** The wrapped database value. */
  public var databaseValue: DatabaseValue { return DatabaseValue.Integer(self) }
}

/**
  This extension provides a helper for converting a double into a wrapped
  database value.
  */
extension Double: DatabaseValueConvertible {
  /** The wrapped database value. */
  public var databaseValue: DatabaseValue { return DatabaseValue.Double(self) }
}

/**
  This extension provides a helper for converting a date into a wrapped
  database value.
  */
extension NSDate: DatabaseValueConvertible {
  /** The wrapped database value. */
  public var databaseValue: DatabaseValue { return DatabaseValue.Timestamp(Timestamp(foundationDate: self)) }
}

/**
  This extension provides a helper for converting a timestamp into a wrapped
  database value.
  */
extension Timestamp: DatabaseValueConvertible {
  /** The wrapped database value. */
  public var databaseValue: DatabaseValue { return DatabaseValue.Timestamp(self) }
}


/**
  This extension provides a helper for converting a timestamp into a wrapped
  database value.
  */
extension Time: DatabaseValueConvertible {
  /** The wrapped database value. */
  public var databaseValue: DatabaseValue { return DatabaseValue.Time(self) }
}

/**
  This extension provides a helper for converting a date into a wrapped
  database value.
  */
extension Date: DatabaseValueConvertible {
  /** The wrapped database value. */
  public var databaseValue: DatabaseValue { return DatabaseValue.Date(self) }
}

/**
  This extension provides a helper for converting a database value into a
  wrapped database value.

  It doesn't change anything about the value. It just makes it easier to use
  values and wrapped values interchangeably.
  */
extension DatabaseValue: DatabaseValueConvertible {
  /** The wrapped database value. */
  public var databaseValue: DatabaseValue { return self }
}

//MARK: - JSON Serialization

extension DatabaseValue: JsonConvertible {
  /**
    This method creates a database value from a JSON primitive.

    This only supports string and numeric primitives. Anything else will
    throw an exception.

    - parameter json:   The JSON value
    */
  public init(json: JsonPrimitive) throws {
    switch(json) {
    case .Null: self = .Null
    case let .String(s): self = .String(s)
    case let .Number(n):
      if n.doubleValue != Swift.Double(n.integerValue) {
        self = .Double(n.doubleValue)
      }
      else {
        self = .Integer(n.integerValue)
      }
    case .Array, .Dictionary:
      throw JsonParsingError.UnsupportedType(json.wrappedType)
    }
  }
  
  /**
    This method converts this value into its corresponding JSON value.
    */
  public func toJson() -> JsonPrimitive {
    switch(self) {
    case .Null: return .Null
    case let .String(s): return .String(s)
    case let .Boolean(b): return .Number(b)
    case let .Data(d): return .String(d.description)
    case let .Integer(i): return .Number(i)
    case let .Double(d): return .Number(d)
    case let .Timestamp(t): return .String(t.format(TimeFormat.Database))
    case let .Time(t): return .String(t.today.format(TimeFormat.DatabaseTime))
    case let .Date(t): return .String(t.beginningOfDay().format(TimeFormat.DatabaseDate))
    }
  }
}