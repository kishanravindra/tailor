import XCTest
import Tailor
import TailorTesting

class ModelTests: TailorTestCase {
  
  class HatForModel: ModelType {
    
  }
  
  //MARK: - Structure
  
  func testModelNameIsTakenFromClassName() {
    assert(Hat.modelName(), equals: "hat", message: "gets lowercased class name for model")
    assert(HatForModel.modelName(), equals: "hat_for_model", message: "gets lowercased class name with underscores for for HatForModel")
  }
  
  //MARK: - Dynamic Properties

  func testModelAttributeNameSeparatesWords() {
    let name = Hat.attributeName("brimSize")
    assert(name, equals: "brim size", message: "gets words from attribute name")
  }
  
  func testModelAttributeNameCanCapitalizeName() {
    let name = Hat.attributeName("brimSize", capitalize: true)
    assert(name, equals: "Brim Size", message: "gets capitalized words from attribute name")
  }
  
  func testModelAttributeNameCanGetNameFromLocalization() {
    final class TestLocalization : LocalizationSource {
      let locale: String
      init(locale: String) {
        self.locale = locale
      }
      func fetch(key: String, inLocale locale: String) -> String? {
        return key + " translated"
      }
      static var availableLocales: [String] { return [] }
    }
    
    let name = Hat.attributeName("brimSize", localization: TestLocalization(locale: "en"))
    assert(name, equals: "record.hat.attributes.brim_size translated", message: "gets string from localization")
  }
}