import XCTest

class UniquenessValidatorTests: XCTestCase {
  let validator = UniquenessValidator(key: "name")
  let store = Store(data: ["name": "Hatapalooza"])
  
  override func setUp() {
    TestApplication.start()
    DatabaseConnection.sharedConnection().executeQuery("TRUNCATE TABLE stores")
    store.save()
  }
  
  func testUniquenessValidatorPutsNoErrorsOnNewRecordWithUniqueValue() {
    let store2 = Store()
    store.name = "Little Shop"
    validator.validate(store2)
    XCTAssertTrue(store2.errors.isEmpty(), "puts no errors on record")
  }
  
  func testUniquenessValidatorPutsNoErrorOnSavedRecordWithUniqueValue() {
    validator.validate(store)
    XCTAssertTrue(store.errors.isEmpty(), "puts no errors on record")
  }
  
  func testUniquenessValidatorPutsErrorOnNewRecordWithUsedValue() {
    let store2 = Store()
    store2.name = store.name
    validator.validate(store2)
    XCTAssertEqual(store2.errors.errors, ["name": ["is already taken"]], "has an error indicating it is already taken")
  }
  
  func testUniquenessValidatorPutsNoErrorOnRecordWithoutRequestedColumn() {
    let validator2 = UniquenessValidator(key: "color")
    validator2.validate(store)
    XCTAssertTrue(store.errors.isEmpty(), "puts no error on record")
  }
  
  func testUniquenessValidatorPutsNoErrorOnRecordWithoutValue() {
    store.name = nil
    validator.validate(store)
    XCTAssertTrue(store.errors.isEmpty(), "puts no error on record")
  }
  
  func testUniquenessValidatorPutsNoErrorOnModelWithoutDatabase() {
    class TestModel : Model {
      var name: String!
    }
    
    let model = TestModel()
    model.name = "Test"
    validator.validate(model)
    XCTAssertTrue(model.errors.isEmpty(), "puts no error on model")
  }
}
