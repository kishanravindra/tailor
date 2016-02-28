import Tailor
import TailorTesting
import XCTest

final class TestTemplateForm: XCTestCase, TailorTestable {
  var form: TemplateForm!
  var template : TemplateType { return form.template }
  var controller: ControllerType!
  
  struct TestTemplate: TemplateType {
    var state: TemplateState
    func body() {}
  }
  
  struct TestController: ControllerType {
    var state: ControllerState
    static func defineRoutes(routes: RouteSet) {
      
    }
    
    init(state: ControllerState) {
      self.state = state
    }
  }
  
  var allTests: [(String, () throws -> Void)] { return [
    ("testInputCallsInputBuilder", testInputCallsInputBuilder),
    ("testDefaultInputBuilderAddsLabelAndTextField", testDefaultInputBuilderAddsLabelAndTextField),
    ("testDefaultInputBuilderWithMultiWordNamesAddsLabelAndTextField", testDefaultInputBuilderWithMultiWordNamesAddsLabelAndTextField),
    ("testFormWithNeitherNameNorTypeHasNameModel", testFormWithNeitherNameNorTypeHasNameModel),
    ("testFormWithCsrfKeyPutsKeyInTemplate", testFormWithCsrfKeyPutsKeyInTemplate),
    ("testDropdownBuildsSelectTag", testDropdownBuildsSelectTag),
    ("testDropdownWithSelectedValueSelectsValue", testDropdownWithSelectedValueSelectsValue),
    ("testDropdownWithSingleValueListBuildsSelectTag", testDropdownWithSingleValueListBuildsSelectTag),
    ("testRadioButtonsBuildsInputTags", testRadioButtonsBuildsInputTags),
    ("testRadioButtonWithSelectedValueSelectsValue", testRadioButtonWithSelectedValueSelectsValue),
    ("testFormTemplateHasEmptyBody", testFormTemplateHasEmptyBody),
  ]}

  func setUp() {
    setUpTestCase()
    controller = TestController(state: ControllerState(request: Request(), response: Response(), actionName: "index", callback: {response in }))
    form = TemplateForm(controller: controller, name: "hat")
  }
  
  func testInputCallsInputBuilder() {
    let expectation = expectationWithDescription("block called")
    let errors: [ValidationError] = [
      ValidationError(modelName: "hat", key: "color", message: "tooShort"),
      ValidationError(modelName: "hat", key: "brimSize", message: "tooLow"),
      ValidationError(modelName: "hat", key: "color", message: "blank")
    ]
    form = TemplateForm(controller: controller, name: "test_model", validationErrors: errors, inputBuilder: {
      form, key, value, attributes, errors in
      expectation.fulfill()
      self.assert(form.name, equals: self.form.name, message: "passes the form builder to the input")
      self.assert(key, equals: "color", message: "passes the key to the input")
      self.assert(value, equals: "red", message: "passes the value to the builder")
      self.assert(attributes, equals: ["length": "10"], message: "passes the attributes to the builder")
      self.assert(errors, equals: [
        ValidationError(modelName: "hat", key: "color", message: "tooShort"),
        ValidationError(modelName: "hat", key: "color", message: "blank")
        ])
      return form.template
    })
    form.input("color", "red", attributes: ["length": "10"])
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testDefaultInputBuilderAddsLabelAndTextField() {
    form.input("color", "black", attributes: ["maxLength": "20"])
    assert(template.contents, equals: "<div><label>color</label><input maxLength=\"20\" name=\"hat[color]\" value=\"black\"></input></div>", message: "puts label and input in template")
    class TopHat: ModelType {
      static func modelName() -> String {
        return "top_hat"
      }
    }
  }
  
  func testDefaultInputBuilderWithMultiWordNamesAddsLabelAndTextField() {
    form = TemplateForm(controller: controller, type: TopHat.self)
    form.input("brimSize", "12")
    assert(template.contents, equals: "<div><label>brim size</label><input name=\"topHat[brimSize]\" value=\"12\"></input></div>", message: "puts label and input in template")
  }
  
  func testFormWithNeitherNameNorTypeHasNameModel() {
    form = TemplateForm(controller: controller)
    assert(form.name, equals: "model")
  }
  
  func testFormWithCsrfKeyPutsKeyInTemplate() {
    
    let controller = TestController(state: ControllerState(request: Request(sessionData: ["csrfKey": "myKey"]), response: Response(), actionName: "index", callback: {response in }))
    form = TemplateForm(controller: controller)
    assert(form.template.contents, equals: "<input name=\"_csrfKey\" type=\"hidden\" value=\"myKey\"></input>")
  }

  
  func testDropdownBuildsSelectTag() {
    form.dropdown("brimSize", values: [("", "None"), ("10", "Ten"), ("20", "Twenty")], attributes: ["multiple": "multiple"])
    assert(template.contents, equals: "<select multiple=\"multiple\" name=\"hat[brimSize]\"><option value=\"\">None</option><option value=\"10\">Ten</option><option value=\"20\">Twenty</option></select>")
  }
  
  func testDropdownWithSelectedValueSelectsValue() {
    form.dropdown("brimSize", value: "10", values: [("", "None"), ("10", "Ten"), ("20", "Twenty")])
    assert(template.contents, equals: "<select name=\"hat[brimSize]\"><option value=\"\">None</option><option selected=\"selected\" value=\"10\">Ten</option><option value=\"20\">Twenty</option></select>")
  }
  
  func testDropdownWithSingleValueListBuildsSelectTag() {
    form.dropdown("brimSize", values: ["", "10", "20"])
    assert(template.contents, equals: "<select name=\"hat[brimSize]\"><option value=\"\"></option><option value=\"10\">10</option><option value=\"20\">20</option></select>")
  }
  
  func testRadioButtonsBuildsInputTags() {
    form.radioButtons("brimSize", values: ["10", "20"], attributes: ["extra-data": "hello"])
    assert(template.contents, equals: "<div><label>10</label><input extra-data=\"hello\" name=\"hat[brimSize]\" type=\"radio\" value=\"10\"></input></div><div><label>20</label><input extra-data=\"hello\" name=\"hat[brimSize]\" type=\"radio\" value=\"20\"></input></div>")
  }
  
  func testRadioButtonWithSelectedValueSelectsValue() {
    form.radioButtons("brimSize", value: "10", values: ["10", "20"], attributes: ["extra-data": "hello"])
    assert(template.contents, equals: "<div><label>10</label><input checked=\"checked\" extra-data=\"hello\" name=\"hat[brimSize]\" type=\"radio\" value=\"10\"></input></div><div><label>20</label><input extra-data=\"hello\" name=\"hat[brimSize]\" type=\"radio\" value=\"20\"></input></div>")
  }
  
  func testFormTemplateHasEmptyBody() {
    form.template.generate()
    assert(form.template.contents.isEmpty)
  }
}
