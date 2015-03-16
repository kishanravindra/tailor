import Foundation
import Tailor

public extension Tailor.Application {
  public class func truncateTables() {
    let results = DatabaseConnection.sharedConnection().executeQuery("SHOW TABLES")
    for result in results {
      if let key = result.data.keys.first {
        if let tableName = result.data[key] as? String {
          if tableName != "tailor_alterations" {
            DatabaseConnection.sharedConnection().executeQuery("TRUNCATE TABLE \(tableName)")
          }
        }
      }
    }
  }
}