import Foundation
import Tailor

public extension Tailor.Application {
  public class func truncateTables(tableNames: String...) {
    for tableName in self.sharedDatabaseConnection().tableNames() where tableName != "tailor_alterations" {
      Application.sharedDatabaseConnection().executeQuery("DELETE FROM \(tableName)")
    }
  }
}