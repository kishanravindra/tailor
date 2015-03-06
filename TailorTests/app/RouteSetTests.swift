import XCTest

class RouteSetTests: XCTestCase {
  var routeSet = RouteSet()
  
  
  class TestController : Controller {
    override class func name() -> String { return "TestController" }
    override func respond() {
      let response = Response()
      response.appendString("Test Controller: \(self.action)")
      self.callback(response)
    }
  }
  
  override func setUp() {
    super.setUp()
    TestApplication.start()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func createTestRoute(pattern: String) -> RouteSet.Route {
    return RouteSet.Route(pathPattern: pattern, method: "GET", handler: {
      request, responseHandler in
      }, description: "test route")
  }
  
  func getLatestRoute() -> RouteSet.Route {
    return routeSet.routes[routeSet.routes.count - 1]
  }
  
  func createTestRequest(path: String = "/") -> Request {
    let body = "GET \(path) HTTP/1.1\r\n\r\n"
    return Request(clientAddress: "0.0.0.0", data: body.dataUsingEncoding(NSUTF8StringEncoding)!)
  }
  
  func testInitializationSetsFieldsFromParameters() {
    let route = createTestRoute("/test/route")
    XCTAssertEqual(route.pathPattern, "/test/route", "sets path pattern")
    XCTAssertEqual(route.method, "GET", "sets method")
    XCTAssertEqual(route.description, "test route")
    
    let regex = NSRegularExpression(pattern: "^/test/route/?$", options: nil, error: nil)!
    XCTAssertEqual(route.regex, regex, "sets path regex")
  }
  
  //MARK: - Route Class
  
  func testInitializationReplacesParameterSections() {
    let route = createTestRoute("/test/user/:id")
    XCTAssertEqual(route.pathPattern, "/test/user/:id", "sets path pattern to unmodified pattern")
    
    let regex = NSRegularExpression(pattern: "^/test/user/([^/]*)/?$", options: nil, error: nil)!
    XCTAssertEqual(route.regex, regex, "sets path regex to pattern with parameter replaces by wildcard")
  }
  
  func testInitializationAddsParameterToPathParameters() {
    let route = createTestRoute("/test/user/:id")
    XCTAssertEqual(route.pathParameters, ["id"], "puts id in the path parameters")
  }
  
  func testFullDescriptionContainsMethodPatternAndDescription() {
    let route = createTestRoute("/test/route")
    XCTAssertEqual(route.fullDescription(), "GET /test/route test route", "give full description")
  }

  func testCanHandleRequestThatMatchesRegex() {
    let route = createTestRoute("/test/route/[A-Z]*")
    XCTAssertTrue(route.canHandleRequest(createTestRequest(path: "/test/route/ABC")), "can handle matching route")
    XCTAssertFalse(route.canHandleRequest(createTestRequest(path: "/test/route/123")), "cannot handle route that doesn't match regex")
    XCTAssertFalse(route.canHandleRequest(createTestRequest(path: "/test/other_route")), "cannot handle route that doesn't match base of route")
  }
  
  func testHandleRequestCallsHandler() {
    let expectation = expectationWithDescription("handler called")
    let route = RouteSet.Route(pathPattern: "/test/route", method: "GET", handler: {
      request, responseHandler in
      expectation.fulfill()
      }, description: "test route")
    route.handleRequest(createTestRequest(path: "/test/route")) {
      response in
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testHandleRequestGivesHandlerParametersFromPath() {
    let expectation = expectationWithDescription("handler called")
    let route = RouteSet.Route(pathPattern: "/test/route/:id", method: "GET", handler: {
      request, responseHandler in
      XCTAssertEqual(request.requestParameters["id"]!, "5")
      expectation.fulfill()
      }, description: "test route")
    route.handleRequest(createTestRequest(path: "/test/route/5")) {
      response in
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  //MARK: - Adding Routes
  
  func testWithPrefixSetsPrefixForBlock() {
    let expectation = expectationWithDescription("handler called")
    routeSet.withPrefix("path") {
      expectation.fulfill()
      self.routeSet.addRoute("test", method: "GET", action: "test")
      XCTAssertEqual(self.getLatestRoute().pathPattern, "/path/test", "includes prefix in route in block")
    }
    routeSet.addRoute("test", method: "GET", action: "test")
    XCTAssertEqual(getLatestRoute().pathPattern, "/test", "does not include prefix in route outside of block")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testWithPrefixSetsControllerForBlock() {
    let expectation = expectationWithDescription("handler called")
    routeSet.withPrefix("path", controller: TestController.self) {
      expectation.fulfill()
      self.routeSet.addRoute("test", method: "GET", action: "test")
      if let controller = self.getLatestRoute().controller {
        XCTAssertEqual(controller.name(), "TestController", "includes controller in route in block")
      }
      else {
        XCTFail("includes controller in route in block")
      }
    }
    routeSet.addRoute("test", method: "GET", action: "test")
    if let controller = self.getLatestRoute().controller {
      XCTAssertEqual(controller.name(), "TailorTests.Controller", "uses default controller in route in block")
    }
    else {
      XCTFail("uses default controller in route in block")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testAddRedirectCreatesRedirectResponse() {
    routeSet.addRedirect("route1", toPath: "/route2")
    let route = getLatestRoute()
    XCTAssertEqual(route.pathPattern, "/route1", "sets route path to the first path")
    route.handler(createTestRequest()) {
      response in
      XCTAssertEqual(response.code, 302, "sets response code to 302")
      
      if let location = response.headers["location"] {
        XCTAssertEqual(location, "/route2", "sets location header to the second path")
      }
      else {
        XCTFail("sets location header to the second path")
      }
      
      let bodyString = NSString(data: response.bodyData, encoding: NSUTF8StringEncoding)!
      XCTAssertEqual(bodyString, "You are being redirected", "sets request body to a redirect message")
    }
  }
  
  func testAddRouteCreatesRoute() {
    let expectation = expectationWithDescription("handler called")
    routeSet.addRoute("path", method: "GET", handler: {
      request, callback in
      expectation.fulfill()
    }, description: "test route")
    let route = self.getLatestRoute()
    XCTAssertEqual(route.pathPattern, "/path", "sets path pattern")
    XCTAssertEqual(route.description, "test route", "sets description")
    XCTAssertEqual(route.method, "GET", "sets method")
    route.handler(createTestRequest()) {
      response in
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testAddRouteWithControllerBuildsHandlerForController() {
    routeSet.addRoute("test", method: "GET", controller: TestController.self, action: "index")
    let route = getLatestRoute()
    let expectation = expectationWithDescription("handler called")
    route.handler(createTestRequest()) {
      response in
      expectation.fulfill()
      let body = NSString(data: response.bodyData, encoding: NSUTF8StringEncoding)!
      XCTAssertEqual(body, "Test Controller: index", "calls controller's respond method")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testAddRestfulRoutesCreatesAllRoutes() {
    routeSet.withPrefix("hats") {
      self.routeSet.addRestfulRoutes()
    }
    XCTAssertEqual(routeSet.routes.count, 7, "creates 7 routes")
    
    XCTAssertEqual(routeSet.routes[0].pathPattern, "/hats", "creates index route")
    XCTAssertEqual(routeSet.routes[0].method, "GET", "creates index route")
    XCTAssertEqual(routeSet.routes[0].action!, "index", "creates index route")
    
    XCTAssertEqual(routeSet.routes[1].pathPattern, "/hats/new", "creates new route")
    XCTAssertEqual(routeSet.routes[1].method, "GET", "creates new route")
    XCTAssertEqual(routeSet.routes[1].action!, "new", "creates new route")
    
    XCTAssertEqual(routeSet.routes[2].pathPattern, "/hats", "creates create route")
    XCTAssertEqual(routeSet.routes[2].method, "POST", "creates create route")
    XCTAssertEqual(routeSet.routes[2].action!, "create", "creates create route")
    
    XCTAssertEqual(routeSet.routes[3].pathPattern, "/hats/:id", "creates show route")
    XCTAssertEqual(routeSet.routes[3].method, "GET", "creates show route")
    XCTAssertEqual(routeSet.routes[3].action!, "show", "creates show route")
    
    XCTAssertEqual(routeSet.routes[4].pathPattern, "/hats/:id/edit", "creates edit route")
    XCTAssertEqual(routeSet.routes[4].method, "GET", "creates edit route")
    XCTAssertEqual(routeSet.routes[4].action!, "edit", "creates edit route")
    
    XCTAssertEqual(routeSet.routes[5].pathPattern, "/hats/:id", "creates update route")
    XCTAssertEqual(routeSet.routes[5].method, "POST", "creates update route")
    XCTAssertEqual(routeSet.routes[5].action!, "update", "creates update route")
    
    XCTAssertEqual(routeSet.routes[6].pathPattern, "/hats/:id/destroy", "creates destroy route")
    XCTAssertEqual(routeSet.routes[6].method, "POST", "creates destroy route")
    XCTAssertEqual(routeSet.routes[6].action!, "destroy", "creates destroy route")
  }
  
  func testAddRestfulRoutesCreatesLimitedSetWithOnly() {
    routeSet.addRestfulRoutes(only: ["index", "show"])
    
    XCTAssertEqual(routeSet.routes.count, 2, "creates two routes")
    XCTAssertEqual(routeSet.routes[0].action!, "index", "creates index route")
    XCTAssertEqual(routeSet.routes[1].action!, "show", "creates show route")
  }
  
  func testAddRestfulRoutesCreatesLimitedSetWithExcept() {
    routeSet.addRestfulRoutes(except: ["edit", "update"])
    
    XCTAssertEqual(routeSet.routes.count, 5, "creates five routes")
    XCTAssertEqual(routeSet.routes[0].action!, "index", "creates index route")
    XCTAssertEqual(routeSet.routes[1].action!, "new", "creates new route")
    XCTAssertEqual(routeSet.routes[2].action!, "create", "creates create route")
    XCTAssertEqual(routeSet.routes[3].action!, "show", "creates show route")
    XCTAssertEqual(routeSet.routes[4].action!, "destroy", "creates destroy route")
  }
  
  func testHandleRequestCallsHandlerForMatchingRequests() {
    let expectation1 = expectationWithDescription("calls first callback")
    let expectation2 = expectationWithDescription("calls second callback")
    let expectation3 = expectationWithDescription("calls third callback")
    
    routeSet.addRoute("hats", method: "GET") {
      request, callback in
      var response = Response()
      response.appendString("Request 1")
      callback(response)
    }
    
    routeSet.addRoute("hats/:id", method: "GET") {
      request, callback in
      var response = Response()
      let id = request.requestParameters["id"]!
      response.appendString("Request 2: \(id)")
      callback(response)
    }
    
    routeSet.handleRequest(createTestRequest(path: "/hats")) {
      response in
      expectation1.fulfill()
      let body = NSString(data: response.bodyData, encoding: NSUTF8StringEncoding)!
      XCTAssertEqual(body, "Request 1", "calls appropriate request")
    }
    
    routeSet.handleRequest(createTestRequest(path: "/hats/3")) {
      response in
      expectation2.fulfill()
      let body = NSString(data: response.bodyData, encoding: NSUTF8StringEncoding)!
      XCTAssertEqual(body, "Request 2: 3", "calls appropriate request")
    }
    
    routeSet.handleRequest(createTestRequest(path: "/bad/path")) {
      response in
      expectation3.fulfill()
      let body = NSString(data: response.bodyData, encoding: NSUTF8StringEncoding)!
      XCTAssertEqual(response.code, 404, "gives 404 response")
      XCTAssertEqual(body, "File Not Found", "gives error response")

    }
    
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  //MARK: - Generating URLs
  
  func testPathForGetsSimplePath() {
    routeSet.addRoute("hats", method: "GET", controller: TestController.self, action: "index")
    if let url = routeSet.pathFor("TestController", action: "index") {
      XCTAssertEqual(url, "/hats", "generates correct route")
    }
    else {
      XCTFail("generates correct route")
    }
  }
  
  func testPathForGetsPathWithInterpolatedParameter() {
    routeSet.addRoute("hats/:id", method: "GET", controller: TestController.self, action: "show")
    if let path = routeSet.pathFor("TestController", action: "show", parameters: ["id": "17"]) {
      XCTAssertEqual(path, "/hats/17", "generates correct route")
    }
    else {
      XCTFail("generates correct route")
    }
  }
  
  func testPathForGetsPathWithQueryString() {
    routeSet.addRoute("hats", method: "GET", controller: TestController.self, action: "index")
    if let path = routeSet.pathFor("TestController", action: "index", parameters: ["color": "black", "brimSize": "15"]) {
      XCTAssertEqual(path, "/hats?brimSize=15&color=black", "generates correct route")
    }
    else {
      XCTFail("generates correct route")
    }
  }
  
  func testPathForWithDomainGetsUrl() {
    routeSet.addRoute("hats", method: "GET", controller: TestController.self, action: "index")
    if let url = routeSet.pathFor("TestController", action: "index", domain: "haberdashery.com") {
      XCTAssertEqual(url, "https://haberdashery.com/hats", "generates correct URL")
    }
    else {
      XCTFail("generates correct route")
    }
  }
  
  func testPathForWithDomainAndHttpFlagGetsUrl() {
    routeSet.addRoute("hats", method: "GET", controller: TestController.self, action: "index")
    if let url = routeSet.pathFor("TestController", action: "index", domain: "haberdashery.com", https: false) {
      XCTAssertEqual(url, "http://haberdashery.com/hats", "generates correct URL")
    }
    else {
      XCTFail("generates correct route")
    }
  }
  
  func testPathForReturnsNilForNonMatchingPath() {
    routeSet.addRoute("hats", method: "GET", controller: TestController.self, action: "index")
    let path = routeSet.pathFor("TestController", action: "show")
    XCTAssertNil(path, "gives nil path")
  }
  
  func testPathForReturnsNilForNonMatchingPathWithDomain() {
    routeSet.addRoute("hats", method: "GET", controller: TestController.self, action: "index")
    let path = routeSet.pathFor("TestController", action: "show", domain: "haberdashery.com")
    XCTAssertNil(path, "gives nil path")
  }
}
