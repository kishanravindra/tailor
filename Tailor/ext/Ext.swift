import Foundation

/**
  This method takes in a block that throws an exception, and returns nil if
  any exception is thrown.

  - parameter block:    The exception-throwing expression.
  - returns:            The value from the exception, or nil if an error
                        occurred.
  */
public func rescue<T>(@autoclosure block: () throws ->T) -> T? {
  do { return try block() }
  catch { return nil }
}