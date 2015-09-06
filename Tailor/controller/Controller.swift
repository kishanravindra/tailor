/**
  This class is the base class for controllers that route requests.

  This class has been deprecated. You should use the ControllerType protocol
  instead.
  */
@available(*, deprecated, message="Use the ControllerType protocol instead") public class Controller: ControllerType {
  /**
    This structure contains all the information about an action that can be run
    on a controller.
    */
  public struct Action {
    /** The name of the action. */
    public let name: String
    
    /**
    The block that provides a normal response for the action.
    
    This has an unusual type signature to support curried methods. For
    instance, if you are writing a controller called `HatsController`, and
    you want to use its `index` method as the body of an action, you can
    just set the body to `HatsController.wrap(HatsController.index)`. If you
    are setting the body inside of a class method on `HatsController`, which
    will be the common case, you can just set it to `wrap(index)`. The wrapper
    method is necessary to support any controller type rather than just
    `HatsController`, which actions require.
    
    If you are not using a curried function, then the body should take in a
    controller and return another block that will execute the action on that
    controller.
    */
    public let body: (Controller)->()->()
    
    /**
    The filters that run for this action.
    
    A filter provides a pre-check before an action's body is run. It can check
    that the request data is valid and potentially render an error response.
    
    By keeping this logic separate from the action body, it can be easier to
    re-use in multiple actions.
    
    If the check fails, this must return false. As soon as a filter returns
    false, the request processing stops, so any filter that returns false must
    also respond to the request.
    */
    public let filters: [(Controller)->()->Bool]
    
    /**
    This method creates an action.
    
    - parameter name:       The name of the action.
    - parameter body:       The body of the action.
    - parameter filters:    The filters that should be run before the body is
    called.
    */
    public init(name: String, body: (Controller)->()->(), filters: [(Controller)->()->Bool] = []) {
      self.name = name
      self.body = body
      self.filters = filters
    }
    
    /**
    This method runs the filters and the action body.
    */
    public func run(controller: Controller) {
      for filter in self.filters {
        if !filter(controller)() {
          return
        }
      }
      self.body(controller)()
    }
  }
  
  /** The action that we are executing. */
  public private(set) var action: Action! = nil
  
  /** The state of the controller. */
  public var state: ControllerState
  
  /** The controller's session information. */
  public var session: Session
  
  /**
  The actions that this controller supports.
  
  This implementation provides no actions. Subclasses must override this with
  their actions.
  */
  public class var actions: [Action] { return [] }
  
  /**
    This method defines the routes that this controller supports.

    - parameter routes:   The route set that we should add our routes into.
    */
  public class func defineRoutes(routes: RouteSet) {
  }
  
  /**
  The templates that this controller has rendered in the course of responding
  to its action.
  */
  public var renderedTemplates: [Template] = []
  
  /** Whether we have responded to our request. */
  public var responded = false
  
  /**
  This method creates a controller for handling a request.
  
  - parameter request:       The request that we are processing
  - parameter response:      The initial response that we should use as a
                              baseline.
  - parameter actionName:    The name of the action that we are executing.
  - parameter callback:      The callback to give the response to.
  */
  public required convenience init(request: Request, response: Response, actionName: String, callback: Connection.ResponseCallback) {
    self.init(state: ControllerState(request: request, response: Response(), actionName: actionName, callback: callback))
  }
  
  /**
    This initializer creates a controller with a controller state.

    - parameter state:    The state that holds the information about the
                          request and how it should be handled.
    */
  public required init(state: ControllerState) {
    self.state = state
    self.session = state.request.session
    
    self.action = self.dynamicType.actions.filter { $0.name == actionName }.first ?? Action(
      name: actionName,
      body: Controller.render404
    )
  }
  
  /**
  This method takes in an action body using a specialized controller
  type and returns a more general one that will take any controller type.
  
  When the resulting function is called, this will perform an safe cast from
  the general controller to the specialized type. If the case fails, this will
  return a block that always renders a 404 page.
  
  - parameter block:    The block with the specialized controller type.
  - returns:            The block with the general controller type.
  */
  public class func wrap<SpecificType: Controller>(block: (SpecificType)->()->())->(Controller)->()->() {
    return {
      (controller) in
      if let controller = controller as? SpecificType {
        return block(controller)
      }
      else {
        return { controller.render404Action() }
      }
    }
  }
  
  /**
    This method renders a 404 response.
    */
  public func render404Action() {
    
    if self.responded {
      NSLog("Error: Controller %@ attempted to respond twice. Subsequent responses will be ignored.", self.dynamicType.name)
      return
    }
    var response = Response()
    response.code = 404
    response.appendString("Page Not Found")
    response.cookies = request.cookies
    request.session.storeInCookies(&response.cookies)
    self.responded = true
    self.callback(response)
  }
  
  /**
  This method takes in an action filter using a specialized controller
  type and returns a more general one that will take any controller type.
  
  When the resulting function is called, this will perform an safe cast from
  the general controller to the specialized type. If the case fails, this will
  return a block that always renders a 404 page.
  
  - parameter block:    The block with the specialized controller type.
  - returns:            The block with the general controller type.
  */
  public class func wrap<SpecificType: Controller>(block: (SpecificType)->()->(Bool))->(Controller)->()->(Bool) {
    return {
      (controller) in
      if let controller = controller as? SpecificType {
        return block(controller)
      }
      else {
        return { controller.render404Action(); return false }
      }
    }
  }
  
  /**
    This method gets the layout within which we render our contents.
    */
  public class var layout: LayoutType.Type { return Layout.self }
  
  
  /**
  This method signs a user in for our session.
  
  This will set them in the controller's user field and store their id in the
  session for future requests.
  
  :param: user    The user to sign in.
  */
  public func signIn(user: UserType) -> Session {
    self.state.currentUser = user
    self.session["userId"] = String(user.id ?? 0)
    return self.session
  }
  
  /**
    This method signs in a user by providing their credentials.
    
    This will not modify any information on the controller. Instead, it provides
    a new session that you can feed into the response.
    
    - parameter emailAddress:   The email address the user has provided.
    - parameter password:       The password the user has provided.
    - returns:                  If we were able to sign them in, this will
                                return a new session with the user signed in.
                                If we were not able to sign them in, this will
                                rethrow the exception from the
                                `UserType.authenticate` method.
    */
  public func signIn(emailAddress: String, password: String) throws -> Session {
    guard let type = Application.configuration.userType else {
      throw UserLoginError.WrongEmailAddress
    }
    let user = try type.authenticate(emailAddress, password: password)
    return self.signIn(user)
  }
  
  /**
  This method signs a user out for our session.
  
  This will not modify any information on the controller. Instead, it provides
  a new session that you can feed into the response.
  
  - returns:    The new session information with the user signed out.
  */
  public func signOut() -> Session {
    self.session["userId"] = nil
    self.state.currentUser = nil
    return session
  }
  
  //MARK: - Responses
  
  /**
  This method calls the controller's action and generates a response.
  */
  public final func respond() {
    self.action.run(self)
  }
  
  /**
    This method generates a response object and passes it to a block.
    This will set the cookies on the response before giving it to the block,
    and after the block is done it will give the response to the controller's
    handler.
    */
  public func generateResponse(contents: (inout Response)->()) {
    if self.responded {
      NSLog("Error: Controller attempted to respond twice for %@:%@. Subsequent responses will be ignored.", self.dynamicType.name, self.actionName)
      return
    }
    var response = Response()
    response.cookies = request.cookies
    contents(&response)
    session.storeInCookies(&response.cookies)
    self.responded = true
    self.callback(response)
  }
  
  
  /**
  This method generates a response with a template.
  
  - parameter template:    The template to use for the request.
  */
  public func respondWith(template: TemplateType) {
    var layout = self.dynamicType.layout.init(controller: self, template: template)
    let contents = layout.generate()
    var response = self.state.response
    response.renderedTemplates.append(template)
    if let castTemplate = template as? Template {
      self.renderedTemplates.append(castTemplate)
    }
    response.appendString(contents)
    self.respondWith(response)
  }
  
  
  /**
  This method calls an action manually on a controller. It is intended for use
  in testing.
  :param: actionName  The name of the action to call.
  :param: request     The request to provide to the controller.
  :param: callback    The callback to call with the response.
  */
  public class func callAction(actionName: String, _ request: Request, callback: (Response,Controller)->()) {
    var controller: Controller!
    
    controller = self.init(
      request: request,
      response: Response(),
      actionName: actionName,
      callback: { response in callback(response, controller) }
    )
    controller.action.run(controller)
  }
  
  
  /**
  This method calls an action manually on a controller. It is intended for use
  in testing.
  
  This will give the controller a request with no parameters.
  :param: action    The name of the action to call.
  :param: callback  The callback to call with the response.
  */
  public class func callAction(action: String, callback: (Response,Controller)->()) {
    self.callAction(action, Request(), callback: callback)
  }
  
  /**
  This method calls an action manually on a controller. It is intended for use
  in testing.
  
  :param: action        The name of the action to call.
  :param: user          The user for the request.
  :param: parameters    The request parameters.
  :param: callback      The callback to call with the response.
  */
  public class func callAction(action: String, user: User?, parameters: [String:String], callback: (Response,Controller)->()) {
    var sessionData = [String:String]()
    if let id = user?.id {
      sessionData["userId"] = String(id)
    }
    else {
      sessionData["userId"] = ""
    }
    self.callAction(action, Request(parameters: parameters, sessionData: sessionData), callback: callback)
  }
  
  /**
  This method calls an action manually on a controller. It is intended for use
  in testing.
  
  :param: action        The name of the action to call.
  :param: parameters    The request parameters.
  :param: callback      The callback to call with the response.
  */
  public class func callAction(action: String, parameters: [String:String], callback: (Response,Controller)->()) {
    self.callAction(action, user: nil, parameters: parameters, callback: callback)
  }
  
  /**
  This method calls an action manually on a controller. It is intended for use
  in testing.
  
  :param: action        The name of the action to call.
  :param: user          The user for the request.
  :param: callback      The callback to call with the response.
  */
  public class func callAction(action: String, user: User?, callback: (Response,Controller)->()) {
    self.callAction(action, user: user, parameters: [:], callback: callback)
  }
}