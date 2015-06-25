/**
  This class is the base class for controllers that route requests.

  This class has been deprecated. You should use the ControllerType protocol
  instead.
  */
@available(*, deprecated, message="Use the ControllerType protocol instead") public class Controller: ControllerType {
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
  
  /** The action that we are executing. */
  public private(set) var action: Action! = nil
  
  /** The state of the controller. */
  public var state: ControllerState
  
  /**
  The actions that this controller supports.
  
  This implementation provides no actions. Subclasses must override this with
  their actions.
  */
  public class var actions: [Action] { return [] }
  
  public class func defineRoutes(inout routes: RouteSet) {
  }
  
  /**
  The templates that this controller has rendered in the course of responding
  to its action.
  */
  public var renderedTemplates: [Template] = []
  
  /** Whether we have responded to our request. */
  public var responded = false
  
  /**
  This method creates a controller for handling a request.
  
  - parameter request:       The request that we are processing
  - parameter actionName:    The name of the action that we are executing.
  - parameter callback:      The callback to give the response to.
  */
  public required convenience init(request: Request, actionName: String, callback: Connection.ResponseCallback) {
    self.init(state: ControllerState(request: request, actionName: actionName, callback: callback))
  }
  
  public required init(state: ControllerState) {
    self.state = state
  }
  
  /**
  This method takes in an action body using a specialized controller
  type and returns a more general one that will take any controller type.
  
  When the resulting function is called, this will perform an safe cast from
  the general controller to the specialized type. If the case fails, this will
  return a block that always renders a 404 page.
  
  - parameter block:    The block with the specialized controller type.
  - returns:            The block with the general controller type.
  */
  public class func wrap<SpecificType: Controller>(block: (SpecificType)->()->())->(Controller)->()->() {
    return {
      (controller) in
      if let controller = controller as? SpecificType {
        return block(controller)
      }
      else {
        return { controller.render404Action() }
      }
    }
  }
  
  public func render404Action() {
    
    if self.responded {
      NSLog("Error: Controller %@ attempted to respond twice. Subsequent responses will be ignored.", self.dynamicType.name)
      return
    }
    var response = Response()
    response.code = 404
    response.appendString("Page Not Found")
    response.cookies = request.cookies
    session.storeInCookies(&response.cookies)
    self.responded = true
    self.callback(response)
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
  public class func wrap<SpecificType: Controller>(block: (SpecificType)->()->(Bool))->(Controller)->()->(Bool) {
    return {
      (controller) in
      if let controller = controller as? SpecificType {
        return block(controller)
      }
      else {
        return { controller.render404Action(); return false }
      }
    }
  }
  
  public class var layout: Layout.Type { return Layout.self }
  
  //MARK: - Responses
  
  /**
  This method calls the controller's action and generates a response.
  */
  public final func respond() {
    self.action.run(self)
  }
  
}