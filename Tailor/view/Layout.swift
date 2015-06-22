/**
  This class provides a template that serves as a layout.

  A layout takes in another template and renders the overall page structure
  with the other template's body within it.
  */
public class Layout: Template {
  /** The template that provides the page contents. */
  public let template: Template
  
  /**
    This method initializes a layout.

    - parameter controller:  The controller that is rendering the template.
    - parameter template:    The template containing the page body.
    */
  public required init(controller: ControllerType, template: Template) {
    self.template = template ?? Template(controller: controller)
    super.init(controller: controller)
  }

  /**
    This method initializees a layout with no template.
  
    A layout with no template would not be very useful, but we provide this for
    compatibility with the general template initializers.

    - parameter controller:  The controller that is rendering the template.
    */
  public override convenience init(controller: ControllerType) {
    self.init(controller: controller, template: Template(controller: controller))
  }
  
  /**
    This method adds the contents for this layout to its body.

    This implementation just renders the template that it is wrapping around.
    Subclasses should override this to add content before or after that template
    body.
    */
  public override func body() {
    self.renderTemplate(self.template)
  }
}
