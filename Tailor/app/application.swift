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
    The path to the root of the application.
  
    This defaults to the path of the executable
    */
  var rootPath = "."
  
  /** The formatters that we have available for dates. */
  var dateFormatters: [String:NSDateFormatter] = [:]
  
  /**
    This method initializes the application.
  
    This implementation does nothing, but subclasses can initialize
    application-specific information like routes.
    */
  required init() {
    self.dateFormatters["short"] = NSDateFormatter()
    self.dateFormatters["long"] = NSDateFormatter()
    self.dateFormatters["shortDate"] = NSDateFormatter()
    self.dateFormatters["longDate"] = NSDateFormatter()
    
    self.dateFormatters["short"]?.dateFormat = "hh:mm Z"
    self.dateFormatters["long"]?.dateFormat = "dd MMMM, yyyy, hh:mm z"

    self.dateFormatters["shortDate"]?.dateFormat = "dd MMMM"
    self.dateFormatters["longDate"]?.dateFormat = "dd MMMM, yyyy"
  }
  
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
  
  /** Starts a version of this application as the shared application. */
  class func start() {
    SHARED_APPLICATION = self.init()
    SHARED_APPLICATION.start()
  }
  
  //MARK: - Configuration
  
  /**
    This method gets the config from our config file based on the filename.
  
    :param: file    The name of the file, with no extension.
    :returns:       The config from the file, or an empty dictionary if we could
                    not load the config.
    */
  func configFromFile(file: String) -> NSDictionary {
    let filename = "\(self.rootPath)/\(file).plist"
    let data = NSData(contentsOfFile: filename)
    let propertyList = NSPropertyListSerialization.propertyListWithData(data, options: Int(NSPropertyListMutabilityOptions.Immutable.toRaw()), format: nil, error: nil) as? NSDictionary
    return propertyList ?? NSDictionary()
  }
}

/** The application that we are running. */
var SHARED_APPLICATION = Application()