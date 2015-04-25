import Foundation

/**
  This enum wraps around the value coming out of a SQL database.

  This allows us to pass a database value of an unknown type in a way that still
  puts type constraints on what it can be.
  */
public enum DatabaseValue: Equatable, Printable {
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
  
  /** Any date or time type. */
  case Date(NSDate)
  
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
    This method attempts to extract a date value from this value's contents.
    */
  public var dateValue: NSDate? {
    switch(self) {
    case let .Date(date):
      return date
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
    case let .Date(date):
      return date.format("db") ?? "NULL"
    case .Null:
      return "NULL"
    }
  }
}

//MARK: - Comparison

/**
  This method determines if two database values are equal.

  They are equal if they have the same type and their wrapped values are equal.

  :param: lhs   The left-hand of the equality
  :param: rhs   The right-hand of the equality
  :returns:     Whether they are equal.
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
  case (let .Date(date1), let .Date(date2)):
    return date1 == date2
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