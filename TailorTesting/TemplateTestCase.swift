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
  public var controller: Controller!
  
  /**
    The template that we are rendering.
  
    You should set this in your setUp method.
    */
  public var template: Template!
  
  /**
    The contents of the template after rendering.
    */
  public var contents: String { get { return (template?.buffer as? String) ?? "" } }
  
  /**
    This method builds the controller for the template.

    :param: type          The type of controller that will be rendering the 
                          template.
    :param: actionName    The name of the  action on the controller that is
                          being called.
    :param: user          The user who is signed in to the controller.
    */
  public func setUpController(type: Controller.Type, actionName: String = "index", user: User! = nil) {
    
    var request = Request()
    if user != nil {
      request = Request(sessionData: ["userId": String(user.id ?? 0)])
    }
    controller = type.init(request: request, actionName: actionName, callback: {_ in})
  }
  
  /**
    This method checks that this template rendered another template in its body.
  
    This variant will break as soon as it finds a matching template. If there is
    anything other than the template type you need to check, you can add those
    assertions in the block you provide to this method.
    
    :param: templateType      The type of template that are looking for.
    :param: message           The message to show if the assertion fails.
    :param: file              The file that the assertion is coming from. You
                              should generally omit this, since it will be
                              provided automatically.
    :param: line              The line that the assertion is coming from. You
                              should generally omit this, since it will be
                              provided automatically.
    :param: templateChecker   A block that can perform additional checks on the
                              template.
    */
  public func assertRenderedTemplate<TemplateType: Template>(templateType: TemplateType.Type, message: String = "", file: String = __FILE__, line: UInt = __LINE__, _ templateChecker: (TemplateType)->() = {_ in}) {
    var found = false
    for otherTemplate in template.renderedTemplates {
      if let castTemplate = otherTemplate as? TemplateType {
        templateChecker(castTemplate)
        found = true
        break
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
  
  /**
    This method checks that this template rendered another template in its body.
  
    This variant allows you to check in the block whether the template's
    information matches some specific details, and ignore it if it does not.
    This will allow you to call this method multiple times for the same template
    type but different information in the block, and confirm that we rendered
    the template at least once with details matching what the block is looking
    for.
  
    :param: templateType      The type of template that are looking for.
    :param: message           The message to show if the assertion fails.
    :param: file              The file that the assertion is coming from. You
                              should generally omit this, since it will be
                              provided automatically.
    :param: line              The line that the assertion is coming from. You
                              should generally omit this, since it will be
                              provided automatically.
    :param: templateChecker   A block that determines if the template is the one
                              we are looking for.
  */
  public func assertRenderedTemplate<TemplateType: Template>(templateType: TemplateType.Type, message: String = "", file: String = __FILE__, line: UInt = __LINE__, _ templateChecker: (TemplateType)->(Bool)) {
    var found = false
    for otherTemplate in template.renderedTemplates {
      if let castTemplate = otherTemplate as? TemplateType {
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