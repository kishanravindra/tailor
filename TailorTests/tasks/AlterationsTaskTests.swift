import XCTest
import Tailor
import TailorTesting

class AlterationsTaskTests: TailorTestCase {
  func testRunTaskRunsPendingAlterations() {
    DatabaseConnection.sharedConnection().executeQuery("DROP TABLE IF EXISTS tailor_alterations")
    DatabaseConnection.sharedConnection().executeQuery("CREATE TABLE tailor_alterations ( id varchar(255) PRIMARY KEY )")
    
    DatabaseConnection.sharedConnection().executeQuery("INSERT INTO tailor_alterations VALUES (?)", "1")
    
    AlterationsTask.runTask()
    
    let result = DatabaseConnection.sharedConnection().executeQuery("SHOW FIELDS FROM `hats` LIKE 'materiel'")
    assert(result.count, equals: 1, message: "makes the new column")
  }
}
