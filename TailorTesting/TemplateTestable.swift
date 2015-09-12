import Tailor

/**
  This protocol describes a test for a template.
  */
public protocol TemplateTestable: class, TailorTestable {
  /** The type of controller for the template that we are testing. */
  typealias TestedControllerType: ControllerType
  
  /** The type of template that we are testing. */
  typealias TestedTemplateType: TemplateType
  
  /** The controller that we are testing. */
  var controller: TestedControllerType { get set }
  
  /** The template that we are testing. */
  var template: TestedTemplateType { get }
}

extension TemplateTestable {
  //MARK: - Template Information
  
  /**
    The state of the template after rendering.
    
    Note: This will re-render the template on every call, so if you are going
    to test the template multiple times in one call, you should cache the
    result.
    */
  public var renderedState: TemplateState {
    var template = self.template
    template.generate()
    return template.state
  }
  
  /**
    The contents of the template after rendering.
    
    Note: This will re-render the template on every call, so if you are going
    to test the template multiple times in one call, you should cache the
    result.
    */
  public var contents: String { return renderedState.contents }
  
  
  /**
    This method builds the controller for the template.
    
    - parameter type:         The type of controller that will be rendering the
                              template.
    - parameter actionName:   The name of the  action on the controller that is
                              being called.
    - parameter user:         The user who is signed in to the controller.
    - parameter parameters:   The request parameters
    */
  public func setUpController(actionName: String = "index", user: UserType! = nil, parameters: [String:String] = [:]) {
    
    var request = Request(parameters: parameters)
    if user != nil {
      request = Request(sessionData: ["userId": String(user.id ?? 0)])
    }
    controller = TestedControllerType.init(request: request, response: Response(), actionName: actionName, callback: {_ in})
  }
}