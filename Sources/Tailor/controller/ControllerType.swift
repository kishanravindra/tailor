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

    The default implementation uses the name of the type.
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
  
    This has been deprecated in favor of the version that takes a controller
    state.

    - parameter request:      The request that the controller is responding to.
    - parameter response:     The baseline for the response that the controller
                              will generate.
    - parameter actionName:   The name of the action that the controller should
                              invoke. This is mostly useful for generating
                              routes, because the actual action method will be
                              called when the controller needs to respond.
    - parameter callback      The callback that the controller should invoke
                              when the response is ready.
    */
  @available(*, deprecated, message="Use the initializer with a controller state instead")
  init(request: Request, response: Response, actionName: String, callback: Connection.ResponseCallback) throws

  /**
    This method initializes a controller with its state.

    We wrap this state in a `ControllerState` to make it easier for controllers
    to conform to the protocol without lots of boiler plate.
  
    If the request cannot be processed by the controller, for instance because
    it is missing a required field, this should throw an exception.
    The `ControllerError.UnprocessableRequest` error can be particularly
    helpful here.

    - parameter state:    The state that tells the controller about the request and
                          how it should respond.
    */
  init(state: ControllerState) throws
  
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
  
  /**
    The response that the controller is generating.
  
    Some parts of the response may be filled in by filters prior to the
    controller action starting. You should use this as the baseline for the
    response that you generate in the controller action and return to the
    callback.
    */
  public var response: Response

  /** The callback that the controller should call once it has a response. */
  public var callback: Connection.ResponseCallback

  /** The name of the action that is being called, as specified on the route. */
  public var actionName: String

  /** The user that is signed into the session. */
  public var currentUser: UserType?

  /** The localization that the controller should use to localize text. */
  public var localization: LocalizationSource
  
  /**
    This method initializes a controller state for an incoming request.

    This will set the request, action name, and callback from the input
    parameters. It will then build a session based on the request, set a default
    localization, and try and fetch the user from the session information.
  
    It will use the Accept-Language header from the request, in conjunction with
    the available locales from the localization source, to choose a locale.

    - parameter request:      The request that the controller is responding to.
    - parameter response:     The response baseline from the filters.
    - parameter actionName:   The name of the action that the controller should
                              invoke. This is mostly useful for generating
                              routes, because the actual action method will be
                              called when the controller needs to respond.
    - parameter callback      The callback that the controller should invoke
                              when the response is ready.
    */
  public init(request: Request, response: Response, actionName: String, callback: Connection.ResponseCallback) {
    self.request = request
    self.response = response
    self.callback = callback
    self.localization = Application.configuration.localizationForRequest(request)
    self.actionName = actionName
    self.currentUser = request.session.user
  }

  /**
    This method initializes a controller state with a full set of fields.

    - parameter request:      The request that the controller is responding to.
    - parameter response:     The response baseline from the filters.
    - parameter actionName:   The name of the action that the controller should
                              invoke.
    - parameter callback      The callback that the controller should invoke
                              when the response is ready.
    - parameter currentUser   The user that is signed in to the session.
    - parameter localization  The localization that the controller should use
                              to localize its text.
    */
  public init(request: Request, response: Response, callback: Connection.ResponseCallback, actionName: String, currentUser: UserType?, localization: LocalizationSource) {
    self.request = request
    self.response = response
    self.callback = callback
    self.actionName = actionName
    self.currentUser = currentUser
    self.localization = localization
  }
}

extension ControllerType {
  /** The request that the controller is responding to. */
  public var request: Request { return self.state.request }

  /** The callback that the controller should use to respond to its request. */
  public var callback: Connection.ResponseCallback { return self.state.callback }

  /** The name of the action is being invoked. */
  public var actionName: String { return self.state.actionName }

  /** The localization that the controller should use to localize its text. */
  public var localization: LocalizationSource { return self.state.localization }

  /** The user that is signed in. */
  public var currentUser: UserType? { return self.state.currentUser }
  
  /**
    This method initializes a controller to handle a request.
    
    This initializer will always be invoked when creating controllers to handle
    a request.
    
    The default implementation uses this information to initialize a
    `ControllerState`, and then invokes the initializer on the controller that
    takes in the state.
    
    - parameter request:      The request that the controller is responding to.
    - parameter response:     The baseline for the response that the controller
                              will generate.
    - parameter actionName:   The name of the action that the controller should
                              invoke. This is mostly useful for generating
                              routes, because the actual action method will be
                              called when the controller needs to respond.
    - parameter callback      The callback that the controller should invoke
                              when the response is ready.
    */
  @available(*, deprecated)
  public init(request: Request, response: Response, actionName: String, callback: Connection.ResponseCallback) throws {
    try self.init(state: ControllerState(request: request, response: response, actionName: actionName, callback: callback))
  }
  
  /**
    This method gets the name of the controller, for debugging and identifying
    routes.
  
    The default implementation uses the name of the type.
    */
  public static var name: String {
    return String(reflecting: self)
  }
  
  
  /**
    This method gets the layout that this controller uses to wrap around its
    templates.
    
    The default implementation uses an empty layout.
    */
  public static var layout: LayoutType.Type { return EmptyLayout.self }
  
  //MARK: - Responses
  
  /**
    This method generates a response with a template.
    
    - parameter template:    The template to use for the request.
    */
  public func respondWith(template: TemplateType) {
    var layout = self.dynamicType.layout.init(controller: self, template: template)
    let contents = layout.generate()
    var response = self.state.response
    response.renderedTemplates.append(template)
    response.appendString(contents)
    self.respondWith(response)
  }
  
  /**
    This method generates a response with a redirect to a different path.
  
    - parameter path:       The path to redirect to.
    - parameter session:    The new session for the response.
    - parameter flash:      The flash messages to store in the session.
    */
  public func redirectTo(path: String, session: Session? = nil, flash: [String:String?] = [:]) {
    var changedSession = session ?? self.request.session
    for (key, value) in flash {
      changedSession.setFlash(key, value)
    }
    var response = self.state.response
    response.responseCode = .SeeOther
    response.headers["Location"] = path
    response.appendString("<html><body>You are being <a href=\"\(path)\">redirected</a>.</body></html>")
    self.respondWith(response, session: changedSession)
  }
  
  /**
    This method generates a JSON response.
  
    - parameter json:           The object to convert to JSON and render.
    - parameter responseCode:   The response code for the response.
   */
  public func respondWith(json json: SerializationEncodable, responseCode: Response.Code = .Ok) {
    var response = self.state.response
    do {
      let jsonData = try json.serialize.jsonData()
      response.responseCode = responseCode
      response.headers["Content-Type"] = "application/json"
      response.appendData(jsonData)
    }
    catch {
      response.responseCode = .InternalServerError
    }
    self.respondWith(response)
  }
  
  /**
    This method generates a sends a response to our callback.

    If a session is provided, that session info will be stored on the response.
  
    - parameter response:   The response to send.
    - parameter session:    The session info for the response.
    */
  public func respondWith(response: Response, session: Session? = nil) {
    var response = response
    let session = session ?? request.session
    session.storeInCookies(&response.cookies)
    self.callback(response)
  }
  
  /**
    This method generates a response with a redirect to a generated URL.
  
    - parameter actionName:       The name of the action to link to.
    - parameter parameters:       Additional parameters for the path.
    - parameter session:          The session information for the response.
    - parameter flash:            The flash messages to store in the session.
    */
  public func redirectTo(actionName actionName: String, parameters: [String:String] = [:], session: Session? = nil, flash: [String:String?] = [:]) {
    self.redirectTo(self.dynamicType, actionName: actionName, parameters: parameters, session: session, flash: flash)
  }

  /**
    This method generates a response with a redirect to a generated URL.
    
    - parameter controller:       The controller to link to. This will default
                                  to the current controller.
    - parameter actionName:       The name of the action to link to.
    - parameter parameters:       Additional parameters for the path.
    - parameter session:          The session information for the response.
    - parameter flash:            The flash messages to store in the session.
  */
  public func redirectTo(controller: ControllerType.Type, actionName: String, parameters: [String:String] = [:], session: Session? = nil, flash: [String:String?] = [:]) {
    let path = self.pathFor(controller, actionName: actionName, parameters: parameters) ?? "/"
    self.redirectTo(path, session: session, flash: flash)
  }
  
  /**
    This method generates a response with a 404 page.
  */
  public func render404() {
    var response = self.state.response
    response.responseCode = .NotFound
    response.appendString("Page Not Found")
    self.respondWith(response)
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
      for (key,list) in self.request.params.raw {
        guard let value = list.first else { continue }
        if !key.isEmpty {
          path = path?.bridge().stringByReplacingOccurrencesOfString(":\(key)", withString: value)
        }
      }
    }
    return path
  }
  
  /**
    This method gets the path for a route in this controller.
    
    - parameter actionName:       The name of the action for the path.
    - parameter parameters:       Additional parameters for the path.
    - parameter domain:           The domain to use for the URL. If this is
                                  omitted, the result will just be the path part
                                  of the URL.
    - parameter https:            Whether the URL should be https or http. If
                                  the domain is omitted, this is ignored.
    - returns:                    The path
    */
  public static func pathFor(actionName: String, parameters: [String:String] = [:], domain: String? = nil, https: Bool = true) -> String? {
    return RouteSet.shared().pathFor(self, actionName: actionName, parameters: parameters, domain: domain, https: https)
  }
  
  /**
    This method renders a stream to the client.

    The stream will start with a header response with no data. Once that is
    rendered, the callback will be invoked to provide the response body.
  
    In this variant, the stream is driven by the producer. It feeds data to the
    connection on its own schedule, and if it wants to detect connection drops,
    it should use the continuation callback and connect that to another flag
    that will halt processing.

    - parameter headerResponse:     A response containing only the header data
                                    for the stream.
    - parameter continuationCallback:     A callback that can receive
                                          notifications about whether we should
                                          continue processing, so that it can
                                          halt the stream if the connection
                                          drops. This will receive a false value
                                          if the connection drops.
    - parameter callback:           A callback that provides the body of the
                                    response. This callback will be given
                                    another callback, and it should repeatedly
                                    invoke that callback with chunks of data
                                    for the response. The data will be written
                                    to the connection as soon as it is provided.
    */

  public func renderStream(headerResponse: Response, continuationCallback: (Bool->Void)? = nil, callback: ((NSData)->Void)->Void) {
    var headerResponse = headerResponse
    headerResponse.hasDefinedLength = false
    headerResponse.continuationCallback = continuationCallback
    self.callback(headerResponse)
    callback {
      data in
      var chunk = Response()
      chunk.headers = headerResponse.headers
      chunk.hasDefinedLength = false
      chunk.bodyOnly = true
      chunk.appendData(data)
      chunk.continuationCallback = continuationCallback
      self.callback(chunk)
    }
  }
  
  /**
    This method renders a stream to the client.
    
    The stream will start with a header response with no data. Once that is
    rendered, the callback will be invoked to provide the response body.
  
    In this variant, the stream is produced as requested by the connection.
    New data is requested as soon as the connection sends out the last data.
    If the connection is dropped, then this will stop requesting data from its
    callback.
    
    - parameter headerResponse:     A response containing only the header data
                                    for the stream.
    - parameter callback:           A callback that provides the body of the
                                    response. This should return the latest
                                    data, or nil if the data provider is
                                    exhausted.
    */
  
  public func renderPolledStream(headerResponse: Response, callback: (Void->NSData?)) {
    var shouldContinue = true
    let continuationCallback = {
      (result: Bool) in
      shouldContinue = result
    }
    self.renderStream(headerResponse, continuationCallback: continuationCallback) {
      dataCallback in
      while(shouldContinue) {
        guard let data = callback() else { return }
        dataCallback(data)
      }
    }
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
  public func localize(key: String, locale: String? = nil, interpolations: [String:String] = [:]) -> String? {
    var fullKey = key
    if fullKey.hasPrefix(".") {
      fullKey = self.localizationPrefix + fullKey
    }
    if let locale = locale {
      return Application.configuration.localization(locale).fetch(fullKey, interpolations: interpolations)
    }
    else {
      return self.localization.fetch(fullKey, interpolations: interpolations)
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
  public func signIn(user: UserType) -> Session {
    var session = self.request.session
    if let trackableUser = user as? TrackableUserType {
      var trackableUser = trackableUser
      trackableUser.lastSignInIp = request.clientAddress
      trackableUser.lastSignInTime = Timestamp.now()
      trackableUser.save()
    }
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
    var session = self.request.session
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
  
  //MARK: - Request Parameters
  
  /**
    This method fetches a record based from request parameters.
    
    If the record cannot be found, this will throw an UnprocessableRequest
    exception with a 404 response.
    
    If a fallback is provided, and there is no value for the given parameter,
    this will use the fallback. If there is a value, but it doesn't match any
    record's id, this will *not* use the fallback.
    
    - parameter state:        The controller state with the request.
    - parameter parameter:    The name of the parameter containing the id.
    - parameter fallback:     A fallback to use if there is no value for the
                              parameter.
    - returns:                The fetched record.
    */
  public static func fetchRecord<T: Persistable>(state: ControllerState, from parameter: String = "id", fallback: T? = nil) throws -> T {
    func failure(allowFallback allowFallback: Bool) throws -> T {
      var response = Response()
      response.responseCode = .NotFound
      if allowFallback {
        if let value = fallback {
          return value
        }
      }
      throw ControllerError.UnprocessableRequest(response)
    }
    guard let id = state.request.params[parameter] as String? else { return try failure(allowFallback: true) }
    guard let value = Query<T>().filter(["id": id]).first() else { return try failure(allowFallback: false) }
    return value
  }
  
  //MARK: - Caching
  
  /**
    This method causes a response to be cached using a Last-Modified header.

    This will check for an If-Modified-Since header in the request. If the
    header is provided, and is on or after the provided timestamp, then this
    will return a 304 response without trying to regenerate the response.
    Otherwise, it will use the provided block to generate a new response.
  
    This caching mechanism prevents having to re-generate or re-transmit the
    response, but requires a modification time that is known in advance. It is
    best suited for responses that may be time consuming to generate, but have a
    known modification date, like news articles.

    - parameter responseGenerator:  A block that adds the body to the response.
    */
  public func cacheWithModificationTime(timestamp: Timestamp, @noescape responseGenerator: (inout Response)->Void) {
    var response = self.state.response
    if let requestTimestamp = Request.parseTime(request.headers["If-Modified-Since"] ?? "") {
      if Int(requestTimestamp.epochSeconds) >= Int(timestamp.epochSeconds) {
        response.responseCode = .NotModified
        response.headers["Last-Modified"] = timestamp.inTimeZone("GMT").format(TimeFormat.Rfc822)
        self.respondWith(response)
        return
      }
    }
    responseGenerator(&response)
    if response.responseCode == .Ok {
      response.headers["Last-Modified"] = timestamp.inTimeZone("GMT").format(TimeFormat.Rfc822)
    }
    self.respondWith(response)
  }

  //MARK: - Test Helpers
  
  /**
    This method calls an action manually on a controller. It is intended for use
    in testing.
  
    This method is deprecated because it cannot support exceptions in
    initialization. If the controller initialization throws an error, this will
    raise a fatal error.

    - parameter actionName:  The name of the action to call.
    - parameter request:     The request to provide to the controller.
    - parameter callback:    The callback to call with the response.
    */
  @available(*, deprecated, message="This is deprecated because it cannot support exceptions")
  public static func callAction<T:ControllerType>(actionName: String, _ action: (T)->Void->Void, _ request: Request, callback: (Response,T)->()) {
    
    var controller: T
    let response = Response()
    do {
      controller = try T(state: ControllerState(request: request, response: response, actionName: actionName, callback: {_ in }))
      controller = try T(state: ControllerState(
        request: request,
        response: response,
        actionName: actionName,
        callback: { response in callback(response, controller) }
      ))
      
      action(controller)()
    }
    catch {
      fatalError("Got exception when creating controller")
    }
  }
  
  /**
    This method calls an action manually on a controller. It is intended for use
    in testing.
    
    This method is deprecated because it cannot support exceptions in
    initialization. If the controller initialization throws an error, this will
    raise a fatal error.
  
    This will give the controller a request with no parameters.

    - parameter action:    The name of the action to call.
    - parameter callback:  The callback to call with the response.
    */
  @available(*, deprecated, message="This is deprecated because it cannot support exceptions")
  public static func callAction<T:ControllerType>(actionName: String, _ action: (T)->(Void->Void), callback: (Response,T)->()) {
    self.callAction(actionName, action, Request(), callback: callback)
  }
  
  /**
    This method calls an action manually on a controller. It is intended for use
    in testing.
    
    This method is deprecated because it cannot support exceptions in
    initialization. If the controller initialization throws an error, this will
    raise a fatal error.
  
    - parameter action:        The name of the action to call.
    - parameter user:          The user for the request.
    - parameter parameters:    The request parameters.
    - parameter callback:      The callback to call with the response.
  */
  @available(*, deprecated, message="This is deprecated because it cannot support exceptions")
  public static func callAction<T:ControllerType>(actionName: String, _ action: (T)->(Void->Void), user: UserType?, parameters: [String:String], callback: (Response,T)->()) {
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
    
    This method is deprecated because it cannot support exceptions in
    initialization. If the controller initialization throws an error, this will
    raise a fatal error.
  
    - parameter action:        The name of the action to call.
    - parameter parameters:    The request parameters.
    - parameter callback:      The callback to call with the response.
  */
  @available(*, deprecated, message="This is deprecated because it cannot support exceptions")
  public static func callAction<T:ControllerType>(actionName: String, _ action: (T)->(Void->Void), parameters: [String:String], callback: (Response,T)->()) {
    self.callAction(actionName, action, user: nil, parameters: parameters, callback: callback)
  }
  
  /**
    This method calls an action manually on a controller. It is intended for use
    in testing.
    
    This method is deprecated because it cannot support exceptions in
    initialization. If the controller initialization throws an error, this will
    raise a fatal error.
  
    - parameter action:        The name of the action to call.
    - parameter user:          The user for the request.
    - parameter callback:      The callback to call with the response.
  */
  @available(*, deprecated, message="This is deprecated because it cannot support exceptions")
  public static func callAction<T:ControllerType>(actionName: String, _ action: (T)->(Void->Void), user: UserType?, callback: (Response,T)->()) {
    self.callAction(actionName, action, user: user, parameters: [:], callback: callback)
  }
}

/**
  This enum provides errors that controllers can throw during initialization.
  */
public enum ControllerError: ErrorType {
  /**
    This error indicates that a request did not have enough information for the
    controller to process it.

    This wraps around a custom response explaining more about the problem with
    the request.
    */
  case UnprocessableRequest(Response)
  
  /**
   This method builds an exception for returning a 404 error.
   
   - parameter state:     The initial state of the controller. This is used to
                          generate the initial response.
   - parameter message:   A message to include in the body of the response.
   - returns:             An error that the caller can throw.
   */
  public static func resourceNotFoundError(state: ControllerState, message: String = "") -> ControllerError {
    var response = state.response
    response.responseCode = .NotFound
    response.appendString(message)
    return ControllerError.UnprocessableRequest(response)
  }
  
  
  /**
    This method generates a redirect response as a controller error.
   
    - parameter state:    The state from the controller throwing the error.
    - parameter path:     The path that we should redirect to. If this is not
                          provided, this will redirect to the root path.
    - parameter message:  The message to include in the flash messages.
    - returns:            The error you can throw to trigger this redirect.
    */
  public static func redirectResponse(state: ControllerState, path: String? = nil, message: String? = nil) -> ControllerError {
    var response = state.response
    var session = state.request.session
    response.responseCode = .SeeOther
    response.headers["Location"] = path ?? "/"
    session.setFlash("error", message)
    session.storeInCookies(&response.cookies)
    return ControllerError.UnprocessableRequest(response)
  }
}