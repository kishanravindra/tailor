/**
  This protocol describes a template that serves as a layout.

  A layout takes in another template and renders the overall page structure
  with the other template's body within it.
  */
public protocol LayoutType: TemplateType {
  /** The template that provides the page contents. */
  var template: TemplateType { get }
  
  /**
    This method initializes a layout.
    
    - parameter controller:  The controller that is rendering the template.
    - parameter template:    The template containing the page body.
    */
  init(controller: ControllerType, template: TemplateType)
}

/**
  This struct provides a layout that renders its enclosed template with no
  extra content.
  */
public struct EmptyLayout: LayoutType {
  /** The internal state of the layout. */
  public var state: TemplateState
  
  /** The template that we are rendering. */
  public let template: TemplateType
  
  /**
    This method initializes a layout.
    
    - parameter controller:  The controller that is rendering the template.
    - parameter template:    The template containing the page body.
    */
  public init(controller: ControllerType, template: TemplateType) {
    self.state = TemplateState(controller)
    self.template = template
  }
  
  /**
    This method gets the body of the layout.

    This will just render the template with no enclosing content.
    */
  public mutating func body() {
    self.renderTemplate(template)
  }
}