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

    :param: controller  The controller that is rendering the template.
    :param: template    The template containing the page body.
    */
  public required init(controller: Controller, template: Template) {
    self.template = template ?? Template(controller: controller)
    super.init(controller: controller)
  }

  /**
    This method initializees a layout with no template.
  
    A layout with no template would not be very useful, but we provide this for
    compatibility with the general template initializers.

    :param: controller  The controller that is rendering the template.
    */
  public override convenience init(controller: Controller) {
    self.init(controller: controller, template: Template(controller: controller))
  }
  
  public override func body() {
    self.renderTemplate(self.template)
  }
}
