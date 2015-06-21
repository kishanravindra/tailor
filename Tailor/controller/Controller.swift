import Foundation

/**
  This class is the base class for controllers that route requests.
  */
public class Controller {
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
  
  /** The request that we are currently handling. */
  public let request: Request
  
  /** The callback for the current request's response. */
  public let callback: Connection.ResponseCallback
  
  /** The action that we are executing. */
  public private(set) var action: Action! = nil
  
  /** The session information for this request. */
  public let session: Session
  
  /** The user that is accessing the system. */
  public private(set) var currentUser : User?
  
  /** The localization that provides content for this controller. */
  public var localization: Localization
  
  /**
    The actions that this controller supports.

    This implementation provides no actions. Subclasses must override this with
    their actions.
    */
  public class var actions: [Action] { return [] }
  
  /**
    The templates that this controller has rendered in the course of responding
    to its action.
    */
  public private(set) var renderedTemplates: [Template] = []
  
  /** Whether we have responded to our request. */
  var responded = false
  
  /**
    This method takes in an action body using a specialized controller
    type and returns a more general one that will take any controller type.
  
    When the resulting function is called, this will perform an safe cast from
    the general controller to the specialized type. If the case fails, this will
    return a block that always renders a 404 page.
  
    - parameter block:    The block with the specialized controller type.
    - returns:            The block with the general controller type.
    */
  public class func wrap<ControllerType: Controller>(block: (ControllerType)->()->())->(Controller)->()->() {
    return {
      (controller) in
      if let controller = controller as? ControllerType {
        return block(controller)
      }
      else {
        return { controller.render404() }
      }
    }
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
  public class func wrap<ControllerType: Controller>(block: (ControllerType)->()->(Bool))->(Controller)->()->(Bool) {
    return {
      (controller) in
      if let controller = controller as? ControllerType {
        return block(controller)
      }
      else {
        return { controller.render404(); return false }
      }
    }
  }
  
  /** The name used to identify the controller in routing. */
  public class var name: String {
    return reflect(self).summary
  }
  
  /**
    This method creates a controller for handling a request.

    - parameter request:       The request that we are processing
    - parameter actionName:    The name of the action that we are executing.
    - parameter callback:      The callback to give the response to.
    */
  public required init(request: Request, actionName: String, callback: Connection.ResponseCallback) {
    self.request = request
    self.callback = callback
    self.session = Session(request: request)
    self.localization = Application.sharedApplication().localization("en")
    
    self.action = self.dynamicType.actions.filter { $0.name == actionName }.first ?? Action(
      name: actionName,
      body: Controller.render404
    )
    
    if let userId = Int(self.session["userId"] ?? "") {
      self.currentUser = Query<User>().find(userId)
    }
  }
  
  /**
    The template class that provides the layout for the views in this
    controller.

    This class will be instantiated with the template providing the content for
    a particular page.
    */
  public var layout = Layout.self
  
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
  public func generateResponse(@noescape contents: (inout Response)->()) {
    if self.responded {
      NSLog("Error: Controller attempted to respond twice for %@:%@. Subsequent responses will be ignored.", self.dynamicType.name, self.action.name)
      return
    }
    var response = Response()
    response.cookies = request.cookies
    contents(&response)
    session.storeInCookies(response.cookies)
    self.responded = true
    self.callback(response)
  }
  
  /**
    This method generates a response with a template.
  
    - parameter template:    The template to use for the request.
    */
  public func respondWith(template: Template) {
    let contents = self.layout(controller: self, template: template).generate()
    self.renderedTemplates.append(template)
    self.generateResponse {
      (inout response : Response) in
      response.appendString(contents)
    }
  }
  
  /**
    This method generates a response with a redirect to a different path.
  
    - parameter path:      The path to redirect to.
    */
  public func redirectTo(path: String) {
    self.generateResponse {
      response in
      response.code = 302
      response.headers["Location"] = path
    }
  }

  /**
    This method gets the path for a route.
  
    It defaults to the current controller and action. It will also substitute
    any of the current request's parameters into the new path, if they are part
    of that path.
  
    - parameter controllerName:   The controller to link to. This will default
                                  to the current controller.
    - parameter actionName:       The action to link to.
    - parameter parameters:       Additional parameters for the path.
    - parameter domain:           The domain to use for the URL. If this is
                                  omitted, the result will just be the path part
                                  of the URL.
    - parameter https:            Whether the URL should be https or http. If
                                  the domain is omitted, this is ignored.
    - returns:                    The path
  */
  public func pathFor(controllerName: String? = nil, actionName: String? = nil, parameters: [String:String] = [:], domain: String? = nil, https: Bool = true) -> String? {
    var path = Application.sharedApplication().routeSet.pathFor(
      controllerName ?? self.dynamicType.name,
      actionName: actionName ?? self.action.name,
      parameters: parameters,
      domain: domain,
      https: https
    )
    if path != nil {
      for (key,value) in self.request.requestParameters {
        if !key.isEmpty {
          path = path?.stringByReplacingOccurrencesOfString(":\(key)", withString: value)
        }
      }
    }
    return path
  }

  /**
    This method generates a response with a redirect to a generated URL.

    - parameter controllerName:   The controller to link to. This will default to
                                  the current controller.
    - parameter actionName:       The action to link to.
    - parameter parameters:       Additional parameters for the path.
    */
  public func redirectTo(controllerName: String? = nil, actionName: String? = nil, parameters: [String:String] = [:]) {
    let path = self.pathFor(controllerName, actionName: actionName, parameters: parameters) ?? "/"
    self.redirectTo(path)
  }
  
  /**
    This method generates a response with a redirect to a generated URL.
  
    This is a wrapper around the version that uses a controllerName. This
    version provides a more concise syntax when redirecting to other
    controllers.
  
    - parameter controllerName:   The controller to link to. This will default
                                  to the current controller.
    - parameter actionName:       The name of the action to link to.
    - parameter parameters:       Additional parameters for the path.
  */
  public func redirectTo(controller: Controller.Type, actionName: String, parameters: [String:String] = [:]) {
    self.redirectTo(
      controller.name,
      actionName: actionName,
      parameters: parameters
    )
  }

  /**
    This method generates a response with a 404 page.
    */
  public func render404() {
    self.generateResponse {
      response in
      response.code = 404
      response.appendString("Page Not Found")
    }
  }
  
  //MARK: - Authentication
  
  /**
    This method signs a user in for our session.
  
    This will set them in the controller's user field and store their id in the
    session for future requests.
  
    - parameter user:    The user to sign in.
    */
  public func signIn(user: User) {
    self.currentUser = user
    self.session["userId"] = String(user.id ?? 0)
  }
  
  /**
    This method signs a user out for our session.

    This will clear the controller's user field and remove the id from the
    session for future requests.
    */
  public func signOut() {
    self.currentUser = nil
    self.session["userId"] = nil
  }
  
  /**
    This method signs in a user by providing their credentials.
    
    - parameter emailAddress:   The email address the user has provided.
    - parameter password:       The password the user has provided.
    - returns:                  Whether we were able to authenticate the user.
  */
  public func signIn(emailAddress: String, password: String) -> Bool {
    if let user = User.authenticate(emailAddress, password: password) {
      self.signIn(user)
      return true
    }
    else {
      return false
    }
  }
  
  //MARK: - Localization
  
  /**
    This method gets the prefix that is automatically prepended to keys sent for
    localization in this controller.

    This will only be added to keys that start with a dot.
    */
  public var localizationPrefix: String {
    return self.dynamicType.name.underscored() + "." + self.action.name
  }
  
  /**
    This method localizes text.

    - parameter key:      The key for the localized text
    - parameter locale:   The locale that the localized text should be in. If
                          this is not provided, it will use the locale from the
                          default localization on this controller.
    - returns:            The localized text
    */
  public func localize(key: String, locale: String? = nil) -> String? {
    var fullKey = key
    if fullKey.hasPrefix(".") {
      fullKey = self.localizationPrefix + fullKey
    }
    if locale != nil {
      return Application.sharedApplication().localization(locale!).fetch(fullKey)
    }
    else {
      return self.localization.fetch(fullKey)
    }
  }
  
  //MARK: - Test Helpers
  
  /**
    This method calls an action manually on a controller. It is intended for use
    in testing.

    - parameter actionName:  The name of the action to call.
    - parameter request:     The request to provide to the controller.
    - parameter callback:    The callback to call with the response.
    */
  public class func callAction(actionName: String, _ request: Request, callback: (Response,Controller)->()) {
    var controller: Controller!
    
    controller = self.init(
      request: request,
      actionName: actionName,
      callback: { response in callback(response, controller) }
    )
    controller.action.run(controller)
  }
  
  /**
    This method calls an action manually on a controller. It is intended for use
    in testing.
  
    This will give the controller a request with no parameters.

    - parameter action:    The name of the action to call.
    - parameter callback:  The callback to call with the response.
    */
  public class func callAction(action: String, callback: (Response,Controller)->()) {
    self.callAction(action, Request(), callback: callback)
  }
  
  /**
    This method calls an action manually on a controller. It is intended for use
    in testing.
    
    - parameter action:        The name of the action to call.
    - parameter user:          The user for the request.
    - parameter parameters:    The request parameters.
    - parameter callback:      The callback to call with the response.
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
    
    - parameter action:        The name of the action to call.
    - parameter parameters:    The request parameters.
    - parameter callback:      The callback to call with the response.
  */
  public class func callAction(action: String, parameters: [String:String], callback: (Response,Controller)->()) {
    self.callAction(action, user: nil, parameters: parameters, callback: callback)
  }
  
  /**
    This method calls an action manually on a controller. It is intended for use
    in testing.
    
    - parameter action:        The name of the action to call.
    - parameter user:          The user for the request.
    - parameter callback:      The callback to call with the response.
  */
  public class func callAction(action: String, user: User?, callback: (Response,Controller)->()) {
    self.callAction(action, user: user, parameters: [:], callback: callback)
  }
}