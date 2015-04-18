import XCTest
import Tailor
import TailorTesting

class UniquenessValidatorTests: TailorTestCase {
  let validator = UniquenessValidator(key: "name")
  let store = Store(name: "Hatapalooza")
  
  override func setUp() {
    super.setUp()
    store.save()
  }
  
  func testUniquenessValidatorPutsNoErrorsOnNewRecordWithUniqueValue() {
    let store2 = Store(name: "Little Shop")
    validator.validate(store2)
    XCTAssertTrue(store2.errors.isEmpty, "puts no errors on record")
  }
  
  func testUniquenessValidatorPutsNoErrorOnSavedRecordWithUniqueValue() {
    validator.validate(store)
    XCTAssertTrue(store.errors.isEmpty, "puts no errors on record")
  }
  
  func testUniquenessValidatorPutsErrorOnNewRecordWithUsedValue() {
    let store2 = Store(name: store.name)
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
    let shelf = Shelf(name: nil)
    validator.validate(shelf)
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
    let validator2 = UniquenessValidator(key: "shelf_id")
    let hat1 = Hat(shelfId: 1)
    hat1.save()
    let hat2 = Hat(shelfId: 1)
    validator2.validate(hat1)
    validator2.validate(hat2)
    XCTAssertTrue(hat1.errors.isEmpty, "puts no error on the first record")
    XCTAssertFalse(hat2.errors.isEmpty, "puts an error on the second record")
  }
}
