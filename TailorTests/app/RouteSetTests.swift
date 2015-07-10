import XCTest
import Tailor
import TailorTesting

class RouteSetTests: TailorTestCase {
  var routeSet = RouteSet()
  
  struct TestController : ControllerType {
    static var name: String { return "TestController" }
    var state: ControllerState
    static let layout = EmptyLayout.self
    
    static func defineRoutes(routes: RouteSet) {
      routes.withScope(path: "hats") {
        routes.route(.Get(""), to: indexAction, name: "index")
        routes.route(.Get(":id"), to: showAction, name: "show")
      }
    }
    
    func indexAction() {
      generateResponse {
        (inout response: Response) in
        response.appendString("Test Controller: index")
      }
    }
    
    func showAction() {
      generateResponse {
        (inout response: Response) -> Void in
        let id = request.requestParameters["id"] ?? "None"
        response.appendString("Test Controller: show \(id)")
      }
    }
  }
  
  override func setUp() {
    super.setUp()
  }
  
  func createTestRoute(pattern: String) -> RouteSet.Route {
    return RouteSet.Route(path: .Get(pattern), handler: {
      request, responseHandler in
      }, description: "test route")
  }
  
  func getLatestRoute() -> RouteSet.Route? {
    return routeSet.routes.isEmpty ? nil : routeSet.routes[routeSet.routes.count - 1]
  }
  
  func createTestRequest(path: String = "/") -> Request {
    let body = "GET \(path) HTTP/1.1\r\n\r\n"
    return Request(clientAddress: "0.0.0.0", data: body.dataUsingEncoding(NSUTF8StringEncoding)!)
  }
  
  func testInitializationSetsFieldsFromParameters() {
    let route = createTestRoute("/test/route")
    assert(route.path.pathPattern, equals: "/test/route", message: "sets path pattern")
    assert(route.path.methodName, equals: "GET", message: "sets method")
    assert(route.description, equals: "test route")
    
    let regex = try! NSRegularExpression(pattern: "^/test/route/?$", options: [])
    assert(route.regex, equals: regex, message: "sets path regex")
  }
  
  //MARK: - Route Class
  
  func testInitializationReplacesParameterSections() {
    let route = createTestRoute("/test/user/:id")
    assert(route.path.pathPattern, equals: "/test/user/:id", message: "sets path pattern to unmodified pattern")
    
    let regex = try! NSRegularExpression(pattern: "^/test/user/([^/]*)/?$", options: [])
    assert(route.regex, equals: regex, message: "sets path regex to pattern with parameter replaces by wildcard")
  }
  
  func testInitializationAddsParameterToPathParameters() {
    let route = createTestRoute("/test/user/:id")
    assert(route.pathParameters, equals: ["id"], message: "puts id in the path parameters")
  }
  
  func testFullDescriptionContainsMethodPatternAndDescription() {
    let route = createTestRoute("/test/route")
    assert(route.fullDescription(), equals: "GET /test/route test route", message: "give full description")
  }

  func testCanHandleRequestThatMatchesRegex() {
    let route = createTestRoute("/test/route/[A-Z]*")
    XCTAssertTrue(route.canHandleRequest(createTestRequest("/test/route/ABC")), "can handle matching route")
    XCTAssertFalse(route.canHandleRequest(createTestRequest("/test/route/123")), "cannot handle route that doesn't match regex")
    XCTAssertFalse(route.canHandleRequest(createTestRequest("/test/other_route")), "cannot handle route that doesn't match base of route")
  }
  
  func testHandleRequestCallsHandler() {
    let expectation = expectationWithDescription("handler called")
    let route = RouteSet.Route(path: .Get("/test/route"), handler: {
      request, responseHandler in
      expectation.fulfill()
      }, description: "test route")
    route.handleRequest(createTestRequest("/test/route")) {
      response in
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testHandleRequestGivesHandlerParametersFromPath() {
    let expectation = expectationWithDescription("handler called")
    let route = RouteSet.Route(path: .Get("/test/route/:id"), handler: {
      request, responseHandler in
      self.assert(request.requestParameters["id"], equals: "5")
      expectation.fulfill()
      }, description: "test route")
    route.handleRequest(createTestRequest("/test/route/5")) {
      response in
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  //MARK: - RoutePath Enum
  
  func testBuildRoutePathWithGetMakesGetRoute() {
    let path = RouteSet.RoutePath.build("GET", pathPattern: "/test/1")
    assert(path, equals: .Get("/test/1"))
  }
  
  func testBuildRoutePathWithPostMakesPostRoute() {
    let path = RouteSet.RoutePath.build("POST", pathPattern: "/test/2")
    assert(path, equals: .Post("/test/2"))
  }
  
  func testBuildRoutePathWithPatchReturnsNil() {
    let path = RouteSet.RoutePath.build("PATCH", pathPattern: "/test/1")
    assert(isNil: path)
  }
  
  func testPathPatternForGetReturnsPathPattern() {
    let path = RouteSet.RoutePath.Get("/test/3")
    assert(path.pathPattern, equals: "/test/3")
  }
  
  func testPathPatternForPostReturnsPathPattern() {
    let path = RouteSet.RoutePath.Post("/test/4")
    assert(path.pathPattern, equals: "/test/4")
  }
  
  func testMethodNameForGetReturnsGet() {
    let path = RouteSet.RoutePath.Get("/test/3")
    assert(path.methodName, equals: "GET")
  }
  
  func testMethodNameForPostReturnsPost() {
    let path = RouteSet.RoutePath.Post("/test/4")
    assert(path.methodName, equals: "POST")
  }
  
  func testDescriptionForGetContainsMethodNameAndPath() {
    let path = RouteSet.RoutePath.Get("/test/3")
    assert(path.description, equals: "GET /test/3")
  }
  
  func testDescriptionPostContainsMethodNameAndPath() {
    let path = RouteSet.RoutePath.Post("/test/4")
    assert(path.description, equals: "POST /test/4")
  }
  
  func testRoutePathsWithSameMethodAndPatternAreEqual() {
    let path1 = RouteSet.RoutePath.Get("/test/1")
    let path2 = RouteSet.RoutePath.Get("/test/1")
    assert(path1, equals: path2)
  }
  
  func testRoutePathsWithDifferentPatternsAreNotEqual() {
    let path1 = RouteSet.RoutePath.Get("/test/1")
    let path2 = RouteSet.RoutePath.Get("/test/2")
    assert(path1, doesNotEqual: path2)
  }
  
  func testRoutePathsWithDifferentMethodsAreNotEqual() {
    let path1 = RouteSet.RoutePath.Get("/test/1")
    let path2 = RouteSet.RoutePath.Post("/test/1")
    assert(path1, doesNotEqual: path2)
  }
  
  //MARK: - Adding Routes
  
  @available(*, deprecated) func testWithPrefixSetsPrefixForBlock() {
    let expectation = expectationWithDescription("handler called")
    routeSet.withPrefix("path") {
      expectation.fulfill()
      self.routeSet.addRoute("test", method: "GET") {
        request, callback in
      }
      self.assert(self.getLatestRoute()?.pathPattern, equals: "/path/test", message: "includes prefix in route in block")
    }
    routeSet.addRoute("test", method: "GET") {
      request, callback in
    }
    assert(getLatestRoute()?.pathPattern, equals: "/test", message: "does not include prefix in route outside of block")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  @available(*, deprecated) func testWithPrefixSetsControllerForBlock() {
    let expectation = expectationWithDescription("handler called")
    routeSet.withPrefix("path", controller: Controller.self) {
      expectation.fulfill()
      self.routeSet.addRoute("test", method: "GET") {
        request, callback in
      }
      let controller = self.getLatestRoute()?.controller
      self.assert(controller?.name, equals: "Tailor.Controller", message: "includes controller in route in block")
    }
    routeSet.addRoute("test", method: "GET") {
      request, callback in
    }
    let controller = self.getLatestRoute()?.controller
    assert(isNil: controller, message: "uses default controller in route in block")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }

  func testWithScopeSetsPathPrefixForBlock() {
    let expectation = expectationWithDescription("handler called")
    routeSet.withScope(path: "path") {
      expectation.fulfill()
      self.routeSet.addRoute(.Get("test")) {
        request, callback in
      }
      self.assert(self.getLatestRoute()?.path.pathPattern, equals: "/path/test", message: "includes prefix in route in block")
    }
    routeSet.addRoute(.Get("test")) {
      request, callback in
    }
    assert(getLatestRoute()?.path.pathPattern, equals: "/test", message: "does not include prefix in route outside of block")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testWithScopeWithNoPathDoesNotAddPrefix() {
    let expectation = expectationWithDescription("handler called")
    routeSet.withScope() {
      expectation.fulfill()
      self.routeSet.addRoute(.Get("test")) {
        request, callback in
      }
      self.assert(self.getLatestRoute()?.path.pathPattern, equals: "/test", message: "includes normal path in route in block")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testWithScopeWithPassingFilterCallsHandler() {
    let expectation = expectationWithDescription("filter called")
    let filter: (TestController)->Void->Bool = {
      controller in
      return {
        expectation.fulfill()
        self.assert(true, message: "calls filter")
        return true
      }
    }
    routeSet.withScope(filter: filter) {
      self.routeSet.route(.Get("test"), to: TestController.indexAction, name: "index")
      self.assert(self.getLatestRoute()?.path.pathPattern, equals: "/test", message: "includes normal path in route in block")
    }
    let route = getLatestRoute()
    route?.handler(createTestRequest()) {
      response in
      self.assert(response.bodyString, equals: "Test Controller: index")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testWithScopeWithFailingFilterDoesNotCallHandler() {
    let expectation = expectationWithDescription("filter called")
    let filter: (TestController)->Void->Bool = {
      controller in
      return {
        expectation.fulfill()
        controller.render404()
        return false
      }
    }
    routeSet.withScope(filter: filter) {
      self.routeSet.route(.Get("test"), to: TestController.indexAction, name: "index")
      self.assert(self.getLatestRoute()?.path.pathPattern, equals: "/test", message: "includes normal path in route in block")
    }
    let route = getLatestRoute()
    route?.handler(createTestRequest()) {
      response in
      self.assert(response.bodyString, equals: "Page Not Found")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testWithScopeDoesNotCallFilterOnRouteOutsideBlock() {
    let filter: (TestController)->Void->Bool = {
      controller in
      return {
        XCTFail("does not call filter")
        controller.render404()
        return false
      }
    }
    routeSet.withScope(filter: filter) {
      self.routeSet.route(.Get("test"), to: TestController.indexAction, name: "index")
      self.assert(self.getLatestRoute()?.path.pathPattern, equals: "/test", message: "includes normal path in route in block")
    }
    self.routeSet.addRoute(.Get("test2"), handler: {
      request, callback in
      var response = Response()
      response.appendString("Success")
      callback(response)
    })
    let route = getLatestRoute()
    route?.handler(createTestRequest()) {
      response in
      self.assert(response.bodyString, equals: "Success")
    }
  }
  
  func testWithScopeWithMultipleRoutesCallsAllFilters() {
    let expectation1 = expectationWithDescription("filter1 called")
    let filter1: (TestController)->Void->Bool = {
      controller in
      return {
        expectation1.fulfill()
        return true
      }
    }
    let expectation2 = expectationWithDescription("filter1 called")
    let filter2: (TestController)->Void->Bool = {
      controller in
      return {
        expectation2.fulfill()
        return true
      }
    }
    routeSet.withScope(filters: [filter1,filter2]) {
      self.routeSet.route(.Get("test"), to: TestController.indexAction, name: "index")
      self.assert(self.getLatestRoute()?.path.pathPattern, equals: "/test", message: "includes normal path in route in block")
    }
    let route = getLatestRoute()
    route?.handler(createTestRequest()) {
      response in
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testAddRedirectCreatesRedirectResponse() {
    routeSet.addRedirect("route1", toPath: "/route2")
    let route = getLatestRoute()
    assert(route?.path.pathPattern, equals: "/route1", message: "sets route path to the first path")
    route?.handler(createTestRequest()) {
      response in
      self.assert(response.code, equals: 302, message: "sets response code to 302")
      
      let location = response.headers["location"]
      self.assert(location, equals: "/route2", message: "sets location header to the second path")
      
      let bodyString = response.bodyString
      self.assert(bodyString, equals: "You are being redirected", message: "sets request body to a redirect message")
    }
  }
  
  @available(*, deprecated) func testAddRouteWithSeparateComponentsCreatesRoute() {
    let expectation = expectationWithDescription("handler called")
    routeSet.addRoute("path", method: "GET", handler: {
      request, callback in
      expectation.fulfill()
    }, description: "test route")
    let route = self.getLatestRoute()
    assert(route?.pathPattern, equals: "/path", message: "sets path pattern")
    assert(route?.description, equals: "test route", message: "sets description")
    assert(route?.method, equals: "GET", message: "sets method")
    route?.handler(createTestRequest()) {
      response in
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testAddRouteCreatesRoute() {
    let expectation = expectationWithDescription("handler called")
    routeSet.addRoute(.Get("path"), handler: {
      request, callback in
      expectation.fulfill()
      }, description: "test route")
    let route = self.getLatestRoute()
    assert(route?.path, equals: .Get("/path"), message: "sets path")
    assert(route?.description, equals: "test route", message: "sets description")
    route?.handler(createTestRequest()) {
      response in
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  @available(*, deprecated) func testAddRouteWithControllerWithSeparateComponentsBuildsHandlerForController() {
    let action = TestController.indexAction
    routeSet.addRoute("test", method: "GET", actionName: "index", action: action)
    let route = getLatestRoute()
    assert(route?.controller?.name, equals: TestController.name)
    let expectation = expectationWithDescription("handler called")
    route?.handler(createTestRequest()) {
      response in
      expectation.fulfill()
      let body = response.bodyString
      self.assert(body, equals: "Test Controller: index", message: "calls controller's respond method")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testAddRouteWithControllerBuildsHandlerForController() {
    let action = TestController.indexAction
    routeSet.route(.Get("test"), to: action, name: "index")
    let route = getLatestRoute()
    assert(route?.controller?.name, equals: TestController.name)
    let expectation = expectationWithDescription("handler called")
    route?.handler(createTestRequest()) {
      response in
      expectation.fulfill()
      let body = response.bodyString
      self.assert(body, equals: "Test Controller: index", message: "calls controller's respond method")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testAddControllerRoutesAddsRoutesForControllers() {
    struct SecondTestController : ControllerType {
      static var name: String { return "SecondTestController" }
      var state: ControllerState
      static let layout = EmptyLayout.self
      
      static func defineRoutes(routes: RouteSet) {
        routes.withScope(path: "things") {
          routes.route(.Get(""), to: indexAction, name: "index")
        }
      }
      
      func indexAction() {
        generateResponse {
          (inout response: Response) in
          response.appendString("Test Controller: index")
        }
      }
    }
    
    routeSet.addControllerRoutes(TestController.self, SecondTestController.self)
    assert(routeSet.routes.count, equals: 3)
    if routeSet.routes.count == 3 {
      assert(routeSet.routes[0].description, equals: "TestController#index")
      assert(routeSet.routes[1].description, equals: "TestController#show")
      assert(routeSet.routes[2].description, equals: "SecondTestController#index")
    }
  }
  
  func testHandleRequestCallsHandlerForMatchingRequests() {
    let expectation1 = expectationWithDescription("calls first callback")
    let expectation2 = expectationWithDescription("calls second callback")
    let expectation3 = expectationWithDescription("calls third callback")
    
    routeSet.addRoute(.Get("hats")) {
      request, callback in
      var response = Response()
      response.appendString("Request 1")
      callback(response)
    }
    
    routeSet.addRoute(.Get("hats/:id")) {
      request, callback in
      var response = Response()
      let id = request.requestParameters["id"]!
      response.appendString("Request 2: \(id)")
      callback(response)
    }
    
    routeSet.handleRequest(createTestRequest("/hats")) {
      response in
      expectation1.fulfill()
      let body = response.bodyString
      self.assert(body, equals: "Request 1", message: "calls appropriate request")
    }
    
    routeSet.handleRequest(createTestRequest("/hats/3")) {
      response in
      expectation2.fulfill()
      let body = response.bodyString
      self.assert(body, equals: "Request 2: 3", message: "calls appropriate request")
    }
    
    routeSet.handleRequest(createTestRequest("/bad/path")) {
      response in
      expectation3.fulfill()
      let body = response.bodyString
      self.assert(response.code, equals: 404, message: "gives 404 response")
      self.assert(body, equals: "File Not Found", message: "gives error response")

    }
    
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  //MARK: - Generating URLs
  
  @available(*, deprecated) func testPathForWithNameGetsSimplePath() {
    TestController.defineRoutes(routeSet)
    let url = routeSet.pathFor("TestController", actionName: "index")
    self.assert(url, equals: "/hats", message: "generates correct route")
  }
  
  @available(*, deprecated) func testPathForWithNameGetsPathWithInterpolatedParameter() {
    TestController.defineRoutes(routeSet)
    let path = routeSet.pathFor("TestController", actionName: "show", parameters: ["id": "17"])
    self.assert(path, equals: "/hats/17", message: "generates correct route")
  }
  
  @available(*, deprecated) func testPathForWithNameGetsPathWithQueryString() {
    TestController.defineRoutes(routeSet)
    let path = routeSet.pathFor("TestController", actionName: "index", parameters: ["color": "black", "brimSize": "15"])
    assert(path, equals: "/hats?brimSize=15&color=black", message: "generates correct route")
  }
  
  @available(*, deprecated) func testPathForWithNameWithDomainGetsUrl() {
    TestController.defineRoutes(routeSet)
    let url = routeSet.pathFor("TestController", actionName: "index", domain: "haberdashery.com")
    assert(url, equals: "https://haberdashery.com/hats", message: "generates correct URL")
  }
  
  @available(*, deprecated) func testPathForWithNameWithDomainAndHttpFlagGetsUrl() {
    TestController.defineRoutes(routeSet)
    let url = routeSet.pathFor("TestController", actionName: "index", domain: "haberdashery.com", https: false)
    assert(url, equals: "http://haberdashery.com/hats", message: "generates correct URL")
  }
  
  @available(*, deprecated) func testPathForWithNameReturnsNilForNonMatchingPath() {
    TestController.defineRoutes(routeSet)
    let path = routeSet.pathFor("TestController", actionName: "new")
    assert(isNil: path)
  }
  
  @available(*, deprecated) func testPathForWithNameReturnsNilForNonMatchingPathWithDomain() {
    TestController.defineRoutes(routeSet)
    let path = routeSet.pathFor("TestController", actionName: "new", domain: "haberdashery.com")
    assert(isNil: path)
  }
  
  func testPathForGetsSimplePath() {
    TestController.defineRoutes(routeSet)
    let url = routeSet.pathFor(TestController.self, actionName: "index")
    self.assert(url, equals: "/hats", message: "generates correct route")
  }
  
  func testPathForGetsPathWithInterpolatedParameter() {
    TestController.defineRoutes(routeSet)
    let path = routeSet.pathFor(TestController.self, actionName: "show", parameters: ["id": "17"])
    self.assert(path, equals: "/hats/17", message: "generates correct route")
  }
  
  func testPathForGetsPathWithQueryString() {
    TestController.defineRoutes(routeSet)
    let path = routeSet.pathFor(TestController.self, actionName: "index", parameters: ["color": "black", "brimSize": "15"])
    assert(path, equals: "/hats?brimSize=15&color=black", message: "generates correct route")
  }
  
  func testPathForWithDomainGetsUrl() {
    TestController.defineRoutes(routeSet)
    let url = routeSet.pathFor(TestController.self, actionName: "index", domain: "haberdashery.com")
    assert(url, equals: "https://haberdashery.com/hats", message: "generates correct URL")
  }
  
  func testPathForWithDomainAndHttpFlagGetsUrl() {
    TestController.defineRoutes(routeSet)
    let url = routeSet.pathFor(TestController.self, actionName: "index", domain: "haberdashery.com", https: false)
    assert(url, equals: "http://haberdashery.com/hats", message: "generates correct URL")
  }
  
  func testPathForReturnsNilForNonMatchingPath() {
    TestController.defineRoutes(routeSet)
    let path = routeSet.pathFor(TestController.self, actionName: "new")
    assert(isNil: path)
  }
  
  func testPathForReturnsNilForNonMatchingPathWithDomain() {
    TestController.defineRoutes(routeSet)
    let path = routeSet.pathFor(TestController.self, actionName: "new", domain: "haberdashery.com")
    assert(isNil: path)
  }
}
