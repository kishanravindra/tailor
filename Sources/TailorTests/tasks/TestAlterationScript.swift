import XCTest
import Tailor
import TailorTesting

struct TestAlterationScript: XCTestCase, TailorTestable {
  var allTests: [(String, () throws -> Void)] { return [
    ("testDescriptionGetsClassName", testDescriptionGetsClassName),
    ("testPendingAlterationsFindsAlterationsThatAreNotInTable", testPendingAlterationsFindsAlterationsThatAreNotInTable),
  ]}

  class FirstAlteration: AlterationScript {
    static let identifier = "1"
    static func run() {
      Application.sharedDatabaseConnection().executeQuery("CREATE TABLE `alteration_tests` (id integer primary key)")
    }
  }
  
  class SecondAlteration: AlterationScript {
    static let identifier = "2"
    static func run() {
      Application.sharedDatabaseConnection().executeQuery("ALTER TABLE `alteration_tests` ADD COLUMN `material` varchar(255)")
    }
  }
  
  class ThirdAlteration: AlterationScript {
    static let identifier = "3"
    static func run() {
      Application.sharedDatabaseConnection().executeQuery("DROP TABLE `alteration_tests`")
    }
  }
  
  func setUp() {
    setUpTestCase()
  }
  
  func tearDown() {
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE IF EXISTS alteration_tests")
    Application.sharedDatabaseConnection().executeQuery("DELETE FROM tailor_alterations WHERE id IN ('1','2','3')")
  }

  func testDescriptionGetsClassName() {
    assert(FirstAlteration.name, equals: "TailorTests.TestAlterationScript.FirstAlteration", message: "gets class name")
  }
  
  func testPendingAlterationsFindsAlterationsThatAreNotInTable() {
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE IF EXISTS tailor_alterations")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE tailor_alterations ( id varchar(255) PRIMARY KEY )")
    Application.sharedDatabaseConnection().executeQuery("INSERT INTO tailor_alterations values (''), (?), (?)", "0", "1")
    
    let alterations = Application.pendingAlterations()
    let ids = alterations.map { $0.identifier }
    assert(ids, equals: ["2", "3"], message: "gets the ids for the alterations that have not been run")
  }
}
