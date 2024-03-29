import XCTest
import Tailor
import TailorTesting
import Foundation

final class TestTemplateType: XCTestCase, TailorTestable {
  var controller: TestController!
  var template: TemplateType!
  
  struct TestController: ControllerType {
    var state: ControllerState
    static let layout = EmptyLayout.self
    static func defineRoutes(routes: RouteSet) {}
    static let name = "TestController"
    func indexAction() {
      
    }
  }
  
  struct EmptyTemplate: TemplateType {
    var state: TemplateState
    func body() {}
  }
  
  var allTests: [(String, () throws -> Void)] { return [
    ("testGenerateCallsBodyAndReturnsBuffer", testGenerateCallsBodyAndReturnsBuffer),
    ("testGenerateErasesExistingContents", testGenerateErasesExistingContents),
    ("testLocalizationPrefixHasClassName", testLocalizationPrefixHasClassName),
    ("testLocalizeMethodGetsLocalizationFromController", testLocalizeMethodGetsLocalizationFromController),
    ("testLocalizeMethodAddsInterpolationsToText", testLocalizeMethodAddsInterpolationsToText),
    ("testLocalizeMethodPrependsPrefixForKeyWithDot", testLocalizeMethodPrependsPrefixForKeyWithDot),
    ("testTextMethodAddsTextToTemplate", testTextMethodAddsTextToTemplate),
    ("testTextMethodSanitizesText", testTextMethodSanitizesText),
    ("testTextMethodLocalizesText", testTextMethodLocalizesText),
    ("testTextMethodAddsInterpolationsToText", testTextMethodAddsInterpolationsToText),
    ("testTextMethodDoesNotLocalizeTextWhenFlagIsSetToFalse", testTextMethodDoesNotLocalizeTextWhenFlagIsSetToFalse),
    ("testRawMethodAddsTextWithoutSanitization", testRawMethodAddsTextWithoutSanitization),
    ("testRawMethodLocalizesText", testRawMethodLocalizesText),
    ("testRawMethodDoesNotLocalizeTextWhenFlagIsFalse", testRawMethodDoesNotLocalizeTextWhenFlagIsFalse),
    ("testAddSanitizedTextAddsHtmlSanitizedText", testAddSanitizedTextAddsHtmlSanitizedText),
    ("testAddSanitizedTextSanitizesTextThatHasNotBeenSanitized", testAddSanitizedTextSanitizesTextThatHasNotBeenSanitized),
    ("testTagMethodPutsTagInBuffer", testTagMethodPutsTagInBuffer),
    ("testTagMethodWithNoContentsPutsTagInBuffer", testTagMethodWithNoContentsPutsTagInBuffer),
    ("testTagMethodWithoutAttributesPutsTagInBuffer", testTagMethodWithoutAttributesPutsTagInBuffer),
    ("testTagWithTextPutsTagInBuffer", testTagWithTextPutsTagInBuffer),
    ("testTagWithTextAndAttributesPutsTagInBuffer", testTagWithTextAndAttributesPutsTagInBuffer),
    ("testDivPutsDivTagInBuffer", testDivPutsDivTagInBuffer),
    ("testLinkPutsLinkTagInBuffer", testLinkPutsLinkTagInBuffer),
    ("testLinkPutsLinkWithNoContentsTagInBuffer", testLinkPutsLinkWithNoContentsTagInBuffer),
    ("testLinkWithNoControllerTypePutsLinkToCurrentControllerInBuffer", testLinkWithNoControllerTypePutsLinkToCurrentControllerInBuffer),
    ("testLinkWithNoControllerOrContentsPutsTagInBuffer", testLinkWithNoControllerOrContentsPutsTagInBuffer),
    ("testLinkWithInvalidRoutePutsEmptyLinkTagInBuffer", testLinkWithInvalidRoutePutsEmptyLinkTagInBuffer),
    ("testFormMethodBuildsForm", testFormMethodBuildsForm),
    ("testRenderTemplatePutsTemplateContentsInBuffer", testRenderTemplatePutsTemplateContentsInBuffer),
    ("testRenderTemplatePutsTemplateInList", testRenderTemplatePutsTemplateInList),
    ("testCacheWithMissPutsContentsInBody", testCacheWithMissPutsContentsInBody),
    ("testCacheWithMissPutsContentsInCache", testCacheWithMissPutsContentsInCache),
    ("testCacheWithHitPutsContentInBody", testCacheWithHitPutsContentInBody),
    ("testRequestParametersGetsKeysFromRequest", testRequestParametersGetsKeysFromRequest),
    ("testRequestParameterGetsKeyFromRequest", testRequestParameterGetsKeyFromRequest),
    ("testAttributeNameGetsNameFromModel", testAttributeNameGetsNameFromModel),
  ]}

  func setUp() {
    setUpTestCase()
    let request = Request(clientAddress: "1.1.1.1", data: NSData())
    let callback = {
      (response: Response) -> () in
    }
    self.controller = TestController(state: ControllerState(
      request: request,
      response: Response(),
      actionName: "index",
      callback: callback
    ))
    self.controller.state.localization = PropertyListLocalization(locale: "en")
    Application.configuration.staticContent["en.template.test"] = "Localized Text"
    Application.configuration.staticContent["en.template.test_raw"] = "<b>Hello</b>"
    Application.configuration.staticContent["en.template.test_interpolate"] = "Hello \\(value)"
    Application.configuration.staticContent["en.record.shelf.attributes.store"] = "hat store"
    template = EmptyTemplate(state: TemplateState(controller))
  }
  
  //MARK: - Body
  
  func testGenerateCallsBodyAndReturnsBuffer() {
    struct TestTemplate: TemplateType {
      let hatColor: String
      var state: TemplateState

      init(controller: ControllerType, hatColor: String = "red") {
        self.hatColor = hatColor
        self.state = TemplateState(controller)
      }
      
      mutating func body() {
        self.text("Test value \(hatColor)")
      }
    }
    
    var template2 = TestTemplate(controller: controller, hatColor: "red")
    let result = template2.generate()
    assert(result, equals: "Test value red", message: "returns template body")
  }
  
  func testGenerateErasesExistingContents() {
    struct TestTemplate: TemplateType {
      var state: TemplateState
      
      mutating func body() {
        self.text("Test 2")
      }
    }
    
    var template2 = TestTemplate(state: TemplateState(controller))
    template2.text("Test 1")
    assert(template2.contents, equals: "Test 1", message: "starts out with hardcoded text")
    template2.generate()
    assert(template2.contents, equals: "Test 2", message: "replaces with new contents")
  }
  
  //MARK: - Helpers
  
  func testLocalizationPrefixHasClassName() {
    let prefix = template.localizationPrefix
    
    assert(prefix, equals: "tailor_tests.test_template_type.empty_template", message: "has the underscored class name")
  }
  
  func testLocalizeMethodGetsLocalizationFromController() {
    let result = template.localize("template.test")
    assert(result, equals: "Localized Text", message: "gets the text from the controller's localization")
  }
  
  func testLocalizeMethodAddsInterpolationsToText() {
    let result = template.localize("template.test_interpolate", interpolations: ["value": "mom"])
    assert(result, equals: "Hello mom")
  }
  
  func testLocalizeMethodPrependsPrefixForKeyWithDot() {
    Application.configuration.staticContent["en.tailor_tests.test_template_type.empty_template.prefix_test"] = "Localized Text with Prefix"
    let result = template.localize(".prefix_test")
    assert(result, equals: "Localized Text with Prefix", message: "gets the text that ")
  }
  
  func testTextMethodAddsTextToTemplate() {
    template.text("Test Text")
    assert(template.contents, equals: "Test Text", message: "adds text to buffer")
  }
  
  func testTextMethodSanitizesText() {
    template.text("<blink>Hello</blink>")
   assert(template.contents, equals: "&lt;blink&gt;Hello&lt;/blink&gt;", message: "adds sanitized text to buffer")
  }
  
  func testTextMethodLocalizesText() {
    template.text("template.test")
   assert(template.contents, equals: "Localized Text", message: "adds localized text to buffer")
  }
  
  func testTextMethodAddsInterpolationsToText() {
    template.text("template.test_interpolate", interpolations: ["value": "thing", "value2": "thing 2"])
    assert(template.contents, equals: "Hello thing", message: "adds localized text to buffer")
  }
  
  func testTextMethodDoesNotLocalizeTextWhenFlagIsSetToFalse() {
    template.text("template.test", localize: false)
   assert(template.contents, equals: "template.test", message: "adds text to buffer")
  }
  
  func testRawMethodAddsTextWithoutSanitization() {
    template.raw("<p>Hello</p>")
    assert(template.contents, equals: "<p>Hello</p>", message: "adds text to buffer without sanitization")
  }
  
  func testRawMethodLocalizesText() {
    template.raw("template.test_raw")
    assert(template.contents, equals: "<b>Hello</b>", message: "adds localized text to buffer without sanitization")
  }
  
  func testRawMethodDoesNotLocalizeTextWhenFlagIsFalse() {
    template.raw("template.test_raw", localize: false)
    assert(template.contents, equals: "template.test_raw", message: "adds unlocalized text")
  }
  
  func testAddSanitizedTextAddsHtmlSanitizedText() {
    let text = Sanitizer.htmlSanitizer.sanitize("4 < 5")
    template.addSanitizedText(text)
    assert(template.contents, equals: "4 &lt; 5", message: "adds text to buffer")
  }
  
  func testAddSanitizedTextSanitizesTextThatHasNotBeenSanitized() {
    let text = Sanitizer.sqlSanitizer.sanitize("4 > 3")
    template.addSanitizedText(text)
    assert(template.contents, equals: "4 &gt; 3", message: "adds text to buffer")
  }
  
  func testTagMethodPutsTagInBuffer() {
    template.tag("p", ["class": "warning", "style": "font-weight: bold"], with: {
      self.template.text("Stop")
    })
    assert(template.contents, equals: "<p class=\"warning\" style=\"font-weight: bold\">Stop</p>", message: "puts tag in the buffer")
  }
  
  func testTagMethodWithNoContentsPutsTagInBuffer() {
    template.tag("p")
    assert(template.contents, equals: "<p></p>", message: "puts tag in the buffer")
  }
  
  
  func testTagMethodWithoutAttributesPutsTagInBuffer() {
    template.tag("div", with: {
      self.template.tag("p", with: {
        self.template.text("Inside")
      })
    })
    assert(template.contents, equals: "<div><p>Inside</p></div>", message: "puts tags in the buffer")
  }
  
  func testTagWithTextPutsTagInBuffer() {
    template.tag("p", text: "Hello")
    assert(template.contents, equals: "<p>Hello</p>")
  }
  
  func testTagWithTextAndAttributesPutsTagInBuffer() {
    template.tag("p", text: "Hello", attributes: ["class": "greeting", "data-hover": "Hi"])
    assert(template.contents, equals: "<p class=\"greeting\" data-hover=\"Hi\">Hello</p>")
  }
  
  func testDivPutsDivTagInBuffer() {
    template.div("alert", attributes: ["class": "greeting", "data-hover": "Hi"]) { template.text("Hello") }
    assert(template.contents, equals: "<div class=\"alert greeting\" data-hover=\"Hi\">Hello</div>")
  }
  
  func testLinkPutsLinkTagInBuffer() {
    struct InnerTestController: ControllerType {
      var state: ControllerState
      static func defineRoutes(routes: RouteSet) {
        
      }
    }
    
    RouteSet.load {
      routes in
      routes.route(.Get("test/path"), to: TestController.indexAction, name: "index")
      ()
    }
    var template2 = EmptyTemplate(state: TemplateState(InnerTestController(state: ControllerState(
      request: controller.request,
      response: Response(),
      actionName: "show",
      callback: controller.callback
      ))))
    template2.link(TestController.self, actionName: "index", parameters: ["id": "5"], attributes: ["class": "btn"]) {
      template2.text("Click here")
    }
    assert(template2.contents, equals: "<a class=\"btn\" href=\"/test/path?id=5\">Click here</a>", message: "puts the tag in the buffer")
  }
  
  func testLinkPutsLinkWithNoContentsTagInBuffer() {
    struct InnerTestController: ControllerType {
      var state: ControllerState
      static func defineRoutes(routes: RouteSet) {
        
      }
    }
    
    RouteSet.load {
      routes in
      routes.route(.Get("test/path"), to: TestController.indexAction, name: "index")
      ()
    }
    var template2 = EmptyTemplate(state: TemplateState(InnerTestController(state: ControllerState(
      request: controller.request,
      response: Response(),
      actionName: "show",
      callback: controller.callback
      ))))
    template2.link(TestController.self, actionName: "index", parameters: ["id": "5"], attributes: ["class": "btn"])
    assert(template2.contents, equals: "<a class=\"btn\" href=\"/test/path?id=5\"></a>", message: "puts the tag in the buffer")
  }
  
  func testLinkWithNoControllerTypePutsLinkToCurrentControllerInBuffer() {
    struct InnerTestController: ControllerType {
      var state: ControllerState
      static func defineRoutes(routes: RouteSet) {
        
      }
      func indexAction() {
        
      }
    }
    
    RouteSet.load {
      routes in
      routes.route(.Get("test/path"), to: TestController.indexAction, name: "index")
      routes.route(.Get("test/path2"), to: InnerTestController.indexAction, name: "index")
      ()
    }
    var template2 = EmptyTemplate(state: TemplateState(InnerTestController(state: ControllerState(
      request: controller.request,
      response: Response(),
      actionName: "show",
      callback: controller.callback
      ))))
    template2.link(actionName: "index", parameters: ["id": "5"], attributes: ["class": "btn"]) {
      template2.text("Click here")
    }
    assert(template2.contents, equals: "<a class=\"btn\" href=\"/test/path2?id=5\">Click here</a>", message: "puts the tag in the buffer")
  }
  
  func testLinkWithNoControllerOrContentsPutsTagInBuffer() {
    struct InnerTestController: ControllerType {
      var state: ControllerState
      static func defineRoutes(routes: RouteSet) {
        
      }
      func indexAction() {
        
      }
    }
    
    RouteSet.load {
      routes in
      routes.route(.Get("test/path"), to: TestController.indexAction, name: "index")
      routes.route(.Get("test/path2"), to: InnerTestController.indexAction, name: "index")
      ()
    }
    var template2 = EmptyTemplate(state: TemplateState(InnerTestController(state: ControllerState(
      request: controller.request,
      response: Response(),
      actionName: "show",
      callback: controller.callback
      ))))
    template2.link(actionName: "index", parameters: ["id": "5"], attributes: ["class": "btn"])
    assert(template2.contents, equals: "<a class=\"btn\" href=\"/test/path2?id=5\"></a>", message: "puts the tag in the buffer")
  }
  
  func testLinkWithInvalidRoutePutsEmptyLinkTagInBuffer() {
    struct InnerTestController: ControllerType {
      var state: ControllerState
      static func defineRoutes(routes: RouteSet) {
        
      }
    }
    
    RouteSet.load {
      routes in
      routes.route(.Get("test/path"), to: TestController.indexAction, name: "index")
      ()
    }
    var template2 = EmptyTemplate(state: TemplateState(InnerTestController(state: ControllerState(
      request: controller.request,
      response: Response(),
      actionName: "show",
      callback: controller.callback
      ))))
    template2.link(InnerTestController.self, actionName: "index", parameters: ["id": "5"], attributes: ["class": "btn"]) {
      template2.text("Click here")
    }
    assert(template2.contents, equals: "<a class=\"btn\" href=\"\">Click here</a>", message: "puts the tag in the buffer")
  }
  
  func testFormMethodBuildsForm() {
    template.tag("p", text: "Hello")
    template.form("/hats/5", type: Hat.self, attributes: ["form-type": "my-form"]) {
      (inout form: TemplateForm) in
      form.input("color", "red")
      form.input("brimSize", "10")
    }
    template.tag("p", text: "Goodbye")
    assert(template.contents, equals: "<p>Hello</p><form action=\"/hats/5\" form-type=\"my-form\" method=\"POST\"><div><label>color</label><input name=\"hat[color]\" value=\"red\"></input></div><div><label>brim size</label><input name=\"hat[brimSize]\" value=\"10\"></input></div></form><p>Goodbye</p>")
  }
  
  func testRenderTemplatePutsTemplateContentsInBuffer() {
    template.tag("p", text: "Hello")
    struct TestTemplate: TemplateType {
      var state: TemplateState
      let name: String
      
      init(controller: ControllerType, name: String = "Anonymous") {
        self.name = name
        self.state = TemplateState(controller)
      }
      
      mutating func body() {
        tag("p", text: "template.test")
        tag("p", text: name)
      }
    }
    template.renderTemplate(TestTemplate(controller: controller, name: "John"))
    assert(template.contents, equals: "<p>Hello</p><p>Localized Text</p><p>John</p>", message: "buffer has text from original template and sub-template")
  }
  
  func testRenderTemplatePutsTemplateInList() {
    struct TestTemplate: TemplateType {
      var state: TemplateState
      let name: String
      
      init(controller: ControllerType, name: String = "Anonymous") {
        self.name = name
        self.state = TemplateState(controller)
      }
      
      mutating func body() {
        tag("p", text: "template.test")
        tag("p", text: name)
      }
    }
    template.renderTemplate(TestTemplate(controller: controller, name: "John"))
    assert(template.state.renderedTemplates.count, equals: 1, message: "puts a template in the list")
    if !template.state.renderedTemplates.isEmpty {
      if let otherTemplate = template.state.renderedTemplates[0] as? TestTemplate {
        assert(otherTemplate.name, equals: "John", message: "puts the right template in the list")
      }
      else {
        XCTFail("puts the right template in the list")
      }
    }
  }
  
  func testCacheWithMissPutsContentsInBody() {
    struct TestTemplate: TemplateType {
      var state: TemplateState
      
      init(controller: ControllerType) {
        self.state = TemplateState(controller)
      }
      
      mutating func body() {
        self.tag("html") {
          self.tag("body") {
            self.cache("cache.test") {
              self.tag("p") {
                self.text("cached content", localize: false)
              }
            }
          }
        }
      }
    }
    
    let store = Application.cache
      
    store.clear()
    var template = TestTemplate(controller: controller)
    template.generate()
    assert(template.contents, equals: "<html><body><p>cached content</p></body></html>")
  }
  
  func testCacheWithMissPutsContentsInCache() {
    struct TestTemplate: TemplateType {
      var state: TemplateState
      
      init(controller: ControllerType) {
        self.state = TemplateState(controller)
      }
      
      mutating func body() {
        self.tag("html") {
          self.tag("body") {
            self.cache("cache.test") {
              self.tag("p") {
                self.text("cached content", localize: false)
              }
            }
          }
        }
      }
    }
    
    let store = Application.cache
    
    store.clear()
    
    var template = TestTemplate(controller: controller)
    template.generate()
    let contents = store.read("cache.test")
    XCTAssertNotNil(contents, "puts something in the cache")
    if contents != nil {
      assert(contents!, equals: "<p>cached content</p>", message: "puts just the added content from the cache block in the cache")
    }
  }
  
  func testCacheWithHitPutsContentInBody() {
    struct TestTemplate: TemplateType {
      var state: TemplateState
      
      init(controller: ControllerType) {
        self.state = TemplateState(controller)
      }
      
      mutating func body() {
        self.tag("html") {
          self.tag("body") {
            self.cache("cache.test") {
              self.tag("p") {
                XCTest.XCTFail("Does not call the block")
                self.text("cached content", localize: false)
              }
            }
          }
        }
      }
    }
    
    Application.cache.clear()
    Application.cache.write("cache.test", value: "<p>the cached content</p>")
    
    var template = TestTemplate(controller: controller)
    template.generate()
    assert(template.contents, equals: "<html><body><p>the cached content</p></body></html>")
  }
  
  //MARK: - Controller Information
  
  func testRequestParametersGetsKeysFromRequest() {
    var request = controller.request
    request.params.raw = ["id": ["5"], "color": ["red"], "sizes[]": ["10", "11"]]
    let template = EmptyTemplate(state: TemplateState(TestController(state: ControllerState(
      request: request,
      response: Response(),
      actionName: "test",
      callback: controller.callback
    ))))
    let parameters = template.requestParameters("id", "color", "sizes[]")
    assert(parameters, equals: ["id": "5", "color": "red", "sizes[]": "10"], message: "gets a subset of the request parameters")
  }
  
  func testRequestParameterGetsKeyFromRequest() {
    var request = controller.request
    request.params.raw = ["id": ["5"], "color": ["red"], "sizes[]": ["10", "11"]]
    let template = EmptyTemplate(state: TemplateState(TestController(state: ControllerState(
      request: request,
      response: Response(),
      actionName: "test",
      callback: controller.callback
      ))))
    assert(template.requestParameter("id"), equals: "5", message: "gets the parameter from the controller")
    assert(template.requestParameter("sizes[]"), equals: "10", message: "gets the first parameter when there is an array")
    XCTAssertNil(template.requestParameter("foo"), "gives nil for a missing parameter")
  }
  
  func testAttributeNameGetsNameFromModel() {
    let name1 = template.attributeName(Hat.self, "brimSize")
    assert(name1, equals: "Brim Size", message: "gets a capitalized name from a model")
    let name2 = template.attributeName(Shelf.self, "store")
    assert(name2, equals: "Hat Store", message: "gets a capitalized name from the localization")
  }
}