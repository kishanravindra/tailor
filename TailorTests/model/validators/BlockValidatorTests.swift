import XCTest

class BlockValidatorTests: XCTestCase {
  let model = Model()
  
  func testBlockIsRunWhenValidationIsCalled() {
    let expectation = expectationWithDescription("block is called")
    let validator = BlockValidator(key: "name", block: {
      _,_ in
      expectation.fulfill()
    })
    validator.validate(model)
    waitForExpectationsWithTimeout(0.01, handler: nil)
  }
}
