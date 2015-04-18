import XCTest
import Tailor
import TailorTesting

class ModelTests: TailorTestCase {
  
  @objc(HatForModel) class Hat : TailorTests.Hat {
    
  }
  
  //MARK: - Structure
  
  func testModelNameIsTakenFromClassName() {
    assert(TailorTests.Hat.modelName(), equals: "hat", message: "gets lowercased class name for model")
    assert(Hat.modelName(), equals: "hat_for_model", message: "gets lowercased class name with underscores for for HatForModel")
  }
  
  //MARK: - Dynamic Properties

  func testHumanAttributeNameSeparatesWords() {
    let name = Hat.humanAttributeName("brimSize")
    assert(name, equals: "brim size", message: "gets words from attribute name")
  }
  
  func testHumanAttributeNameCanCapitalizeName() {
    let name = Hat.humanAttributeName("brimSize", capitalize: true)
    assert(name, equals: "Brim Size", message: "gets capitalized words from attribute name")
  }
  
  func testHumanAttributeNameCanGetNameFromLocalization() {
    class TestLocalization : Localization {
      override func fetch(key: String, inLocale locale: String) -> String? {
        return key + " translated"
      }
    }
    
    let name = Hat.humanAttributeName("brimSize", localization: TestLocalization(locale: "en"))
    assert(name, equals: "record.hat_for_model.attributes.brim_size translated", message: "gets string from localization")
  }
}
