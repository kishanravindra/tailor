import XCTest
import Tailor

class AlterationTests: XCTestCase {
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
    XCTAssertEqual(Alteration.description(), "Tailor.Alteration", "gets class name")
  }
  
  func testPendingAlterationsFindsAlterationsThatAreNotInTable() {
    TailorTests.TestApplication.start()
    DatabaseConnection.sharedConnection().executeQuery("DROP TABLE IF EXISTS tailor_alterations")
    DatabaseConnection.sharedConnection().executeQuery("CREATE TABLE tailor_alterations ( id varchar(255) PRIMARY KEY )")
    DatabaseConnection.sharedConnection().executeQuery("INSERT INTO tailor_alterations values (''), (?)", "1")
    
    let alterations = Alteration.pendingAlterations()
    let ids = alterations.map { $0.id() }
    XCTAssertEqual(ids, ["2", "3"], "gets the ids for the alterations that have not been run")
    SHARED_APPLICATION = nil
  }
}
