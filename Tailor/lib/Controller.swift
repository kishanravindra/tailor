/**
  This class is the base class for controllers that route requests.
  */
class Controller {
  /** The actions that the controller provides. */
  var actions: [String:Server.RequestHandler] = [:]
  
  /** A name used for the controller in debugging. */
  var name = "Controller"
}