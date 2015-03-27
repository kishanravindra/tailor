import XCTest
import Tailor
import TailorTesting

class FormBuilderTests: TailorTestCase {
  var template : Template!
  let model = Hat()
  var builder : FormBuilder!
  
  override func setUp() {
    template = Template(controller: Controller())
    builder = FormBuilder(template: template, model: model)
  }
  
  func testDefaultNameIsModelName() {
    assert(builder.name, equals: "hat", message: "uses the model name as the name in the form")
  }
  
  func testFormPutsFormTagInTemplate() {
    builder.form("/test/path", with: {
    })
    assert(template.buffer, equals: "<form action=\"/test/path\" method=\"POST\"></form>")
  }
  
  func testFormUsesCustomAction() {
    builder.form("/test/path", "GET", with: {
      
    })
    assert(template.buffer, equals: "<form action=\"/test/path\" method=\"GET\"></form>")
  }
  
  func testFormAddsContentInBlock() {
    builder.form("/test/path", with: {
      self.template.text("Form Contents", localize: false)
    })
    assert(template.buffer, equals: "<form action=\"/test/path\" method=\"POST\">Form Contents</form>")
  }
  
  func testInputCallsInputBuilder() {
    let expectation = expectationWithDescription("block called")
    model.color = "red"
    model.errors.add("color", "too bright")
    builder = FormBuilder(template: template, model: model, name: "test_model", inputBuilder: {
      form, key, value, attributes, errors in
      expectation.fulfill()
      let messages = errors.map { $0.message }
      self.assert(form.name, equals: self.builder.name, message: "passes the form builder to the input")
      self.assert(key, equals: "color", message: "passes the key to the input")
      self.assert(value, equals: "red", message: "passes the value to the builder")
      self.assert(attributes, equals: ["length": "10"], message: "passes the attributes to the builder")
      self.assert(messages, equals: ["too bright"], message: "passes the model object's errors to the builder")
    })
    builder.input("color", attributes: ["length": "10"])
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testInputWithNumericValueConvertsToString() {
    let expectation = expectationWithDescription("block called")
    model.brimSize = 10
    builder = FormBuilder(template: template, model: model, inputBuilder: {
      _, _, value, _, _ in
      expectation.fulfill()
      self.assert(value, equals: "10", message: "passes the string value to the input builder")
    })
    builder.input("brimSize")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testInputWithNilValuePassesBlankString() {
    let expectation = expectationWithDescription("block called")
    builder = FormBuilder(template: template, model: model, inputBuilder: {
      _, _, value, _, _ in
      expectation.fulfill()
      self.assert(value, equals: "", message: "passes a blank value to the input builder")
    })
    builder.input("color")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testDefaultInputBuilderAddsLabelAndTextField() {
    model.color = "black"
    builder.input("color", attributes: ["maxLength": "20"])
    assert(template.buffer, equals: "<div><label>color</label><input maxLength=\"20\" name=\"hat[color]\" value=\"black\"></input></div>", message: "puts label and input in template")
  }
}
