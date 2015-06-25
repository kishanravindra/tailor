import Foundation
import Tailor

public extension Tailor.Application {
  public class func truncateTables() {
    let results = Application.sharedDatabaseConnection().executeQuery("SHOW TABLES")
    for result in results {
      if let key = result.data.keys.first {
        if let tableName = result.data[key]?.stringValue {
          if tableName != "tailor_alterations" {
            Application.sharedDatabaseConnection().executeQuery("TRUNCATE TABLE \(tableName)")
          }
        }
      }
    }
  }
}