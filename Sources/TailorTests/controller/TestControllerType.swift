import XCTest
import Tailor
import TailorTesting
import Foundation

final class TestControllerType: XCTestCase, TailorTestable {
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
      if request.params.raw["failFilter"] != nil {
        var response = Response()
        response.responseCode = .init(419, "")
        self.callback(response)
        return false
      }
      return true
    }
    
    func indexAction() {
      var response = Response()
      response.responseCode = .Ok
      response.appendString("Index Action")
      self.callback(response)
    }
    
    func showAction() {
      var response = Response()
      response.responseCode = .Ok
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
  
  var user: UserType!
  var callback: Connection.ResponseCallback = {response in }
  var controller: ControllerType!
  var routeSet = RouteSet()
  
  var allTests: [(String, () throws -> Void)] { return [
    ("testInitializeSetsUserFromIdInSession", testInitializeSetsUserFromIdInSession),
    ("testInitializerSetsUserToNilWithBadId", testInitializerSetsUserToNilWithBadId),
    ("testInitializerSetsUserToNilWithNoId", testInitializerSetsUserToNilWithNoId),
    ("testInitializeStateWithAllFieldsSetsAllFields", testInitializeStateWithAllFieldsSetsAllFields),
    ("testInitializerSetsLocaleFromConfigurationSettings", testInitializerSetsLocaleFromConfigurationSettings),
    ("testRespondWithRendersTemplateInLayout", testRespondWithRendersTemplateInLayout),
    ("testRespondWithAddsTemplateToList", testRespondWithAddsTemplateToList),
    ("testRespondWithResponseAndSessionCallsCallbackWithResponse", testRespondWithResponseAndSessionCallsCallbackWithResponse),
    ("testRespondWithResponseAndSessionSetsSessionInfoOnResponse", testRespondWithResponseAndSessionSetsSessionInfoOnResponse),
    ("testRespondWithResponseAndNoSessionSetsRequestSessionInfoOnResponse", testRespondWithResponseAndNoSessionSetsRequestSessionInfoOnResponse),
    ("testRedirectToGeneratesRedirectResponse", testRedirectToGeneratesRedirectResponse),
    ("testRedirectToWithSessionGeneratesRedirectResponse", testRedirectToWithSessionGeneratesRedirectResponse),
    ("testRedirectToWithFlashPutsFlashMessagesInSession", testRedirectToWithFlashPutsFlashMessagesInSession),
    ("testPathForCanGetFullyQualifiedRoute", testPathForCanGetFullyQualifiedRoute),
    ("testPathForCanGetPathForSameAction", testPathForCanGetPathForSameAction),
    ("testPathForWithParametersInPathReusesParameters", testPathForWithParametersInPathReusesParameters),
    ("testPathForCanGetUrlWithDomain", testPathForCanGetUrlWithDomain),
    ("testPathForGetsNilForInvalidCombination", testPathForGetsNilForInvalidCombination),
    ("testPathForOnControllerTypeGetsPathForThatController", testPathForOnControllerTypeGetsPathForThatController),
    ("testRedirectToWithControllerTypeGeneratesRedirectResponse", testRedirectToWithControllerTypeGeneratesRedirectResponse),
    ("testRedirectToWithoutControllerTypeGeneratesRedirectToCurrentController", testRedirectToWithoutControllerTypeGeneratesRedirectToCurrentController),
    ("testRedirectToWithControllerTypeWithSessionGeneratesRedirectResponse", testRedirectToWithControllerTypeWithSessionGeneratesRedirectResponse),
    ("testRedirectToWithControllerTypeWithBadRouteGeneratesRedirectToRootPath", testRedirectToWithControllerTypeWithBadRouteGeneratesRedirectToRootPath),
    ("testRespondWithJsonGeneratesJsonResponse", testRespondWithJsonGeneratesJsonResponse),
    ("testRespondWithJsonWithStringGives500Response", testRespondWithJsonWithStringGives500Response),
    ("testRender404Gives404Response", testRender404Gives404Response),
    ("testRenderStreamWritesStreamDataToConnection", testRenderStreamWritesStreamDataToConnection),
    ("testRenderStreamFeedsContinuationDataToCallback", testRenderStreamFeedsContinuationDataToCallback),
    ("testRenderStreamWithPolledDataSendsDataToConnection", testRenderStreamWithPolledDataSendsDataToConnection),
    ("testDefaultLayoutIsEmptyLayout", testDefaultLayoutIsEmptyLayout),
    ("testSignInSetsCurrentUserAndStoresIdInSession", testSignInSetsCurrentUserAndStoresIdInSession),
    ("testSignInWithNewUserSetsUserIdToZero", testSignInWithNewUserSetsUserIdToZero),
    ("testSignOutClearsUserIdIdInSession", testSignOutClearsUserIdIdInSession),
    ("testSignInWithEmailAndPasswordSignsIn", testSignInWithEmailAndPasswordSignsIn),
    ("testSignInWithInvalidPasswordThrowsException", testSignInWithInvalidPasswordThrowsException),
    ("testSignInWithTrackableUserSetsTrackingInformation", testSignInWithTrackableUserSetsTrackingInformation),
    ("testCacheWithModificationTimeWithFreshTimestampReturnsNotModifiedResponse", testCacheWithModificationTimeWithFreshTimestampReturnsNotModifiedResponse),
    ("testCacheWithModificationTimeWithStaleTimestampReturnsFullResponse", testCacheWithModificationTimeWithStaleTimestampReturnsFullResponse),
    ("testCacheWithModificationTimeWithNoTimestampReturnsFullResponse", testCacheWithModificationTimeWithNoTimestampReturnsFullResponse),
    ("testCacheWithModificationTimeWithNon200ResponseDoesNotSetModificationTime", testCacheWithModificationTimeWithNon200ResponseDoesNotSetModificationTime),
    ("testFetchRecordWithValidIdFetchesRecord", testFetchRecordWithValidIdFetchesRecord),
    ("testFetchRecordWithInvalidIdThrowsException", testFetchRecordWithInvalidIdThrowsException),
    ("testFetchRecordWithNoIdGivesFallback", testFetchRecordWithNoIdGivesFallback),
    ("testFetchRecordWithNoIdOrFallbackThrowsException", testFetchRecordWithNoIdOrFallbackThrowsException),
    ("testFetchRecordCanFetchRecordWithDifferentParameterName", testFetchRecordCanFetchRecordWithDifferentParameterName),
    ("testLocalizationPrefixGetsUnderscoredControllerNameAndAction", testLocalizationPrefixGetsUnderscoredControllerNameAndAction),
    ("testLocalizeWithNoLocaleUsesLocalization", testLocalizeWithNoLocaleUsesLocalization),
    ("testLocalizeWithInterpolationsAddsInterpolationsToText", testLocalizeWithInterpolationsAddsInterpolationsToText),
    ("testLocalizeWithDotPrependsPrefix", testLocalizeWithDotPrependsPrefix),
    ("testLocalizeWithLocaleSwitchesToThatLanguage", testLocalizeWithLocaleSwitchesToThatLanguage),
    ("testResourceNotFoundErrorGeneratesError", testResourceNotFoundErrorGeneratesError),
    ("testRedirectErrorGeneratesError", testRedirectErrorGeneratesError),
    ("testRedirectErrorWithNilParametersFillsInDefaults", testRedirectErrorWithNilParametersFillsInDefaults),
  ]}
  
  func setUp() {
    setUpTestCase()
    Application.configuration.localization = { PropertyListLocalization(locale: $0) }

    var user = TestUser()
    user.emailAddress = "test@test.com"
    user.password = "test"
    self.user = user.save()!
    
    RouteSet.load { routes in
      TestController.defineRoutes(routes)
      SecondTestController.defineRoutes(routes)
    }
    
    controller = TestController(state: ControllerState(
      request: Request(),
      response: Response(),
      actionName: "index",
      callback: {
        response in
        self.callback(response)
      }
    ))
  }

  func tearDown() {
    RouteSet.load { routes in }
  }
  
  func testInitializeSetsUserFromIdInSession() {
    TestSeedTaskType.SeedTask.saveSchema()
    TestSeedTaskType.SeedTask.saveTable("tailor_alterations")
    controller = TestController(state: ControllerState(
      request: Request(sessionData: ["userId": String(user.id)]),
      response: Response(),
      actionName: "index",
      callback: {
        (response) in
      }
    ))
    assert(controller.currentUser?.id, equals: user.id, message: "sets user to the one with the id given")
  }
  
  func testInitializerSetsUserToNilWithBadId() {
    controller = TestController(state: ControllerState(
      request: Request(sessionData: ["userId": String(user.id + 1)]),
      response: Response(),
      actionName: "index",
      callback: {
        (response) in
      }
    ))
    assert(isNil: controller.currentUser, message: "sets user to nil")
  }
  
  func testInitializerSetsUserToNilWithNoId() {
    controller = TestController(state: ControllerState(
      request: Request(),
      response: Response(),
      actionName: "index",
      callback: {
        (response) in
      }
    ))
    assert(isNil: controller.currentUser, message: "sets user to nil")
  }
  
  func testInitializeStateWithAllFieldsSetsAllFields() {
    let request = Request()
    let response = Response()
    let user = TestUser().save()!
    let state = ControllerState(request: request, response: response, callback: {_ in}, actionName: "show", currentUser: user, localization: PropertyListLocalization(locale: "es"))
    assert(state.request, equals: request)
    assert(state.actionName, equals: "show")
    assert(state.currentUser?.id, equals: user.id)
    assert(state.localization.locale, equals: "es")
    assert(state.response, equals: response)
  }
  
  func testInitializerSetsLocaleFromConfigurationSettings() {
    Application.configuration.localizationForRequest = { request in return PropertyListLocalization(locale: "es") }
    let state = ControllerState(request: Request(), response: Response(), actionName: "index", callback: {_ in})
    assert(state.localization.locale, equals: "es")
    Application.configuration = Application.Configuration()
  }
  
  //MARK: - Responses
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
      let body = response.bodyText
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
  
  func testRespondWithResponseAndSessionCallsCallbackWithResponse() {
    var response = Response()
    response.appendString("Test Body")
    var session = controller.request.session
    session["test"] = "value"
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response2 in
      expectation.fulfill()
      self.assert(response2.bodyData, equals: response.bodyData)
    }
    controller.respondWith(response, session: session)
    self.waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testRespondWithResponseAndSessionSetsSessionInfoOnResponse() {
    var response = Response()
    response.appendString("Test Body")
    var session = controller.request.session
    session["test"] = "value"
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response2 in
      expectation.fulfill()
      let request = Request(cookies: ["_session": response2.cookies["_session"] ?? ""])
      let session = request.session
      self.assert(session["test"], equals: "value")
    }
    controller.respondWith(response, session: session)
    self.waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testRespondWithResponseAndNoSessionSetsRequestSessionInfoOnResponse() {
    controller = TestController(state: ControllerState(
      request: Request(sessionData: ["A": "B"]),
      response: Response(),
      actionName: "index",
      callback: {
        response in
        self.callback(response)
      }
    ))
    var response = Response()
    response.appendString("Test Body")
    var session = controller.request.session
    session["test"] = "value"
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response2 in
      expectation.fulfill()
      let request = Request(cookies: ["_session": response2.cookies["_session"] ?? ""])
      let session = request.session
      self.assert(session["A"], equals: "B")
    }
    controller.respondWith(response)
    self.waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testRedirectToGeneratesRedirectResponse() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.responseCode, equals: .SeeOther, message: "gives a 302 response")
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
      self.assert(response.responseCode, equals: .SeeOther, message: "gives a 302 response")
      self.assert(response.headers, equals: ["Location": "/test/path"], message: "gives a location header")
      
      let session = Request(cookies: response.cookies.cookieDictionary()).session
      self.assert(session["test1"], equals: "value1")
    }
    var newSession = controller.request.session
    newSession["test1"] = "value1"
    self.controller.redirectTo("/test/path", session: newSession)
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRedirectToWithFlashPutsFlashMessagesInSession() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.responseCode, equals: .SeeOther, message: "gives a 302 response")
      self.assert(response.headers, equals: ["Location": "/test/path"], message: "gives a location header")
      
      let session = Request(cookies: response.cookies.cookieDictionary()).session
      self.assert(session.flash("success"), equals: "hi")
      self.assert(isNil: session.flash("error"))
    }
    self.controller.redirectTo("/test/path", flash: ["success": "hi", "error": nil])
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testPathForCanGetFullyQualifiedRoute() {
    let path = self.controller.pathFor(TestController.self, actionName: "index", parameters: ["id": "5"])
    assert(path, equals: "/route1?id=5", message: "gets the url for the controller and action")
  }
  
  func testPathForCanGetPathForSameAction() {
    self.controller = SecondTestController(state: ControllerState(
      request: Request(),
      response: Response(),
      actionName: "index",
      callback: { self.callback($0) }
    ))
    let path = self.controller.pathFor(parameters: ["confirmed": "1"])
    assert(path, equals: "/route2?confirmed=1", message: "uses the same controller and action, but adds the parameters")
  }
  
  func testPathForWithParametersInPathReusesParameters() {
    controller = TestController(state: ControllerState(
      request: Request(parameters: ["id": "10"]),
      response: Response(),
      actionName: "show",
      callback: {
        response in
        self.callback(response)
      }
    ))
    let path = self.controller.pathFor(TestController.self, actionName: "show")
    assert(path, equals: "/route1/10", message: "gets the url for the controller and action")
  }
  
  func testPathForCanGetUrlWithDomain() {
    let path = self.controller.pathFor(TestController.self, actionName: "index", parameters: ["id": "5"], domain: "test.com")
    assert(path, equals: "https://test.com/route1?id=5", message: "gets the url for the controller and action")
  }
  
  func testPathForGetsNilForInvalidCombination() {
    let path = self.controller.pathFor(actionName: "new")
    XCTAssertNil(path, "gives a nil path")
  }
  
  func testPathForOnControllerTypeGetsPathForThatController() {
    let path = TestController.self.pathFor("index", parameters: ["id": "5"])
    assert(path, equals: "/route1?id=5")
  }
  
  func testRedirectToWithControllerTypeGeneratesRedirectResponse() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.responseCode, equals: .SeeOther, message: "gives a 303 response")
      self.assert(response.headers, equals: ["Location": "/route2"], message: "has a location header")
      self.assert(response.bodyText, equals: "<html><body>You are being <a href=\"/route2\">redirected</a>.</body></html>")
    }
    self.controller.redirectTo(SecondTestController.self, actionName: "index")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRedirectToWithoutControllerTypeGeneratesRedirectToCurrentController() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.responseCode, equals: .SeeOther, message: "gives a 303 response")
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
      self.assert(response.responseCode, equals: .SeeOther, message: "gives a 303 response")
      self.assert(response.headers, equals: ["Location": "/route1"], message: "has a location header")
      
      let session = Request(cookies: response.cookies.cookieDictionary()).session
      self.assert(session["test3"], equals: "value3")
    }
    var newSession = controller.request.session
    newSession["test3"] = "value3"
    
    self.controller.redirectTo(TestController.self, actionName: "index", session: newSession)
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRedirectToWithControllerTypeWithBadRouteGeneratesRedirectToRootPath() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.responseCode, equals: .SeeOther, message: "gives a 303 response")
      self.assert(response.headers, equals: ["Location": "/"], message: "has a location header")
    }
    self.controller.redirectTo(TestController.self, actionName: "foo")
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRespondWithJsonGeneratesJsonResponse() {
    do {
      let hat = Hat(brimSize: 10, color: "red", shelfId: nil, owner: nil, id: 0)
      let data = try hat.serialize.jsonData()
      let expectation = expectationWithDescription("callback called")
      self.callback = {
        response in
        expectation.fulfill()
        self.assert(response.responseCode, equals: .Created, message: "gives a success response")
        self.assert(response.headers, equals: ["Content-Type": "application/json"])
        self.assert(response.bodyData, equals: data)
      }
      self.controller.respondWith(json: hat.serialize, responseCode: .Created)
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
      self.assert(response.responseCode, equals: .InternalServerError, message: "gives an error response")
    }
    self.controller.respondWith(json: "Hat")
    waitForExpectationsWithTimeout(0.01, handler: nil)
    
  }
  
  func testRender404Gives404Response() {
    let expectation = expectationWithDescription("callback called")
    self.callback = {
      response in
      expectation.fulfill()
      self.assert(response.responseCode, equals: .NotFound, message: "gives a 404 response")
    }
    self.controller.render404()
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRenderStreamWritesStreamDataToConnection() {
    let expectation1 = expectationWithDescription("callback called 1")
    let expectation2 = expectationWithDescription("callback called 2")
    let expectation3 = expectationWithDescription("callback called 3")
    var responseCount = 0
    self.callback = {
      response in
      switch(responseCount) {
      case 0:
        expectation1.fulfill()
        self.assert(response.headers["Test"], equals: "value")
        self.assert(response.bodyData.length, equals: 0)
      case 1:
        expectation2.fulfill()
        self.assert(response.bodyText, equals: "Hello")
      case 2:
        expectation3.fulfill()
        self.assert(response.bodyText, equals: "Goodbye")
      default:
        self.assert(false, message: "Received too many responses")
      }
      responseCount += 1
    }
    var response = Response()
    response.headers["Test"] = "value"
    self.controller.renderStream(response) {
      callback in
      callback(NSData(bytes: "Hello".utf8))
      callback(NSData(bytes: "Goodbye".utf8))
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRenderStreamFeedsContinuationDataToCallback() {
    var responseCount = 0
    self.callback = {
      response in
      response.continuationCallback?(responseCount < 2)
      responseCount += 1
    }
    var response = Response()
    response.headers["Test"] = "value"
    let expectation1 = expectationWithDescription("callback called 1")
    let expectation2 = expectationWithDescription("callback called 2")
    let expectation3 = expectationWithDescription("callback called 3")
    let continuation = {
      (shouldContinue: Bool) in
      switch(responseCount) {
      case 0: expectation1.fulfill()
      case 1: expectation2.fulfill()
      case 2: expectation3.fulfill()
      default: self.assert(false, message: "Received unexpected callback")
      }
      self.assert(shouldContinue, equals: responseCount < 2)
    }
    self.controller.renderStream(response, continuationCallback: continuation) {
      callback in
      callback(NSData(bytes: "Hello".utf8))
      callback(NSData(bytes: "Goodbye".utf8))
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testRenderStreamWithPolledDataSendsDataToConnection() {
    let expectation1 = expectationWithDescription("callback called 1")
    let expectation2 = expectationWithDescription("callback called 2")
    let expectation3 = expectationWithDescription("callback called 3")
    var responseCount = 0
    self.callback = {
      response in
      responseCount += 1
      switch(responseCount) {
      case 1:
        expectation1.fulfill()
        self.assert(response.headers["Test"], equals: "value")
        self.assert(response.bodyData.length, equals: 0)
        response.continuationCallback?(true)
      case 2:
        expectation2.fulfill()
        self.assert(response.bodyText, equals: "1")
        response.continuationCallback?(true)
      case 3:
        expectation3.fulfill()
        self.assert(response.bodyText, equals: "2")
        response.continuationCallback?(false)
      default:
        self.assert(false, message: "Received too many responses")
      }
    }
    var response = Response()
    response.headers["Test"] = "value"
    var index = 0
    self.controller.renderPolledStream(response) {
      Void->NSData? in
      index += 1
      return NSData(bytes: String(index).utf8)
    }
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
      self.assert(response.bodyText, equals: "Hello")
    }
    
    
    controller = SecondTestController(state: ControllerState(
      request: Request(),
      response: Response(),
      actionName: "index",
      callback: {
        response in
        self.callback(response)
      }
    ))

    controller.respondWith(TestTemplate(state: TemplateState(controller)))
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  //MARK: - Authentication
  
  func testSignInSetsCurrentUserAndStoresIdInSession() {
    let user2 = TestUser().save()!
    
    let newSession = self.controller.signIn(user2)
    
    assert(newSession["userId"], equals: String(user2.id), message: "sets userId in session")
  }
  
  func testSignInWithNewUserSetsUserIdToZero() {
    let user2 = TestUser()
    let newSession = self.controller.signIn(user2)
    assert(newSession["userId"], equals: "0", message: "sets userId to zero")
  }
  
  func testSignOutClearsUserIdIdInSession() {
    
    controller = TestController(state: ControllerState(
      request: Request(sessionData: ["foo": "bar", "userId": String(user.id)]),
      response: Response(),
      actionName: "index",
      callback: {
        response in
        self.callback(response)
      }
    ))
    assert(isNotNil: controller.request.session["userId"])
    let newSession = controller.signOut()
    assert(isNil: newSession["userId"])
    assert(newSession["foo"], equals: "bar")
  }
  
  func testSignInWithEmailAndPasswordSignsIn() {
    do {
      let result = try controller.signIn("test@test.com", password: "test")
      self.assert(result["userId"], equals: String(user.id), message: "sets user as current user in new session")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testSignInWithInvalidPasswordThrowsException() {
    do {
      _ = try controller.signIn("test@test.com", password: "test2")
      assert(false, message: "should throw exception")
    }
    catch {
      assert(true, message: "threw exception")
    }
  }
  
  func testSignInWithTrackableUserSetsTrackingInformation() {
    Application.configuration.userType = TestUserType.TrackableUser.self
    
    let connection = Application.sharedDatabaseConnection()
    connection.executeQuery("ALTER TABLE `users` ADD COLUMN `last_sign_in_ip` varchar(255)")
    connection.executeQuery("ALTER TABLE `users` ADD COLUMN `last_sign_in_time` timestamp")
    do {
      _ = try controller.signIn("test@test.com", password: "test")
      let user = Query<TestUserType.TrackableUser>().first()
      assert(user?.lastSignInIp, equals: controller.request.clientAddress)
      assert(user?.lastSignInTime, equals: Timestamp.now().change(nanosecond: 0))
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
    Application.configuration.userType = TestUser.self
    resetDatabase()
  }
  
  //MARK: - Caching
  
  func testCacheWithModificationTimeWithFreshTimestampReturnsNotModifiedResponse() {
    let data = NSData(bytes: [1,2,3,4])
    let timestamp = 1.hour.ago
    let expectation = expectationWithDescription("callback called")
    
    controller = TestController(state: ControllerState(
      request: Request(headers: ["If-Modified-Since": 30.minutes.ago.format(TimeFormat.Rfc822)]),
      response: Response(),
      actionName: "index",
      callback: {
        response in
        expectation.fulfill()
        self.assert(response.responseCode, equals: .NotModified)
        self.assert(response.headers["Last-Modified"], equals: timestamp.inTimeZone("GMT").format(TimeFormat.Rfc822))
        self.assert(response.bodyData.length, equals: 0)
      }
    ))
    
    controller.cacheWithModificationTime(timestamp) {
      (inout response: Response) -> Void in
      assert(false, message: "Does not generate the response again")
      response.appendData(data)
    }
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testCacheWithModificationTimeWithStaleTimestampReturnsFullResponse() {
    let data = NSData(bytes: [1,2,3,4])
    let timestamp = 1.hour.ago
    let expectation = expectationWithDescription("callback called")
    
    controller = TestController(state: ControllerState(
      request: Request(headers: ["If-Modified-Since": 2.hours.ago.format(TimeFormat.Rfc822)]),
      response: Response(),
      actionName: "index",
      callback: {
        response in
        expectation.fulfill()
        self.assert(response.responseCode, equals: .Ok)
        self.assert(response.headers["Last-Modified"], equals: timestamp.inTimeZone("GMT").format(TimeFormat.Rfc822))
        self.assert(response.bodyData, equals: data)
      }
    ))
    
    controller.cacheWithModificationTime(timestamp) {
      (inout response: Response) -> Void in
      response.appendData(data)
    }
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testCacheWithModificationTimeWithNoTimestampReturnsFullResponse() {
    let data = NSData(bytes: [1,2,3,4])
    let timestamp = 1.hour.ago
    let expectation = expectationWithDescription("callback called")
    
    controller = TestController(state: ControllerState(
      request: Request(),
      response: Response(),
      actionName: "index",
      callback: {
        response in
        expectation.fulfill()
        self.assert(response.responseCode, equals: .Ok)
        self.assert(response.headers["Last-Modified"], equals: timestamp.inTimeZone("GMT").format(TimeFormat.Rfc822))
        self.assert(response.bodyData, equals: data)
      }
    ))
    
    controller.cacheWithModificationTime(timestamp) {
      (inout response: Response) -> Void in
      response.appendData(data)
    }
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  
  func testCacheWithModificationTimeWithNon200ResponseDoesNotSetModificationTime() {
    let data = NSData(bytes: [1,2,3,4])
    let timestamp = 1.hour.ago
    let expectation = expectationWithDescription("callback called")
    
    controller = TestController(state: ControllerState(
      request: Request(),
      response: Response(),
      actionName: "index",
      callback: {
        response in
        expectation.fulfill()
        self.assert(response.responseCode, equals: .Created)
        self.assert(isNil: response.headers["Last-Modified"])
        self.assert(response.bodyData, equals: data)
      }
    ))
    
    controller.cacheWithModificationTime(timestamp) {
      (inout response: Response) -> Void in
      response.responseCode = .Created
      response.appendData(data)
    }
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  //MARK: - Request Parameters
  
  func testFetchRecordWithValidIdFetchesRecord() {
    Hat().save()
    let hat = Hat().save()!
    let request = Request(parameters: ["id": String(hat.id)])
    assert(try? EmptyController.fetchRecord(ControllerState(request: request)), equals: hat)
  }
  
  func testFetchRecordWithInvalidIdThrowsException() {
    Hat().save()
    let hat = Hat().save()!
    let request = Request(parameters: ["id": String(hat.id + 1)])
    do {
      let _ = try EmptyController.fetchRecord(ControllerState(request: request)) as Hat
      assert(false, message: "should throw exception")
    }
    catch let ControllerError.UnprocessableRequest(response) {
      assert(response.responseCode, equals: .NotFound)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testFetchRecordWithNoIdGivesFallback() {
    Hat().save()
    let request = Request()
    let record: Hat? = try? EmptyController.fetchRecord(ControllerState(request: request), fallback: Hat())
    assert(record?.id, equals: 0)
  }
  
  func testFetchRecordWithNoIdOrFallbackThrowsException() {
    _ = Hat().save()
    let request = Request()
    do {
      let _ = try EmptyController.fetchRecord(ControllerState(request: request)) as Hat
      assert(false, message: "should throw exception")
    }
    catch let ControllerError.UnprocessableRequest(response) {
      assert(response.responseCode, equals: .NotFound)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testFetchRecordCanFetchRecordWithDifferentParameterName() {
    Hat().save()
    let hat = Hat().save()!
    let request = Request(parameters: ["hatId": String(hat.id)])
    assert(try? EmptyController.fetchRecord(ControllerState(request: request), from: "hatId"), equals: hat)
  }

  
  //MARK: - Localization
  
  func testLocalizationPrefixGetsUnderscoredControllerNameAndAction() {
    let controller = TestController(state: ControllerState(request: Request(), response: Response(), actionName: "index", callback: {_ in }))
    let prefix = controller.localizationPrefix
    assert(prefix, equals: "tailor_tests.test_controller.index")
  }
  
  func testLocalizeWithNoLocaleUsesLocalization() {
    Application.configuration.staticContent["en.controller.test.message"] = "Hello"
    let string = controller.localize("controller.test.message")
    assert(string, equals: "Hello", message: "returns the string from the localization")
  }
  
  func testLocalizeWithInterpolationsAddsInterpolationsToText() {
    Application.configuration.staticContent["en.controller.test.message_interpolate"] = "Hello \\(value)"
    let string = controller.localize("controller.test.message_interpolate", interpolations: ["value": "hi"])
    assert(string, equals: "Hello hi", message: "returns the string from the localization, with the values interpolated")
  }
  
  func testLocalizeWithDotPrependsPrefix() {
    let key = ".test.message"
    let fullKey = controller.localizationPrefix + key
    Application.configuration.staticContent["en.\(fullKey)"] = "Hello 2"
    let string = controller.localize(key)
    assert(string, equals: "Hello 2", message: "returns the string from the localization")
  }
  
  func testLocalizeWithLocaleSwitchesToThatLanguage() {
    Application.configuration.staticContent["es.controller.test.message"] = "Hola"
    let string = controller.localize("controller.test.message", locale: "es")
    assert(string, equals: "Hola", message: "returns the string from the localization")
  }
  
  //MARK: - Errors
  
  func testResourceNotFoundErrorGeneratesError() {
    let state = ControllerState()
    let error = ControllerError.resourceNotFoundError(state, message: "Thing not found")
    switch(error) {
    case let ControllerError.UnprocessableRequest(response):
      assert(response.responseCode, equals: .NotFound)
      assert(response.bodyText, equals: "Thing not found")
    }
  }
  
  func testRedirectErrorGeneratesError() {
    let state = ControllerState()
    let error = ControllerError.redirectResponse(state, path: "/test/path", message: "Success!")
    switch(error) {
    case let ControllerError.UnprocessableRequest(response):
      assert(response.responseCode, equals: .SeeOther)
      assert(response.headers["Location"], equals: "/test/path")
      assert(response.session.flash("error"), equals: "Success!")
    }
  }
  
  func testRedirectErrorWithNilParametersFillsInDefaults() {
    let state = ControllerState()
    let error = ControllerError.redirectResponse(state)
    switch(error) {
    case let ControllerError.UnprocessableRequest(response):
      assert(response.responseCode, equals: .SeeOther)
      assert(response.headers["Location"], equals: "/")
      assert(isNil: response.session.flash("error"))
    }
  }
  
  //MARK: - Test Helpers
  
  @available(*, deprecated) func testCallActionCanCallAction() {
    let expectation = expectationWithDescription("respond method called")
    struct TestController: ControllerType {
      var state: ControllerState
      static func defineRoutes(routes: RouteSet) {
        
      }
      func index() {
        XCTAssertEqual(actionName, "runTest", "sets the controller's action")
        XCTAssertEqual(request.params["test1"], "value1")
        var response = self.state.response
        response.appendString("Test Response")
        self.callback(response)
      }
    }
    
    TestController.callAction("runTest", TestController.index, Request(parameters: ["test1": "value1"])) {
      response, controller in
      expectation.fulfill()
      self.assert(response.bodyText, equals: "Test Response", message: "gets test response")
    }
    
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }
  
  @available(*, deprecated) func testCallActionCanCallActionWithImplicitRequest() {
    let expectation = expectationWithDescription("respond method called")
    TestController.callAction("index", TestController.indexAction) {
      response, _ in
      expectation.fulfill()
      self.assert(response.bodyText, equals: "Index Action", message: "gets body from action")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  @available(*, deprecated) func testCallActionCanCallActionWithParameters() {
    let expectation = expectationWithDescription("respond method called")
    struct TestController: ControllerType {
      var state: ControllerState
      static func defineRoutes(routes: RouteSet) {
        
      }
      func index() {
        XCTAssertEqual(actionName, "runTest", "sets the controller's action")
        XCTAssertEqual(request.params["test1"], "value1")
        var response = self.state.response
        response.appendString("Test Response")
        self.callback(response)
      }
    }
    
    TestController.callAction("runTest", TestController.index, parameters: ["test1": "value1"]) {
      response, controller in
      expectation.fulfill()
      self.assert(response.bodyText, equals: "Test Response", message: "gets test response")
    }
    
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  @available(*, deprecated) func testCallActionCanCallActionWithUserAndParameters() {
    let expectation = expectationWithDescription("respond method called")
    let user = TestUser().save()!
    TestController.callAction("index", TestController.indexAction, user: user, parameters: ["id": "5"]) {
      response, controller in
      expectation.fulfill()
      self.assert(controller.request.params == Request.ParameterDictionary(["id": "5"]), message: "sets request parameters")
      let currentUser = controller.currentUser
      self.assert(currentUser?.id, equals: user.id, message: "has the user given")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  @available(*, deprecated) func testCallActionCanCallActionWithUser() {
    let expectation = expectationWithDescription("respond method called")
    let user = TestUser().save()!
    TestController.callAction("index", TestController.indexAction, user: user) {
      response, controller in
      expectation.fulfill()
      let currentUser = controller.currentUser
      self.assert(currentUser?.id, equals: user.id, message: "has the user given")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
}
