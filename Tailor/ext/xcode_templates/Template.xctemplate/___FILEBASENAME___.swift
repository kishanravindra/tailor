import Tailor

struct ___FILEBASENAME___ : TemplateType {
  /** The internal state of the template. */
  var state: TemplateState
    
  /**
  This method initializes the template.
  
  - parameter controller:    The controller that is rendering the page.
  */
  init(controller: ControllerType) {
    self.hats = hats
    self.state = TemplateState(controller)
  }
    
  mutating func body() {
  }
}