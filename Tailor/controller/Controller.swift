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
  typealias Filter = (
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
  var filters: [Filter] = []
  
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
    self.localization = Localization(locale: "en")
    
    if let userId = self.session["userId"]?.toInt() {
      self.currentUser = User.find(userId) as? User
    }
  }
  
  /**
    The template that provides the layout for the views in this controller.

    This template's body will be called with a different template as the first
    argument. At some point in its body, this should call that other template's
    body.
    */
  public var layout = Template { $0.body($0,$1) }
  
  //MARK - Responses
  
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
    session["_flash_notice"] = nil
    session.storeInCookies(response.cookies)
    self.responded = true
    self.callback(response)
  }
  
  /**
    This method generates a response with a template.
  
    :param: template    The template to use for the request.
    :param: parameters  The parameters to pass to the template.
    */
  public func respondWith(template: Template, parameters: [String:Any] = [:]) {
    template.controller = self
    template.buffer.setString("")
    self.layout.body(template, parameters)
    self.generateResponse {
      (inout response : Response) in
      response.appendString(template.buffer)
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
    This method gets the URL for a route.
  
    It defaults to the current controller and action. It will also substitute
    any of the current request's parameters into the new URL, if they are part
    of that URL's path.
  
    :param: controllerName  The controller to link to. This will default to the
                            current controller.
    :param: action          The action to link to.
    :param: parameters      Additional parameters for the path.
    :returns:               The path
  */
  public func urlFor(controllerName: String? = nil, action: String? = nil, parameters: [String:String] = [:]) -> String? {
    var url = SHARED_APPLICATION.routeSet.urlFor(
      controllerName ?? self.dynamicType.name(),
      action: action ?? self.action,
      parameters: parameters
    )
    if url != nil {
      for (key,value) in self.request.requestParameters {
        url = url?.stringByReplacingOccurrencesOfString(":\(key)", withString: value)
      }
    }
    return url
  }

  /**
    This method generates a response with a redirect to a generated URL.

    :param: controllerName  The controller to link to. This will default to the
                            current controller.
    :param: action          The action to link to.
    :param: parameters      Additional parameters for the path.
    */
  public func redirectTo(controllerName: String? = nil, action: String? = nil, parameters: [String:String] = [:]) {
    let url = self.urlFor(controllerName: controllerName, action: action, parameters: parameters) ?? "/"
    self.redirectTo(url)
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
  public func addFilter(filter: ()->Bool, only: [String] = [], except: [String] = []) {
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
    This method localizes text.

    :param: key     The key for the localized text
    :param: locale  The locale that the localized text should be in. If this is
                    not provided, it will use the locale from the default
                    localization on this controller.
    :returns:       The localized text
    */
  public func localize(key: String, locale: String? = nil) -> String? {
    if locale != nil {
      return self.localization.dynamicType.init(locale: locale!).fetch(key)
    }
    else {
      return self.localization.fetch(key)
    }
  }
}