import Foundation

/**
  This enum wraps around the value coming out of a SQL database.

  This allows us to pass a database value of an unknown type in a way that still
  puts type constraints on what it can be.
  */
public enum DatabaseValue {
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
}

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

extension String: DatabaseValueConvertible {
  public var databaseValue: DatabaseValue { return DatabaseValue.String(self) }
}

extension Bool: DatabaseValueConvertible {
  public var databaseValue: DatabaseValue { return DatabaseValue.Boolean(self) }
}

extension NSData: DatabaseValueConvertible {
  public var databaseValue: DatabaseValue { return DatabaseValue.Data(self) }
}

extension Int: DatabaseValueConvertible {
  public var databaseValue: DatabaseValue { return DatabaseValue.Integer(self) }
}

extension Double: DatabaseValueConvertible {
  public var databaseValue: DatabaseValue { return DatabaseValue.Double(self) }
}

extension NSDate: DatabaseValueConvertible {
  public var databaseValue: DatabaseValue { return DatabaseValue.Date(self) }
}