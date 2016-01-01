@testable import ___PROJECTNAME___
import Tailor
import TailorTesting
import XCTest

class ___FILEBASENAME___ : XCTestCase, ControllerTestable {
  typealias TestedControllerType = ___FILEBASENAME___
  var params = [
    "index": ["": ""]
  ]
  
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
}