import Foundation

/**
  This class provides the application for the Haberdashery.
  */
class HaberdasheryApplication : Application {
  /**
    This method initializes the application.

    We override this to set custom routes.
    */
  required init(){
    super.init()
    self.routeSet = HaberdasheryRouteSet
  }
  
  /**
    This method starts our application.

    We override this to initialize our database connection before starting the
    server.
    */
  override func start() {
    MysqlConnection.open(self.configFromFile("database") as [String:String])
    super.start()
  }
}