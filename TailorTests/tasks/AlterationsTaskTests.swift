import XCTest
import Tailor
import TailorTesting

class AlterationsTaskTests: TailorTestCase {
  func testRunTaskRunsPendingAlterations() {
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE IF EXISTS tailor_alterations")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE tailor_alterations ( id varchar(255) PRIMARY KEY )")
    
    Application.sharedDatabaseConnection().executeQuery("INSERT INTO tailor_alterations VALUES (?)", "1")
    
    AlterationsTask.runTask()
    
    let result = Application.sharedDatabaseConnection().executeQuery("SHOW FIELDS FROM `hats` LIKE 'materiel'")
    assert(result.count, equals: 1, message: "makes the new column")
  }
}
