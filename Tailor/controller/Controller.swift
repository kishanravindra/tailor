import Foundation

/**
  This class is the base class for controllers that route requests.
  */
public class Controller {
  /**
    This type represents a filter that can be run before processing an action.
  
    :param: filter          The function to run as the filter. This should
                            return true if the filter passed. If the filter
                            fails, this must either render or redirect.
    :param: includedActions The actions that this filter should be run for.
                            If this is empty, it will be run for all actions.
    :param: excludedActions The actions that this filter should not be run for.
    */
  public typealias Filter = (
    filter: ()->Bool,
    includedActions: [String],
    excludedActions: [String]
  )
  
  /** The request that we are currently handling. */
  public let request: Request
  
  /** The callback for the current request's response. */
  public let callback: Server.ResponseCallback
  
  /** The action that we are executing. */
  public let action: String
  
  /** The session information for this request. */
  public let session: Session
  
  /** The user that is accessing the system. */
  public private(set) var currentUser : User?
  
  /** The localization that provides content for this controller. */
  public var localization: Localization
  
  /** The filters that this controller runs. */
  public private(set) var filters: [Filter] = []
  
  /**
    The templates that this controller has rendered in the course of responding
    to its action.
    */
  public private(set) var renderedTemplates: [Template] = []
  
  /** Whether we have responded to our request. */
  var responded = false
  
  /** The name used to identify the controller in routing. */
  public class func name() -> String {
    return NSStringFromClass(self)
  }
  
  /**
    This method creates a controller for handling a request.

    :param: request   The request that we are processing
    :param: action    The action that we are executing.
    :param: callback  The callback to give the response to.
    */
  public required init(request: Request, action: String, callback: Server.ResponseCallback) {
    self.request = request
    self.action = action
    self.callback = callback
    self.session = Session(request: request)
    self.localization = Application.sharedApplication().localization("en")
    
    if let userId = self.session["userId"]?.toInt() {
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
    This method executes our current action.
  
    This implementation renders a 404 response. Sublcasses should map this to
    real implementations.
    */
  public func respond() {
    if !runFilters() { return }
    var klass : AnyClass! = object_getClass(self)
    let method = class_getInstanceMethod(klass, Selector("\(self.action)Action"))
    
    if method != nil {
      tailorInvokeFunction(self, method)
    }
    else {
      render404()
    }
  }
  
  /**
    This method generates a response object and passes it to a block.

    This will set the cookies on the response before giving it to the block, 
    and after the block is done it will give the response to the controller's
    handler.
    */
  public func generateResponse(contents: (inout Response)->()) {
    if self.responded {
      NSLog("Error: Controller attempted to respond twice for %@:%@. Subsequent responses will be ignored.", self.dynamicType.name(), self.action)
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
  
    :param: template    The template to use for the request.
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
    This method takes an object and returns a version of it that can be safely
    serialized into JSON.

    Strings, Numbers, Ints, and Bools will be passed unmodified. Dates will be
    formatted using the database format.
  
    Records will be converted into a JSON-friendly format using the
    toPropertyList method.

    Arrays will be have their items filtered by the same logic. Dictionaries
    whose keys are strings will have their values filtered by the same logic.
    Any value that cannot be converted will be omitted.
  
    :param: value   The value to convert
    :returns:       The converted value.
    */
  public class func filterForJson(value: AnyObject) -> AnyObject? {
    switch(value) {
    case let s as String:
      return s
    case let n as NSNumber:
      return n
    case let i as Int:
      return i
    case let b as Bool:
      return b
    case let d as NSDate:
      return d.format("db")
    case let d as [String:AnyObject]:
      var results = [String:AnyObject]()
      for (key,subValue) in d {
        if let filtered: AnyObject = self.filterForJson(subValue) {
          results[key] = filtered
        }
      }
      return results
    case let a as Array<AnyObject>:
      return removeNils(a.map { self.filterForJson($0) })
    case let r as Record:
      return self.filterForJson(r.toPropertyList())
    default:
      return nil
    }
  }
  
  /**
    This method responds with a JSON representation of an object.

    :param: data    The data to respond with.
    */
  public func respondWithJson(data: AnyObject) {
    if let filtered: AnyObject = self.dynamicType.filterForJson(data) {
      if let jsonData = NSJSONSerialization.dataWithJSONObject(filtered, options: nil, error: nil) {
          self.generateResponse {
            response in
            response.code = 200
            response.appendData(jsonData)
          }
      }
      else {
        self.render404()
      }
    }
    else {
      self.render404()
    }
  }
  
  /**
    This method generates a response with a redirect to a different path.
  
    :param: path      The path to redirect to.
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
  
    :param: controllerName  The controller to link to. This will default to the
                            current controller.
    :param: action          The action to link to.
    :param: parameters      Additional parameters for the path.
    :param: domain          The domain to use for the URL. If this is omitted,
                            the result will just be the path part of the URL.
    :param: https           Whether the URL should be https or http. If the
                            domain is omitted, this is ignored.
    :returns:               The path
  */
  public func pathFor(controllerName: String? = nil, action: String? = nil, parameters: [String:String] = [:], domain: String? = nil, https: Bool = true) -> String? {
    var path = Application.sharedApplication().routeSet.pathFor(
      controllerName ?? self.dynamicType.name(),
      action: action ?? self.action,
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

    :param: controllerName  The controller to link to. This will default to the
                            current controller.
    :param: action          The action to link to.
    :param: parameters      Additional parameters for the path.
    */
  public func redirectTo(controllerName: String? = nil, action: String? = nil, parameters: [String:String] = [:]) {
    let path = self.pathFor(controllerName: controllerName, action: action, parameters: parameters) ?? "/"
    self.redirectTo(path)
  }
  
  /**
    This method generates a response with a redirect to a generated URL.
  
    This is a wrapper around the version that uses a controllerName. This
    version provides a more concise syntax when redirecting to other
    controllers.
  
    :param: controllerName  The controller to link to. This will default to the
            current controller.
    :param: action          The action to link to.
    :param: parameters      Additional parameters for the path.
  */
  public func redirectTo(controller: Controller.Type, action: String, parameters: [String:String] = [:]) {
    self.redirectTo(
      controllerName: controller.name(),
      action: action,
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
  
    :param: user    The user to sign in.
    */
  public func signIn(user: User) {
    self.currentUser = user
    self.session["userId"] = user.id.stringValue
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
    
    :param: emailAddress  The email address the user has provided.
    :param: password      The password the user has provided.
    :returns:             Whether we were able to authenticate the user.
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
  
  
  //MARK: - Filters
  
  /**
    This method adds a filter.
  
    :param: filter    The filter function.
    :param: only      The actions to run the filter for.
    :param: except    The actions not to run the filter for.
  */
  public func addFilter(only: [String] = [], except: [String] = [], filter: ()->Bool) {
    filters.append((filter, only, except))
  }
  
  /**
    This method runs all the filters set for this controller.
  
    If any of the filters returns false, this will return false immediately.
  
    :returns:   Whether all the filters passed.
  */
  public func runFilters() -> Bool {
    for (filter, only, except) in self.filters {
      if (only.isEmpty || contains(only, action)) && !contains(except, action) {
        if !filter() {
          return false
        }
      }
    }
    return true
  }
  
  //MARK: - Localization
  
  /**
    This method gets the prefix that is automatically prepended to keys sent for
    localization in this controller.

    This will only be added to keys that start with a dot.
    */
  public var localizationPrefix: String {
    return self.dynamicType.name().underscored() + "." + self.action
  }
  
  /**
    This method localizes text.

    :param: key     The key for the localized text
    :param: locale  The locale that the localized text should be in. If this is
                    not provided, it will use the locale from the default
                    localization on this controller.
    :returns:       The localized text
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

    :param: action    The name of the action to call.
    :param: request   The request to provide to the controller.
    :param: callback  The callback to call with the response.
    */
  public class func callAction(action: String, _ request: Request, callback: (Response,Controller)->()) {
    var controller: Controller!
    
    controller = self.init(
      request: request,
      action: action,
      callback: { response in callback(response, controller) }
    )
    controller.respond()
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
    if user != nil {
      sessionData["userId"] = user?.id?.stringValue ?? ""
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