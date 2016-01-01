@testable import ___PROJECTNAME___
import Tailor
import TailorTesting
import XCTest

class ___FILEBASENAME___ : XCTestCase, TemplateTestable {
  /**
    A stock controller for the template to refer to. You should replace this
    with a custom controller that will render the template in practice.
    */
  var controller = EmptyController()
  
  /**
    The template that you are testing.
    You'll need to replace the type with your real controller type, and you may
    also need to change the initialization params.
    */
  var template: ___FILEBASENAME___ {
    return .init(controller: controller)
  }
  
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
}