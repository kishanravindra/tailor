import XCTest

class TemplateTests: XCTestCase {
  var controller: Controller!
  var template: Template!
  
  class TestLocalization : Localization {
    var customStrings: [String:String]
    override init(locale: String) {
      customStrings = [
        "template.test": "Localized Text",
        "template.test_raw": "<b>Hello</b>",
        "record.shelf.attributes.store": "hat store"
      ]
      super.init(locale: locale)
    }
    
    override func fetch(key: String) -> String? {
      return customStrings[key]
    }
  }
  
  override func setUp() {
    TestApplication.start()
    let request = Request(clientAddress: "1.1.1.1", data: NSData())
    let callback = {
      (response: Response) -> () in
    }
    self.controller = Controller(
      request: request,
      action: "index",
      callback: callback
    )
    self.controller.localization = TestLocalization(locale: "en")
    template = Template(controller: controller)
  }
  //MARK: - Body
  
  func testGenerateCallsBodyAndReturnsBuffer() {
    class TestTemplate: Template {
      let hatColor: String
      
      init(controller: Controller, hatColor: String = "red") {
        self.hatColor = hatColor
        super.init(controller: controller)
      }
      
      override func body() {
        self.text("Test value \(hatColor)")
      }
    }
    
    let result = TestTemplate(controller: controller, hatColor: "red").generate()
    XCTAssertEqual(result, "Test value red", "returns template body")
  }
  
  func testGenerateErasesExistingContents() {
    class TestTemplate: Template {
      override func body() {
        self.text("Test 2")
      }
    }
    var template2 = TestTemplate(controller: controller)
    template2.text("Test 1")
    XCTAssertEqual(template2.buffer, "Test 1", "starts out with hardcoded text")
    template2.generate()
    XCTAssertEqual(template2.buffer, "Test 2", "replaces with new contents")
  }
  
  //MARK: - Helpers
  
  func testTextMethodAddsTextToTemplate() {
    template.text("Test Text")
    XCTAssertEqual(template.buffer, "Test Text", "adds text to buffer")
  }
  
  func testTextMethodSanitizesText() {
    template.text("<blink>Hello</blink>")
    XCTAssertEqual(template.buffer, "&lt;blink&gt;Hello&lt;/blink&gt;", "adds sanitized text to buffer")
  }
  
  func testTextMethodLocalizesText() {
    template.text("template.test")
    XCTAssertEqual(template.buffer, "Localized Text", "adds localized text to buffer")
  }
  
  func testTextMethodDoesNotLocalizeTextWhenFlagIsSetToFalse() {
    template.text("template.test", localize: false)
    XCTAssertEqual(template.buffer, "template.test", "adds text to buffer")
  }
  
  func testRawMethodAddsTextWithoutSanitization() {
    template.raw("<p>Hello</p>")
    XCTAssertEqual(template.buffer, "<p>Hello</p>", "adds text to buffer without sanitization")
  }
  
  func testRawMethodLocalizesText() {
    template.raw("template.test_raw")
    XCTAssertEqual(template.buffer, "<b>Hello</b>", "adds localized text to buffer without sanitization")
  }
  
  func testRawMethodDoesNotLocalizeTextWhenFlagIsFalse() {
    template.raw("template.test_raw", localize: false)
    XCTAssertEqual(template.buffer, "template.test_raw", "adds unlocalized text")
  }
  
  func testAddSanitizedTextAddsHtmlSanitizedText() {
    let text = HtmlSanitizer().sanitize("4 < 5")
    template.addSanitizedText(text)
    XCTAssertEqual(template.buffer, "4 &lt; 5", "adds text to buffer")
  }
  
  func testAddSanitizedTextSanitizesTextThatHasNotBeenSanitized() {
    let text = SqlSanitizer().sanitize("4 > 3")
    template.addSanitizedText(text)
    XCTAssertEqual(template.buffer, "4 &gt; 3", "adds text to buffer")
  }
  
  func testTagMethodPutsTagInBuffer() {
    template.tag("p", ["class": "warning", "style": "font-weight: bold"], with: {
      self.template.text("Stop")
    })
    XCTAssertEqual(template.buffer, "<p class=\"warning\" style=\"font-weight: bold\">Stop</p>", "puts tag in the buffer")
  }
  
  func testTagMethodWithoutAttributesPutsTagInBuffer() {
    template.tag("div", with: {
      self.template.tag("p", with: {
        self.template.text("Inside")
      })
    })
    XCTAssertEqual(template.buffer, "<div><p>Inside</p></div>", "puts tags in the buffer")
  }
  
  func testTagWithTextPutsTagInBuffer() {
    template.tag("p", text: "Hello")
    XCTAssertEqual(template.buffer, "<p>Hello</p>")
  }
  
  func testTagWithTextAndAttributesPutsTagInBuffer() {
    template.tag("p", text: "Hello", attributes: ["class": "greeting", "data-hover": "Hi"])
    XCTAssertEqual(template.buffer, "<p class=\"greeting\" data-hover=\"Hi\">Hello</p>")
  }
  
  func testUrlForGetsUrlFromController() {
    class TestController: Controller {
      override func urlFor(controllerName: String? = nil, action: String? = nil, parameters: [String:String] = [:]) -> String? {
        XCTAssertEqual(controllerName!, "TestController", "has the controller name")
        XCTAssertEqual(action!, "index", "has the action")
        XCTAssertEqual(parameters, ["id": "5"], "has the parameters")
        return "/test/path"
      }
    }
    
    let template = Template(controller: TestController(
      request: controller.request,
      action: controller.action,
      callback: controller.callback
    ))
    let result = template.urlFor(controllerName: "TestController", action: "index", parameters: ["id": "5"])
    XCTAssertNotNil(result, "has a result")
    if result != nil {
      XCTAssertEqual(result!, "/test/path", "returns the path from the controller")
    }
  }
  
  func testLinkPutsLinkTagInBuffer() {
    class TestController: Controller {
      override func urlFor(controllerName: String? = nil, action: String? = nil, parameters: [String:String] = [:]) -> String? {
        XCTAssertEqual(controllerName!, "TestController", "has the controller name")
        XCTAssertEqual(action!, "index", "has the action")
        XCTAssertEqual(parameters, ["id": "5"], "has the parameters")
        return "/test/path"
      }
    }
    let template2 = Template(controller: TestController(
      request: controller.request,
      action: controller.action,
      callback: controller.callback
    ))
    template2.link(controllerName: "TestController", action: "index", parameters: ["id": "5"], attributes: ["class": "btn"]) {
      template2.text("Click here")
    }
    XCTAssertEqual(template2.buffer, "<a class=\"btn\" href=\"/test/path\">Click here</a>", "puts the tag in the buffer")
  }
  
  func testRenderTemplatePutsTemplateContentsInBuffer() {
    template.tag("p", text: "Hello")
    class TestTemplate: Template {
      let name: String
      
      init(controller: Controller, name: String = "Anonymous") {
        self.name = name
        super.init(controller: controller)
      }
      
      override func body() {
        tag("p", text: "template.test")
        tag("p", text: name)
      }
    }
    template.renderTemplate(TestTemplate(controller: controller, name: "John"))
    XCTAssertEqual(template.buffer, "<p>Hello</p><p>Localized Text</p><p>John</p>", "buffer has text from original template and sub-template")
  }
  
  //MARK: - Controller Information
  
  func testRequestParametersGetsKeysFromRequest() {
    var request = controller.request
    request.requestParameters = ["id": "5", "color": "red", "size": "10"]
    let template = Template(controller: Controller(
      request: request,
      action: controller.action,
      callback: controller.callback
    ))
    let parameters = template.requestParameters("id", "color", "shelf")
    XCTAssertEqual(parameters, ["id": "5", "color": "red"], "gets a subset of the request parameters")
  }
  
  func testRequestParameterGetsKeyFromRequest() {
    var request = controller.request
    request.requestParameters = ["id": "5", "color": "red", "size": "10"]
    let template = Template(controller: Controller(
      request: request,
      action: controller.action,
      callback: controller.callback
      ))
    if let param1 = template.requestParameter("id") {
      XCTAssertEqual(param1, "5", "gets the parameter from the controller")
    }
    else {
      XCTFail("gets the parameter from the controller")
    }
    
    let param2 = template.requestParameter("foo")
    XCTAssertNil(param2, "gives nil for a missing parameter")
  }
  
  func testAttributeNameGetsNameFromModel() {
    let name1 = template.attributeName(Hat.self, "brimSize")
    XCTAssertEqual(name1, "Brim Size", "gets a capitalized name from a model")
    let name2 = template.attributeName(Shelf.self, "store")
    XCTAssertEqual(name2, "Hat Store", "gets a capitalized name from the localization")
  }
}