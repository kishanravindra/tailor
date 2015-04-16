import XCTest
import Tailor
import TailorTesting

class ControllerTests: TailorTestCase {
  class TestController : Controller {
    required init(request: Request, action: String, callback: Server.ResponseCallback) {
      super.init(request: request, action: action, callback: callback)
      self.addFilter(filter: self.checkParams)
    }
    
    override class func name() -> String {
      return "TailorTests.TestController"
    }
    
    func checkParams() -> Bool {
      if let param = request.requestParameters["failFilter"] {
        var response = Response()
        response.code = 419
        self.callback(response)
        return false
      }
      return true
    }
    dynamic func indexAction() {
      var response = Response()
      response.code = 200
      response.appendString("Index Action")
      self.callback(response)
    }
  }
  
  class SecondTestController : Controller {
  }
  
  var user: User!
  var callback: Server.ResponseCallback = {response in }
  var controller: Controller!
  
  override func setUp() {
    super.setUp()
    user = User(emailAddress: "test@test.com", password: "test")
    user.save()
    
    var routeSet = RouteSet()
    routeSet.addRoute("route1", method: "GET", controller: TestController.self, action: "index")
    routeSet.addRoute("route1/:id", method: "GET", controller: TestController.self, action: "show")
    routeSet.addRoute("route2", method: "GET", controller: SecondTestController.self, action: "index")
    Application.sharedApplication().routeSet = routeSet
    
    controller = Controller(
      request: Request(),
      action: "index",
      callback: {
        response in
        self.callback(response)
      }
    )
  }
  
  override func tearDown() {
    Application.sharedApplication().routeSet = RouteSet()
  }
  
  func testInitializeSetsUserFromIdInSession() {
    controller = Controller(
      request: Request(sessionData: ["userId": String(user.id!)]),
      action: "index",
      callback: {
        (response) in
      }
    )
    assert(controller.currentUser, equals: user, message: "sets user to the one with the id given")
  }
  
  func testInitializerSetsUserToNilWithBadId() {
    controller = Controller(
      request: Request(sessionData: ["userId": String(user.id! + 1)]),
      action: "index",
      callback: {
        (response) in
      }
    )
    XCTAssertNil(controller.currentUser, "sets user to nil")
  }

  func testInitializerSetsUserToNilWithNoId() {
    controller = Controller(
      request: Request(),
      action: "index",
      callback: {
        (response) in
      }
    )
    XCTAssertNil(controller.currentUser, "sets user to nil")
  }
  
  //MARK: - Responses
  
  func testRespondMethodCallsActionMethod() {
    let expectation = expectationWithDescription("method called")
    
    controller = TestController(
      request: Request(),
      action: "index",
      callback: {
        response in
        expectation.fulfill()
        let data = "Index Action".dataUsingEncoding(NSUTF8StringEncoding)
        self.assert(response.bodyData, equals: data!, message: "gives the expected response body")
      }
    )
    controller.respond()
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRespondMethodGives404WithUnsupportedAction() {
    let expectation = expectationWithDescription("method called")
    
    let controller = TestController(
      request: Request(),
      action: "show",
      callback: {
        response in
        expectation.fulfill()
        self.assert(response.code, equals: 404, message: "gives a 404 response")
      }
    )
    controller.respond()
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRespondMethodCallsFilters() {
    let expectation = expectationWithDescription("method called")
    
    let controller = TestController(
      request: Request(parameters: ["failFilter": "1"]),
      action: "index",
      callback: {
        response in
        expectation.fulfill()
        self.assert(response.code, equals: 419, message: "gives a 419 response, from the filter")
      }
    )
    controller.respond()
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testGenerateResponseGivesResponseToBlock() {
    let expectation = expectationWithDescription("block called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.code, equals: 123, message: "has the response code from the block given to generateResponse")
    }
    
    controller.generateResponse { (inout r: Response) in r.code = 123 }
    
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testGenerateResponseWillNotRespondTwice() {
    var callCount = 0
    self.callback = {
      response in
      callCount += 1
      self.assert(response.code, equals: 123, message: "has the response code from the block given to generateResponse")
    }
    
    controller.generateResponse { (inout r: Response) in r.code = 123 }
    controller.generateResponse { (inout r: Response) in r.code = 456 }

    assert(callCount, equals: 1, message: "only calls the callback once")
  }
  
  func testGenerateResponseSetsCookies() {
    let expectation = expectationWithDescription("callback called")
    controller = Controller(
      request: Request(cookies: ["cookie1": "value1"]),
      action: "index",
      callback: { self.callback($0) }
    )
    
    controller.generateResponse {
      (inout response: Response) in
      response.cookies["cookie2"] = "value2"
      
      self.callback = {
        response in
        expectation.fulfill()
        self.assert(response.cookies.cookieDictionary(), equals: [
          "cookie1": "value1",
          "cookie2": "value2",
          "_session": self.controller.session.cookieString()
        ], message: "gets old cookies, new cookies, and session info")
      }
    }
    
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRespondWithRendersTemplateInLayout() {
    let expectation = expectationWithDescription("callback called")
    class TestTemplate: Template {
      override func body() {
        tag("p", text: "Nesting")
      }
    }
    class TestLayout: Layout {
      override func body() {
        self.tag("html") {
          self.tag("body") {
            self.renderTemplate(self.template)
          }
        }
      }
    }
    
    self.callback = {
      response in
      expectation.fulfill()
      let body = NSString(data: response.bodyData, encoding: NSUTF8StringEncoding)!
      self.assert(body, equals: "<html><body><p>Nesting</p></body></html>", message: "sets body")
    }
    
    controller.layout = TestLayout.self
    controller.respondWith(TestTemplate(controller: controller))
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRespondWithAddsTemplateToList() {
    let expectation = expectationWithDescription("callback called")
    class TestTemplate: Template {
      let message: String
      
      init(controller: Controller, message: String = "") {
        self.message = message
        super.init(controller: controller)
      }
      override func body() {
        tag("p", text: message)
      }
    }
    
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(self.controller.renderedTemplates.count, equals: 1, message: "has 1 template in the list")
      if !self.controller.renderedTemplates.isEmpty {
        let template = self.controller.renderedTemplates[0] as? TestTemplate
        self.assert(template?.message, equals: "hello", message: "puts the right template in the list")
      }
      
    }
    
    controller.respondWith(TestTemplate(controller: controller, message: "hello"))
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testFilterForJsonWithStringReturnsString() {
    let input = "Test"
    let s = Controller.filterForJson(input) as? String
    self.assert(s, equals: input, message: "returns the string itself")
  }
  
  func testFilterForJsonWithNumberReturnsNumber() {
    let input = NSNumber(integer: 5)
    if let n = Controller.filterForJson(input) as? NSNumber {
      assert(n, equals: input, message: "returns the number itself")
    }
    else {
      XCTFail("returns the number itself")
    }
  }
  
  func testFilterForJsonWithIntReturnsInt() {
    let input = 17
    let i = Controller.filterForJson(input) as? Int
    assert(i, equals: input, message: "returns the number itself")
  }
  
  func testFilterFroJsonWithBoolReturnsBool() {
    let input = false
    if let b = Controller.filterForJson(input) as? Bool {
      assert(b, equals: input, message: "returns the boolean itself")
    }
    else {
      XCTFail("returns the boolean itself")
    }
  }
  
  func testFilterForJsonWithDateReturnsFormattedString() {
    let input = NSDate(timeIntervalSince1970: 1234512345)
    let s = Controller.filterForJson(input) as? String
    assert(s, equals: "2009-02-13 03:05:45", message: "returns the formatted date")
  }
  
  func testFilterForJsonWithRecordReturnsProperties() {
    let store = Store(name: "Shop")
    let result = Controller.filterForJson(store) as? [String:String] ?? [:]
    assert(result, equals: ["name": "Shop"], message: "returns the formatted attributes")
  }
  
  func testFilterForJsonWithArrayReturnsFilteredList() {
    let list = [
      Store(name: "Shop 1"),
      Store(name: "Shop 2")
    ]
    let result = Controller.filterForJson(list) as? [[String: String]] ?? []
    assert(result, equals: [["name": "Shop 1"], ["name": "Shop 2"]], message: "returns the formatted attributes")
  }
  
  func testFilterForJsonWithDictionaryReturnsFilteredDictionary() {
    let list = [
      "1": Store(name: "Shop 1"),
      "2": Store(name: "Shop 2")
    ]
    let result = Controller.filterForJson(list) as? [String: [String: String]] ?? [:]
    assert(result, equals: ["1": ["name": "Shop 1"], "2": ["name": "Shop 2"]], message: "returns the formatted attributes")
  }
  
  func testFilterForJsonWithCustomTypeReturnsNil() {
    let input = TestApplication.sharedApplication()
    XCTAssertNil(Controller.filterForJson(input), "returns nil")
  }
  
  func testRespondWithJsonGivesJsonResponse() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      let body = NSString(data: response.bodyData, encoding: NSUTF8StringEncoding)!
      self.assert(body, equals: "{\"key1\":\"value1\",\"key2\":\"value2\"}", message: "gives JSON response in body")
    }
    self.controller.respondWithJson([
      "key1": "value1",
      "key2": "value2"
    ])
    self.waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRespondWithJsonWithInvalidValueGives404() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.code, equals: 404, message: "gives a 404 response")
    }
    self.controller.respondWithJson(self.controller)
    self.waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRedirectToGeneratesRedirectResponse() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.code, equals: 302, message: "gives a 302 response")
      self.assert(response.headers, equals: ["Location": "/test/path"], message: "gives a location header")
    }
    self.controller.redirectTo("/test/path")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testPathForCanGetFullyQualifiedRoute() {
    let path = self.controller.pathFor(controllerName: TestController.name(), action: "index", parameters: ["id": "5"])
    assert(path, equals: "/route1?id=5", message: "gets the url for the controller and action")
  }
  
  func testPathForCanGetPathForSameAction() {
    self.controller = SecondTestController(
      request: Request(),
      action: "index",
      callback: { self.callback($0) }
    )
    let path = self.controller.pathFor(parameters: ["confirmed": "1"])
    assert(path, equals: "/route2?confirmed=1", message: "uses the same controller and action, but adds the parameters")
  }
  
  func testPathForCanGetUrlWithDomain() {
    let path = self.controller.pathFor(controllerName: TestController.name(), action: "index", parameters: ["id": "5"], domain: "test.com")
    assert(path, equals: "https://test.com/route1?id=5", message: "gets the url for the controller and action")
  }
  
  func testPathForGetsNilForInvalidCombination() {
    let path = self.controller.pathFor()
    XCTAssertNil(path, "gives a nil path")
  }
  
  func testRedirectToWithControllerNameGeneratesRedirectResponse() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.code, equals: 302, message: "gives a 302 response")
      self.assert(response.headers, equals: ["Location": "/route1"], message: "has a location header")
    }
    self.controller.redirectTo(controllerName: TestController.name(), action: "index")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRedirectToWithControllerTypeGeneratesRedirectResponse() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.code, equals: 302, message: "gives a 302 response")
      self.assert(response.headers, equals: ["Location": "/route1"], message: "has a location header")
    }
    self.controller.redirectTo(TestController.self, action: "index")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRender404Gives404Response() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.code, equals: 404, message: "gives a 404 response")
    }
    self.controller.render404()
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  //MARK: - Authentication
  
  func testSignInSetsCurrentUserAndStoresIdInSession() {
    let user2 = User(emailAddress: "test2@test.com", password: "test")
    user2.save()
    self.controller.signIn(user2)
    
    assert(self.controller.currentUser, equals: user2, message: "sets user")
    assert(self.controller.session["userId"], equals: String(user2.id!), message: "sets userId in session")
  }
  
  func testSignOutClearsCurrentUserAndIdInSession() {
    controller.signIn(user)
    controller.signOut()
    XCTAssertNil(controller.currentUser)
    XCTAssertNil(controller.session["userId"])
  }
  
  func testSignInWithEmailAndPasswordSignsIn() {
    controller.signIn("test@test.com", password: "test")
    self.assert(controller.currentUser, equals: user, message: "sets user as controller's current user")
  }
  
  func testSignInWithEmailAndPasswordReturnsTrue() {
    let result = controller.signIn("test@test.com", password: "test")
    XCTAssertTrue(result, "returns true")
  }
  
  func testSignInWithInvalidCombinationReturnsFalse() {
    let result = controller.signIn("test@test.com", password: "test2")
    XCTAssertFalse(result, "returns false")
  }
  
  //MARK: - Filters
  
  func testAddFiltersAddsFilterToList() {
    let expectation = expectationWithDescription("filter called")
    let filterMethod = {
      () -> Bool in
      expectation.fulfill()
      return true
    }
    controller.addFilter(only: ["index", "show"], except: ["edit"], filter: filterMethod)
    assert(controller.filters.count, equals: 1, message: "has one filter")
    if controller.filters.count == 1 {
      let filter = controller.filters[0]
      assert(filter.1, equals: ["index", "show"], message: "sets the list of allowed actions")
      assert(filter.2, equals: ["edit"], message: "sets the list of excluded actions")
      filter.0()
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRunFiltersReturnsFalseWhenFilterFails() {
    controller.addFilter { return false }
    let result = controller.runFilters()
    XCTAssertFalse(result, "returns false")
  }
  
  func testRunFiltersReturnTrueWhenFilterPasses() {
    controller.addFilter { return true }
    let result = controller.runFilters()
    XCTAssertTrue(result, "returns true")
  }
  
  func testRunFiltersReturnsTrueWithNoFilters() {
    let result = controller.runFilters()
    XCTAssertTrue(result, "returns true")
  }
  
  func testRunFiltersReturnsTrueWithNoFiltersForAction() {
    controller.addFilter(only: ["show"]) {
      return false
    }
    let result = controller.runFilters()
    XCTAssertTrue(result, "returns true")
  }
  
  func testRunFiltersReturnsTrueWithFilterThatExcludesAction() {
    controller.addFilter(except: ["index"]) {
      return false
    }
    let result = controller.runFilters()
    XCTAssertTrue(result, "returns true")
  }
  
  func testRunFiltersReturnsFalseWithFilterThatExcludesOtherAction() {
    controller.addFilter(except: ["show"]) {
      return false
    }
    let result = controller.runFilters()
    XCTAssertFalse(result, "returns false")
  }
  
  //MARK: - Localization
  
  func testLocalizationPrefixGetsUnderscoredControllerNameAndAction() {
    let controller = TestController(request: Request(), action: "index", callback: {_ in })
    let prefix = controller.localizationPrefix
    assert(prefix, equals: "tailor_tests.test_controller.index")
  }
  
  func testLocalizeWithNoLocaleUsesLocalization() {
    Application.sharedApplication().configuration["localization.content.en.controller.test.message"] = "Hello"
    let string = controller.localize("controller.test.message")
    assert(string, equals: "Hello", message: "returns the string from the localization")
  }
  
  func testLocalizeWithDotPrependsPrefix() {
    let key = ".test.message"
    let fullKey = controller.localizationPrefix + key
    Application.sharedApplication().configuration["localization.content.en.\(fullKey)"] = "Hello 2"
    let string = controller.localize(key)
    assert(string, equals: "Hello 2", message: "returns the string from the localization")
  }
  
  func testLocalizeWithLocaleSwitchesToThatLanguage() {
    Application.sharedApplication().configuration["localization.content.es.controller.test.message"] = "Hola"
    let string = controller.localize("controller.test.message", locale: "es")
    assert(string, equals: "Hola", message: "returns the string from the localization")
  }
  
  //MARK: - Test Helpers
  
  func testCallActionCanCallAction() {
    let expectation = expectationWithDescription("respond method called")
    class TestController: Controller {
      override func respond() {
        XCTAssertEqual(action, "runTest", "sets the controller's action")
        let value1 = request.requestParameters["test1"]
        XCTAssertNotNil(value1)
        if value1 != nil {
          XCTAssertEqual(value1!, "value1")
        }
        self.generateResponse {
          (inout response: Response) in
          response.appendString("Test Response")
        }
      }
    }
    
    TestController.callAction("runTest", Request(parameters: ["test1": "value1"])) {
      response, controller in
      expectation.fulfill()
      self.assert(response.bodyString, equals: "Test Response", message: "gets test response")
      
      if let castController = controller as? TestController {}
      else { XCTFail("gives a test controller") }
    }
    
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }
  
  func testCallActionCanCallActionWithImplicitRequest() {
    let expectation = expectationWithDescription("respond method called")
    TestController.callAction("index") {
      response, _ in
      expectation.fulfill()
      self.assert(response.bodyString, equals: "Index Action", message: "gets body from action")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testCallActionCanCallActionWithParameters() {
    let expectation = expectationWithDescription("respond method called")
    TestController.callAction("index", parameters: ["failFilter": "1"]) {
      response, _ in
      expectation.fulfill()
      self.assert(response.code, equals: 419, message: "gets response appropriate for parameters")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testCallActionCanCallActionWithUserAndParameters() {
    let expectation = expectationWithDescription("respond method called")
    let user = User(emailAddress: "test@test.com", password: "test")
    user.save()
    TestController.callAction("index", user: user, parameters: ["id": "5"]) {
      response, controller in
      expectation.fulfill()
      self.assert(controller.request.requestParameters, equals: ["id": "5"], message: "sets request parameters")
      let currentUser = controller.currentUser
      XCTAssertNotNil(currentUser, "has a user")
      if currentUser != nil { self.assert(currentUser!, equals: user, message: "has the user given") }
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testCallActionCanCallActionWithUser() {
    let expectation = expectationWithDescription("respond method called")
    let user = User(emailAddress: "test@test.com", password: "test")
    user.save()
    TestController.callAction("index", user: user) {
      response, controller in
      expectation.fulfill()
      let currentUser = controller.currentUser
      XCTAssertNotNil(currentUser, "has a user")
      if currentUser != nil { self.assert(currentUser!, equals: user, message: "has the user given") }
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
}
