import Tailor
import TailorSqlite

extension Configuration {
  public dynamic func configure() {
    databaseDriver = { return SqliteConnection(path: "__PACKAGENAME__.sqlite") }
    sessionEncryptionKey = ""
    RouteSet.load(loadRoutes)
  }
  
  /** This method loads the routes for the your application. */
  public func loadRoutes(inout routes: RouteSet) {
  }
}