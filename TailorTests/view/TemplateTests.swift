import XCTest
import Tailor
import TailorTesting


class TemplateTests: TailorTestCase {
  var controller: TestController!
  var template: Template!
  
  struct TestController: ControllerType {
    var state: ControllerState
    static let layout = Layout.self
    static func defineRoutes(inout RouteSet) {}
    static let name = "TestController"
    func indexAction() {
      
    }
  }
  override func setUp() {
    super.setUp()
    let request = Request(clientAddress: "1.1.1.1", data: NSData())
    let callback = {
      (response: Response) -> () in
    }
    self.controller = TestController(
      request: request,
      actionName: "index",
      callback: callback
    )
    self.controller.state.localization = PropertyListLocalization(locale: "en")
    Application.sharedApplication().configuration.child("localization.content.en").addDictionary([
      "template.test": "Localized Text",
      "template.test_raw": "<b>Hello</b>",
      "record.shelf.attributes.store": "hat store"
    ])
    template = Template(controller: controller)
  }
  
  //MARK: - Body
  
  func testGenerateCallsBodyAndReturnsBuffer() {
    class TestTemplate: Template {
      let hatColor: String
      
      init(controller: ControllerType, hatColor: String = "red") {
        self.hatColor = hatColor
        super.init(controller: controller)
      }
      
      override func body() {
        self.text("Test value \(hatColor)")
      }
    }
    
    let result = TestTemplate(controller: controller, hatColor: "red").generate()
    assert(result, equals: "Test value red", message: "returns template body")
  }
  
  func testGenerateErasesExistingContents() {
    class TestTemplate: Template {
      override func body() {
        self.text("Test 2")
      }
    }
    let template2 = TestTemplate(controller: controller)
    template2.text("Test 1")
    assert(template2.buffer, equals: "Test 1", message: "starts out with hardcoded text")
    template2.generate()
    assert(template2.buffer, equals: "Test 2", message: "replaces with new contents")
  }
  
  //MARK: - Helpers
  
  func testLocalizationPrefixHasClassName() {
    let prefix = template.localizationPrefix
    
    assert(prefix, equals: "tailor.template", message: "has the underscored class name")
  }
  
  func testLocalizeMethodGetsLocalizationFromController() {
    let result = template.localize("template.test")
    assert(result, equals: "Localized Text", message: "gets the text from the controller's localization")
  }
  
  func testLocalizeMethodPrependsPrefixForKeyWithDot() {
    Application.sharedApplication().configuration["localization.content.en.tailor.template.prefix_test"] = "Localized Text with Prefix"
    let result = template.localize(".prefix_test")
    assert(result, equals: "Localized Text with Prefix", message: "gets the text that ")
  }
  
  func testTextMethodAddsTextToTemplate() {
    template.text("Test Text")
    assert(template.buffer, equals: "Test Text", message: "adds text to buffer")
  }
  
  func testTextMethodSanitizesText() {
    template.text("<blink>Hello</blink>")
   assert(template.buffer, equals: "&lt;blink&gt;Hello&lt;/blink&gt;", message: "adds sanitized text to buffer")
  }
  
  func testTextMethodLocalizesText() {
    template.text("template.test")
   assert(template.buffer, equals: "Localized Text", message: "adds localized text to buffer")
  }
  
  func testTextMethodDoesNotLocalizeTextWhenFlagIsSetToFalse() {
    template.text("template.test", localize: false)
   assert(template.buffer, equals: "template.test", message: "adds text to buffer")
  }
  
  func testRawMethodAddsTextWithoutSanitization() {
    template.raw("<p>Hello</p>")
    assert(template.buffer, equals: "<p>Hello</p>", message: "adds text to buffer without sanitization")
  }
  
  func testRawMethodLocalizesText() {
    template.raw("template.test_raw")
    assert(template.buffer, equals: "<b>Hello</b>", message: "adds localized text to buffer without sanitization")
  }
  
  func testRawMethodDoesNotLocalizeTextWhenFlagIsFalse() {
    template.raw("template.test_raw", localize: false)
    assert(template.buffer, equals: "template.test_raw", message: "adds unlocalized text")
  }
  
  func testAddSanitizedTextAddsHtmlSanitizedText() {
    let text = Sanitizer.htmlSanitizer.sanitize("4 < 5")
    template.addSanitizedText(text)
    assert(template.buffer, equals: "4 &lt; 5", message: "adds text to buffer")
  }
  
  func testAddSanitizedTextSanitizesTextThatHasNotBeenSanitized() {
    let text = Sanitizer.sqlSanitizer.sanitize("4 > 3")
    template.addSanitizedText(text)
    assert(template.buffer, equals: "4 &gt; 3", message: "adds text to buffer")
  }
  
  func testTagMethodPutsTagInBuffer() {
    template.tag("p", ["class": "warning", "style": "font-weight: bold"], with: {
      self.template.text("Stop")
    })
    assert(template.buffer, equals: "<p class=\"warning\" style=\"font-weight: bold\">Stop</p>", message: "puts tag in the buffer")
  }
  
  func testTagMethodWithoutAttributesPutsTagInBuffer() {
    template.tag("div", with: {
      self.template.tag("p", with: {
        self.template.text("Inside")
      })
    })
    assert(template.buffer, equals: "<div><p>Inside</p></div>", message: "puts tags in the buffer")
  }
  
  func testTagWithTextPutsTagInBuffer() {
    template.tag("p", text: "Hello")
    assert(template.buffer, equals: "<p>Hello</p>")
  }
  
  func testTagWithTextAndAttributesPutsTagInBuffer() {
    template.tag("p", text: "Hello", attributes: ["class": "greeting", "data-hover": "Hi"])
    assert(template.buffer, equals: "<p class=\"greeting\" data-hover=\"Hi\">Hello</p>")
  }

  func testLinkPutsLinkTagInBuffer() {
    struct InnerTestController: ControllerType {
      var state: ControllerState
      static func defineRoutes(inout routes: RouteSet) {
        
      }
    }
    Application.sharedApplication().routeSet.addRoute("test/path", method: "GET", actionName: "index", action: TestController.indexAction)
    let template2 = Template(controller: InnerTestController(
      request: controller.request,
      actionName: "show",
      callback: controller.callback
    ))
    template2.link("TestController", actionName: "index", parameters: ["id": "5"], attributes: ["class": "btn"]) {
      template2.text("Click here")
    }
    assert(template2.buffer, equals: "<a class=\"btn\" href=\"/test/path?id=5\">Click here</a>", message: "puts the tag in the buffer")
  }
  
  func testRenderTemplatePutsTemplateContentsInBuffer() {
    template.tag("p", text: "Hello")
    class TestTemplate: Template {
      let name: String
      
      init(controller: ControllerType, name: String = "Anonymous") {
        self.name = name
        super.init(controller: controller)
      }
      
      override func body() {
        tag("p", text: "template.test")
        tag("p", text: name)
      }
    }
    template.renderTemplate(TestTemplate(controller: controller, name: "John"))
    assert(template.buffer, equals: "<p>Hello</p><p>Localized Text</p><p>John</p>", message: "buffer has text from original template and sub-template")
  }
  
  func testRenderTemplatePutsTemplateInList() {
    class TestTemplate: Template {
      let name: String
      
      init(controller: ControllerType, name: String = "Anonymous") {
        self.name = name
        super.init(controller: controller)
      }
      
      override func body() {
        tag("p", text: "template.test")
        tag("p", text: name)
      }
    }
    template.renderTemplate(TestTemplate(controller: controller, name: "John"))
    assert(template.renderedTemplates.count, equals: 1, message: "puts a template in the list")
    if !template.renderedTemplates.isEmpty {
      if let otherTemplate = template.renderedTemplates[0] as? TestTemplate {
        assert(otherTemplate.name, equals: "John", message: "puts the right template in the list")
      }
      else {
        XCTFail("puts the right template in the list")
      }
    }
  }
  
  func testCacheWithMissPutsContentsInBody() {
    class TestTemplate: Template {
      override func body() {
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
    
    let template = TestTemplate(controller: controller)
    template.generate()
    assert(template.buffer, equals: "<html><body><p>cached content</p></body></html>")
  }
  
  func testCacheWithMissPutsContentsInCache() {
    class TestTemplate: Template {
      override func body() {
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
    
    let template = TestTemplate(controller: controller)
    template.generate()
    let contents = store.read("cache.test")
    XCTAssertNotNil(contents, "puts something in the cache")
    if contents != nil {
      assert(contents!, equals: "<p>cached content</p>", message: "puts just the added content from the cache block in the cache")
    }
  }
  
  func testCacheWithHitPutsContentInBody() {
    class TestTemplate: Template {
      override func body() {
        self.tag("html") {
          self.tag("body") {
            self.cache("cache.test") {
              self.tag("p") {
                XCTFail("Does not call the block")
                self.text("cached content", localize: false)
              }
            }
          }
        }
      }
    }
    
    Application.cache.clear()
    Application.cache.write("cache.test", value: "<p>the cached content</p>")
    
    let template = TestTemplate(controller: controller)
    template.generate()
    assert(template.buffer, equals: "<html><body><p>the cached content</p></body></html>")
  }
  
  //MARK: - Controller Information
  
  func testRequestParametersGetsKeysFromRequest() {
    var request = controller.request
    request.requestParameters = ["id": "5", "color": "red", "size": "10"]
    let template = Template(controller: TestController(
      request: request,
      actionName: "test",
      callback: controller.callback
    ))
    let parameters = template.requestParameters("id", "color", "shelf")
    assert(parameters, equals: ["id": "5", "color": "red"], message: "gets a subset of the request parameters")
  }
  
  func testRequestParameterGetsKeyFromRequest() {
    var request = controller.request
    request.requestParameters = ["id": "5", "color": "red", "size": "10"]
    let template = Template(controller: TestController(
      request: request,
      actionName: "test",
      callback: controller.callback
      ))
    if let param1 = template.requestParameter("id") {
      assert(param1, equals: "5", message: "gets the parameter from the controller")
    }
    else {
      XCTFail("gets the parameter from the controller")
    }
    
    let param2 = template.requestParameter("foo")
    XCTAssertNil(param2, "gives nil for a missing parameter")
  }
  
  func testAttributeNameGetsNameFromModel() {
    let name1 = template.attributeName(Hat.self, "brimSize")
    assert(name1, equals: "Brim Size", message: "gets a capitalized name from a model")
    let name2 = template.attributeName(Shelf.self, "store")
    assert(name2, equals: "Hat Store", message: "gets a capitalized name from the localization")
  }
}