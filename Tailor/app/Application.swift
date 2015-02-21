import Foundation

/**
  This class represents a web application.
  */
public class Application {
  /** The IP Address that the application listens on. */
  public var ipAddress = (0,0,0,0)
  
  /** The port that the application listens on. */
  public var port = 8080
  
  /** The routes that process requests for the app. */
  public var routeSet = RouteSet()
  
  /** The formatters that we have available for dates. */
  public var dateFormatters: [String:NSDateFormatter] = [:]
  
  /** The subclasses that we've registered for certain critical base classes. */
  private var registeredSubclasses: [String:[AnyClass]] = [:]
  
  /**
    The space-separated arguments given from the command-line.
    */
  public private(set) var arguments: [String]
  
  /**
    The command that the application is running, which is provided in the first
    command-line argument.
    */
  public private(set) var command: String  = ""
  
  /**
    The additional flags that have been passed to the application.
    These flags can be passed in after the command in key=value format. If just
    a key is passed, it will be mapped to "1".
    */
  public private(set) var flags: [String:String] = [:]
  
  /**
    The configuration settings for the application.
    */
  public let configuration = ConfigurationSetting()
    
  /**
    This method initializes the application.
  
    This implementation parses command-line arguments, loads date formatters,
    and registers all the subclasses of Task and Alteration for use in
    running scripts.
    */
  public required init(arguments : [String]? = nil) {
    self.arguments = arguments ?? []
    if self.arguments.isEmpty {
      self.arguments = self.dynamicType.extractArguments()
    }
    self.loadDateFormatters()
    self.registerSubclasses(Task.self, Alteration.self)
    self.parseArguments()
    self.loadConfigFromFile("sessions")
    self.loadConfigFromFile("database")
    self.loadConfigFromFile("localization")
    self.configuration.setDefaultValue("localization.class", value: "PropertyListLocalization")
  }
  
  /** The application that we are running. */
  public class func sharedApplication() -> Application {
    return SHARED_APPLICATION
  }
  
  //MARK: - Running
  
  /**
    This method starts the application.
  
    It looks for a registered task with the command that was invoked when
    starting the application, and runs that task.
  
    If the provided command doesn't have a matching task, this will crash.
    */
  public func start() {
    NSLog("Starting application: %@, %@", command, flags)
    
    for task in self.registeredSubclassList(Task.self) {
      if task.command() == command {
        task().run()
        return
      }
    }
    NSLog("Could not find the specified task")
    exit(1)
  }
  
  /**
    This method starts a server for this application.
    */
  public func startServer() {
    Server().start(ipAddress, port: port, handler: { self.routeSet.handleRequest($0, callback: $1) })
  }
  
  /** Starts a version of this application as the shared application. */
  public class func start() {
    if(SHARED_APPLICATION == nil) {
      SHARED_APPLICATION = self.init()
      SHARED_APPLICATION.start()
    }
  }
  
  /**
    This method opens a database connection.
    
    This will be called every time a new thread is created, so that we have a
    distinct database connection for every thread.
 
    This implementation will return a dummy connection. Subclasses must provide
    their own implementation.

    :returns:   The connection
    */
  public func openDatabaseConnection() -> DatabaseConnection {
    return DatabaseConnection(config: [:])
  }
  
  //MARK: - Loading
  
  /**
    This method extracts the command-line arguments to the current executable
    as a list of strings.

    :returns:
      The arguments.
    */
  public class func extractArguments() -> [String] {
    var arguments = [String]()
    for indexOfArgument in 1..<C_ARGC {
      if let argument = String.fromCString(C_ARGV[Int(indexOfArgument)]) {
        arguments.append(argument)
      }
    }
    return arguments
  }

  
  /**
    This method parses a list of command-line arguments.

    The arguments will be interpreted as a command followed by a series of
    flags. The flags should have the format key=value. If there is no equal sign
    in an flag, the value will be 1.
    
    :returns:   The command and the arguments.
    */
  public class func parseArguments(arguments: [String]) -> (String, [String:String]) {
    var command = ""
    var flags = [String:String]()
    if !arguments.isEmpty {
      command = arguments[0]
      for indexOfFlag in 1..<arguments.count {
        let flagParts = arguments[indexOfFlag].componentsSeparatedByString("=")
        if flagParts.count == 1 {
          flags[flagParts[0]] = "1"
        }
        else {
          flags[flagParts[0]] = flagParts[1]
        }
      }
    }
    return (command,flags)
  }
  
  /**
    This method gets the command and flags from the command-line arguments.
    
    If the command doesn't match a task, this will prompt the user to put in
    a task on the command line, either by name or by number. It will keep
    prompting until it gets a valid task.
    */
  private func parseArguments() {
    (self.command, self.flags) = self.dynamicType.parseArguments(self.arguments)
    let tasks = self.registeredSubclassList(Task.self).sorted {
      task1, task2 in
      task1.command().compare(task2.command()) == NSComparisonResult.OrderedAscending
    }
    
    while (tasks.filter { $0.command() == self.command }).isEmpty {
      print("Please provide a task by name, or from the following list:\n")
      
      for (index,task) in enumerate(tasks) {
        print("\(index + 1). \(task.command())\n")
      }
      let keyboard = NSFileHandle.fileHandleWithStandardInput()
      let inputData = keyboard.availableData
      let invocation = NSString(data: inputData, encoding:NSUTF8StringEncoding)?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
      if invocation == nil {
        continue
      }
      let int = Int((invocation! as NSString).intValue)
      if int > 0 && int < tasks.count {
        self.command = tasks[int - 1].command()
        self.flags = [:]
      }
      else {
        self.arguments = invocation?.componentsSeparatedByString(" ") ?? []
        (self.command, self.flags) = self.dynamicType.parseArguments(self.arguments)
      }
    }

  }
  
  /**
    This method loads the default date formatters.
    */
  private func loadDateFormatters() {
    self.dateFormatters["short"] = NSDateFormatter()
    self.dateFormatters["long"] = NSDateFormatter()
    self.dateFormatters["shortDate"] = NSDateFormatter()
    self.dateFormatters["longDate"] = NSDateFormatter()
    self.dateFormatters["db"] = NSDateFormatter()
    
    self.dateFormatters["short"]?.dateFormat = "hh:mm Z"
    self.dateFormatters["long"]?.dateFormat = "dd MMMM, yyyy, hh:mm z"
    
    self.dateFormatters["shortDate"]?.dateFormat = "dd MMMM"
    self.dateFormatters["longDate"]?.dateFormat = "dd MMMM, yyyy"
    
    self.dateFormatters["db"]?.dateFormat = "yyyy-MM-dd HH:mm:ss"

  }
  
  /**
    This method loads all the subclasses the provided classes into the
    application's registered subclass list.

    The Application initializer uses this to identify all the tasks and
    annotations, but subclasses can invoke it with other classes that they want
    to dynamically crawl.

    The registered subclass list will include the types passed in.

    :param: types   The types to get subclasses of.
    */
  public func registerSubclasses(types: AnyClass...) {
    var classCount = objc_getClassList(nil, 0)
    var allClasses = UnsafeMutablePointer<AnyClass?>(calloc(UInt(sizeof(AnyClass)), UInt(classCount)))
    
    objc_getClassList(AutoreleasingUnsafeMutablePointer<AnyClass?>(allClasses), classCount)
    
    for indexOfClass in 0..<classCount {
      let klass : AnyClass! = allClasses.memory
      
      if klass == nil {
        continue
      }
      allClasses = advance(allClasses, 1)

      let method = class_getClassMethod(klass, Selector("isSubclassOfClass:"))
      if method == nil  {
        continue
      }
      
      for type in types {
        if klass.isSubclassOfClass(type) {
          let typeKey = NSStringFromClass(type)
          var subclasses = self.registeredSubclasses[typeKey] ?? []
          subclasses.append(klass)
          self.registeredSubclasses[typeKey] = subclasses
        }
      }
    }
  }
  
  /**
    This method fetches subclasses of a type.

    The type must have previously been passed in to registerSubclasses to load
    the list.
  
    :param: type  The type to get subclasses of.
    :returns:     The subclasses of the type.
    */
  public func registeredSubclassList<ParentType : AnyObject>(type: ParentType.Type) -> [ParentType.Type] {
    let klass : AnyClass = ParentType.self
    let description = NSStringFromClass(klass)
    let classes = self.registeredSubclasses[description] ?? []
    return classes.map { $0 as ParentType.Type }
  }
  
  //MARK: - Configuration
  
  /**
    The path to the root of the application.
  
    This defaults to the path of the executable
    */
  public func rootPath() -> String {
    return "."
  }
  
  /**
    This method loads configuration from a file into the application's settings.
  
    The settings will be put into the configuration with a prefix taken from the
    filename of the path.
  
    :param: path    The path to the file, relative to the application's root
                    path.
    */
  public func loadConfigFromFile(path: String) {
    let name = path.lastPathComponent.stringByDeletingPathExtension
    self.configuration.child(name).addDictionary(ConfigurationSetting(contentsOfFile: path).toDictionary())
  }
  
  /**
    This method constructs a localization based on the configuration settings.
  
    :param: locale    The locale for the localization
    :returns:         The localization
    */
  public func localization(locale: String) -> Localization {
    let name = self.configuration["localization.class"]
    var klass = NSClassFromString(self.configuration["localization.class"] ?? "") as? Localization.Type ?? Localization.self
    return klass(locale: locale)
  }
}

/** The application that we are running. */
var SHARED_APPLICATION : Application!
