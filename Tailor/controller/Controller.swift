import Foundation

/**
  This class is the base class for controllers that route requests.
  */
public class Controller {
  /** A name used for the controller in routing. */
  public var name: String { get { return NSStringFromClass(self.dynamicType) } }
  
  /** The request that we are currently handling. */
  public let request: Request
  
  /** The callback for the current request's response. */
  public let callback: Server.ResponseCallback
  
  /** The action that we are executing. */
  public let action: String
  
  /** The session information for this request. */
  public let session: Session
  
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
    :param: action      The name of the action we are responding to.
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
}