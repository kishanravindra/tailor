import Foundation

/**
  This protocol describes the method that a controller must provide.

  A controller encapsulates a set of responses for related types of requests.
  For instance, you might have a controller for managing hats through restful
  actions, and it would handle requests for listing hats, showing details on a
  single hat, showing a form for updating a hat, and receiving a form submission
  for updating a hat. Each of these requests would be mapped to an action, which
  is an instance method that provides a response to a request.

  This protocol does not specify much about how you set up the actions, or even
  require that you set up the actions. Instead, it describes how a controller
  should represent the state of a request and some metadata about the
  controller, which allows the protocol to provide lots of helper methods for
  responding to requests.
  */
public protocol ControllerType {
  //MARK: - Metadata
  
  /**
    This method gets the name of the controller, for debugging and identifying
    routes.

    The default implementation uses the name of the class.
    */
  static var name: String { get }
  
  /**
    This method gets the layout that this controller uses to wrap around its
    templates.

    The default implementation uses an empty layout.
    */
  static var layout: LayoutType.Type { get }
  
  /**
    This method initializes a controller to handle a request.

    This initializer will always be invoked when creating controllers to handle
    a request.
  
    The default implementation uses this information to initialize a
    `ControllerState`, and then invokes the initializer on the controller that
    takes in the state.

    - parameter request:      The request that the controller is responding to.
    - parameter actionName:   The name of the action that the controller should
                              invoke. This is mostly useful for generating
                              routes, because the actual action method will be
                              called when the controller needs to respond.
    - parameter callback      The callback that the controller should invoke
                              when the response is ready.
    */
  init(request: Request, actionName: String, callback: Connection.ResponseCallback)

  /**
    This method initializes a controller with its state.

    We wrap this state in a `ControllerState` to make it easier for controllers
    to conform to the protocol without lots of boiler plate.

    - parameter state:    The state that tells the controller about the request and
                          how it should respond.
    */
  init(state: ControllerState)
  
  /**
    This attribute gets the state for the controller.

    We wrap it in another struct to reduce the boilerplate of conforming to the
    protocol.
    */
  var state: ControllerState { get }
  
  /**
    This method defines routes for the controller.

    The main thing you will want to do here is add routes for your actions. You
    can also define scopes for filters that the controller provides, or add a
    path prefix for the controller.
  
    - parameter routes:   The route set that we are adding our routes to.
    */
  static func defineRoutes(routes:  RouteSet)
}

/**
  This struct wraps around the state that we use to initialize a controller.
  */
public struct ControllerState {
  /** The request that the controller is responding to. */
  public var request: Request

  /** The callback that the controller should call once it has a response. */
  public var callback: Connection.ResponseCallback

  /** The session information that we extracted from the request. */
  public var session: Session

  /** The name of the action that is being called, as specified on the route. */
  public var actionName: String

  /** The user that is signed into the session. */
  public var currentUser: User?

  /** The localization that the controller should use to localize text. */
  public var localization: LocalizationSource

  /**
    This method initializes a controller state for an incoming request.

    This will set the request, action name, and callback from the input
    parameters. It will then build a session based on the request, set a default
    localization, and try and fetch the user from the session information.

    - parameter request:      The request that the controller is responding to.
    - parameter actionName:   The name of the action that the controller should
                              invoke. This is mostly useful for generating
                              routes, because the actual action method will be
                              called when the controller needs to respond.
    - parameter callback      The callback that the controller should invoke
                              when the response is ready.
    */
  public init(request: Request, actionName: String, callback: Connection.ResponseCallback) {
    self.request = request
    self.callback = callback
    self.session = Session(request: request)
    self.localization = Application.sharedApplication().localization("en")
    self.actionName = actionName
    
    if let userId = Int(self.session["userId"] ?? "") {
      self.currentUser = Users.find(userId)
    }
  }

  /**
    This method initializes a controller state with a full set of fields.

    - parameter request:      The request that the controller is responding to.
    - parameter actionName:   The name of the action that the controller should
                              invoke.
    - parameter callback      The callback that the controller should invoke
                              when the response is ready.
    - parameter session       The session information from the request.
    - parameter currentUser   The user that is signed in to the session.
    - parameter localization  The localization that the controller should use
                              to localize its text.
    */
  public init(request: Request, callback: Connection.ResponseCallback, session: Session, actionName: String, currentUser: User?, localization: LocalizationSource) {
    self.request = request
    self.callback = callback
    self.session = session
    self.actionName = actionName
    self.currentUser = currentUser
    self.localization = localization
  }
}

extension ControllerType {
  /** The request that the controller is responding to. */
  public var request: Request { return self.state.request }

  /** The session information from the request. */
  public var session: Session { return self.state.session }

  /** The callback that the controller should use to respond to its request. */
  public var callback: Connection.ResponseCallback { return self.state.callback }

  /** The name of the action is being invoked. */
  public var actionName: String { return self.state.actionName }

  /** The localization that the controller should use to localize its text. */
  public var localization: LocalizationSource { return self.state.localization }

  /** The user that is signed in. */
  public var currentUser: User? { return self.state.currentUser }

  public init(request: Request, actionName: String, callback: Connection.ResponseCallback) {
    self.init(state: ControllerState(request: request, actionName: actionName, callback: callback))
  }
  
  public static var name: String {
    return typeName(self)
  }
  
  public static var layout: LayoutType.Type { return EmptyLayout.self }
  
  //MARK: - Responses
  
  /**
    This method generates a response object and passes it to a block.
    
    This will set the cookies on the response before giving it to the block,
    and after the block is done it will give the response to the controller's
    handler.
    */
  public func generateResponse(@noescape contents: (inout Response)->()) {
    var response = Response()
    response.cookies = request.cookies
    contents(&response)
    session.storeInCookies(&response.cookies)
    self.callback(response)
  }
  
  /**
    This method generates a response object and passes it to a block.
    
    This will set the cookies on the response before giving it to the block,
    and after the block is done it will give the response to the controller's
    handler.
    */
  public func generateResponse(@noescape contents: (inout Response)->(Session)) {
    var response = Response()
    response.cookies = request.cookies
    let session = contents(&response)
    session.storeInCookies(&response.cookies)
    self.callback(response)
  }
  
  /**
    This method generates a response with a template.
    
    - parameter template:    The template to use for the request.
    */
  public func respondWith(template: TemplateType) {
    var layout = self.dynamicType.layout.init(controller: self, template: template)
    let contents = layout.generate()
    self.generateResponse {
      (inout response : Response) -> Void in
      response.renderedTemplates.append(template)
      response.appendString(contents)
    }
  }
  
  /**
    This method generates a response with a redirect to a different path.
  
    - parameter path:       The path to redirect to.
    - parameter session:    The session information for the response.
    */
  public func redirectTo(path: String, session: Session? = nil) {
    self.generateResponse {
      response -> Session in
      response.code = 302
      response.headers["Location"] = path
      return session ?? self.session
    }
  }
  
  /**
    This method generates a JSON response.
  
    - parameter json:   The object to convert to JSON and render.
    */
  public func respondWith(json json: JsonEncodable) {
    do {
      let jsonData = try json.toJson().jsonData()
      generateResponse {
        (inout response: Response) -> Void in
        response.code = 200
        response.headers["Content-Type"] = "application/json"
        response.appendData(jsonData)
      }
    }
    catch {
      generateResponse {
        (inout response: Response) -> Void in
        response.code = 500
      }
    }
  }
  
  /**
    This method generates a response with a redirect to a generated URL.
  
    This method has been deprecated in favor of the version that takes a
    controller type.
    
    - parameter controllerName:   The controller to link to. This will default to
                                  the current controller.
    - parameter actionName:       The action to link to.
    - parameter parameters:       Additional parameters for the path.
    - parameter session:          The session information for the response.
  */
  @available(*, deprecated) public func redirectTo(controllerName: String?, actionName: String? = nil, parameters: [String:String] = [:], session: Session? = nil) {
    let path = self.pathFor(controllerName, actionName: actionName, parameters: parameters) ?? "/"
    self.redirectTo(path, session: session)
  }
  
  
  /**
    This method generates a response with a redirect to a generated URL.
  
    - parameter actionName:       The name of the action to link to.
    - parameter parameters:       Additional parameters for the path.
    - parameter session:          The session information for the response.
    */
  public func redirectTo(actionName actionName: String, parameters: [String:String] = [:], session: Session? = nil) {
    self.redirectTo(self.dynamicType, actionName: actionName, parameters: parameters, session: session)
  }

  /**
    This method generates a response with a redirect to a generated URL.
    
    - parameter controller:       The controller to link to. This will default
                                  to the current controller.
    - parameter actionName:       The name of the action to link to.
    - parameter parameters:       Additional parameters for the path.
    - parameter session:    The session information for the response.
  */
  public func redirectTo(controller: ControllerType.Type, actionName: String, parameters: [String:String] = [:], session: Session? = nil) {
    let path = self.pathFor(controller, actionName: actionName, parameters: parameters) ?? "/"
    self.redirectTo(path, session: session)  }
  
  /**
    This method generates a response with a 404 page.
  */
  public func render404() {
    self.generateResponse {
      response -> Void in
      response.code = 404
      response.appendString("Page Not Found")
    }
  }
  
  /**
    This method gets the path for a route.
    
    It defaults to the current controller and action. It will also substitute
    any of the current request's parameters into the new path, if they are part
    of that path.
  
    This method has been deprecated in favor of the version that takes a
    controller type.
    
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
  @available(*, deprecated) public func pathFor(controllerName: String?, actionName: String? = nil, parameters: [String:String] = [:], domain: String? = nil, https: Bool = true) -> String? {
    var path = RouteSet.shared().pathFor(
      controllerName ?? self.dynamicType.name,
      actionName: actionName ?? self.actionName,
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
    This method gets the path for a route.
    
    It defaults to the current controller and action. It will also substitute
    any of the current request's parameters into the new path, if they are part
    of that path.
  
    - parameter parameters:       Additional parameters for the path.
    - parameter domain:           The domain to use for the URL. If this is
                                  omitted, the result will just be the path part
                                  of the URL.
    - parameter https:            Whether the URL should be https or http. If
                                  the domain is omitted, this is ignored.
    - returns:                    The path
    */
  public func pathFor(actionName actionName: String? = nil, parameters: [String:String] = [:], domain: String? = nil, https: Bool = true) -> String? {
    return self.pathFor(self.dynamicType, actionName: actionName, parameters: parameters, domain: domain, https: https)
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
  public func pathFor(controllerType: ControllerType.Type, actionName: String? = nil, parameters: [String:String] = [:], domain: String? = nil, https: Bool = true) -> String? {
    var path = RouteSet.shared().pathFor(
      controllerType,
      actionName: actionName ?? self.actionName,
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
  
  //MARK: - Localization
  
  /**
    This method gets the prefix that is automatically prepended to keys sent for
    localization in this controller.
    
    This will only be added to keys that start with a dot.
  */
  public var localizationPrefix: String {
    return self.dynamicType.name.underscored() + "." + self.actionName
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
    if let locale = locale {
      return Application.sharedApplication().localization(locale).fetch(fullKey)
    }
    else {
      return self.localization.fetch(fullKey)
    }
  }
  
  //MARK: - Authentication
  
  /**
    This method signs a user in for our session.
  
    This will not modify any information on the controller. Instead, it provides
    a new session that you can feed into the response.
  
    - parameter user:     The user to sign in.
    - returns:            The new session information with the user signed in.
    */
  public func signIn(user: User) -> Session {
    var session = self.session
    session["userId"] = String(user.id ?? 0)
    return session
  }
  
  /**
    This method signs a user out for our session.
    
    This will not modify any information on the controller. Instead, it provides
    a new session that you can feed into the response.

    - returns:    The new session information with the user signed out.
    */
  public func signOut() -> Session {
    var session = self.session
    session["userId"] = nil
    return session
  }
  
  /**
    This method signs in a user by providing their credentials.
    
    This will not modify any information on the controller. Instead, it provides
    a new session that you can feed into the response.
  
    - parameter emailAddress:   The email address the user has provided.
    - parameter password:       The password the user has provided.
    - returns:                  If we were able to sign them in, this will
                                return a new session with the user signed out.
                                If we were not able to sign them in, this will
                                return nil.
  */
  public func signIn(emailAddress: String, password: String) -> Session? {
    if let user = User.authenticate(emailAddress, password: password) {
      return self.signIn(user)
    }
    else {
      return nil
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
  public static func callAction<T:ControllerType>(actionName: String, _ action: (T)->Void->Void, _ request: Request, callback: (Response,T)->()) {
    
    var controller: T

    controller = T(request: request, actionName: actionName, callback: {_ in })
    controller = T(
      request: request,
      actionName: actionName,
      callback: { response in callback(response, controller) }
    )
    
    action(controller)()
  }
  
  /**
    This method calls an action manually on a controller. It is intended for use
    in testing.
  
    This will give the controller a request with no parameters.

    - parameter action:    The name of the action to call.
    - parameter callback:  The callback to call with the response.
    */
  public static func callAction<T:ControllerType>(actionName: String, _ action: (T)->(Void->Void), callback: (Response,T)->()) {
    self.callAction(actionName, action, Request(), callback: callback)
  }
  
  /**
    This method calls an action manually on a controller. It is intended for use
    in testing.
    
    - parameter action:        The name of the action to call.
    - parameter user:          The user for the request.
    - parameter parameters:    The request parameters.
    - parameter callback:      The callback to call with the response.
  */
  public static func callAction<T:ControllerType>(actionName: String, _ action: (T)->(Void->Void), user: User?, parameters: [String:String], callback: (Response,T)->()) {
    var sessionData = [String:String]()
    if let id = user?.id {
      sessionData["userId"] = String(id)
    }
    else {
      sessionData["userId"] = ""
    }
    self.callAction(actionName, action, Request(parameters: parameters, sessionData: sessionData), callback: callback)
  }
  
  /**
    This method calls an action manually on a controller. It is intended for use
    in testing.
    
    - parameter action:        The name of the action to call.
    - parameter parameters:    The request parameters.
    - parameter callback:      The callback to call with the response.
  */
  public static func callAction<T:ControllerType>(actionName: String, _ action: (T)->(Void->Void), parameters: [String:String], callback: (Response,T)->()) {
    self.callAction(actionName, action, user: nil, parameters: parameters, callback: callback)
  }
  
  /**
    This method calls an action manually on a controller. It is intended for use
    in testing.
    
    - parameter action:        The name of the action to call.
    - parameter user:          The user for the request.
    - parameter callback:      The callback to call with the response.
  */
  public static func callAction<T:ControllerType>(actionName: String, _ action: (T)->(Void->Void), user: User?, callback: (Response,T)->()) {
    self.callAction(actionName, action, user: user, parameters: [:], callback: callback)
  }
}