import Tailor

/**
  This class provides helpers for building a test suite around a template.
  */
public class TemplateTestCase: TailorTestCase {
  //MARK: - Template Information

  /**
    The controller that is rendering the template.
  
    You should set this in your setUp method.
    */
  public var controller: ControllerType!
  
  /**
    The template that we are rendering.
  
    You should set this in your setUp method.
    */
  public var template: TemplateType!
  
  /**
    The contents of the template after rendering.
    */
  public var contents: String { get { return template.state.contents } }
  
  /**
    This method builds the controller for the template.

    - parameter type:         The type of controller that will be rendering the
                              template.
    - parameter actionName:   The name of the  action on the controller that is
                              being called.
    - parameter user:         The user who is signed in to the controller.
    - parameter parameters:   The request parameters
    */
  public func setUpController(type: ControllerType.Type, actionName: String = "index", user: UserType! = nil, parameters: [String:String] = [:]) {
    
    var request = Request(parameters: parameters)
    if user != nil {
      request = Request(sessionData: ["userId": String(user.id ?? 0)])
    }
    controller = type.init(request: request, response: Response(), actionName: actionName, callback: {_ in})
  }
  
  /**
    This method checks that this template rendered another template in its body.
  
    This variant will break as soon as it finds a matching template. If there is
    anything other than the template type you need to check, you can add those
    assertions in the block you provide to this method.
    
    - parameter templateType:     The type of template that are looking for.
    - parameter message:          The message to show if the assertion fails.
    - parameter file:             The file that the assertion is coming from.
                                  You should generally omit this, since it will
                                  be provided automatically.
    - parameter line:             The line that the assertion is coming from.
                                  You should generally omit this, since it will
                                  be provided automatically.
    - parameter templateChecker:  A block that can perform additional checks on
                                  the template.
    */
  public func assertRenderedTemplate<SpecificType: TemplateType>(templateType: SpecificType.Type, message: String = "", file: String = __FILE__, line: UInt = __LINE__, _ templateChecker: (SpecificType)->() = {_ in}) {
    self.assert(template, renderedTemplate: templateType, message: message, file: file, line: line, templateChecker)
  }
  
  /**
    This method checks that this template rendered another template in its body.
  
    This variant allows you to check in the block whether the template's
    information matches some specific details, and ignore it if it does not.
    This will allow you to call this method multiple times for the same template
    type but different information in the block, and confirm that we rendered
    the template at least once with details matching what the block is looking
    for.
  
    - parameter templateType:       The type of template that are looking for.
    - parameter message:            The message to show if the assertion fails.
    - parameter file:               The file that the assertion is coming from.
                                    You should generally omit this, since it
                                    will be provided automatically.
    - parameter line:               The line that the assertion is coming from.
                                    You should generally omit this, since it
                                    will be provided automatically.
    - parameter templateChecker:    A block that determines if the template is
                                    the one we are looking for.
  */
  public func assertRenderedTemplate<SpecificType: TemplateType>(templateType: SpecificType.Type, message: String = "", file: String = __FILE__, line: UInt = __LINE__, _ templateChecker: (SpecificType)->(Bool)) {
    var found = false
    for otherTemplate in template.state.renderedTemplates {
      if let castTemplate = otherTemplate as? SpecificType {
        if templateChecker(castTemplate) {
          found = true
          break
        }
      }
    }
    if(!found) {
      var failureMessage = "Did not render a matching template"
      if !message.isEmpty {
        failureMessage += " - \(message)"
      }
      self.recordFailureWithDescription(failureMessage, inFile: file, atLine: line, expected: true)
    }
  }
}