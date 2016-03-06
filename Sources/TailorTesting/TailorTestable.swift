import Tailor
import XCTest
import Foundation

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
    This method initializes a new test case.
    */
  init()

  /**
    This method records a failure. 

    The default implementation shells out to the XCTest version, but we can
    also stub this out when testing our test cases.
    */
  func XCTFail(message: String, file: StaticString, line: UInt)
}

extension TailorTestable {
  public func XCTFail(message: String, file: StaticString = #file, line: UInt = #line) {
    XCTest.XCTFail(message, file: file, line: line)
  }

  //MARK: - Set Up
  
  /**
    This method resets the test database.

    This will rebuild the database from the seeds, if there are any, and
    run any pending alterations. It will only do this once per execution. It
    will also truncate all the tables in the database, every time you call the
    method.
    */
  public func resetDatabase() {
    if !TAILOR_TESTABLE_DATABASE_RESET {
      Application.removeSharedDatabaseConnection()
      for task in TypeInventory.shared.registeredTasks {
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
  
  /**
    This method prepares the test case.

    This will freeze the timestamp to give consistent timings, run the
    `configure` method to load your testing configuration, and reset the
    database.
    */
  public func setUpTestCase() {
    Timestamp.unfreeze()
    Timestamp.freeze()
    configure()
  }
  
  //MARK: - Equality Checks
  
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
  public func assert<T : Equatable>(lhs: T!, equals rhs: T, message: String = "", file: StaticString = #file, line: UInt = #line) {
    let message = (message.isEmpty ? message: " - " + message)
    if lhs == nil {
      XCTFail("Value was nil\(message)", file: file, line: line)
    }
    else if lhs != rhs {
      XCTFail("\(lhs) != \(rhs)\(message)", file: file, line: line)
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
  public func assert<T : Equatable>(lhs: T!, doesNotEqual rhs: T, message: String = "", file: StaticString = #file, line: UInt = #line) {
    let message = (message.isEmpty ? message: " - " + message)
    if lhs != nil && lhs == rhs {
      XCTFail("\(lhs) == \(rhs)\(message)", file: file, line: line)
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
  public func assert<T : Equatable>(lhs: [T], equals rhs: [T], message: String = "", file: StaticString = #file, line: UInt = #line) {
    let message = (message.isEmpty ? message: " - " + message)
    if lhs != rhs {
      XCTFail("\(lhs) != \(rhs)\(message)", file: file, line: line)
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
  public func assert<T : Equatable>(lhs: [[T]], equals rhs: [[T]], message: String = "", file: StaticString = #file, line: UInt = #line) {
    let message = (message.isEmpty ? message: " - " + message)
    if lhs.count != rhs.count {
      XCTFail("\(lhs) != \(rhs)\(message)", file: file, line: line)
      return
    }
    for index in 0..<lhs.count {
      if lhs[index] != rhs[index] {
        XCTFail("\(lhs) != \(rhs)\(message)", file: file, line: line)
        return
      }
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
  public func assert<K : Equatable, V: Equatable>(lhs: [K:V], equals rhs: [K:V], message: String = "", file: StaticString = #file, line: UInt = #line) {
    if lhs != rhs {
      let message = (message.isEmpty ? message: " - " + message)
      XCTFail("\(lhs) != \(rhs)\(message)", file: file, line: line)
    }
  }
  
  //MARK: - Fuzzy Checks
  
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
  public func assert(string: String, contains substring: String, message: String = "", file: StaticString = #file, line: UInt = #line) {
    let range = string.bridge().rangeOfString(substring)
    if range.location == NSNotFound {
      let message = (message.isEmpty ? message: " - " + message)
      XCTFail("\(string) does not contain \(substring)\(message)", file: file, line: line)
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
    public func assert(string: String, doesNotContain substring: String, message: String = "", file: StaticString = #file, line: UInt = #line) {
      let range = string.bridge().rangeOfString(substring)
      if range.location != NSNotFound {
        let message = (message.isEmpty ? message: " - " + message)
        XCTFail("\(string) contains \(substring)\(message)", file: file, line: line)
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
  public func assert(isNil value: Any?, message: String = "", file: StaticString = #file, line: UInt = #line) {
    if value != nil {
      let message = (message.isEmpty ? message: " - " + message)
      XCTFail("value was not nil\(message)", file: file, line: line)
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
  public func assert(isNotNil value: Any?, message: String = "", file: StaticString = #file, line: UInt = #line) {
    if value == nil {
      let message = (message.isEmpty ? message: " - " + message)
      XCTFail("value was nil\(message)", file: file, line: line)
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
  public func assert(value: Double?, within range: Double, of correctValue: Double, message: String = "", file: StaticString = #file, line: UInt = #line) {
    let message = (message.isEmpty ? message: " - " + message)
    if value == nil {
      XCTFail("value was nil\(message)", file: file, line: line)
    }
    else {
      if value! < correctValue - range || value! > correctValue + range {
        XCTFail("\(value!) is not within \(range) of \(correctValue)\(message)", file: file, line: line)
      }
    }
  }
  
  /**
    This method asserts that a value matches a regular expression.

    - parameter string:         The value to check.
    - parameter matches:        The pattern that the value has to match.
    - parameter message:        The message to show if the assertion fails.
    - parameter file:           The name of the file where the assertion is
                                coming from. You should generally omit this,
                                since it will be provided automatically.
    - parameter line:           The line of the file where the assertion is
                                coming from. You should generally omit this,
                                since it will be provided automatically.
  */

  public func assert(string: String, matches pattern: String, message: String = "", file: StaticString = #file, line: UInt = #line) {
    var message = message
    if !message.isEmpty {
      message = " - " + message
    }
    guard let regex = try? Tailor.NSRegularExpression(pattern: pattern, options: []) else {
      XCTFail("\(pattern) was not a valid pattern\(message)", file: file, line: line)
      return
    }
    let matchCount = regex.numberOfMatchesInString(string, options: [], range: string.rangeOfSelf)
    if matchCount == 0 {
      XCTFail("\(string) did not match \(pattern)\(message)", file: file, line: line)
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
  public func assert(condition: Bool, message: String = "", file: StaticString = #file, line: UInt = #line) {
    if !condition {
      let message = (message.isEmpty ? message: " - " + message)
      XCTFail("Condition was false\(message)", file: file, line: line)
    }
  }
  
  //MARK: - Template Rendering
  
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
  public func assert<SpecificType: TemplateType>(renderer: TemplateRenderingType, renderedTemplate: SpecificType.Type, message: String = "", file: StaticString = #file, line: UInt = #line, @noescape _ templateChecker: (SpecificType)->() = {_ in}) {
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
      XCTFail(failureMessage, file: file, line: line)
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
  public func assert<SpecificType: TemplateType>(renderer: TemplateRenderingType, renderedMatchingTemplate templateType: SpecificType.Type, message: String = "", file: StaticString = #file, line: UInt = #line, _ templateChecker: (SpecificType)->(Bool)) {
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
      XCTFail(failureMessage, file: file, line: line)
    }
  }
  
  //MARK: - Exceptions
  
  /**
    This method asserts that a block does not throw an exception.

    - parameter message:            The message to show if the assertion fails.
    - parameter file:               The file that the assertion is coming from.
                                    You should generally omit this, since it
                                    will be provided automatically.
    - parameter line:               The line that the assertion is coming from.
                                    You should generally omit this, since it
                                    will be provided automatically.
    - parameter block:              The block that we are checking for
                                    exceptions.
    */
  public func assertNoExceptions(message: String = "", file: StaticString = #file, line: UInt = #line, @noescape block: Void throws -> Void) {
    do {
      try block()
    }
    catch {
      let fullMessage = "Threw exception" +  (message.isEmpty ? "" : " - \(message)")
      XCTFail(fullMessage, file: file, line: line)
    }
  }
  
  /**
    This method asserts that a block throws a certain exception.
   
    - parameter exception:          The exception that we are expecting to see.
    - parameter message:            The message to show if the assertion fails.
    - parameter file:               The file that the assertion is coming from.
                                    You should generally omit this, since it
                                    will be provided automatically.
    - parameter line:               The line that the assertion is coming from.
                                    You should generally omit this, since it
                                    will be provided automatically.
    - parameter block:              The block that we are checking for
                                    exceptions.
   */
  public func assertThrows<ExceptionType: ErrorType where ExceptionType: Equatable>(exception: ExceptionType, message: String = "", file: StaticString = #file, line: UInt = #line, @noescape block: Void throws -> Void) {
    do {
      try block()
      let fullMessage = "Did not throw exception" + (message.isEmpty ? "" : " - \(message)")
      XCTFail(fullMessage, file: file, line: line)
    }
    catch let thrown as ExceptionType {
      self.assert(thrown, equals: exception, message: message, file: file, line: line)
    }
    catch {
      let fullMessage = "Threw exception"  + (message.isEmpty ? "" : " - \(message)")
      XCTFail(fullMessage, file: file, line: line)
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