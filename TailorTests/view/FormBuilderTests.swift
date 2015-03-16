import XCTest
import Tailor

class FormBuilderTests: XCTestCase {
  var template : Template!
  let model = Hat()
  var builder : FormBuilder!
  
  override func setUp() {
    template = Template(controller: Controller())
    builder = FormBuilder(template: template, model: model)
  }
  
  func testDefaultNameIsModelName() {
    XCTAssertEqual(builder.name, "hat", "uses the model name as the name in the form")
  }
  
  func testFormPutsFormTagInTemplate() {
    builder.form("/test/path", with: {
    })
    XCTAssertEqual(template.buffer, "<form action=\"/test/path\" method=\"POST\"></form>")
  }
  
  func testFormUsesCustomAction() {
    builder.form("/test/path", "GET", with: {
      
    })
    XCTAssertEqual(template.buffer, "<form action=\"/test/path\" method=\"GET\"></form>")
  }
  
  func testFormAddsContentInBlock() {
    builder.form("/test/path", with: {
      self.template.text("Form Contents", localize: false)
    })
    XCTAssertEqual(template.buffer, "<form action=\"/test/path\" method=\"POST\">Form Contents</form>")
  }
  
  func testInputCallsInputBuilder() {
    let expectation = expectationWithDescription("block called")
    model.color = "red"
    model.errors.add("color", "too bright")
    builder = FormBuilder(template: template, model: model, name: "test_model", inputBuilder: {
      form, key, value, attributes, errors in
      expectation.fulfill()
      let messages = errors.map { $0.message }
      XCTAssertEqual(form.name, self.builder.name, "passes the form builder to the input")
      XCTAssertEqual(key, "color", "passes the key to the input")
      XCTAssertEqual(value, "red", "passes the value to the builder")
      XCTAssertEqual(attributes, ["length": "10"], "passes the attributes to the builder")
      XCTAssertEqual(messages, ["too bright"], "passes the model object's errors to the builder")
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
      XCTAssertEqual(value, "10", "passes the string value to the input builder")
    })
    builder.input("brimSize")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testInputWithNilValuePassesBlankString() {
    let expectation = expectationWithDescription("block called")
    builder = FormBuilder(template: template, model: model, inputBuilder: {
      _, _, value, _, _ in
      expectation.fulfill()
      XCTAssertEqual(value, "", "passes a blank value to the input builder")
    })
    builder.input("color")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testDefaultInputBuilderAddsLabelAndTextField() {
    model.color = "black"
    builder.input("color", attributes: ["maxLength": "20"])
    XCTAssertEqual(template.buffer, "<div><label>color</label><input maxLength=\"20\" name=\"hat[color]\" value=\"black\"></input></div>", "puts label and input in template")
  }
}
