import Tailor
import Tailor
import TailorSqlite
@testable import TailorTesting
import XCTest
import Foundation

final class TestTemplateTestable : XCTestCase {
  final class TestCase: StubbedTestCase, TemplateTestable {
    var controller = EmptyController(state: ControllerState())
    var template = EmptyController.EmptyTemplate(controller: EmptyController(state: ControllerState()))

    var allTests: [(String, () throws -> Void)] { return [] }
  }
  
  var testCase = TestCase()

  func setUp() {
    testCase = TestCase()
  }

  //FIXME: Re-enable commented-out tests
  var allTests: [(String, () throws -> Void)] { return [
    ("testAssertXmlContainsElementWithMatchingElementDoesNotRegisterFailure", testAssertXmlContainsElementWithMatchingElementDoesNotRegisterFailure),
    ("testAssertXmlContainsElementWithNonMatchingElementNameRegistersFailure", testAssertXmlContainsElementWithNonMatchingElementNameRegistersFailure),
    ("testAssertXmlContainsElementWithNonMatchingAttributeRegistersFailure", testAssertXmlContainsElementWithNonMatchingAttributeRegistersFailure),
    ("testAssertXmlDoesNotContainsElementWithoutMatchingElementDoesNotRegisterFailure", testAssertXmlDoesNotContainsElementWithoutMatchingElementDoesNotRegisterFailure),
    ("testAssertXmlDoesNotContainsElementWithMatchingElementRegistersFailure", testAssertXmlDoesNotContainsElementWithMatchingElementRegistersFailure),
  ]}

  func testAssertXmlContainsElementWithMatchingElementDoesNotRegisterFailure() {
    let xml = "<form name=\"test-form\" action=\"/test/path\"><input name=\"foo\"></input></form>"
    testCase.assert(xml, containsElement: "form", attributes: ["action": "/test/path"])
    XCTAssertEqual(testCase.failures.count, 0)
  }

  func testAssertXmlContainsElementWithNonMatchingElementNameRegistersFailure() {
    let xml = "<for name=\"test-form\" action=\"/test/path\"><input name=\"foo\"></input></for>"
    testCase.assert(xml, containsElement: "form", attributes: ["action": "/test/path"])
    XCTAssertEqual(testCase.failures.count, 1)
    guard testCase.failures.count > 0 else { return }
    XCTAssertEqual(testCase.failures[0].message, "<html><body>\(xml)</body></html> did not contain an element matching form([\"action\": \"/test/path\"])")
    XCTAssertEqual(testCase.failures[0].file, __FILE__)
    XCTAssertEqual(testCase.failures[0].line, __LINE__ - 5)
  }

  func testAssertXmlContainsElementWithNonMatchingAttributeRegistersFailure() {
    let xml = "<form name=\"test-form\" action=\"/test/path2\"><input name=\"foo\"></input></form>"
    testCase.assert(xml, containsElement: "form", attributes: ["action": "/test/path"])
    XCTAssertEqual(testCase.failures.count, 1)
    guard testCase.failures.count == 1 else { return }
    XCTAssertEqual(testCase.failures[0].message, "<html><body>\(xml)</body></html> did not contain an element matching form([\"action\": \"/test/path\"])")
    XCTAssertEqual(testCase.failures[0].file, __FILE__)
    XCTAssertEqual(testCase.failures[0].line, __LINE__ - 5)
  }

  func testAssertXmlDoesNotContainsElementWithoutMatchingElementDoesNotRegisterFailure() {
    let xml = "<for name=\"test-form\" action=\"/test/path\"><input name=\"foo\"></input></for>"
    testCase.assert(xml, doesNotContainElement: "form", attributes: ["action": "/test/path"])
    XCTAssertEqual(testCase.failures.count, 0)
  }

  func testAssertXmlDoesNotContainsElementWithMatchingElementRegistersFailure() {
    let xml = "<form name=\"test-form\" action=\"/test/path\"><input name=\"foo\"></input></form>"
    testCase.assert(xml, containsElement: "form", attributes: ["action": "/test/path"])
    guard testCase.failures.count == 1 else { return }
    XCTAssertEqual(testCase.failures[0].message, "<html><body>\(xml)</body></html> did not contain an element matching form([\"action\": \"/test/path\"])")
    XCTAssertEqual(testCase.failures[0].file, __FILE__)
    XCTAssertEqual(testCase.failures[0].line, __LINE__ - 5)
  }
}