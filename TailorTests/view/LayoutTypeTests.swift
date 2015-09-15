import TailorTesting
import Tailor
import XCTest

class LayoutTypeTests: XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
  func testEmptyLayoutRendersInnerTemplate() {
    struct TestTemplate: TemplateType {
      var state: TemplateState
      mutating func body() {
        self.text("Hello")
      }
    }
    struct TestController: ControllerType {
      var state: ControllerState
      static func defineRoutes(routes: RouteSet) {}
    }
    
    let controller = TestController(state: ControllerState(request: Request(), response: Response(), actionName: "index", callback: {response in}))
    let template = TestTemplate(state: TemplateState(controller))
    var layout = EmptyLayout(controller: controller, template: template)
    layout.generate()
    assert(layout.contents, equals: "Hello")
  }
}
