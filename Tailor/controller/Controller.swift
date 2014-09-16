import Foundation

/**
  This class is the base class for controllers that route requests.
  */
class Controller {
  /** A name used for the controller in routing. */
  var name: String { get { return NSStringFromClass(self.dynamicType) } }
  
  /** The request that we are currently handling. */
  let request: Request
  
  /** The callback for the current request's response. */
  let callback: Server.ResponseCallback
  
  /** The action that we are executing. */
  let action: String
  
  /**
    This method creates a controller for handling a request.

    :param: request   The request that we are processing
    :param: action    The action that we are executing.
    :param: callback  The callback to give the response to.
    */
  required init(request: Request, action: String, callback: Server.ResponseCallback) {
    self.request = request
    self.action = action
    self.callback = callback
  }
  
  /**
    The template that provides the layout for the views in this controller.

    This template's body will be called with a different template as the first
    argument. At some point in its body, this should call that other template's
    body.
    */
  var layout = Template { $0.body($0,$1) }
  
  //MARK - Responses
  
  /**
    This method executes our current action.
  
    This implementation renders a 404 response. Sublcasses should map this to
    real implementations.
    */
  func respond() {
    self.render404()
  }
  
  /**
    This method generates a response with a template.
  
    :param: template    The template to use for the request.
    :param: action      The name of the action we are responding to.
    :param: parameters  The parameters to pass to the template.
    */
  func respondWith(template: Template, parameters: [String:Any] = [:]) {
    template.controller = self
    template.buffer.setString("")
    self.layout.body(template, parameters)
    var response = Response()
    response.cookies = request.cookies
    response.appendString(template.buffer)
    self.callback(response)
  }
  
  /**
    This method generates a response with a redirect to a different path.
  
    :param: path      The path to redirect to.
    */
  func redirectTo(path: String) {
    var response = Response()
    response.cookies = request.cookies
    response.code = 302
    response.headers["Location"] = path
    self.callback(response)
  }
  
  /**
    This method generates a response with a 404 page.
    */
  func render404() {
    var response = Response()
    response.cookies = request.cookies
    response.code = 404
    response.appendString("Page Not Found")
    self.callback(response)
  }
}