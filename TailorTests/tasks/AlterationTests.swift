import XCTest
import Tailor
import TailorTesting

class AlterationTests: TailorTestCase {
  class FirstAlteration: Alteration {
    override class func id() -> String { return "1" }
    override func alter() {
      DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE `hats` ADD COLUMN `brim_size` int(11)")
    }
  }
  
  class SecondAlteration: Alteration {
    override class func id() -> String { return "2" }
    override func alter() {
      DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE `hats` ADD COLUMN `material` varchar(255)")
    }
  }
  
  class ThirdAlteration: Alteration {
    override class func id() -> String { return "3" }
    override func alter() {
      DatabaseConnection.sharedConnection().executeQuery("ALTER TABLE `hats` CHANGE column `material` `materiel` varchar(250)")
    }
  }

  func testDescriptionGetsClassName() {
    assert(Alteration.description(), equals: "Tailor.Alteration", message: "gets class name")
  }
  
  func testPendingAlterationsFindsAlterationsThatAreNotInTable() {
    Application.start()
    DatabaseConnection.sharedConnection().executeQuery("DROP TABLE IF EXISTS tailor_alterations")
    DatabaseConnection.sharedConnection().executeQuery("CREATE TABLE tailor_alterations ( id varchar(255) PRIMARY KEY )")
    DatabaseConnection.sharedConnection().executeQuery("INSERT INTO tailor_alterations values (''), (?)", "1")
    
    let alterations = Alteration.pendingAlterations()
    let ids = alterations.map { $0.id() }
    assert(ids, equals: ["2", "3"], message: "gets the ids for the alterations that have not been run")
    SHARED_APPLICATION = nil
  }
}
