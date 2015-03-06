import XCTest

class ControllerTests: XCTestCase {
  class TestController : Controller {
    required init(request: Request, action: String, callback: Server.ResponseCallback) {
      super.init(request: request, action: action, callback: callback)
      self.addFilter(self.checkParams)
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
    TestApplication.start()
    DatabaseConnection.sharedConnection().executeQuery("TRUNCATE TABLE users")
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
      request: Request(sessionData: ["userId": user.id.stringValue]),
      action: "index",
      callback: {
        (response) in
      }
    )
    XCTAssertNotNil(controller.currentUser, "fetches a user")
    if controller.currentUser != nil {
      XCTAssertEqual(controller.currentUser!, user, "sets user to the one with the id given")
    }
  }
  
  func testInitializerSetsUserToNilWithBadId() {
    controller = Controller(
      request: Request(sessionData: ["userId": String(user.id.integerValue + 1)]),
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
        XCTAssertEqual(response.bodyData, data!, "gives the expected response body")
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
        XCTAssertEqual(response.code, 404, "gives a 404 response")
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
        XCTAssertEqual(response.code, 419, "gives a 419 response, from the filter")
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
      XCTAssertEqual(response.code, 123, "has the response code from the block given to generateResponse")
    }
    
    controller.generateResponse { (inout r: Response) in r.code = 123 }
    
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testGenerateResponseWillNotRespondTwice() {
    var callCount = 0
    self.callback = {
      response in
      callCount += 1
      XCTAssertEqual(response.code, 123, "has the response code from the block given to generateResponse")
    }
    
    controller.generateResponse { (inout r: Response) in r.code = 123 }
    controller.generateResponse { (inout r: Response) in r.code = 456 }

    XCTAssertEqual(callCount, 1, "only calls the callback once")
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
        XCTAssertEqual(response.cookies.cookieDictionary(), [
          "cookie1": "value1",
          "cookie2": "value2",
          "_session": self.controller.session.cookieString()
        ], "gets old cookies, new cookies, and session info")
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
      XCTAssertEqual(body, "<html><body><p>Nesting</p></body></html>", "sets body")
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
      XCTAssertEqual(self.controller.renderedTemplates.count, 1, "has 1 template in the list")
      if !self.controller.renderedTemplates.isEmpty {
        if let template = self.controller.renderedTemplates[0] as? TestTemplate {
          XCTAssertEqual(template.message, "hello", "puts the right template in the list")
        }
        else {
          XCTFail("Puts the right template in the list")
        }
      }
      
    }
    
    controller.respondWith(TestTemplate(controller: controller, message: "hello"))
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testFilterForJsonWithStringReturnsString() {
    let input = "Test"
    if let s = Controller.filterForJson(input) as? String {
      XCTAssertEqual(s, input, "returns the string itself")
    }
    else {
      XCTFail("returns the string itself")
    }
  }
  
  func testFilterForJsonWithNumberReturnsNumber() {
    let input = NSNumber(integer: 5)
    if let n = Controller.filterForJson(input) as? NSNumber {
      XCTAssertEqual(n, input, "returns the number itself")
    }
    else {
      XCTFail("returns the number itself")
    }
  }
  
  func testFilterForJsonWithIntReturnsInt() {
    let input = 17
    if let i = Controller.filterForJson(input) as? Int {
      XCTAssertEqual(i, input, "returns the number itself")
    }
    else {
      XCTFail("returns the number itself")
    }
  }
  
  func testFilterFroJsonWithBoolReturnsBool() {
    let input = false
    if let b = Controller.filterForJson(input) as? Bool {
      XCTAssertEqual(b, input, "returns the boolean itself")
    }
    else {
      XCTFail("returns the boolean itself")
    }
  }
  
  func testFilterForJsonWithDateReturnsFormattedString() {
    let input = NSDate(timeIntervalSince1970: 1234512345)
    if let s = Controller.filterForJson(input) as? String {
      XCTAssertEqual(s, "2009-02-13 03:05:45", "returns the formatted date")
    }
    else {
      XCTFail("returns the formatted date")
    }
  }
  
  func testFilterForJsonWithRecordReturnsProperties() {
    let hat = Store(data: ["name": "Shop"])
    if let result = Controller.filterForJson(hat) as? [String:String] {
      XCTAssertEqual(result, ["name": "Shop"], "returns the formatted attributes")
    }
    else {
      XCTFail("rturns the formatted attributes")
    }
  }
  
  func testFilterForJsonWithArrayReturnsFilteredList() {
    let list = [
      Store(data: ["name": "Shop 1"]),
      Store(data: ["name": "Shop 2"])
    ]
    if let result = Controller.filterForJson(list) as? [[String: String]] {
      XCTAssertEqual(result, [["name": "Shop 1"], ["name": "Shop 2"]], "returns the formatted attributes")
    }
    else {
      XCTFail("returns the formatted attributes")
    }
  }
  
  func testFilterForJsonWithDictionaryReturnsFilteredDictionary() {
    let list = [
      "1": Store(data: ["name": "Shop 1"]),
      "2": Store(data: ["name": "Shop 2"])
    ]
    if let result = Controller.filterForJson(list) as? [String: [String: String]] {
      XCTAssertEqual(result, ["1": ["name": "Shop 1"], "2": ["name": "Shop 2"]], "returns the formatted attributes")
    }
    else {
      XCTFail("returns the formatted attributes")
    }
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
      XCTAssertEqual(body, "{\"key1\":\"value1\",\"key2\":\"value2\"}", "gives JSON response in body")
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
      XCTAssertEqual(response.code, 404, "gives a 404 response")
    }
    self.controller.respondWithJson(self.controller)
    self.waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRedirectToGeneratesRedirectResponse() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      XCTAssertEqual(response.code, 302, "gives a 302 response")
      XCTAssertEqual(response.headers, ["Location": "/test/path"], "gives a location header")
    }
    self.controller.redirectTo("/test/path")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testPathForCanGetFullyQualifiedRoute() {
    let path = self.controller.pathFor(controllerName: TestController.name(), action: "index", parameters: ["id": "5"])
    
    XCTAssertNotNil(path, "has a URL")
    if path != nil {
      XCTAssertEqual(path!, "/route1?id=5", "gets the url for the controller and action")
    }
  }
  
  func testPathForCanGetPathForSameAction() {
    self.controller = SecondTestController(
      request: Request(),
      action: "index",
      callback: { self.callback($0) }
    )
    let path = self.controller.pathFor(parameters: ["confirmed": "1"])
    XCTAssertNotNil(path, "has a URL")
    if path != nil {
      XCTAssertEqual(path!, "/route2?confirmed=1", "uses the same controller and action, but adds the parameters")
    }
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
      XCTAssertEqual(response.code, 302, "gives a 302 response")
      XCTAssertEqual(response.headers, ["Location": "/route1"], "has a location header")
    }
    self.controller.redirectTo(controllerName: TestController.name(), action: "index")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRedirectToWithControllerTypeGeneratesRedirectResponse() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      XCTAssertEqual(response.code, 302, "gives a 302 response")
      XCTAssertEqual(response.headers, ["Location": "/route1"], "has a location header")
    }
    self.controller.redirectTo(TestController.self, action: "index")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRender404Gives404Response() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      XCTAssertEqual(response.code, 404, "gives a 404 response")
    }
    self.controller.render404()
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  //MARK: - Authentication
  
  func testSignInSetsCurrentUserAndStoresIdInSession() {
    let user2 = User(emailAddress: "test2@test.com", password: "test")
    user2.save()
    self.controller.signIn(user2)
    
    if let user = self.controller.currentUser {
      XCTAssertEqual(user, user2, "sets user")
    }
    else {
      XCTFail("sets user")
    }
    
    if let id = self.controller.session["userId"] {
      XCTAssertEqual(id, user2.id.stringValue, "sets userId in session")
    }
    else {
      XCTFail("sets userId in session")
    }
  }
  
  func testSignOutClearsCurrentUserAndIdInSession() {
    controller.signIn(user)
    controller.signOut()
    XCTAssertNil(controller.currentUser)
    XCTAssertNil(controller.session["userId"])
  }
  
  func testSignInWithEmailAndPasswordSignsIn() {
    controller.signIn("test@test.com", password: "test")
    XCTAssertNotNil(controller.currentUser)
    if controller.currentUser != nil {
      XCTAssertEqual(controller.currentUser!, user, "sets user as controller's current user")
    }
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
    controller.addFilter(filterMethod, only: ["index", "show"], except: ["edit"])
    XCTAssertEqual(controller.filters.count, 1, "has one filter")
    if controller.filters.count == 1 {
      let filter = controller.filters[0]
      XCTAssertEqual(filter.1, ["index", "show"], "sets the list of allowed actions")
      XCTAssertEqual(filter.2, ["edit"], "sets the list of excluded actions")
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
    controller.addFilter({
      return false
    }, only: ["show"])
    let result = controller.runFilters()
    XCTAssertTrue(result, "returns true")
  }
  
  func testRunFiltersReturnsTrueWithFilterThatExcludesAction() {
    controller.addFilter({
      return false
      }, except: ["index"])
    let result = controller.runFilters()
    XCTAssertTrue(result, "returns true")
  }
  
  func testRunFiltersReturnsFalseWithFilterThatExcludesOtherAction() {
    controller.addFilter({
      return false
    }, except: ["show"])
    let result = controller.runFilters()
    XCTAssertFalse(result, "returns false")
  }
  
  //MARK: - Localization
  
  func testLocalizationPrefixGetsUnderscoredControllerNameAndAction() {
    let controller = TestController(request: Request(), action: "index", callback: {_ in })
    let prefix = controller.localizationPrefix
    XCTAssertEqual(prefix, "tailor_tests.test_controller.index")
  }
  
  func testLocalizeWithNoLocaleUsesLocalization() {
    Application.sharedApplication().configuration["localization.content.en.controller.test.message"] = "Hello"
    let string = controller.localize("controller.test.message")
    XCTAssertNotNil(string, "returns a string")
    if string != nil {
      XCTAssertEqual(string!, "Hello", "returns the string from the localization")
    }
  }
  
  func testLocalizeWithDotPrependsPrefix() {
    let key = ".test.message"
    let fullKey = controller.localizationPrefix + key
    Application.sharedApplication().configuration["localization.content.en.\(fullKey)"] = "Hello 2"
    let string = controller.localize(key)
    XCTAssertNotNil(string, "returns a string")
    if string != nil {
      XCTAssertEqual(string!, "Hello 2", "returns the string from the localization")
    }
  }
  
  func testLocalizeWithLocaleSwitchesToThatLanguage() {
    Application.sharedApplication().configuration["localization.content.es.controller.test.message"] = "Hola"
    let string = controller.localize("controller.test.message", locale: "es")
    XCTAssertNotNil(string, "returns a string")
    if string != nil {
      XCTAssertEqual(string!, "Hola", "returns the string from the localization")
    }
  }
  
  //MARK: - Test Helpers
  
  func testCallActionCanCallAction() {
    let expectation = expectationWithDescription("respond method called")
    class TestController: Controller {
      override func respond() {
        XCTAssertEqual(action, "runTest", "sets the controller's action")
        let value1 = request.requestParameters["test1"]
        XCTAssertEqual(value1!, "value1")
        self.generateResponse {
          (inout response: Response) in
          response.appendString("Test Response")
        }
      }
    }
    
    TestController.callAction("runTest", Request(parameters: ["test1": "value1"])) {
      response, controller in
      expectation.fulfill()
      XCTAssertEqual(response.bodyString, "Test Response", "gets test response")
      
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
      XCTAssertEqual(response.bodyString, "Index Action", "gets body from action")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testCallActionCanCallActionWithParameters() {
    let expectation = expectationWithDescription("respond method called")
    TestController.callAction("index", parameters: ["failFilter": "1"]) {
      response, _ in
      expectation.fulfill()
      XCTAssertEqual(response.code, 419, "gets response appropriate for parameters")
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
      XCTAssertEqual(controller.request.requestParameters, ["id": "5"], "sets request parameters")
      let currentUser = controller.currentUser
      XCTAssertNotNil(currentUser, "has a user")
      if currentUser != nil { XCTAssertEqual(currentUser!, user, "has the user given") }
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
      if currentUser != nil { XCTAssertEqual(currentUser!, user, "has the user given") }
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
}
