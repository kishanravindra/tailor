import Foundation

/**
  This class represents a web application.
  */
class Application {
  /** The IP Address that the application listens on. */
  var ipAddress = (0,0,0,0)
  
  /** The port that the application listens on. */
  var port = 8080
  
  /** The routes that process requests for the app. */
  var routeSet = RouteSet()
  
  /**
    This method starts the server.
    */
  func start() {
    Server().start(ipAddress, port: port, handler: { self.routeSet.handleRequest($0, callback: $1) })
  }
  
  /** The application that we are running. */
  class func sharedApplication() -> Application {
    return SHARED_APPLICATION
  }
}

/** The application that we are running. */
let SHARED_APPLICATION = Application()