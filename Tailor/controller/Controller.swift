import Foundation

/**
  This class is the base class for controllers that route requests.
  */
public class Controller {
  
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
    self.render404()
  }
  
  /**
    This method generates a response object and passes it to a block.

    This will set the cookies on the response before giving it to the block, 
    and after the block is done it will give the response to the controller's
    handler.
    */
  public func generateResponse(contents: (inout Response)->()) {
    var response = Response()
    response.cookies = request.cookies
    contents(&response)
    session["_flash_notice"] = nil
    session.storeInCookies(response.cookies)
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
    self.session["userId"] = String(user.id)
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