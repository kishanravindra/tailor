import XCTest
import Tailor

class AlterationsTaskTests: XCTestCase {
  func testRunTaskRunsPendingAlterations() {
    Application.start()
    DatabaseConnection.sharedConnection().executeQuery("DROP TABLE IF EXISTS tailor_alterations")
    DatabaseConnection.sharedConnection().executeQuery("CREATE TABLE tailor_alterations ( id varchar(255) PRIMARY KEY )")
    
    DatabaseConnection.sharedConnection().executeQuery("INSERT INTO tailor_alterations VALUES (?)", "1")
    
    AlterationsTask().run()
    
    let result = DatabaseConnection.sharedConnection().executeQuery("SHOW FIELDS FROM `hats` LIKE 'materiel'")
    XCTAssertEqual(result.count, 1, "makes the new column")
    SHARED_APPLICATION = nil
  }
}
