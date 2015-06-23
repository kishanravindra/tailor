import XCTest
import Tailor
import TailorTesting

class AlterationTests: TailorTestCase {
  class FirstAlteration: AlterationScript {
    static let identifier = "1"
    static func run() {
      DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE `hats` ADD COLUMN `brim_size` int(11)")
    }
  }
  
  class SecondAlteration: AlterationScript {
    static let identifier = "2"
    static func run() {
      DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE `hats` ADD COLUMN `material` varchar(255)")
    }
  }
  
  class ThirdAlteration: AlterationScript {
    static let identifier = "3"
    static func run() {
      DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE `hats` CHANGE column `material` `materiel` varchar(250)")
    }
  }

  func testDescriptionGetsClassName() {
    assert(FirstAlteration.name, equals: "TailorTests.AlterationTests.FirstAlteration", message: "gets class name")
  }
  
  func testPendingAlterationsFindsAlterationsThatAreNotInTable() {
    DatabaseConnection.sharedConnection().executeQuery("DROP TABLE IF EXISTS tailor_alterations")
    DatabaseConnection.sharedConnection().executeQuery("CREATE TABLE tailor_alterations ( id varchar(255) PRIMARY KEY )")
    DatabaseConnection.sharedConnection().executeQuery("INSERT INTO tailor_alterations values (''), (?)", "1")
    
    let alterations = PendingAlterations()
    let ids = alterations.map { $0.identifier }
    assert(ids, equals: ["2", "3"], message: "gets the ids for the alterations that have not been run")
  }
}
