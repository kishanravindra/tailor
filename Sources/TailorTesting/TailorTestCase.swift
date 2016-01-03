import Tailor
import XCTest
import Foundation

/**
  This class provides a test case for a Tailor application.

  It provides a setUp method that gets the application in a testable state, as
  well as matchers that will be generally useful in test cases.

  This has been deprecated in favor of the TailorTestable protocol.
  */
@available(*, deprecated, message="Use TailorTestable instead") public class TailorTestCase: XCTestCase, TailorTestable {
  public var allTests: [(String, () -> Void)] { return [] }
  /**
    This method configures the application for testing.

    This does nothing by default, but you can re-implement it in an extension to
    TailorTestCase to provide special configuration for your app in testing,
    like using a different test database.
    */
  public dynamic func configure() {
  }

  public required init() {
  
  }
  
  /**
    This method resets the test database.

    This will load the schema and the alterations table from the seed data,
    if they have not already been loaded. It will also run any pending
    alterations.

    It will also truncate all of the tables besides tailor_alterations. It will
    do this every time the method is called, whereas the rest of the work in
    this method is only done the first time the method has called.
    */
  public func resetDatabase() {
    if !TAILOR_TEST_CASE_DATABASE_RESET {
      Application.removeSharedDatabaseConnection()
      for task in Application.sharedApplication().registeredTasks() {
        if let seedTask = task as? SeedTaskType.Type {
          seedTask.loadSchema()
          seedTask.loadTable("tailor_alterations")
        }
      }
      
      AlterationsTask.runTask()
      TAILOR_TEST_CASE_DATABASE_RESET = true
    }
    Application.truncateTables()
  }
  
  /**
    This method does the set up for a test case.

    This will freeze the current time to ensure consistent times within tests,
    and reconfigure the application using the configure method. It will also
    truncate all the tables.

    If we have not done so already, this will also reset the test database. This
    requires that you have a task defined that implements `SeedTaskType`. It
    will use that task to reload the schema. It will also run any pending
    alterations that have not been saved into the seeds.
    */
  public func setUp() {
    Timestamp.freeze()
    configure()
    resetDatabase()
  }
  
  /**
    This method cleans up after a test case.
    
    It will unfreeze the current time, allowing it to proceed normally between
    test cases.
    */
  public func tearDown() {
    Timestamp.unfreeze()
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
  public func assert<T : Equatable>(lhs: T!, equals rhs: T, message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let message = (message.isEmpty ? message: " - " + message)
    if lhs == nil {
      self.testFailure("Value was nil\(message)", expected: true, file: file, line: line)
    }
    else if lhs != rhs {
      self.testFailure("\(lhs) != \(rhs)\(message)", expected: true, file: file, line: line)
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
  public func assert<T : Equatable>(lhs: T!, doesNotEqual rhs: T, message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let message = (message.isEmpty ? message: " - " + message)
    if lhs != nil && lhs == rhs {
      self.testFailure("\(lhs) == \(rhs)\(message)", expected: true, file: file, line: line)
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
  public func assert<T : Equatable>(lhs: [T], equals rhs: [T], message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let message = (message.isEmpty ? message: " - " + message)
    if lhs != rhs {
      self.testFailure("\(lhs) != \(rhs)\(message)", expected: true, file: file, line: line)
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
  public func assert<K : Equatable, V: Equatable>(lhs: [K:V], equals rhs: [K:V], message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    if lhs != rhs {
      let message = (message.isEmpty ? message: " - " + message)
      self.testFailure("\(lhs) != \(rhs)\(message)", expected: true, file: file, line: line)
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
  public func assert(string: String, contains substring: String, message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let range = string.bridge().rangeOfString(substring)
    if range.location == NSNotFound {
      let message = (message.isEmpty ? message: " - " + message)
      self.testFailure("\(string) does not contain \(substring)\(message)", expected: true, file: file, line: line)
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
  public func assert(isNil value: Any?, message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    if value != nil {
      let message = (message.isEmpty ? message: " - " + message)
      self.testFailure("value was not nil\(message)", expected: true, file: file, line: line)
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
  public func assert(isNotNil value: Any?, message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    if value == nil {
      let message = (message.isEmpty ? message: " - " + message)
      self.testFailure("value was nil\(message)", expected: true, file: file, line: line)
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
  public func assert(value: Double?, within range: Double, of correctValue: Double, message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let message = (message.isEmpty ? message: " - " + message)
    if value == nil {
      self.testFailure("value was nil\(message)", expected: true, file: file, line: line)
    }
    else {
      if value! < correctValue - range || value! > correctValue + range {
        self.testFailure("\(value!) is not within \(range) of \(correctValue)\(message)", expected: true, file: file, line: line)
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
  public func assert(condition: Bool, message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    if !condition {
      let message = (message.isEmpty ? message: " - " + message)
      self.testFailure("Condition was false\(message)", expected: true, file: file, line: line)
    }
  }
  
  /**
    This method asserts that a response includes a template
    of a given type.
    
    - parameter response:           The response we are checking.
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
  public func assert<SpecificType: TemplateType>(response: Response, renderedTemplate: SpecificType.Type, message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__, @noescape _ templateChecker: (SpecificType)->() = {_ in}) {
    self.assert(response.renderedTemplates, renderedTemplate: renderedTemplate, message: message, file: file, line: line, templateChecker)
  }
  
  /**
    This method asserts that an email includes a template
    of a given type.
  
    - parameter email:              The email we are checking.
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
  public func assert<SpecificType: TemplateType>(email: Email, renderedTemplate: SpecificType.Type, message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__, @noescape _ templateChecker: (SpecificType)->() = {_ in}) {
    self.assert(email.renderedTemplates, renderedTemplate: renderedTemplate, message: message, file: file, line: line, templateChecker)
  }
  
  /**
    This method asserts that a template includes a template
    of a given type.
  
    - parameter template:           The template we are checking.
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
  public func assert<SpecificType: TemplateType>(template: TemplateType, renderedTemplate: SpecificType.Type, message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__, @noescape _ templateChecker: (SpecificType)->() = {_ in}) {
    self.assert(template.state.renderedTemplates, renderedTemplate: renderedTemplate, message: message, file: file, line: line, templateChecker)
  }
  
  
  /**
    This method asserts that a list of templates includes a template
    of a given type.
  
    - parameter templates:          The list of templates we are checking.
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
  private func assert<SpecificType: TemplateType>(templates: [TemplateType], renderedTemplate: SpecificType.Type, message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__, @noescape _ templateChecker: (SpecificType)->() = {_ in}) {
    var found = false
    for template in templates {
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
      self.testFailure(failureMessage, expected: true, file: file, line: line)
    }
  }
}

private var TAILOR_TEST_CASE_DATABASE_RESET = false