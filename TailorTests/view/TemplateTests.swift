import XCTest

class TemplateTests: XCTestCase {
  
  let template = Template(body: {_,_ in})
  
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
    template.controller = Controller(
      request: request,
      action: "index",
      callback: callback
    )
    template.controller?.localization = TestLocalization(locale: "en")
  }
  //MARK: - Body
  
  func testGenerateCallsBodyAndReturnsBuffer() {
    let template2 = Template {
      template, attributes in
      let color = attributes["hat color"] as String
      template.text("Test Value \(color)")
    }
    
    let result = template2.generate(["hat color": "red"])
    XCTAssertEqual(result, "Test Value red", "returns template body")
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
    let oldController = template.controller!
    template.controller = TestController(
      request: oldController.request,
      action: oldController.action,
      callback: oldController.callback
    )
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
    let oldController = template.controller!
    template.controller = TestController(
      request: oldController.request,
      action: oldController.action,
      callback: oldController.callback
    )
    template.link(controllerName: "TestController", action: "index", parameters: ["id": "5"], attributes: ["class": "btn"]) {
      self.template.text("Click here")
    }
    XCTAssertEqual(template.buffer, "<a class=\"btn\" href=\"/test/path\">Click here</a>", "puts the tag in the buffer")
  }
  
  func testRenderTemplatePutsTemplateContentsInBuffer() {
    template.tag("p", text: "Hello")
    let otherTemplate = Template {
      (t, p) in
      t.tag("p", text: "template.test")
      let name = p["name"] as String
      t.tag("p", text: name)
    }
    template.renderTemplate(otherTemplate, ["name": "John"])
    XCTAssertEqual(template.buffer, "<p>Hello</p><p>Localized Text</p><p>John</p>", "buffer has text from original template and sub-template")
  }
  
  func testRenderTemplateErasesExistingContents() {
    template.tag("p", text: "Hello")
    let otherTemplate = Template {
      (t, p) in
      t.tag("p", text: "template.test")
    }
    otherTemplate.text("Stuff")
    template.renderTemplate(otherTemplate, [:])
    XCTAssertEqual(template.buffer, "<p>Hello</p><p>Localized Text</p>")
  }
  
  //MARK: - Controller Information
  
  func testRequestParametersGetsKeysFromRequest() {
    let oldController = template.controller!
    var request = oldController.request
    request.requestParameters = ["id": "5", "color": "red", "size": "10"]
    template.controller = Controller(
      request: request,
      action: oldController.action,
      callback: oldController.callback
    )
    let parameters = template.requestParameters("id", "color", "shelf")
    XCTAssertEqual(parameters, ["id": "5", "color": "red"], "gets a subset of the request parameters")
  }
  
  func testAttributeNameGetsNameFromModel() {
    let name1 = template.attributeName(Hat.self, "brimSize")
    XCTAssertEqual(name1, "Brim Size", "gets a capitalized name from a model")
    let name2 = template.attributeName(Shelf.self, "store")
    XCTAssertEqual(name2, "Hat Store", "gets a capitalized name from the localization")
  }
}