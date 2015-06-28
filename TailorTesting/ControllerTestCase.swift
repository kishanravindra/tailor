import XCTest
import Tailor

/**
  This class provides helper methods for a test suite for testing a controller.
  */
public class ControllerTestCase : TailorTestCase {
  //MARK: - Request Information
  
  /**
    This hash maps action names to standard request parameters for tests of that
    action.

    These parameters will be used for any request that is generated by the
    callAction helper.
    */
  public var params: [String: [String:String]] = [:]
  
  /**
    The type of controller that we are testing.
    */
  public var controllerType: ControllerType.Type!
  
  /**
    The user that should be considered logged in for the request we are testing.
    */
  public var user: User!
  
  /**
    The file data that should be set on the request.

    The keys in the outermost dictionary are action names. Those action names
    are mapped to a dictionary that should have the same structure as a
    request's uploadedFiles attributes.
    */
  public var files: [String:[String:[String:Any]]] = [:]

  //MARK: - Assertions

  /**
    This method asserts that a response is a redirect.

    This will check both that the response's HTTP code is 302 and that its
    location header has the provided path.

    - parameter response:     The response that we are checking.
    - parameter path:         The path that it should redirect to. If this is
                              nil, the assertion will always fail, but we allow
                              it to be nil so that you can provide a potentially
                              nil path from pathFor without an additional check.
    - parameter message:      The message to show when the assertion fails.
    - parameter file:         The file that the assertion is coming from. You
                              should generally omit this, since it will be
                              provided automatically.
    - parameter line:         The line that the assertion is coming from. You
                              should generally omit this, since it will be
                              provided automatically.
    */
  public func assertResponse(response: Response, redirectsTo path: String?, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    assert(response.code, equals: 302, message: "gives a redirect response")
    if path == nil {
      self.recordFailureWithDescription("Target path is nil - \(message)", inFile: file, atLine: line, expected: true)
    }
    else {
      assert(response.headers["Location"], equals: path!, message: message, file:file, line:line)
    }
  }
  
  /**
    This method asserts that a response contains some text in its body.

    - parameter response:       The response to check.
    - parameter substring:      The text that the response must contain.
    - parameter message:        The message to show when the assertion fails.
    - parameter file:           The file that the assertion is coming from. You
                                should generally omit this, since it will be
                                provided automatically.
    - parameter line:           The line that the assertion is coming from. You
                                should generally omit this, since it will be
                                provided automatically.
    */
  public func assertResponse(response: Response, contains substring: String, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    let body = response.bodyString
    if !body.contains(substring) {
      self.recordFailureWithDescription("Assertion failed: \(body) does not contain \(substring) - \(message)", inFile: file, atLine: line, expected: true)
    }
  }
  
  /**
    This method asserts that a controller rendered a template of a given type.
  
    - parameter controller:         The controller whose templates we are
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
                                    on the
                                    template.
    */
  @available(*, deprecated) public func assert<TemplateType: Template>(controller: Controller, renderedTemplate: TemplateType.Type, message: String = "", file: String = __FILE__, line: UInt = __LINE__, _ templateChecker: (TemplateType)->() = {_ in}) {
    var found = false
    for template in controller.renderedTemplates {
      if let castTemplate = template as? TemplateType {
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
    This method asserts that a response rendered a template of a given type.
    
    - parameter response:           The response whose templates we are
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
  public func assert<SpecificType: TemplateType>(response: Response, renderedTemplate: SpecificType.Type, message: String = "", file: String = __FILE__, line: UInt = __LINE__, _ templateChecker: (SpecificType)->() = {_ in}) {
    var found = false
    for template in response.renderedTemplates {
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
  
  //MARK: - Helpers
  
  public func pathFor(controllerName: String? = nil, actionName: String, parameters: [String:String] = [:]) -> String? {
    let name: String
    
    if let type = controllerType {
      name = controllerName ?? type.name
    }
    else {
      name = controllerName ?? ""
    }
    return RouteSet.shared().pathFor(name, actionName: actionName, parameters: parameters)
  }

  //MARK: - Calling Actions
  
  public func callAction(actionName: String, file: String = __FILE__, line: UInt = __LINE__, callback: Response -> Void) {
    let actionParams = params[actionName] ?? [:]
    var sessionData = [String:String]()
    if user != nil {
      sessionData["userId"] = String(user.id ?? 0)
    }
    let routes = RouteSet.shared()
    
    guard let type = controllerType else { assert(false, message: "Did not have a controller type"); return }
    let path = routes.pathFor(type.name, actionName: actionName, parameters: actionParams)
    let method = routes.routes.filter {
      route in
      return route.controller == type && route.actionName == actionName
    }.first?.path.methodName ?? "GET"
    if path == nil {
      recordFailureWithDescription("could not generate route for \(type.name)/\(actionName)", inFile: file, atLine: line, expected: true)
      return
    }
    var request = Request(parameters: actionParams, sessionData: sessionData, path: path!, method: method)
    if let actionFiles = files[actionName] {
      request.uploadedFiles = actionFiles
    }
    let expectation = expectationWithDescription("response called")
    
    routes.handleRequest(request) {
      response in
      expectation.fulfill()
      callback(response)
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
}