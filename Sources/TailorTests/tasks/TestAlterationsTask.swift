import XCTest
import Tailor
import TailorTesting

struct TestAlterationsTask: XCTestCase, TailorTestable {
  var allTests: [(String, () throws -> Void)] { return [
    ("testRunTaskRunsPendingAlterations", testRunTaskRunsPendingAlterations),
  ]}

  func setUp() {
    setUpTestCase()
  }

  func tearDown() {
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE IF EXISTS alteration_tests")
  }
  
  func testRunTaskRunsPendingAlterations() {
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE IF EXISTS tailor_alterations")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE tailor_alterations ( id varchar(255) PRIMARY KEY )")
    
    Application.sharedDatabaseConnection().executeQuery("INSERT INTO tailor_alterations VALUES (0),(1),(3)")
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE IF EXISTS alteration_tests")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE `alteration_tests` (id integer primary key)")
    AlterationsTask.runTask()
    
    let result = Application.sharedDatabaseConnection().executeQuery("SELECT sql FROM sqlite_master WHERE type='table' AND name='alteration_tests'")
    assert(result.count, equals: 1, message: "gets the table structure from SQLite")
    if result.count == 1 {
      if let value = result[0].data["sql"], let query = try? String(deserialize: value) {
        assert(query, equals: "CREATE TABLE `alteration_tests` (id integer primary key, `material` varchar(255))")
      }
      else {
        assert(false, message: "gets the table structure from SQLite")
      }
    }
  }
}
