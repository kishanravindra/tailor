import Tailor

/**
  This protocol describes a test case for testing a controller.
  */
public protocol ControllerTestable: class, TailorTestable {
  /** The type of controller that we are testing. */
  typealias TestedControllerType: ControllerType
  
  /**
    The parameters for the actions that we are testing.

    The keys in this dictionary must be the names of the controller's actions,
    and the values should be dictionaries that will provide the request
    parameters for these actions.
    */
  var params: [String:[String:String]] { get set }
  
  /**
   The parameters for the actions where the value for the parameter is an array
   of strings rather than just a string.
   
   The keys in this dictionary must be the names of the controller's actions,
   and the values should be dictionaries that will provide the request
   parameters for these actions.
   
   The default is an empty dictionary, so if you don't need array parameters
   you can ignore this.
   */
  var arrayParams: [String:[String:[String]]] { get }
  
  /** The user who should be logged in for our test requests. */
  var loggedInUser: UserType? { get }
  
  /** The files that should be uploaded in our test requests. */
  var files: [String:[String:[String:Any]]] { get }
}

extension ControllerTestable {
  public var files: [String:[String:[String:Any]]] { return [:] }
  public var loggedInUser: UserType? { return nil }
  public var arrayParams: [String:[String:[String]]] { return [:] }

  /**
    This method sets a value for a request parameter.

    By default, this only sets the parameter for actions where there is already
    a value for the parameter. The `all` parameter overrides this behavior.

    - parameter name:     The name of the parameter to set
    - parameter value:    The new value to set
    - parameter all:      Whether we should set the value on all actions.
    */
  public func setParam(name: String, to value: String, all: Bool = false) {
    for (key, var paramList) in params {
      if paramList[name] != nil || all {
        paramList[name] = value
      }
      params[key] = paramList
    }
  }
  /**
    This method calls an action on the controller this test case is testing.
    
    This will use the route set to get the actual action, so there must be a
    route defined for it for this method to work.
    - parameter actionName:   The name of the action we are calling.
    - parameter headers:      Additional headers to include in the request.
    - parameter sessionData:  The data to put in the request's session.
    - parameter cookies:      Cookies to include with the request.
    - parameter file:         The name of the file that is making the call. This
                              will be supplied automatically.
    - parameter line:         The line of the file that is making the call. This
                              will be supplied automatically.
    - parameter callback:     A callback that will perform checks on the
                              response.
    */
  public func callAction(actionName: String, headers: [String:String] = [:], var sessionData: [String:String] = [:], cookies: [String:String] = [:], timeoutIn timeout: NSTimeInterval = 0.01, file: String = __FILE__, line: UInt = __LINE__, callback: Response -> Void) {
    var actionParams = params[actionName] ?? [:]
    let csrfKey = AesEncryptor.generateKey()
    sessionData["csrfKey"] = csrfKey
    actionParams["_csrfKey"] = csrfKey
    if let id = self.loggedInUser?.id {
      sessionData["userId"] = String(id)
    }
    let routes = RouteSet.shared()
  
    var path = routes.pathFor(TestedControllerType.self, actionName: actionName, parameters: actionParams)
    
    if let queryStringLocation = path?.rangeOfString("?", options: NSStringCompareOptions.BackwardsSearch) {
      path = path?.substringToIndex(queryStringLocation.startIndex)
    }
    
    let method = routes.routes.filter {
      route in
      return route.controller == TestedControllerType.self && route.actionName == actionName
    }.first?.path.methodName ?? "GET"
    if path == nil {
      recordFailureWithDescription("could not generate route for \(TestedControllerType.name)/\(actionName)", inFile: file, atLine: line, expected: true)
      return
    }
    var request = Request(parameters: actionParams, sessionData: sessionData, path: path!, method: method, headers: headers, cookies: cookies)
    if let actionFiles = files[actionName] {
      request.uploadedFiles = actionFiles
    }
    if let arrayParams = self.arrayParams[actionName] {
      for (key,list) in arrayParams {
        request.params[key] = list
      }
    }
    
    let expectation = expectationWithDescription("response called")
  
    routes.handleRequest(request) {
      response in
      expectation.fulfill()
      callback(response)
    }
    waitForExpectationsWithTimeout(timeout, handler: nil)
  }
  
  /**
    This method gets the path to a controller route.
    
    - parameter controllerType:   The type of the controller we are getting the
                                  route for. This defaults to the type being
                                  tested.
    - parameter actionName:       The name of the action that we are getting the
                                  route for.
    - parameter parameters:       Additional request parameters to include in
                                  the path.
    */
  public func pathFor(controllerType: ControllerType.Type? = nil, actionName: String, parameters: [String:String] = [:]) -> String? {
    return RouteSet.shared().pathFor(controllerType ?? TestedControllerType.self, actionName: actionName, parameters: parameters)
  }
  
  
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
  public func assert(response: Response, redirectsTo path: String?, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    assert(response.responseCode, equals: .SeeOther, message: "gives a redirect response", file: file, line: line)
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
  public func assert(response: Response, contains substring: String, message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    let body = response.bodyString
    if !body.contains(substring) {
      self.recordFailureWithDescription("Assertion failed: \(body) does not contain \(substring) - \(message)", inFile: file, atLine: line, expected: true)
    }
  }
}

extension ControllerState {
  /**
    This initializer creates a controller state with an empty request.
    */
  public init() {
    self.init(request: Request())
  }
  
  /**
    This initializer creates a controller state with just a request.

    - parameter request:    The request that the controller will handle.
    */
  public init(request: Request) {
    self.init(request: request, response: Response(), actionName: "index", callback: {_ in})
  }
}

/**
  This protocol describes a controller that has an initializer that cannot throw
  exceptions.

  You can add this protocol to your controllers in testing so that you can get a
  default initializer with no parameters. This can be helpful in setting up
  dummy controllers for view tests.
  */
public protocol ControllerTypeWithCleanInitializer {
  init(state: ControllerState)
}

extension ControllerTypeWithCleanInitializer {
  /**
    This method creates a controller with an empty request.
    */
  public init() {
    self.init(state: ControllerState())
  }
}