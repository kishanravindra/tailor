import Tailor
import XCTest

/**
  This protocol describes a test case for testing a tailor expectation.

  It provides helper methods for setting up the application for testing, as well
  as shorthands for making test assertions.
  */
public protocol TailorTestable {
  /**
    This method configures the application for testing.
  
    You should provide an extension that defines this for your entire test
    suite.
    */
  func configure()
  
  /**
    This method records a failure of a test case.

    This is provided automatically by XCTestCase.

    - parameter message:    A message identifying the failure.
    - parameter inFile:     The file where the failure occurred.
    - parameter atLine:     The line where the failure occurred.
    - parameter expected:   Whether the failure came from an assertion.
    */
  func recordFailureWithDescription(message: String, inFile: String, atLine: UInt, expected: Bool)
  
  /**
    This method creates an expectation that can be fulfilled asynchronously.

    This is provided automatically by XCTestCase.
    
    - parameter description:    The description of the expectation.
    - returns:                  The expectation.
    */
  func expectationWithDescription(description: String)->XCTestExpectation
  
  /**
    This method blocks until all pending expectations is fulfilled.

    If the expectations are not fulfilled, this will record a failure.

    - parameter timeout:    How long we should wait before recording a failure.
    - parameter handler:    A callback to call with failures.
    */
  func waitForExpectationsWithTimeout(timeout: NSTimeInterval, handler: XCWaitCompletionHandler?)
}

extension TailorTestable {
  public func resetDatabase() {
    if !TAILOR_TESTABLE_DATABASE_RESET {
      Application.removeSharedDatabaseConnection()
      for task in Application.sharedApplication().registeredTasks() {
        if let seedTask = task as? SeedTaskType.Type {
          seedTask.loadSchema()
          seedTask.loadTable("tailor_alterations")
        }
      }
      
      AlterationsTask.runTask()
      TAILOR_TESTABLE_DATABASE_RESET = true
    }
    Application.truncateTables()
  }
  
  public func setUpTestCase() {
    Timestamp.unfreeze()
    Timestamp.freeze()
    configure()
    resetDatabase()
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
    
    - parameter lhs:        The left-hand side of the equality comparison.
    - parameter rhs:        The right-hand side of the equality comparison.
    - parameter message:    The message to show if the assertion fails.
    - parameter file:       The name of the file where the assertion is coming
                            from. You should generally omit this, since it will
                            be provided automatically.
    - parameter line:       The line of the file where the assertion is coming
                            from. You should generally omit this, since it will
                            be provided automatically.
    */
  public func assert<T : Equatable>(lhs: [T], equals rhs: [T], message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    let message = (message.isEmpty ? message: " - " + message)
    if lhs != rhs {
      self.recordFailureWithDescription("\(lhs) != \(rhs)\(message)", inFile: file, atLine: line, expected: true)
    }
  }
  
  /**
    This method asserts that two dictionaries are equal.
    
    - parameter lhs:        The left-hand side of the equality comparison.
    - parameter rhs:        The right-hand side of the equality comparison.
    - parameter message:    The message to show if the assertion fails.
    - parameter file:       The name of the file where the assertion is coming
                            from. You should generally omit this, since it will
                            be provided automatically.
    - parameter line:       The line of the file where the assertion is coming
                            from. You should generally omit this, since it will
                            be provided automatically.
  */
  public func assert<K : Equatable, V: Equatable>(lhs: [K:V], equals rhs: [K:V], message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    if lhs != rhs {
      let message = (message.isEmpty ? message: " - " + message)
      self.recordFailureWithDescription("\(lhs) != \(rhs)\(message)", inFile: file, atLine: line, expected: true)
    }
  }
  
  /**
    This method asserts that one string contains another.
    - parameter string:       The string to check.
    - parameter substring:    The string that it should contain.
    - parameter message:      The message to show if the assertion fails.
    - parameter file:         The name of the file where the assertion is coming
                              from. You should generally omit this, since it
                              will be provided automatically.
    - parameter line:         The line of the file where the assertion is coming
                              from. You should generally omit this, since it
                              will be provided automatically.
    */
  public func assert(string: String, contains substring: String, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    let range = string.rangeOfString(substring)
    if range == nil {
      let message = (message.isEmpty ? message: " - " + message)
      self.recordFailureWithDescription("\(string) does not contain \(substring)\(message)", inFile: file, atLine: line, expected: true)
    }
  }
  
  /**
    This method asserts that one string does not contain another.
  
    - parameter string:       The string to check.
    - parameter substring:    The string that it should not contain.
    - parameter message:      The message to show if the assertion fails.
    - parameter file:         The name of the file where the assertion is coming
                              from. You should generally omit this, since it
                              will be provided automatically.
    - parameter line:         The line of the file where the assertion is coming
                              from. You should generally omit this, since it
                              will be provided automatically.
    */
    public func assert(string: String, doesNotContain substring: String, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
      let range = string.rangeOfString(substring)
      if range != nil {
        let message = (message.isEmpty ? message: " - " + message)
        self.recordFailureWithDescription("\(string) contains \(substring)\(message)", inFile: file, atLine: line, expected: true)
      }
    }
  
  /**
    This method asserts that a value is nil.
  
    - parameter value:        The value to check.
    - parameter message:      The message to show if the assertion fails.
    - parameter file:         The name of the file where the assertion is coming
                              from. You should generally omit this, since it
                              will be provided automatically.
    - parameter line:         The line of the file where the assertion is coming
                              from. You should generally omit this, since it
                              will be provided automatically.
    */
  public func assert(isNil value: Any?, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    if value != nil {
      let message = (message.isEmpty ? message: " - " + message)
      self.recordFailureWithDescription("value was not nil\(message)", inFile: file, atLine: line, expected: true)
    }
  }
  
  /**
    This method asserts that a value is not nil.
    
    - parameter value:        The value to check.
    - parameter message:      The message to show if the assertion fails.
    - parameter file:         The name of the file where the assertion is coming
                              from. You should generally omit this, since it
                              will be provided automatically.
    - parameter line:         The line of the file where the assertion is coming
                              from. You should generally omit this, since it
                              will be provided automatically.
  */
  public func assert(isNotNil value: Any?, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    if value == nil {
      let message = (message.isEmpty ? message: " - " + message)
      self.recordFailureWithDescription("value was nil\(message)", inFile: file, atLine: line, expected: true)
    }
  }
  /**
    This method asserts that a value is close to another value.
    
    - parameter value:          The value to check.
    - parameter within:         How close the value has to be to the correct
                                value.
    - parameter correctValue:   What the value is supposed to be.
    - parameter message:        The message to show if the assertion fails.
    - parameter file:           The name of the file where the assertion is
                                coming from. You should generally omit this,
                                since it will be provided automatically.
    - parameter line:           The line of the file where the assertion is
                                coming from. You should generally omit this,
                                since it will be provided automatically.
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
  
    - parameter condition:    The condition to check.
    - parameter message:      The message to show if the assertion fails.
    - parameter file:         The name of the file where the assertion is coming
                              from. You should generally omit this, since it
                              will be provided automatically.
    - parameter line:         The line of the file where the assertion is coming
                              from. You should generally omit this, since it
                              will be provided automatically.
    */
  public func assert(condition: Bool, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    if !condition {
      let message = (message.isEmpty ? message: " - " + message)
      self.recordFailureWithDescription("Condition was false\(message)", inFile: file, atLine: line, expected: true)
    }
  }
  
  /**
    This method asserts that something includes a template
    of a given type.
  
    - parameter renderer:           The item whose rendered templates we are
                                    checking.
    - parameter renderedTemplate:   The type of template that we want to examine.
    - parameter message:            A message to show if the assertion fails.
    - parameter file:               The file that the assertion is coming from.
                                    You should generally omit this, since it
                                    will be provided automatically.
    - parameter line:               The line that the assertion is coming from.
                                    You should generally omit this, since it
                                    will be provided automatically.
    - parameter templateChecker:    A block that can perform additional checks
                                    on the template.
    */
  public func assert<SpecificType: TemplateType>(renderer: TemplateRenderingType, renderedTemplate: SpecificType.Type, message: String = "", file: String = __FILE__, line: UInt = __LINE__, @noescape _ templateChecker: (SpecificType)->() = {_ in}) {
    var found = false
    for template in renderer._renderedTemplates {
      if let castTemplate = template as? SpecificType {
        found = true
        templateChecker(castTemplate)
      }
    }
    if(!found) {
      var failureMessage = "Did not render a matching template"
      if !message.isEmpty {
        failureMessage += " - \(message)"
      }
      self.recordFailureWithDescription(failureMessage, inFile: file, atLine: line, expected: true)
    }
  }
  
  
  
  /**
    This method checks that something rendered a template.
    
    This variant allows you to check in the block whether the template's
    information matches some specific details, and ignore it if it does not.
    This will allow you to call this method multiple times for the same template
    type but different information in the block, and confirm that we rendered
    the template at least once with details matching what the block is looking
    for.
  
    - parameter renderer:           The item that may have rendered the
                                    template.
    - parameter templateType:       The type of template that are looking for.
    - parameter message:            The message to show if the assertion fails.
    - parameter file:               The file that the assertion is coming from.
                                    You should generally omit this, since it
                                    will be provided automatically.
    - parameter line:               The line that the assertion is coming from.
                                    You should generally omit this, since it
                                    will be provided automatically.
    - parameter templateChecker:    A block that determines if the template is
                                    the one we are looking for.
    */
  public func assert<SpecificType: TemplateType>(renderer: TemplateRenderingType, renderedMatchingTemplate templateType: SpecificType.Type, message: String = "", file: String = __FILE__, line: UInt = __LINE__, _ templateChecker: (SpecificType)->(Bool)) {
    var found = false
    for otherTemplate in renderer._renderedTemplates {
      if let castTemplate = otherTemplate as? SpecificType {
        if templateChecker(castTemplate) {
          found = true
          break
        }
      }
    }
    if(!found) {
      var failureMessage = "Did not render a matching template"
      if !message.isEmpty {
        failureMessage += " - \(message)"
      }
      self.recordFailureWithDescription(failureMessage, inFile: file, atLine: line, expected: true)
    }
  }
}

var TAILOR_TESTABLE_DATABASE_RESET = false

/**
  This protocol describes something that has a list of rendered templates.
  */
public protocol TemplateRenderingType {
  /** The templates this item has rendered. */
  var _renderedTemplates: [TemplateType] { get }
}

extension Response: TemplateRenderingType {
  /** The templates that the response rendered. */
  public var _renderedTemplates: [TemplateType] {
    return renderedTemplates
  }
}
extension Email: TemplateRenderingType {
  /** The templates this email has rendered. */
  public var _renderedTemplates: [TemplateType] {
    return renderedTemplates
  }
}
extension TemplateState: TemplateRenderingType {
  /** The templates this template has rendered. */
  public var _renderedTemplates: [TemplateType] {
    return renderedTemplates
  }
}