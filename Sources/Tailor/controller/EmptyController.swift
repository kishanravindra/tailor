/**
  This struct provides a controller that does not do any rendering or handle any
  actions.

  This can be useful when rendering templates outside the context of a
  controller, like in an email from a background job.
  */
public struct EmptyController: ControllerType {
  /** The state of the controller. */
  public let state: ControllerState
  
  /** The name of the controller. */
  public static let name = "EmptyController"
  
  /** An empty layout */
  public static let layout = EmptyLayout.self
  
  /**
    This method defines the routes for this controller.

    This defines no routes, since the controller does not have any actions. We
    need this for compliance with the ControllerType protocol.
  
    - parameter routes:   The route set that will contain the routes.
    */
  public static func defineRoutes(routes: RouteSet) {}
  
  /**
    This initializer creates the controller.

    - parameter state:    The internal state for the controller.
    */
  public init(state: ControllerState) {
    self.state = state
  }
  
  /**
    This method creates a controller with a dummy request, action, and callback.
    */
  public init() {
    self.init(state: ControllerState(request: Request(), response: Response(), actionName: "empty", callback: {
      _ in
    }))
  }

  /**
    This type provides an empty template for testing purposes.
    */
  public struct EmptyTemplate: TemplateType {
    /** The internal state of the template. */
    public var state: TemplateState

    /**
      This initializer creates a template.

      - parameter controller: The controller that is rendering the template.
      */
    public init(controller: EmptyController) {
      self.state = TemplateState(controller)
    }

    /**
      This method adds the body of the template.

      This will do nothing, because the template is empty.
      */
    public mutating func body() {}
  }
}