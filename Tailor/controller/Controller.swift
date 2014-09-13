import Foundation

/**
  This class is the base class for controllers that route requests.
  */
class Controller : NSObject {
  /** The actions that the controller provides. */
  var actions: [String:Server.RequestHandler] = [:]
  
  /** A name used for the controller in debugging. */
  var name = "Controller"
  
  //MARK - Responses
  
  /**
    This method generates a response with a template.
  
    :param: template    The template to use for the request.
    :param: callback    The callback to give the response to.
    :param: parameters  The parameters to pass to the template.
    */
  func respondWith(template: Template, callback: Server.ResponseCallback, parameters: [String:Any] = [:]) {
    let body = template.generate(parameters)
    var response = Response()
    response.appendString(body)
    callback(response)
  }
}