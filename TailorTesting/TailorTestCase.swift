import Tailor
import XCTest

/**
  This class provides a test case for a Tailor application.

  It provides a setUp method that gets the application in a testable state, as
  well as matchers that will be generally useful in test cases.
  */
public class TailorTestCase: XCTestCase {
  public override func setUp() {
    APPLICATION_ARGUMENTS = ("tailor.exit", [:])
    
    if NSThread.currentThread().threadDictionary["SHARED_APPLICATION"] == nil {
      Application.start()
    }
    Application.truncateTables()
  }

  /**
    This method asserts that two things are equal.

    :param: lhs       The left-hand side of the equality comparison. If this is
                      nil, then it will be judged as not equal.
    :param: rhs       The right-hand side of the equality comparison. This
                      cannot be nil.
    :param: message   The message to show if the assertion fails.
    :param: file      The name of the file where the assertion is coming from.
                      You should generally omit this, since it will be provided
                      automatically.
    :param: line      The line of the file where the assertion is coming from.
                      You should generally omit this, since it will be provided
                      automatically.
    */
  public func assert<T : Equatable>(lhs: T!, equals rhs: T, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    if lhs == nil {
      self.recordFailureWithDescription("Value was nil - \(message)", inFile: file, atLine: line, expected: true)
    }
    else if lhs != rhs {
      self.recordFailureWithDescription("\(lhs) != \(rhs) - \(message)", inFile: file, atLine: line, expected: true)
    }
  }
  
  /**
    This method asserts that two arrays are equal.
    
    :param: lhs       The left-hand side of the equality comparison.
    :param: rhs       The right-hand side of the equality comparison.
    :param: message   The message to show if the assertion fails.
    :param: file      The name of the file where the assertion is coming from.
                      You should generally omit this, since it will be provided
                      automatically.
    :param: line      The line of the file where the assertion is coming from.
                      You should generally omit this, since it will be provided
                      automatically.
  */
  public func assert<T : Equatable>(lhs: [T], equals rhs: [T], message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    if lhs != rhs {
      self.recordFailureWithDescription("\(lhs) != \(rhs) - \(message)", inFile: file, atLine: line, expected: true)
    }
  }
  
  /**
    This method asserts that two dictionaries are equal.
    
    :param: lhs       The left-hand side of the equality comparison.
    :param: rhs       The right-hand side of the equality comparison.
    :param: message   The message to show if the assertion fails.
    :param: file      The name of the file where the assertion is coming from.
                      You should generally omit this, since it will be provided
                      automatically.
    :param: line      The line of the file where the assertion is coming from.
                      You should generally omit this, since it will be provided
                      automatically.
  */
  public func assert<K : Equatable, V: Equatable>(lhs: [K:V], equals rhs: [K:V], message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    if lhs != rhs {
      self.recordFailureWithDescription("\(lhs) != \(rhs) - \(message)", inFile: file, atLine: line, expected: true)
    }
  }
  
  /**
    This method asserts that one string contains another.

    :param: string      The string to check.
    :param: substring   The string that it should contain.
    :param: message     The message to show if the assertion fails.
    :param: file        The name of the file where the assertion is coming from.
                        You should generally omit this, since it will be
                        provided automatically.
    :param: line        The line of the file where the assertion is coming from.
                        You should generally omit this, since it will be
                        provided automatically.
    */
  public func assert(string: String, contains substring: String, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    let range = string.rangeOfString(substring)
    if range == nil {
      self.recordFailureWithDescription("\(string) does not contain \(substring) - \(message)", inFile: file, atLine: line, expected: true)
    }
  }
  
  /**
    This method asserts that a value is nil.
  
    :param: value       The value to check.
    :param: message     The message to show if the assertion fails.
    :param: file        The name of the file where the assertion is coming from.
                        You should generally omit this, since it will be
                        provided automatically.
    :param: line        The line of the file where the assertion is coming from.
                        You should generally omit this, since it will be
                        provided automatically.
    */
  public func assert(isNil value: Any?, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    if value != nil {
      self.recordFailureWithDescription("value was not nil - \(message)", inFile: file, atLine: line, expected: true)
    }
  }
  
  /**
    This method asserts that a value is not nil.
    
    :param: value       The value to check.
    :param: message     The message to show if the assertion fails.
    :param: file        The name of the file where the assertion is coming from.
                        You should generally omit this, since it will be
                        provided automatically.
    :param: line        The line of the file where the assertion is coming from.
                        You should generally omit this, since it will be
                        provided automatically.
  */
  public func assert(isNotNil value: Any?, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    if value == nil {
      self.recordFailureWithDescription("value was nil - \(message)", inFile: file, atLine: line, expected: true)
    }
  }
  /**
    This method asserts that a value is close to another value.
    
    :param: value         The value to check.
    :param: within        How close the value has to be to the correct value.
    :param: correctValue  What the value is supposed to be.
    :param: message       The message to show if the assertion fails.
    :param: file          The name of the file where the assertion is coming
                          from. You should generally omit this, since it will be
                          provided automatically.
    :param: line          The line of the file where the assertion is coming
                          from. You should generally omit this, since it will be
                          provided automatically.
  */
  public func assert(value: Double?, within range: Double, of correctValue: Double, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    if value == nil {
      self.recordFailureWithDescription("value was nil - \(message)", inFile: file, atLine: line, expected: true)
    }
    else {
      if value! < correctValue - range || value! > correctValue + range {
        self.recordFailureWithDescription("\(value!) is not within \(range) of \(correctValue) - \(message)", inFile: file, atLine: line, expected: true)
      }
    }
  }
}