import XCTest
import Tailor
import TailorTesting

class ModelTests: TailorTestCase {
  
  class HatForModel {
    
  }
  
  //MARK: - Structure
  
  func testModelNameIsTakenFromClassName() {
    assert(modelName(Hat.self), equals: "hat", message: "gets lowercased class name for model")
    assert(modelName(HatForModel.self), equals: "hat_for_model", message: "gets lowercased class name with underscores for for HatForModel")
  }
  
  //MARK: - Dynamic Properties

  func testModelAttributeNameSeparatesWords() {
    let name = modelAttributeName("hat", "brimSize")
    assert(name, equals: "brim size", message: "gets words from attribute name")
  }
  
  func testModelAttributeNameCanCapitalizeName() {
    let name = modelAttributeName("hat", "brimSize", capitalize: true)
    assert(name, equals: "Brim Size", message: "gets capitalized words from attribute name")
  }
  
  func testModelAttributeNameCanGetNameFromLocalization() {
    class TestLocalization : Localization {
      override func fetch(key: String, inLocale locale: String) -> String? {
        return key + " translated"
      }
    }
    
    let name = modelAttributeName("hat", "brimSize", localization: TestLocalization(locale: "en"))
    assert(name, equals: "record.hat.attributes.brim_size translated", message: "gets string from localization")
  }
}