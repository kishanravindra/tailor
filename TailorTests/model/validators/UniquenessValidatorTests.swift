import XCTest
import Tailor
import TailorTesting

class UniquenessValidatorTests: TailorTestCase {
  let validator = UniquenessValidator(key: "name")
  let store = Store(data: ["name": "Hatapalooza"])
  
  override func setUp() {
    Application.start()
    DatabaseConnection.sharedConnection().executeQuery("TRUNCATE TABLE stores")
    DatabaseConnection.sharedConnection().executeQuery("TRUNCATE TABLE hats")
    store.save()
  }
  
  func testUniquenessValidatorPutsNoErrorsOnNewRecordWithUniqueValue() {
    let store2 = Store()
    store.name = "Little Shop"
    validator.validate(store2)
    XCTAssertTrue(store2.errors.isEmpty, "puts no errors on record")
  }
  
  func testUniquenessValidatorPutsNoErrorOnSavedRecordWithUniqueValue() {
    validator.validate(store)
    XCTAssertTrue(store.errors.isEmpty, "puts no errors on record")
  }
  
  func testUniquenessValidatorPutsErrorOnNewRecordWithUsedValue() {
    let store2 = Store()
    store2.name = store.name
    validator.validate(store2)
    let error = ValidationError(modelType: Store.self, key: "name", message: "taken", data: [:])
    assert(store2.errors.errors, equals: [error], message: "puts the error on the record")
  }
  
  func testUniquenessValidatorPutsNoErrorOnRecordWithoutRequestedColumn() {
    let validator2 = UniquenessValidator(key: "color")
    validator2.validate(store)
    XCTAssertTrue(store.errors.isEmpty, "puts no error on record")
  }
  
  func testUniquenessValidatorPutsNoErrorOnRecordWithoutValue() {
    store.name = nil
    validator.validate(store)
    XCTAssertTrue(store.errors.isEmpty, "puts no error on record")
  }
  
  func testUniquenessValidatorPutsNoErrorOnModelWithoutDatabase() {
    class TestModel : Model {
      var name: String!
    }
    
    let model = TestModel()
    model.name = "Test"
    validator.validate(model)
    XCTAssertTrue(model.errors.isEmpty, "puts no error on model")
  }
  
  func testUniquenessValidatorPutsErrorsWithMultiWordKey() {
    let validator2 = UniquenessValidator(key: "shelfId")
    let hat1 = Hat.create(["shelfId": NSNumber(int: 1)])
    let hat2 = Hat(data: ["shelfId": NSNumber(int: 1)])
    validator2.validate(hat1)
    validator2.validate(hat2)
    XCTAssertTrue(hat1.errors.isEmpty, "puts no error on the first record")
    XCTAssertFalse(hat2.errors.isEmpty, "puts an error on the second record")
  }
}
