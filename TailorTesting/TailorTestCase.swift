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
      AlterationsTask.runTask()
    }
    Application.truncateTables()
  }

  /**
    This method asserts that two things are equal.

    - parameter lhs:        The left-hand side of the equality comparison. If
                            this is nil, then it will be judged as not equal.
    - parameter rhs:        The right-hand side of the equality comparison. This
                            cannot be nil.
    - parameter message:    The message to show if the assertion fails.
    - parameter file:       The name of the file where the assertion is coming
                            from. You should generally omit this, since it will
                            be provided automatically.
    - parameter line:       The line of the file where the assertion is coming
                            from. You should generally omit this, since it will
                            be provided automatically.
    */
  public func assert<T : Equatable>(lhs: T!, equals rhs: T, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    let message = (message.isEmpty ? message: " - " + message)
    if lhs == nil {
      self.recordFailureWithDescription("Value was nil\(message)", inFile: file, atLine: line, expected: true)
    }
    else if lhs != rhs {
      self.recordFailureWithDescription("\(lhs) != \(rhs)\(message)", inFile: file, atLine: line, expected: true)
    }
  }
  
  /**
    This method asserts that two things are unequal.
  
    - parameter lhs:        The left-hand side of the equality comparison. If
                            this is nil, then it will be judged as not equal.
    - parameter rhs:        The right-hand side of the equality comparison. This
                            cannot be nil.
    - parameter message:    The message to show if the assertion fails.
    - parameter file:       The name of the file where the assertion is coming
                            from. You should generally omit this, since it will
                            be provided automatically.
    - parameter line:       The line of the file where the assertion is coming
                            from. You should generally omit this, since it will
                            be provided automatically.
    */
  public func assert<T : Equatable>(lhs: T!, doesNotEqual rhs: T, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    let message = (message.isEmpty ? message: " - " + message)
    if lhs != nil && lhs == rhs {
      self.recordFailureWithDescription("\(lhs) == \(rhs)\(message)", inFile: file, atLine: line, expected: true)
    }
  }
  
  /**
    This method asserts that two arrays are equal.
  
    - parameter lhs:       The left-hand side of the equality comparison.
    - parameter rhs:       The right-hand side of the equality comparison.
    - parameter message:   The message to show if the assertion fails.
    - parameter file:      The name of the file where the assertion is coming from.
                      You should generally omit this, since it will be provided
                      automatically.
    - parameter line:      The line of the file where the assertion is coming from.
                      You should generally omit this, since it will be provided
                      automatically.
  */
  public func assert<T : Equatable>(lhs: [T], equals rhs: [T], message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    let message = (message.isEmpty ? message: " - " + message)
    if lhs != rhs {
      self.recordFailureWithDescription("\(lhs) != \(rhs)\(message)", inFile: file, atLine: line, expected: true)
    }
  }
  
  /**
    This method asserts that two dictionaries are equal.
    
    - parameter lhs:       The left-hand side of the equality comparison.
    - parameter rhs:       The right-hand side of the equality comparison.
    - parameter message:   The message to show if the assertion fails.
    - parameter file:      The name of the file where the assertion is coming from.
                      You should generally omit this, since it will be provided
                      automatically.
    - parameter line:      The line of the file where the assertion is coming from.
                      You should generally omit this, since it will be provided
                      automatically.
  */
  public func assert<K : Equatable, V: Equatable>(lhs: [K:V], equals rhs: [K:V], message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    if lhs != rhs {
      let message = (message.isEmpty ? message: " - " + message)
      self.recordFailureWithDescription("\(lhs) != \(rhs)\(message)", inFile: file, atLine: line, expected: true)
    }
  }
  
  /**
    This method asserts that one string contains another.

    - parameter string:      The string to check.
    - parameter substring:   The string that it should contain.
    - parameter message:     The message to show if the assertion fails.
    - parameter file:        The name of the file where the assertion is coming from.
                        You should generally omit this, since it will be
                        provided automatically.
    - parameter line:        The line of the file where the assertion is coming from.
                        You should generally omit this, since it will be
                        provided automatically.
    */
  public func assert(string: String, contains substring: String, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    let range = string.rangeOfString(substring)
    if range == nil {
      let message = (message.isEmpty ? message: " - " + message)
      self.recordFailureWithDescription("\(string) does not contain \(substring)\(message)", inFile: file, atLine: line, expected: true)
    }
  }
  
  /**
    This method asserts that a value is nil.
  
    - parameter value:       The value to check.
    - parameter message:     The message to show if the assertion fails.
    - parameter file:        The name of the file where the assertion is coming from.
                        You should generally omit this, since it will be
                        provided automatically.
    - parameter line:        The line of the file where the assertion is coming from.
                        You should generally omit this, since it will be
                        provided automatically.
    */
  public func assert(isNil value: Any?, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    if value != nil {
      let message = (message.isEmpty ? message: " - " + message)
      self.recordFailureWithDescription("value was not nil\(message)", inFile: file, atLine: line, expected: true)
    }
  }
  
  /**
    This method asserts that a value is not nil.
    
    - parameter value:       The value to check.
    - parameter message:     The message to show if the assertion fails.
    - parameter file:        The name of the file where the assertion is coming from.
                        You should generally omit this, since it will be
                        provided automatically.
    - parameter line:        The line of the file where the assertion is coming from.
                        You should generally omit this, since it will be
                        provided automatically.
  */
  public func assert(isNotNil value: Any?, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    if value == nil {
      let message = (message.isEmpty ? message: " - " + message)
      self.recordFailureWithDescription("value was nil\(message)", inFile: file, atLine: line, expected: true)
    }
  }
  /**
    This method asserts that a value is close to another value.
    
    - parameter value:         The value to check.
    - parameter within:        How close the value has to be to the correct value.
    - parameter correctValue:  What the value is supposed to be.
    - parameter message:       The message to show if the assertion fails.
    - parameter file:          The name of the file where the assertion is coming
                          from. You should generally omit this, since it will be
                          provided automatically.
    - parameter line:          The line of the file where the assertion is coming
                          from. You should generally omit this, since it will be
                          provided automatically.
  */
  public func assert(value: Double?, within range: Double, of correctValue: Double, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    let message = (message.isEmpty ? message: " - " + message)
    if value == nil {
      self.recordFailureWithDescription("value was nil\(message)", inFile: file, atLine: line, expected: true)
    }
    else {
      if value! < correctValue - range || value! > correctValue + range {
        self.recordFailureWithDescription("\(value!) is not within \(range) of \(correctValue)\(message)", inFile: file, atLine: line, expected: true)
      }
    }
  }
  
  /**
    This method asserts that a condition is true.
    - parameter condition:   The condition to check.
    - parameter message:     The message to show if the assertion fails.
    - parameter file:        The name of the file where the assertion is coming
                        from. You should generally omit this, since it will be
                        provided automatically.
    - parameter line:        The line of the file where the assertion is coming
                        from. You should generally omit this, since it will be
                        provided automatically.
    */
  public func assert(condition: Bool, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    if !condition {
      let message = (message.isEmpty ? message: " - " + message)
      self.recordFailureWithDescription("Condition was false\(message)", inFile: file, atLine: line, expected: true)
    }
  }
}