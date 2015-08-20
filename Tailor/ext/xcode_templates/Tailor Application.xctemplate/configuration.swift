import Tailor
import TailorSqlite

extension Application.Configuration {
  public dynamic func configure() {
    databaseDriver = { return SqliteConnection(path: "___PACKAGENAME___.sqlite") }
    staticContent = Application.Configuration.configurationFromFile("localization")
    sessionEncryptionKey = ""
    RouteSet.load(loadRoutes)
  }
  
  /** This method loads the routes for the your application. */
  public func loadRoutes(inout routes: RouteSet) {
  }
}