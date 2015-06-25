import Foundation

/**
  This class provides a template for generating a response to a request.

  This has been deprecated in favor of the TemplateType protocol.
  */
@available(*, deprecated, message="Use TemplateType instead") public class Template: TemplateType {
  /** The internal state of the template. */
  public var state: TemplateState
  
  /** The buffer that we use to build our result. */
  public var buffer: String { return contents }
  
  /**
    This method initializes a template.

    - parameter controller:    The controller that is rendering the template.
    */
  public init(controller: ControllerType) {
    self.state = TemplateState(controller)
  }
  
  //MARK: - Body
  
  /**
    This method runs the body.

    This implementation does nothing. Subclasses must override this to provide
    the real rendered content.

    The content should be added to the buffer instance variable.
    */
  public func body() {
    
  }
}