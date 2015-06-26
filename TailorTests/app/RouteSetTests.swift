import XCTest
import Tailor
import TailorTesting

class RouteSetTests: TailorTestCase {
  var routeSet = RouteSet()
  
  struct TestController : ControllerType {
    static var name: String { return "TestController" }
    var state: ControllerState
    static let layout = EmptyLayout.self
    
    static func defineRoutes(inout routes: RouteSet) {
      routes.withScope(path: "hats") {
        routes.addRoute("", method: "GET", actionName: "index", action: indexAction)
        routes.addRoute(":id", method: "GET", actionName: "show", action: showAction)
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
    return RouteSet.Route(pathPattern: pattern, method: "GET", handler: {
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
    assert(route.pathPattern, equals: "/test/route", message: "sets path pattern")
    assert(route.method, equals: "GET", message: "sets method")
    assert(route.description, equals: "test route")
    
    let regex = try! NSRegularExpression(pattern: "^/test/route/?$", options: [])
    assert(route.regex, equals: regex, message: "sets path regex")
  }
  
  //MARK: - Route Class
  
  func testInitializationReplacesParameterSections() {
    let route = createTestRoute("/test/user/:id")
    assert(route.pathPattern, equals: "/test/user/:id", message: "sets path pattern to unmodified pattern")
    
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
    let route = RouteSet.Route(pathPattern: "/test/route", method: "GET", handler: {
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
    let route = RouteSet.Route(pathPattern: "/test/route/:id", method: "GET", handler: {
      request, responseHandler in
      self.assert(request.requestParameters["id"], equals: "5")
      expectation.fulfill()
      }, description: "test route")
    route.handleRequest(createTestRequest("/test/route/5")) {
      response in
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
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
  
  func testWithScopeWithNoPathDoesNotAddPrefix() {
    let expectation = expectationWithDescription("handler called")
    routeSet.withScope() {
      expectation.fulfill()
      self.routeSet.addRoute("test", method: "GET") {
        request, callback in
      }
      self.assert(self.getLatestRoute()?.pathPattern, equals: "/test", message: "includes normal path in route in block")
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
      self.routeSet.addRoute("test", method: "GET", actionName: "index", action: TestController.indexAction)
      self.assert(self.getLatestRoute()?.pathPattern, equals: "/test", message: "includes normal path in route in block")
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
      self.routeSet.addRoute("test", method: "GET", actionName: "index", action: TestController.indexAction)
      self.assert(self.getLatestRoute()?.pathPattern, equals: "/test", message: "includes normal path in route in block")
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
      self.routeSet.addRoute("test", method: "GET", actionName: "index", action: TestController.indexAction)
      self.assert(self.getLatestRoute()?.pathPattern, equals: "/test", message: "includes normal path in route in block")
    }
    self.routeSet.addRoute("test2", method: "GET", handler: {
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
      self.routeSet.addRoute("test", method: "GET", actionName: "index", action: TestController.indexAction)
      self.assert(self.getLatestRoute()?.pathPattern, equals: "/test", message: "includes normal path in route in block")
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
    assert(route?.pathPattern, equals: "/route1", message: "sets route path to the first path")
    route?.handler(createTestRequest()) {
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
    assert(route?.pathPattern, equals: "/path", message: "sets path pattern")
    assert(route?.description, equals: "test route", message: "sets description")
    assert(route?.method, equals: "GET", message: "sets method")
    route?.handler(createTestRequest()) {
      response in
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testAddRouteWithControllerBuildsHandlerForController() {
    let action = TestController.indexAction
    routeSet.addRoute("test", method: "GET", actionName: "index", action: action)
    let route = getLatestRoute()
    assert(route?.controller?.name, equals: TestController.name)
    let expectation = expectationWithDescription("handler called")
    route?.handler(createTestRequest()) {
      response in
      expectation.fulfill()
      let body = NSString(data: response.bodyData, encoding: NSUTF8StringEncoding)!
      self.assert(body, equals: "Test Controller: index", message: "calls controller's respond method")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
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
    
    routeSet.handleRequest(createTestRequest("/hats")) {
      response in
      expectation1.fulfill()
      let body = NSString(data: response.bodyData, encoding: NSUTF8StringEncoding)!
      self.assert(body, equals: "Request 1", message: "calls appropriate request")
    }
    
    routeSet.handleRequest(createTestRequest("/hats/3")) {
      response in
      expectation2.fulfill()
      let body = NSString(data: response.bodyData, encoding: NSUTF8StringEncoding)!
      self.assert(body, equals: "Request 2: 3", message: "calls appropriate request")
    }
    
    routeSet.handleRequest(createTestRequest("/bad/path")) {
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
    TestController.defineRoutes(&routeSet)
    let url = routeSet.pathFor("TestController", actionName: "index")
    self.assert(url, equals: "/hats", message: "generates correct route")
  }
  
  func testPathForGetsPathWithInterpolatedParameter() {
    TestController.defineRoutes(&routeSet)
    let path = routeSet.pathFor("TestController", actionName: "show", parameters: ["id": "17"])
    self.assert(path, equals: "/hats/17", message: "generates correct route")
  }
  
  func testPathForGetsPathWithQueryString() {
    TestController.defineRoutes(&routeSet)
    let path = routeSet.pathFor("TestController", actionName: "index", parameters: ["color": "black", "brimSize": "15"])
    assert(path, equals: "/hats?brimSize=15&color=black", message: "generates correct route")
  }
  
  func testPathForWithDomainGetsUrl() {
    TestController.defineRoutes(&routeSet)
    let url = routeSet.pathFor("TestController", actionName: "index", domain: "haberdashery.com")
    assert(url, equals: "https://haberdashery.com/hats", message: "generates correct URL")
  }
  
  func testPathForWithDomainAndHttpFlagGetsUrl() {
    TestController.defineRoutes(&routeSet)
    let url = routeSet.pathFor("TestController", actionName: "index", domain: "haberdashery.com", https: false)
    assert(url, equals: "http://haberdashery.com/hats", message: "generates correct URL")
  }
  
  func testPathForReturnsNilForNonMatchingPath() {
    TestController.defineRoutes(&routeSet)
    let path = routeSet.pathFor("TestController", actionName: "new")
    assert(isNil: path)
  }
  
  func testPathForReturnsNilForNonMatchingPathWithDomain() {
    TestController.defineRoutes(&routeSet)
    let path = routeSet.pathFor("TestController", actionName: "new", domain: "haberdashery.com")
    assert(isNil: path)
  }
}
