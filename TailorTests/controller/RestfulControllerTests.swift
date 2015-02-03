import XCTest

class TestRestfulController<RecordType: Record>: RestfulController<RecordType> {
  required init(request: Request, action: String, callback: Server.ResponseCallback) {
    super.init(request: request, action: action, callback: callback)
    self.templates["index"] = Template {
      t,p in
      if let hats = p["records"] as? [RecordType] {
        t.tag("ul") {
          for hat in hats {
            t.tag("li", text: hat.id.stringValue)
          }
        }
      }
    }
    
    self.templates["show"] = Template {
      t,p in
      if let record = p["record"] as? RecordType {
        t.tag("h1", text: record.id.stringValue)
      }
    }
    
    self.templates["form"] = Template {
      t,p in
      if let record = p["record"] as? RecordType {
        t.tag("form") {
          t.tag("h1", text: record.id?.stringValue ?? "New Record")
        }
      }
    }
  }
  
  override class func name() -> String {
    return "TestRestfulController"
  }
  
  override func setAttributesOnRecord(record: RecordType, parameters: [String : String]) {
    record.setValue(parameters["color"], forKey: "color")
  }
}

class RestfulControllerTests: XCTestCase {
  var controller: RestfulController<Hat>!
  var callback: Server.ResponseCallback = {response in }
  var testBody = "Test"
  var testData = "Test".dataUsingEncoding(NSUTF8StringEncoding)!
  
  override func setUp() {
    TestApplication.start()
    DatabaseConnection.sharedConnection().executeQuery("TRUNCATE TABLE `hats`")
    controller = RestfulController<Hat>(
      request: Request(),
      action: "index",
      callback: { self.callback($0) }
    )
    
    var routeSet = RouteSet()
    routeSet.withPrefix("hats", controller: TestRestfulController<Hat>.self) {
      routeSet.addRestfulRoutes()
    }
    TestApplication.sharedApplication().routeSet = routeSet
  }
  
  //MARK: - Data
  
  func testRecordWithNoIdGetsNewRecord() {
    let record = controller.record()
    XCTAssertNotNil(record, "record is not nil")
    if record != nil {
      XCTAssertNil(record!.id, "id is nil")
    }
  }
  
  func testRecordWithValidIdGetsRecord() {
    let hat = Hat()
    hat.save()
    controller = RestfulController<Hat>(
      request: Request(parameters: ["id": hat.id.stringValue]),
      action: "index",
      callback: { self.callback($0) }
    )
    let record = controller.record()
    XCTAssertNotNil(record, "record is not nil")
    if record != nil {
      XCTAssertEqual(record!, hat, "returns the record with that id")
    }
  }
  
  func testRecordWithInvalidIdGetsNil() {
    let hat = Hat()
    hat.save()
    controller = RestfulController<Hat>(
      request: Request(parameters: ["id": String(hat.id.integerValue + 1)]),
      action: "index",
      callback: { self.callback($0) }
    )
    let record = controller.record()
    XCTAssertNil(record, "record is nil")
  }
  
  func testIndexActionRendersIndexTemplateWithRecords() {
    let expectation = expectationWithDescription("callback called")
    let hat1 = Hat.create(["color": "red"])
    let hat2 = Hat.create(["color": "black"])
    TestRestfulController<Hat>.callAction("index") {
      response, _ in
      expectation.fulfill()
      XCTAssertEqual(response.code, 200, "gives a successful response")
      XCTAssertEqual(response.bodyString, "<ul><li>\(hat1.id)</li><li>\(hat2.id)</li></ul>", "puts hats into the index template")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testIndexActionWithNoTemplateRenders404() {
    let expectation = expectationWithDescription("callback called")
    RestfulController<Hat>.callAction("index") {
      response, _ in
      expectation.fulfill()
      XCTAssertEqual(response.code, 404, "gives a 404 response")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testShowActionWithValidIdRendersShowTemplate() {
    let hat = Hat.create()
    let expectation = expectationWithDescription("callback called")
    TestRestfulController<Hat>.callAction("show", parameters: ["id": hat.id.stringValue]) {
      response, _ in
      expectation.fulfill()
      XCTAssertEqual(response.code, 200, "gives a successful response")
      XCTAssertEqual(response.bodyString, "<h1>\(hat.id)</h1>", "puts the template body in the response")
    }
    self.waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testShowActionWithInvalidIdGives404() {
    let hat = Hat.create()
    let expectation = expectationWithDescription("callback called")
    TestRestfulController<Hat>.callAction("show", parameters: ["id": String(hat.id.integerValue + 1)]) {
      response, _ in
      expectation.fulfill()
      XCTAssertEqual(response.code, 404, "gives a 404 response")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testShowActionWithNoTemplateGives404() {
    let hat = Hat.create()
    let expectation = expectationWithDescription("callback called")
    RestfulController<Hat>.callAction("show", parameters: ["id": hat.id.stringValue]) {
      response, _ in
      expectation.fulfill()
      XCTAssertEqual(response.code, 404, "gives a 404 response")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testNewActionRendersTemplate() {
    let expectation = expectationWithDescription("callback called")
    TestRestfulController<Hat>.callAction("new") {
      response, _ in
      expectation.fulfill()
      XCTAssertEqual(response.code, 200, "gives a successful response")
      XCTAssertEqual(response.bodyString, "<form><h1>New Record</h1></form>", "has the form data for a new response")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testNewActionWithNoTemplateGives404() {
    let expectation = expectationWithDescription("callback called")
    RestfulController<Hat>.callAction("new") {
      response, _ in
      expectation.fulfill()
      XCTAssertEqual(response.code, 404)
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testCreateActionCreatesRecord() {
    let expectation = expectationWithDescription("callback called")
    TestRestfulController<Hat>.callAction("create", Request(parameters: ["color": "black"], method: "POST")) {
      response, _ in
      expectation.fulfill()
      let hats = Query<Hat>().all()
      XCTAssertEqual(hats.count, 1, "creates a record")
      if hats.count == 1 {
        let hat = hats[0]
        XCTAssertNotNil(hat.color, "sets attributes on the record")
        if hat.color != nil {
          XCTAssertEqual(hat.color, "black", "sets attributes on the record")
        }
      }
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testCreateActionRedirectsToIndexPath() {
    let expectation = expectationWithDescription("callback called")
    TestRestfulController<Hat>.callAction("create", Request(method: "POST")) {
      response, _ in
      expectation.fulfill()
      XCTAssertEqual(response.code, 302, "gives a 302 response")
      
      let location = response.headers["Location"]
      XCTAssertNotNil(location)
      if location != nil {
        XCTAssertEqual(location!, "/hats")
      }
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testCreateActionWithInvalidDataRendersForm() {
    let expectation = expectationWithDescription("callback called")
    class TestHat : Hat {
      override class func validators() -> [Validator] {
        return [PresenceValidator(key: "color")]
      }
    }
    
    TestRestfulController<TestHat>.callAction("create", Request(method: "POST")) {
      response, _ in
      expectation.fulfill()
      XCTAssertEqual(response.code, 200, "gives a success response")
      XCTAssertEqual(response.bodyString, "<form><h1>New Record</h1></form>", "renders the form template")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testCreateActionWithInvalidDataAndNoTemplateRenders404() {
    let expectation = expectationWithDescription("callback called")
    class TestHat : Hat {
      override class func validators() -> [Validator] {
        return [PresenceValidator(key: "color")]
      }
    }
    
    RestfulController<TestHat>.callAction("create", Request(method: "POST")) {
      response, _ in
      expectation.fulfill()
      XCTAssertEqual(response.code, 404, "gives a 404 response")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testEditActionWithValidIdRendersTemplate() {
    let hat = Hat.create()
    let expectation = expectationWithDescription("callback called")
    TestRestfulController<Hat>.callAction("edit", parameters: ["id": hat.id.stringValue]) {
      response, _ in
      expectation.fulfill()
      XCTAssertEqual(response.code, 200, "gives a 200 response")
      XCTAssertEqual(response.bodyString, "<form><h1>\(hat.id)</h1></form>")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testEditActionWithInvalidIdRenders404() {
    let hat = Hat.create()
    let expectation = expectationWithDescription("callback called")
    TestRestfulController<Hat>.callAction("edit", parameters: ["id": String(hat.id.integerValue + 1)]) {
      response, _ in
      expectation.fulfill()
      XCTAssertEqual(response.code, 404, "gives a 404 response")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testEditActionWithNoTemplateRenders404() {
    let hat = Hat.create()
    let expectation = expectationWithDescription("callback called")
    RestfulController<Hat>.callAction("edit", parameters: ["id": hat.id.stringValue]) {
      response, _ in
      expectation.fulfill()
      XCTAssertEqual(response.code, 404, "gives a 200 response")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testUpdateActionWithValidIdUpdatesObject() {
    let hat = Hat.create(["color": "red"])
    let expectation = expectationWithDescription("callback called")
    TestRestfulController<Hat>.callAction("update", parameters: ["id": hat.id.stringValue, "color": "black"]) {
      response in
      expectation.fulfill()
      let hat2 = Query<Hat>().find(hat.id.integerValue)!
      XCTAssertEqual(hat2.color, "black", "sets color on hat")
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testUpdateActionWithValidIdRedirectsToIndex() {
    let hat = Hat.create(["color": "red"])
    let expectation = expectationWithDescription("callback called")
    TestRestfulController<Hat>.callAction("update", parameters: ["id": hat.id.stringValue, "color": "black"]) {
      response, _ in
      expectation.fulfill()
      XCTAssertEqual(response.code, 302)
      let location = response.headers["Location"]
      XCTAssertNotNil(location, "has a location header")
      if location != nil {
        XCTAssertEqual(location!, "/hats", "redirects to the list of hats")
      }
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
  
  func testUpdateActionWithInvalidIdGives404() {
    let hat = Hat.create(["color": "red"])
    let expectation = expectationWithDescription("callback called")
    TestRestfulController<Hat>.callAction("update", parameters: ["id": String(hat.id.integerValue + 1), "color": "black"]) {
      response, _ in
      expectation.fulfill()
      XCTAssertEqual(response.code, 404)
    }
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
}
