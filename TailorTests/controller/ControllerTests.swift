import XCTest
import Tailor
import TailorTesting

class ControllerTests: TailorTestCase {
  struct TestController : ControllerType {
    static var name: String {
      return "TailorTests.TestController"
    }
    var state: ControllerState
    static func defineRoutes(routes: RouteSet) {
      routes.route(.Get("route1"), to: indexAction, name: "index")
      routes.route(.Get("route1/:id"), to: showAction, name: "show")
    }
    
    func checkParams() -> Bool {
      if request.requestParameters["failFilter"] != nil {
        var response = Response()
        response.code = 419
        self.callback(response)
        return false
      }
      return true
    }
    
    func indexAction() {
      var response = Response()
      response.code = 200
      response.appendString("Index Action")
      self.callback(response)
    }
    
    func showAction() {
      var response = Response()
      response.code = 200
      response.appendString("Show Action")
      self.callback(response)
    }
    
    static var layout: LayoutType.Type = EmptyLayout.self
  }
  
  struct SecondTestController : ControllerType {
    static var name: String {
      return "TailorTests.SecondTestController"
    }
    var state: ControllerState
    static func defineRoutes(routes: RouteSet) {
      routes.route(.Get("route2"), to: indexAction, name: "index")
    }
    
    func indexAction() {
      
    }
  }
  
  var user: User!
  var callback: Connection.ResponseCallback = {response in }
  var controller: ControllerType!
  var routeSet = RouteSet()
  
  override func setUp() {
    super.setUp()
    
    user = User(emailAddress: "test@test.com", password: "test").save()!
    
    RouteSet.load { routes in
      TestController.defineRoutes(routes)
      SecondTestController.defineRoutes(routes)
    }
    
    controller = TestController(
      request: Request(),
      actionName: "index",
      callback: {
        response in
        self.callback(response)
      }
    )
  }
  
  override func tearDown() {
    RouteSet.load { routes in }
  }
  
  func testInitializeSetsUserFromIdInSession() {
    controller = TestController(
      request: Request(sessionData: ["userId": String(user.id!)]),
      actionName: "index",
      callback: {
        (response) in
      }
    )
    assert(controller.currentUser, equals: user, message: "sets user to the one with the id given")
  }
  
  func testInitializerSetsUserToNilWithBadId() {
    controller = TestController(
      request: Request(sessionData: ["userId": String(user.id! + 1)]),
      actionName: "index",
      callback: {
        (response) in
      }
    )
    XCTAssertNil(controller.currentUser, "sets user to nil")
  }
  
  func testInitializerSetsUserToNilWithNoId() {
    controller = TestController(
      request: Request(),
      actionName: "index",
      callback: {
        (response) in
      }
    )
    XCTAssertNil(controller.currentUser, "sets user to nil")
  }
  
  func testInitializeStateWithAllFieldsSetsAllFields() {
    let request = Request()
    let session = Session(request: request)
    let user = User(emailAddress: "test@test.com", password: "12341234").save()!
    let state = ControllerState(request: request, callback: {_ in}, session: session, actionName: "show", currentUser: user, localization: PropertyListLocalization(locale: "es"))
    assert(state.request, equals: request)
    assert(state.actionName, equals: "show")
    assert(state.currentUser, equals: user)
    assert(state.localization.locale, equals: "es")
  }
  
  //MARK: - Responses
  
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
  
  func testGenerateResponseSetsCookies() {
    let expectation = expectationWithDescription("callback called")
    controller = TestController(
      request: Request(cookies: ["cookie1": "value1"]),
      actionName: "index",
      callback: { self.callback($0) }
    )
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.cookies.cookieDictionary(), equals: [
        "cookie1": "value1",
        "cookie2": "value2",
        "_session": self.controller.session.cookieString()
        ], message: "gets old cookies, new cookies, and session info")
    }
    
    controller.generateResponse {
      (inout response: Response)->Void in
      response.cookies["cookie2"] = "value2"
    }
    
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testGenerateResponseWithSessionSetsSessionInfoOnResponse() {
    let expectation = expectationWithDescription("callback called")
    
    self.callback = {
      response in
      expectation.fulfill()
      let newRequest = Request(cookies: response.cookies.cookieDictionary())
      let session = Session(request: newRequest)
      self.assert(session["test"], equals: "value")
    }
    
    controller.generateResponse {
      response -> Session in
      var session = controller.session
      session["test"] = "value"
      return session
    }
    
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRespondWithRendersTemplateInLayout() {
    let expectation = expectationWithDescription("callback called")
    struct TestTemplate: TemplateType {
      var state: TemplateState

      init(controller: ControllerType) {
        self.state = TemplateState(controller)
      }

      mutating func body() {
        tag("p", text: "Nesting")
      }
    }
    struct TestLayout: LayoutType {
      var state: TemplateState
      let template: TemplateType
      
      init(controller: ControllerType, template: TemplateType) {
        self.state = TemplateState(controller)
        self.template = template
      }
      
      mutating func body() {
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
      let body = response.bodyString
      self.assert(body, equals: "<html><body><p>Nesting</p></body></html>", message: "sets body")
    }
    
    TestController.layout = TestLayout.self
    controller.respondWith(TestTemplate(controller: controller))
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRespondWithAddsTemplateToList() {
    let expectation = expectationWithDescription("callback called")
    struct TestTemplate: TemplateType {
      var state: TemplateState
      let message: String
      
      init(controller: ControllerType, message: String = "") {
        self.state = TemplateState(controller)
        self.message = message
      }
      
      mutating func body() {
        tag("p", text: message)
      }
    }
    
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.renderedTemplates.count, equals: 1, message: "has 1 template in the list")
      if !response.renderedTemplates.isEmpty {
        let template = response.renderedTemplates[0] as? TestTemplate
        self.assert(template?.message, equals: "hello", message: "puts the right template in the list")
      }
    }
    
    controller.respondWith(TestTemplate(controller: controller, message: "hello"))
    waitForExpectationsWithTimeout(0.01, handler: nil)
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
  
  func testRedirectToWithSessionGeneratesRedirectResponse() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.code, equals: 302, message: "gives a 302 response")
      self.assert(response.headers, equals: ["Location": "/test/path"], message: "gives a location header")
      
      let session = Session(request: Request(cookies: response.cookies.cookieDictionary()))
      self.assert(session["test1"], equals: "value1")
    }
    var newSession = controller.session
    newSession["test1"] = "value1"
    self.controller.redirectTo("/test/path", session: newSession)
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }

  @available(*, deprecated) func testPathForWithNameCanGetFullyQualifiedRoute() {
    let path = self.controller.pathFor(SecondTestController.name, actionName: "index", parameters: ["name": "John"])
    assert(path, equals: "/route2?name=John", message: "gets the url for the controller and action")
  }
  
  @available(*, deprecated) func testPathForWithNameWithOmittedInformationRoutesToCurrentPath() {
    let path = self.controller.pathFor(nil, parameters: ["name": "John"])
    assert(path, equals: "/route1?name=John", message: "gets the url for the controller and action")
  }
  
  @available(*, deprecated) func testPathForWithNameWithParametersInPathReusesThoseParameters() {
    controller = TestController(
      request: Request(parameters: ["id": "10"]),
      actionName: "show",
      callback: {
        response in
        self.callback(response)
      }
    )
    let path = self.controller.pathFor(TestController.name, actionName: "show")
    assert(path, equals: "/route1/10", message: "gets the url for the controller and action")
  }
  
  func testPathForCanGetFullyQualifiedRoute() {
    let path = self.controller.pathFor(TestController.self, actionName: "index", parameters: ["id": "5"])
    assert(path, equals: "/route1?id=5", message: "gets the url for the controller and action")
  }
  
  func testPathForCanGetPathForSameAction() {
    self.controller = SecondTestController(
      request: Request(),
      actionName: "index",
      callback: { self.callback($0) }
    )
    let path = self.controller.pathFor(parameters: ["confirmed": "1"])
    assert(path, equals: "/route2?confirmed=1", message: "uses the same controller and action, but adds the parameters")
  }
  
  func testPathForWithParametersInPathReusesParameters() {
    controller = TestController(
      request: Request(parameters: ["id": "10"]),
      actionName: "show",
      callback: {
        response in
        self.callback(response)
      }
    )
    let path = self.controller.pathFor(TestController.self, actionName: "show")
    assert(path, equals: "/route1/10", message: "gets the url for the controller and action")
  }
  
  @available(*, deprecated) func testPathWithNameForCanGetUrlWithDomain() {
    let path = self.controller.pathFor(TestController.name, actionName: "index", parameters: ["id": "5"], domain: "test.com")
    assert(path, equals: "https://test.com/route1?id=5", message: "gets the url for the controller and action")
  }
  
  func testPathForCanGetUrlWithDomain() {
    let path = self.controller.pathFor(TestController.self, actionName: "index", parameters: ["id": "5"], domain: "test.com")
    assert(path, equals: "https://test.com/route1?id=5", message: "gets the url for the controller and action")
  }
  
  func testPathForGetsNilForInvalidCombination() {
    let path = self.controller.pathFor(actionName: "new")
    XCTAssertNil(path, "gives a nil path")
  }
  
  @available(*, deprecated) func testRedirectToWithControllerNameGeneratesRedirectResponse() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.code, equals: 302, message: "gives a 302 response")
      self.assert(response.headers, equals: ["Location": "/route1"], message: "has a location header")
    }
    self.controller.redirectTo(TestController.name, actionName: "index")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  @available(*, deprecated) func testRedirectToWithControllerNameWithSessionGeneratesRedirectResponse() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.code, equals: 302, message: "gives a 302 response")
      self.assert(response.headers, equals: ["Location": "/route1"], message: "has a location header")
      
      let session = Session(request: Request(cookies: response.cookies.cookieDictionary()))
      self.assert(session["test2"], equals: "value2")
    }
    var newSession = controller.session
    newSession["test2"] = "value2"

    self.controller.redirectTo(TestController.name, actionName: "index", session: newSession)
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  @available(*, deprecated) func testRedirectToWithControllerNameWithInvalidPathRedirectsToRootPath() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.code, equals: 302, message: "gives a 302 response")
      self.assert(response.headers, equals: ["Location": "/"], message: "has a location header")
    }
    
    self.controller.redirectTo(TestController.name, actionName: "foo")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRedirectToWithControllerTypeGeneratesRedirectResponse() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.code, equals: 302, message: "gives a 302 response")
      self.assert(response.headers, equals: ["Location": "/route2"], message: "has a location header")
    }
    self.controller.redirectTo(SecondTestController.self, actionName: "index")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRedirectToWithoutControllerTypeGeneratesRedirectToCurrentController() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.code, equals: 302, message: "gives a 302 response")
      self.assert(response.headers, equals: ["Location": "/route1"], message: "has a location header")
    }
    self.controller.redirectTo(actionName: "index")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRedirectToWithControllerTypeWithSessionGeneratesRedirectResponse() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.code, equals: 302, message: "gives a 302 response")
      self.assert(response.headers, equals: ["Location": "/route1"], message: "has a location header")
      
      let session = Session(request: Request(cookies: response.cookies.cookieDictionary()))
      self.assert(session["test3"], equals: "value3")
    }
    var newSession = controller.session
    newSession["test3"] = "value3"
    
    self.controller.redirectTo(TestController.self, actionName: "index", session: newSession)
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRedirectToWithControllerTypeWithBadRouteGeneratesRedirectToRootPath() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.code, equals: 302, message: "gives a 302 response")
      self.assert(response.headers, equals: ["Location": "/"], message: "has a location header")
    }
    self.controller.redirectTo(TestController.self, actionName: "foo")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRespondWithJsonGeneratesJsonResponse() {
    do {
      let hat = Hat(brimSize: 10, color: "red", shelfId: nil, owner: nil, id: nil)
      let data = try hat.toJson().jsonData()
      let expectation = expectationWithDescription("callback called")
      self.callback = {
        response in
        expectation.fulfill()
        self.assert(response.code, equals: 200, message: "gives a success response")
        self.assert(response.headers, equals: ["Content-Type": "application/json"])
        self.assert(response.body, equals: data)
      }
      self.controller.respondWith(json: hat)
      waitForExpectationsWithTimeout(0.01, handler: nil)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testRespondWithJsonWithStringGives500Response() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.code, equals: 500, message: "gives an error response")
    }
    self.controller.respondWith(json: "Hat")
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
  
  func testDefaultLayoutIsEmptyLayout() {
    struct TestTemplate: TemplateType {
      var state: TemplateState
      mutating func body() {
        text("Hello")
      }
    }
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.bodyString, equals: "Hello")
    }
    
    
    controller = SecondTestController(
      request: Request(),
      actionName: "index",
      callback: {
        response in
        self.callback(response)
      }
    )

    controller.respondWith(TestTemplate(state: TemplateState(controller)))
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  //MARK: - Authentication
  
  func testSignInSetsCurrentUserAndStoresIdInSession() {
    let user2 = User(emailAddress: "test2@test.com", password: "test").save()!
    
    let newSession = self.controller.signIn(user2)
    
    assert(newSession["userId"], equals: String(user2.id!), message: "sets userId in session")
  }
  
  func testSignInWithNewUserSetsUserIdToZero() {
    let user2 = User(emailAddress: "test2@test.com", password: "test")
    let newSession = self.controller.signIn(user2)
    assert(newSession["userId"], equals: "0", message: "sets userId to zero")
  }
  
  func testSignOutClearsCurrentUserAndIdInSession() {
    controller.signIn(user)
    controller.signOut()
    XCTAssertNil(controller.currentUser)
    XCTAssertNil(controller.session["userId"])
  }
  
  func testSignInWithEmailAndPasswordSignsIn() {
    let result = controller.signIn("test@test.com", password: "test")
    self.assert(isNotNil: result)
    self.assert(result?["userId"], equals: String(user.id!), message: "sets user as current user in new session")
  }
  
  func testSignInWithInvalidCombinationReturnsNil() {
    let result = controller.signIn("test@test.com", password: "test2")
    self.assert(isNil: result)
  }
  
  //MARK: - Localization
  
  func testLocalizationPrefixGetsUnderscoredControllerNameAndAction() {
    let controller = TestController(request: Request(), actionName: "index", callback: {_ in })
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
    struct TestController: ControllerType {
      var state: ControllerState
      static func defineRoutes(routes: RouteSet) {
        
      }
      func index() {
        XCTAssertEqual(actionName, "runTest", "sets the controller's action")
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
    
    TestController.callAction("runTest", TestController.index, Request(parameters: ["test1": "value1"])) {
      response, controller in
      expectation.fulfill()
      self.assert(response.bodyString, equals: "Test Response", message: "gets test response")
    }
    
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }
  
  func testCallActionCanCallActionWithImplicitRequest() {
    let expectation = expectationWithDescription("respond method called")
    TestController.callAction("index", TestController.indexAction) {
      response, _ in
      expectation.fulfill()
      self.assert(response.bodyString, equals: "Index Action", message: "gets body from action")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testCallActionCanCallActionWithParameters() {
    let expectation = expectationWithDescription("respond method called")
    struct TestController: ControllerType {
      var state: ControllerState
      static func defineRoutes(routes: RouteSet) {
        
      }
      func index() {
        XCTAssertEqual(actionName, "runTest", "sets the controller's action")
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
    
    TestController.callAction("runTest", TestController.index, parameters: ["test1": "value1"]) {
      response, controller in
      expectation.fulfill()
      self.assert(response.bodyString, equals: "Test Response", message: "gets test response")
    }
    
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testCallActionCanCallActionWithUserAndParameters() {
    let expectation = expectationWithDescription("respond method called")
    let user = User(emailAddress: "test@test.com", password: "test").save()!
    TestController.callAction("index", TestController.indexAction, user: user, parameters: ["id": "5"]) {
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
    let user = User(emailAddress: "test@test.com", password: "test").save()!
    TestController.callAction("index", TestController.indexAction, user: user) {
      response, controller in
      expectation.fulfill()
      let currentUser = controller.currentUser
      XCTAssertNotNil(currentUser, "has a user")
      if currentUser != nil { self.assert(currentUser!, equals: user, message: "has the user given") }
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
}
