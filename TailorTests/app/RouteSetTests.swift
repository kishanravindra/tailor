import XCTest
import Tailor
import TailorTesting

class RouteSetTests: TailorTestCase {
  var routeSet = RouteSet()
  
  
  class TestController : Controller {
    override class var name: String { return "TestController" }
    override class var actions: [Action] { return [
      Action(name: "index", body: wrap(index))
    ]}
    
    func index() {
      let response = Response()
      response.appendString("Test Controller: \(self.action.name)")
      self.callback(response)
    }
  }
  
  override func setUp() {
    super.setUp()
    Application.start()
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
    assert(route.pathPattern, equals: "/test/route", message: "sets path pattern")
    assert(route.method, equals: "GET", message: "sets method")
    assert(route.description, equals: "test route")
    
    let regex = NSRegularExpression(pattern: "^/test/route/?$", options: nil, error: nil)!
    assert(route.regex, equals: regex, message: "sets path regex")
  }
  
  //MARK: - Route Class
  
  func testInitializationReplacesParameterSections() {
    let route = createTestRoute("/test/user/:id")
    assert(route.pathPattern, equals: "/test/user/:id", message: "sets path pattern to unmodified pattern")
    
    let regex = NSRegularExpression(pattern: "^/test/user/([^/]*)/?$", options: nil, error: nil)!
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
      self.assert(request.requestParameters["id"], equals: "5")
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
      self.routeSet.addRoute("test", method: "GET", actionName: "test")
      self.assert(self.getLatestRoute().pathPattern, equals: "/path/test", message: "includes prefix in route in block")
    }
    routeSet.addRoute("test", method: "GET", actionName: "test")
    assert(getLatestRoute().pathPattern, equals: "/test", message: "does not include prefix in route outside of block")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testWithPrefixSetsControllerForBlock() {
    let expectation = expectationWithDescription("handler called")
    routeSet.withPrefix("path", controller: TestController.self) {
      expectation.fulfill()
      self.routeSet.addRoute("test", method: "GET", actionName: "test")
      let controller = self.getLatestRoute().controller
      self.assert(controller?.name, equals: "TestController", message: "includes controller in route in block")
    }
    routeSet.addRoute("test", method: "GET", actionName: "test")
    let controller = self.getLatestRoute().controller
    assert(controller?.name, equals: "Tailor.Controller", message: "uses default controller in route in block")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testAddRedirectCreatesRedirectResponse() {
    routeSet.addRedirect("route1", toPath: "/route2")
    let route = getLatestRoute()
    assert(route.pathPattern, equals: "/route1", message: "sets route path to the first path")
    route.handler(createTestRequest()) {
      response in
      self.assert(response.code, equals: 302, message: "sets response code to 302")
      
      let location = response.headers["location"]
      self.assert(location, equals: "/route2", message: "sets location header to the second path")
      
      let bodyString = NSString(data: response.bodyData, encoding: NSUTF8StringEncoding)!
      self.assert(bodyString, equals: "You are being redirected", message: "sets request body to a redirect message")
    }
  }
  
  func testAddRouteCreatesRoute() {
    let expectation = expectationWithDescription("handler called")
    routeSet.addRoute("path", method: "GET", handler: {
      request, callback in
      expectation.fulfill()
    }, description: "test route")
    let route = self.getLatestRoute()
    assert(route.pathPattern, equals: "/path", message: "sets path pattern")
    assert(route.description, equals: "test route", message: "sets description")
    assert(route.method, equals: "GET", message: "sets method")
    route.handler(createTestRequest()) {
      response in
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testAddRouteWithControllerBuildsHandlerForController() {
    routeSet.addRoute("test", method: "GET", controller: TestController.self, actionName: "index")
    let route = getLatestRoute()
    let expectation = expectationWithDescription("handler called")
    route.handler(createTestRequest()) {
      response in
      expectation.fulfill()
      let body = NSString(data: response.bodyData, encoding: NSUTF8StringEncoding)!
      self.assert(body, equals: "Test Controller: index", message: "calls controller's respond method")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testAddRestfulRoutesCreatesAllRoutes() {
    routeSet.withPrefix("hats") {
      self.routeSet.addRestfulRoutes()
    }
    assert(routeSet.routes.count, equals: 7, message: "creates 7 routes")
    
    assert(routeSet.routes[0].pathPattern, equals: "/hats", message: "creates index route")
    assert(routeSet.routes[0].method,equals:  "GET", message: "creates index route")
    assert(routeSet.routes[0].actionName!,equals:  "index", message: "creates index route")
    
    assert(routeSet.routes[1].pathPattern, equals: "/hats/new", message: "creates new route")
    assert(routeSet.routes[1].method, equals: "GET", message: "creates new route")
    assert(routeSet.routes[1].actionName!, equals: "new", message: "creates new route")
    
    assert(routeSet.routes[2].pathPattern, equals: "/hats", message: "creates create route")
    assert(routeSet.routes[2].method, equals: "POST", message: "creates create route")
    assert(routeSet.routes[2].actionName!, equals: "create", message: "creates create route")
    
    assert(routeSet.routes[3].pathPattern, equals: "/hats/:id", message: "creates show route")
    assert(routeSet.routes[3].method, equals: "GET", message: "creates show route")
    assert(routeSet.routes[3].actionName!, equals: "show", message: "creates show route")
    
    assert(routeSet.routes[4].pathPattern, equals: "/hats/:id/edit", message: "creates edit route")
    assert(routeSet.routes[4].method, equals: "GET", message: "creates edit route")
    assert(routeSet.routes[4].actionName!, equals: "edit", message: "creates edit route")
    
    assert(routeSet.routes[5].pathPattern, equals: "/hats/:id", message: "creates update route")
    assert(routeSet.routes[5].method, equals: "POST", message: "creates update route")
    assert(routeSet.routes[5].actionName!, equals: "update", message: "creates update route")
    
    assert(routeSet.routes[6].pathPattern, equals: "/hats/:id/destroy", message: "creates destroy route")
    assert(routeSet.routes[6].method, equals: "POST", message: "creates destroy route")
    assert(routeSet.routes[6].actionName!, equals: "destroy", message: "creates destroy route")
  }
  
  func testAddRestfulRoutesCreatesLimitedSetWithOnly() {
    routeSet.addRestfulRoutes(only: ["index", "show"])
    
    assert(routeSet.routes.count, equals: 2, message: "creates two routes")
    assert(routeSet.routes[0].actionName!, equals: "index", message: "creates index route")
    assert(routeSet.routes[1].actionName!, equals: "show", message: "creates show route")
  }
  
  func testAddRestfulRoutesCreatesLimitedSetWithExcept() {
    routeSet.addRestfulRoutes(except: ["edit", "update"])
    
    assert(routeSet.routes.count, equals: 5, message: "creates five routes")
    assert(routeSet.routes[0].actionName, equals: "index", message: "creates index route")
    assert(routeSet.routes[1].actionName, equals: "new", message: "creates new route")
    assert(routeSet.routes[2].actionName, equals: "create", message: "creates create route")
    assert(routeSet.routes[3].actionName, equals: "show", message: "creates show route")
    assert(routeSet.routes[4].actionName, equals: "destroy", message: "creates destroy route")
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
      self.assert(body, equals: "Request 1", message: "calls appropriate request")
    }
    
    routeSet.handleRequest(createTestRequest(path: "/hats/3")) {
      response in
      expectation2.fulfill()
      let body = NSString(data: response.bodyData, encoding: NSUTF8StringEncoding)!
      self.assert(body, equals: "Request 2: 3", message: "calls appropriate request")
    }
    
    routeSet.handleRequest(createTestRequest(path: "/bad/path")) {
      response in
      expectation3.fulfill()
      let body = NSString(data: response.bodyData, encoding: NSUTF8StringEncoding)!
      self.assert(response.code, equals: 404, message: "gives 404 response")
      self.assert(body, equals: "File Not Found", message: "gives error response")

    }
    
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  //MARK: - Generating URLs
  
  func testPathForGetsSimplePath() {
    routeSet.addRoute("hats", method: "GET", controller: TestController.self, actionName: "index")
    let url = routeSet.pathFor("TestController", actionName: "index")
    self.assert(url, equals: "/hats", message: "generates correct route")
  }
  
  func testPathForGetsPathWithInterpolatedParameter() {
    routeSet.addRoute("hats/:id", method: "GET", controller: TestController.self, actionName: "show")
    let path = routeSet.pathFor("TestController", actionName: "show", parameters: ["id": "17"])
    self.assert(path, equals: "/hats/17", message: "generates correct route")
  }
  
  func testPathForGetsPathWithQueryString() {
    routeSet.addRoute("hats", method: "GET", controller: TestController.self, actionName: "index")
    let path = routeSet.pathFor("TestController", actionName: "index", parameters: ["color": "black", "brimSize": "15"])
    assert(path, equals: "/hats?brimSize=15&color=black", message: "generates correct route")
  }
  
  func testPathForWithDomainGetsUrl() {
    routeSet.addRoute("hats", method: "GET", controller: TestController.self, actionName: "index")
    let url = routeSet.pathFor("TestController", actionName: "index", domain: "haberdashery.com")
    assert(url, equals: "https://haberdashery.com/hats", message: "generates correct URL")
  }
  
  func testPathForWithDomainAndHttpFlagGetsUrl() {
    routeSet.addRoute("hats", method: "GET", controller: TestController.self, actionName: "index")
    let url = routeSet.pathFor("TestController", actionName: "index", domain: "haberdashery.com", https: false)
    assert(url, equals: "http://haberdashery.com/hats", message: "generates correct URL")
  }
  
  func testPathForReturnsNilForNonMatchingPath() {
    routeSet.addRoute("hats", method: "GET", controller: TestController.self, actionName: "index")
    let path = routeSet.pathFor("TestController", actionName: "show")
    XCTAssertNil(path, "gives nil path")
  }
  
  func testPathForReturnsNilForNonMatchingPathWithDomain() {
    routeSet.addRoute("hats", method: "GET", controller: TestController.self, actionName: "index")
    let path = routeSet.pathFor("TestController", actionName: "show", domain: "haberdashery.com")
    XCTAssertNil(path, "gives nil path")
  }
}
