import XCTest
import Tailor
import TailorTesting

class RouteSetTests: TailorTestCase {
  struct TestFilter: RequestFilterType, Equatable {
    let greeting: String
    init(greeting: String = "dawg") {
      self.greeting = greeting
    }
    func preProcess(request: Request, var response: Response, callback: (Request, Response, stop: Bool) -> Void) {
      response.appendString("Yo \(greeting)\r\n")
      callback(request, response, stop: false)
    }
    func postProcess(request: Request, var response: Response, callback: (Response) -> Void) {
      response.appendString("\r\nBye")
      callback(response)
    }
  }
  
  
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
      var response = self.state.response
      response.appendString("Test Controller: index")
      self.callback(response)
    }
    
    func showAction() {
      var response = self.state.response
      let id = request.requestParameters["id"] ?? "None"
      response.appendString("Test Controller: show \(id)")
      callback(response)
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
  
  func createTestRequest(path: String = "/", headers: [String:String] = [:]) -> Request {
    var body = "GET \(path) HTTP/1.1\r\n"
    for (key,value) in headers {
      body += "\(key): \(value)\r\n"
    }
    body += "\r\n"
    return Request(clientAddress: "0.0.0.0", data: NSData(bytes: body.utf8))
  }
  
  //MARK: - Route Class
  
  func testInitializationSetsFieldsFromParameters() {
    let route = createTestRoute("/test/route")
    assert(route.path.pathPattern, equals: "/test/route", message: "sets path pattern")
    assert(route.path.methodName, equals: "GET", message: "sets method")
    assert(route.description, equals: "test route")
    
    let regex = try! NSRegularExpression(pattern: "^/test/route/?$", options: [])
    assert(route.regex, equals: regex, message: "sets path regex")
  }
  
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
  
  func testInitializationHandlesInvalidPathPattern() {
    let route = createTestRoute("/test/route/(")
    assert(route.path.pathPattern, equals: "/test/route/(", message: "sets path pattern")
    assert(route.path.methodName, equals: "GET", message: "sets method")
    assert(route.description, equals: "test route")
    
    assert(isNil: route.regex)
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
  
  func testCanHandleRequestThatIsPercentEncoded() {
    let route = createTestRoute("/test/route/[A-Z]*")
    XCTAssertTrue(route.canHandleRequest(createTestRequest("/test/route/AB%50")), "can handle percent-encoded")
    XCTAssertFalse(route.canHandleRequest(createTestRequest("/test/route/AB%FF")), "cannot handle request with invalid percent-encoding")
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
  
  func testHandleRequestWithBadRegexCallsHandler() {
    let expectation = expectationWithDescription("handler called")
    let route = RouteSet.Route(path: .Get("/test/route("), handler: {
      request, responseHandler in
      expectation.fulfill()
      }, description: "test route")
    route.handleRequest(createTestRequest("/test/route(")) {
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
  
  func testBuildRoutePathWithPutMakesPutRoute() {
    let path = RouteSet.RoutePath.build("PUT", pathPattern: "/test/2")
    assert(path, equals: .Put("/test/2"))
  }
  
  func testBuildRoutePathWithPatchMakesPatchRoute() {
    let path = RouteSet.RoutePath.build("PATCH", pathPattern: "/test/2")
    assert(path, equals: .Patch("/test/2"))
  }
  
  func testBuildRoutePathWithDeleteMakesDeleteRoute() {
    let path = RouteSet.RoutePath.build("DELETE", pathPattern: "/test/2")
    assert(path, equals: .Delete("/test/2"))
  }
  
  func testBuildRoutePathWithOptionsMakesOptionsRoute() {
    let path = RouteSet.RoutePath.build("OPTIONS", pathPattern: "/test/2")
    assert(path, equals: .Options("/test/2"))
  }
  
  func testBuildRoutePathWithHeadMakesHeadRoute() {
    let path = RouteSet.RoutePath.build("HEAD", pathPattern: "/test/2")
    assert(path, equals: .Head("/test/2"))
  }
  
  func testBuildRoutePathWithTraceMakesTraceRoute() {
    let path = RouteSet.RoutePath.build("TRACE", pathPattern: "/test/2")
    assert(path, equals: .Trace("/test/2"))
  }
  
  func testBuildRoutePathWithConnectMakesConnectRoute() {
    let path = RouteSet.RoutePath.build("CONNECT", pathPattern: "/test/2")
    assert(path, equals: .Connect("/test/2"))
  }
  
  func testBuildRoutePathWithBadNameReturnsNil() {
    let path = RouteSet.RoutePath.build("FOO", pathPattern: "/test/1")
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
  
  func testPathPatternForPutReturnsPathPattern() {
    let path = RouteSet.RoutePath.Put("/test/4")
    assert(path.pathPattern, equals: "/test/4")
  }
  
  func testPathPatternForPatchReturnsPathPattern() {
    let path = RouteSet.RoutePath.Patch("/test/4")
    assert(path.pathPattern, equals: "/test/4")
  }
  
  func testPathPatternForDeleteReturnsPathPattern() {
    let path = RouteSet.RoutePath.Delete("/test/4")
    assert(path.pathPattern, equals: "/test/4")
  }
  
  func testPathPatternForOptionsReturnsPathPattern() {
    let path = RouteSet.RoutePath.Options("/test/4")
    assert(path.pathPattern, equals: "/test/4")
  }
  
  func testPathPatternForHeadReturnsPathPattern() {
    let path = RouteSet.RoutePath.Head("/test/4")
    assert(path.pathPattern, equals: "/test/4")
  }
  
  func testPathPatternForTraceReturnsPathPattern() {
    let path = RouteSet.RoutePath.Trace("/test/4")
    assert(path.pathPattern, equals: "/test/4")
  }
  
  func testPathPatternForConnectReturnsPathPattern() {
    let path = RouteSet.RoutePath.Connect("/test/4")
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
  
  func testMethodNameForPutReturnsPut() {
    let path = RouteSet.RoutePath.Put("/test/4")
    assert(path.methodName, equals: "PUT")
  }
  
  
  func testMethodNameForPatchReturnsPatch() {
    let path = RouteSet.RoutePath.Patch("/test/4")
    assert(path.methodName, equals: "PATCH")
  }
  
  
  func testMethodNameForDeleteReturnsDelete() {
    let path = RouteSet.RoutePath.Delete("/test/4")
    assert(path.methodName, equals: "DELETE")
  }
  
  
  func testMethodNameForOptionsReturnsOptions() {
    let path = RouteSet.RoutePath.Options("/test/4")
    assert(path.methodName, equals: "OPTIONS")
  }
  
  
  func testMethodNameForHeadReturnsHead() {
    let path = RouteSet.RoutePath.Head("/test/4")
    assert(path.methodName, equals: "HEAD")
  }
  
  
  func testMethodNameForTraceReturnsTrace() {
    let path = RouteSet.RoutePath.Trace("/test/4")
    assert(path.methodName, equals: "TRACE")
  }
  
  
  func testMethodNameForConnectReturnsConnect() {
    let path = RouteSet.RoutePath.Connect("/test/4")
    assert(path.methodName, equals: "CONNECT")
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
  
  func testWithPathPatternSwitchesPathPattern() {
    assert(RouteSet.RoutePath.Get("/test/1").withPathPattern("/test/2"), equals: RouteSet.RoutePath.Get("/test/2"))
    assert(RouteSet.RoutePath.Post("/test/1").withPathPattern("/test/2"), equals: RouteSet.RoutePath.Post("/test/2"))
    assert(RouteSet.RoutePath.Put("/test/1").withPathPattern("/test/2"), equals: RouteSet.RoutePath.Put("/test/2"))
    assert(RouteSet.RoutePath.Patch("/test/1").withPathPattern("/test/2"), equals: RouteSet.RoutePath.Patch("/test/2"))
    assert(RouteSet.RoutePath.Delete("/test/1").withPathPattern("/test/2"), equals: RouteSet.RoutePath.Delete("/test/2"))
    assert(RouteSet.RoutePath.Options("/test/1").withPathPattern("/test/2"), equals: RouteSet.RoutePath.Options("/test/2"))
    assert(RouteSet.RoutePath.Head("/test/1").withPathPattern("/test/2"), equals: RouteSet.RoutePath.Head("/test/2"))
    assert(RouteSet.RoutePath.Trace("/test/1").withPathPattern("/test/2"), equals: RouteSet.RoutePath.Trace("/test/2"))
    assert(RouteSet.RoutePath.Connect("/test/1").withPathPattern("/test/2"), equals: RouteSet.RoutePath.Connect("/test/2"))
  }
  
  //MARK: - Adding Routes
  
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
  
  func testWithScopeWithContinuingFilterCallsHandler() {
    routeSet.withScope(filter: TestFilter()) {
      self.routeSet.route(.Get("test"), to: TestController.indexAction, name: "index")
      self.assert(self.getLatestRoute()?.path.pathPattern, equals: "/test", message: "includes normal path in route in block")
    }
    let route = getLatestRoute()
    route?.handler(createTestRequest()) {
      response in
      self.assert(response.bodyString, equals: "Yo dawg\r\nTest Controller: index\r\nBye")
    }
  }
  
  func testWithScopeWithStoppingFilterDoesNotCallController() {
    struct TestFilterTwo: RequestFilterType {
      func preProcess(request: Request, response: Response, callback: (Request, Response, stop: Bool) -> Void) {
        callback(request, response, stop: true)
      }
      
      func postProcess(request: Request, response: Response, callback: (Response) -> Void) {
        callback(response)
      }
    }
    routeSet.withScope(filter: TestFilterTwo()) {
      self.routeSet.route(.Get("test"), to: TestController.indexAction, name: "index")
      self.assert(self.getLatestRoute()?.path.pathPattern, equals: "/test", message: "includes normal path in route in block")
    }
    let route = getLatestRoute()
    route?.handler(createTestRequest()) {
      response in
      self.assert(response.bodyString, equals: "")
    }
  }
  
  func testWithScopeDoesNotCallFilterOnRouteOutsideBlock() {
    routeSet.withScope(filter: TestFilter()) {
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
  
  func testWithScopeWithPathAndFilterAddsPathPrefix() {
    routeSet.withScope(path: "foo", filter: TestFilter()) {
      self.routeSet.route(.Get("test"), to: TestController.indexAction, name: "index")
      self.assert(self.getLatestRoute()?.path.pathPattern, equals: "/foo/test", message: "includes normal path in route in block")
    }
    self.routeSet.addRoute(.Get("test2"), handler: {
      request, callback in
      var response = Response()
      response.appendString("Success")
      callback(response)
    })
    let route = getLatestRoute()
    assert(route?.path.pathPattern, equals: "/test2")
  }
  
  func testWithScopeWithMultipleFiltersCallsAllFilters() {
    struct TestFilterTwo: RequestFilterType {
      func preProcess(var request: Request, var response: Response, callback: (Request, Response, stop: Bool) -> Void) {
        request.headers["Test"] = "1"
        response.appendString("Yo\r\n")
        callback(request, response, stop: false)
      }
      func postProcess(request: Request, response: Response, callback: (Response) -> Void) {
        callback(response)
      }
    }
    struct TestFilterThree: RequestFilterType {
      func preProcess(request: Request, var response: Response, callback: (Request, Response, stop: Bool) -> Void) {
        let value = request.headers["Test"] ?? "None"
        response.appendString("My \(value)\r\n")
        callback(request, response, stop: false)
      }
      func postProcess(request: Request, var response: Response, callback: (Response) -> Void) {
        response.appendString("\r\nDawg")
        callback(response)
      }
    }
    routeSet.withScope(filters: [TestFilterTwo(),TestFilterThree()]) {
      self.routeSet.route(.Get("test"), to: TestController.indexAction, name: "index")
      self.assert(self.getLatestRoute()?.path.pathPattern, equals: "/test", message: "includes normal path in route in block")
    }
    let route = getLatestRoute()
    route?.handler(createTestRequest()) {
      response in
      self.assert(response.bodyString, equals: "Yo\r\nMy 1\r\nTest Controller: index\r\nDawg")
    }
  }
  
  func testWithoutFilterRemovesFilterFromChain() {
    routeSet.withScope(filters: [TestFilter(greeting: "dawg"),TestFilter(greeting: "friend")]) {
      self.routeSet.route(.Get("test"), to: TestController.indexAction, name: "index")
      self.routeSet.withoutFilter(TestFilter(greeting: "friend")) {
        self.routeSet.route(.Get("test2"), to: TestController.indexAction, name: "index")
      }
    }
    guard self.routeSet.routes.count == 2 else {
      assert(false, message: "Failed to generate routes")
      return
    }
    self.routeSet.routes[0].handler(createTestRequest()) {
      response in
      self.assert(response.bodyString, equals: "Yo dawg\r\nYo friend\r\nTest Controller: index\r\nBye\r\nBye")
    }
    self.routeSet.routes[1].handler(createTestRequest()) {
      response in
      self.assert(response.bodyString, equals: "Yo dawg\r\nTest Controller: index\r\nBye")
    }
    
  }
  
  func testAddRedirectCreatesRedirectResponse() {
    routeSet.addRedirect("route1", toPath: "/route2")
    let route = getLatestRoute()
    assert(route?.path.pathPattern, equals: "/route1", message: "sets route path to the first path")
    route?.handler(createTestRequest()) {
      response in
      self.assert(response.responseCode, equals: .SeeOther, message: "sets response code to 303")
      
      let location = response.headers["location"]
      self.assert(location, equals: "/route2", message: "sets location header to the second path")
      
      let bodyString = response.bodyString
      self.assert(bodyString, equals: "You are being redirected", message: "sets request body to a redirect message")
    }
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
  
  func testStaticAssetsGeneratesRoutesToAssets() {
    routeSet.staticAssets(prefix: "assets", localPrefix: "", assets: ["TestConfig.plist", "TestStylesheet.css"])
    routeSet.handleRequest(createTestRequest("/assets/TestConfig.plist")) {
      response in
      self.assert(response.responseCode, equals: .Ok)
      let path = Application.sharedApplication().rootPath() + "/TestConfig.plist"
      self.assert(response.body, equals: NSData(contentsOfFile: path)!)
      self.assert(response.headers["ETag"], equals: "57066efdb031b7a6ad8b4a4b2f985fee")
      self.assert(response.headers["Content-Type"], equals: "text/plain", message: "has a default mime type of text/plain")
    }
    routeSet.handleRequest(createTestRequest("/assets/TestStylesheet.css")) {
      response in
      self.assert(response.headers["Content-Type"], equals: "text/css", message: "gets the correct mime type based on the extension")
    }
  }
  
  func testStaticAssetWithMatchingEtagGenerates304Response() {
    routeSet.staticAssets(prefix: "assets", localPrefix: "", assets: ["TestConfig.plist"])
    routeSet.handleRequest(createTestRequest("/assets/TestConfig.plist", headers: ["If-None-Match": "57066efdb031b7a6ad8b4a4b2f985fee"])) {
      response in
      self.assert(response.responseCode, equals: .NotModified)
      self.assert(response.headers["ETag"], equals: "57066efdb031b7a6ad8b4a4b2f985fee")
      self.assert(response.body.length, equals: 0)
    }
  }
  
  func testStaticAssetWithInvalidEtagSendsNewAsset() {
    routeSet.staticAssets(prefix: "assets", localPrefix: "", assets: ["TestConfig.plist"])
    routeSet.handleRequest(createTestRequest("/assets/TestConfig.plist", headers: ["If-None-Match": "57066efdb031b7a6ad8b4a4b2f985fef"])) {
      response in
      self.assert(response.responseCode, equals: .Ok)
      let path = Application.sharedApplication().rootPath() + "/TestConfig.plist"
      self.assert(response.body, equals: NSData(contentsOfFile: path)!)
      self.assert(response.headers["ETag"], equals: "57066efdb031b7a6ad8b4a4b2f985fee")
    }
  }
  
  func testStaticAssetsWithMissingFileGenerates404Response() {
    routeSet.staticAssets(prefix: "assets", localPrefix: "", assets: ["BadConfig.plist"])
    routeSet.handleRequest(createTestRequest("/assets/BadConfig.plist")) {
      response in
      self.assert(response.responseCode, equals: .NotFound)
    }
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
        var response = self.state.response
        response.appendString("Test Controller: index")
        self.callback(response)
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
  
  //MARK: - Handling Requests
  
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
      self.assert(response.responseCode, equals: .NotFound, message: "gives 404 response")
      self.assert(body, equals: "File Not Found", message: "gives error response")

    }
    
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRouteSetCanHandleRequestsWithMatchingRoutes() {
    
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
    
    assert(routeSet.canHandleRequest(createTestRequest("/hats")))
    assert(routeSet.canHandleRequest(createTestRequest("/hats/3")))
    assert(!routeSet.canHandleRequest(createTestRequest("/bad/path")))
  }

  
  func testHandleRequestWithPercentEncodedUrlCallsHandler() {
    let expectation = expectationWithDescription("calls callback")
    
    routeSet.addRoute(.Get("hats")) {
      request, callback in
      var response = Response()
      response.appendString("Request 1")
      callback(response)
    }
    
    routeSet.addRoute(.Get("hats/:id")) {
      request, callback in
    }
    

    routeSet.handleRequest(createTestRequest("/hat%73")) {
      response in
      expectation.fulfill()
      let body = response.bodyString
      self.assert(body, equals: "Request 1", message: "calls appropriate request")
    }
    routeSet.handleRequest(createTestRequest("/hat%ff")) {
      response in
      self.assert(response.responseCode, equals: .NotFound)
    }
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  //MARK: - Generating URLs
    
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
  
  //MARK: - Shared Routes
  
  func testLoadSetsInfoOnSharedRouteSet() {
    RouteSet.load {
      (inout routeSet: RouteSet) -> Void in
      routeSet.addRoute(.Get("sharedTest")) {
        request, callback in
      }
    }
    let routes = RouteSet.shared()
    assert(routes.routes.count, equals: 1)
    let route = routes.routes[0]
    assert(route.path.pathPattern, equals: "/sharedTest")
  }
  
  func testLoadErasesExistingRoutes() {
    RouteSet.load {
      (inout routeSet: RouteSet) -> Void in
      routeSet.addRoute(.Get("sharedTest")) {
        request, callback in
      }
    }
    RouteSet.load {
      (inout routeSet: RouteSet) -> Void in
      routeSet.addRoute(.Get("sharedTest2")) {
        request, callback in
      }
      routeSet.addRoute(.Get("sharedTest3")) {
        request, callback in
      }
    }
    let routes = RouteSet.shared()
    assert(routes.routes.count, equals: 2)
    let route = routes.routes[0]
    assert(route.path.pathPattern, equals: "/sharedTest2")
  }

}

func ==(lhs: RouteSetTests.TestFilter, rhs: RouteSetTests.TestFilter) -> Bool {
  return lhs.greeting == rhs.greeting
}