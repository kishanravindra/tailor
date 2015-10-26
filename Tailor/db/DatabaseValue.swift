import Foundation

/**
  This enum wraps around the value coming out of a SQL database.

  This allows us to pass a database value of an unknown type in a way that still
  puts type constraints on what it can be.
  */
@available(*, deprecated)
public typealias DatabaseValue = SerializableValue

//MARK: - Conversion

/**
  This protocol expresses that a type can be provided to a database value to
  wrap it.
  */
@available(*, deprecated)
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
@available(*, deprecated)
extension String: DatabaseValueConvertible {
  /** The wrapped database value. */
  public var databaseValue: DatabaseValue { return DatabaseValue.String(self) }
}

/**
  This extension provides a helper for converting a boolean into a wrapped
  database value.
  */
@available(*, deprecated)
extension Bool: DatabaseValueConvertible {
  /** The wrapped database value. */
  public var databaseValue: DatabaseValue { return DatabaseValue.Boolean(self) }
}

/**
  This extension provides a helper for converting a data blob into a wrapped
  database value.
 */
@available(*, deprecated)
extension NSData: DatabaseValueConvertible {
  /** The wrapped database value. */
  public var databaseValue: DatabaseValue { return DatabaseValue.Data(self) }
}

/**
  This extension provides a helper for converting an integer into a wrapped
  database value.
 */
@available(*, deprecated)
extension Int: DatabaseValueConvertible {
  /** The wrapped database value. */
  public var databaseValue: DatabaseValue { return DatabaseValue.Integer(self) }
}

/**
  This extension provides a helper for converting an integer into a wrapped
  database value.
 */
@available(*, deprecated)
extension UInt: DatabaseValueConvertible {
  /** The wrapped database value. */
  public var databaseValue: DatabaseValue { return DatabaseValue.Integer(Int(self)) }
}

/**
  This extension provides a helper for converting a double into a wrapped
  database value.
 */
@available(*, deprecated)
extension Double: DatabaseValueConvertible {
  /** The wrapped database value. */
  public var databaseValue: DatabaseValue { return DatabaseValue.Double(self) }
}

/**
  This extension provides a helper for converting a date into a wrapped
  database value.
 */
@available(*, deprecated)
extension NSDate: DatabaseValueConvertible {
  /** The wrapped database value. */
  public var databaseValue: DatabaseValue { return DatabaseValue.Timestamp(Timestamp(foundationDate: self)) }
}

/**
  This extension provides a helper for converting a timestamp into a wrapped
  database value.
 */
@available(*, deprecated)
extension Timestamp: DatabaseValueConvertible {
  /** The wrapped database value. */
  public var databaseValue: DatabaseValue { return DatabaseValue.Timestamp(self) }
}


/**
  This extension provides a helper for converting a timestamp into a wrapped
  database value.
 */
@available(*, deprecated)
extension Time: DatabaseValueConvertible {
  /** The wrapped database value. */
  public var databaseValue: DatabaseValue { return DatabaseValue.Time(self) }
}

/**
  This extension provides a helper for converting a date into a wrapped
  database value.
 */
@available(*, deprecated)
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
@available(*, deprecated)
extension DatabaseValue: DatabaseValueConvertible {
  /** The wrapped database value. */
  public var databaseValue: DatabaseValue { return self }
}