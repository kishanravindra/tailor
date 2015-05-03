import XCTest
import Tailor
import TailorTesting

class FormBuilderTests: TailorTestCase {
  var template : Template!
  var builder : FormBuilder!
  
  override func setUp() {
    super.setUp()
    template = Template(controller: Controller())
    builder = FormBuilder(template: template, name: "hat")
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
    let errors: [ValidationError] = [
      ValidationError(modelName: "hat", key: "color", message: "tooShort"),
      ValidationError(modelName: "hat", key: "brimSize", message: "tooLow"),
      ValidationError(modelName: "hat", key: "color", message: "blank")
    ]
    builder = FormBuilder(template: template, name: "test_model", validationErrors: errors, inputBuilder: {
      form, key, value, attributes, errors in
      expectation.fulfill()
      self.assert(form.name, equals: self.builder.name, message: "passes the form builder to the input")
      self.assert(key, equals: "color", message: "passes the key to the input")
      self.assert(value, equals: "red", message: "passes the value to the builder")
      self.assert(attributes, equals: ["length": "10"], message: "passes the attributes to the builder")
      self.assert(errors, equals: [
        ValidationError(modelName: "hat", key: "color", message: "tooShort"),
        ValidationError(modelName: "hat", key: "color", message: "blank")
      ])
    })
    builder.input("color", "red", attributes: ["length": "10"])
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testDefaultInputBuilderAddsLabelAndTextField() {
    builder.input("color", "black", attributes: ["maxLength": "20"])
    assert(template.buffer, equals: "<div><label>color</label><input maxLength=\"20\" name=\"hat[color]\" value=\"black\"></input></div>", message: "puts label and input in template")
  }
  
  func testDropdownBuildsSelectTag() {
    builder.dropdown("brimSize", values: [("", "None"), ("10", "Ten"), ("20", "Twenty")], attributes: ["multiple": "multiple"])
    assert(template.buffer, equals: "<select multiple=\"multiple\" name=\"hat[brimSize]\"><option value=\"\">None</option><option value=\"10\">Ten</option><option value=\"20\">Twenty</option></select>")
  }
  
  func testDropdownWithSelectedValueSelectsValue() {
    builder.dropdown("brimSize", value: "10", values: [("", "None"), ("10", "Ten"), ("20", "Twenty")])
    assert(template.buffer, equals: "<select name=\"hat[brimSize]\"><option value=\"\">None</option><option selected=\"selected\" value=\"10\">Ten</option><option value=\"20\">Twenty</option></select>")
  }
  
  func testDropdownWithSingleValueListBuildsSelectTag() {
    builder.dropdown("brimSize", values: ["", "10", "20"])
    assert(template.buffer, equals: "<select name=\"hat[brimSize]\"><option value=\"\"></option><option value=\"10\">10</option><option value=\"20\">20</option></select>")
  }
  
  func testRadioButtonsBuildsInputTags() {
    builder.radioButtons("brimSize", values: ["10", "20"], attributes: ["extra-data": "hello"])
    assert(template.buffer, equals: "<div><label>10</label><input extra-data=\"hello\" name=\"hat[brimSize]\" type=\"radio\" value=\"10\"></input></div><div><label>20</label><input extra-data=\"hello\" name=\"hat[brimSize]\" type=\"radio\" value=\"20\"></input></div>")
  }
  
  func testRadioButtonWithSelectedValueSelectsValue() {
    builder.radioButtons("brimSize", value: "10", values: ["10", "20"], attributes: ["extra-data": "hello"])
    assert(template.buffer, equals: "<div><label>10</label><input checked=\"checked\" extra-data=\"hello\" name=\"hat[brimSize]\" type=\"radio\" value=\"10\"></input></div><div><label>20</label><input extra-data=\"hello\" name=\"hat[brimSize]\" type=\"radio\" value=\"20\"></input></div>")
  }
}
