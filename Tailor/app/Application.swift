import Foundation

/**
  This class represents a web application.
  */
public class Application {
  /**
    This structure provides the configuration settings for an application.
    */
  public struct Configuration {
    /** The port that the application listens on. */
    public var port = 8080
    
    /** The IP address that the application listens on. */
    public var ipAddress = (0,0,0,0)
    
    /** A function for creating the localization for a given locale. */
    public var localization: (String->LocalizationSource) = { PropertyListLocalization(locale: $0) }
    
    /** The static content for a property list localization. */
    public var staticContent = [String:String]()
    
    /**
      The encryption key used for session information.
    
      You must set this before starting the application. The best practice is
      to store this in a special configuration file that is not under source
      control.
      */
    public var sessionEncryptionKey = ""
    
    /**
      A function for creating the database driver for the application.

      You must set this yourself if you are going to make any database queries.
      */
    public var databaseDriver: (Void->DatabaseDriver)? = nil
    
    /** A function for creating the cache store for the application. */
    public var cacheStore: (Void->CacheImplementation) = { MemoryCacheStore() }
    
    /** A function for creating the email agent for the application. */
    public var emailAgent: (Void->EmailAgent) = { FileEmailAgent() }
    
    /**
      This initializer creates a configuration setting object with the default
      values.
      */
    public init() {
      
    }
    
    /**
      This method flattens a nested dictionary of strings into a flat dictionary
      of strings.
    
      The key components for nested levels will be separated by dots, forming
      key paths.
    
      Anything in the dictionary that is not a string or a dictionary will be
      ignored.
    
      - parameter dictionary:   The nested dictionary
      - returns:                The flattened dictionary.
      */
    public static func flattenDictionary(dictionary: NSDictionary) -> [String:String] {
      var result = [String:String]()
      for (key,value) in dictionary {
        guard let keyString = key as? String else { continue }
        switch(value) {
        case let s as String:
          result[keyString] = s
        case let d as NSDictionary:
          for (innerKey, innerValue) in flattenDictionary(d) {
            result[keyString + "." + innerKey] = innerValue
          }
        default:
          continue
        }
      }
      return result
    }
    
    /**
      This method sets a default value for a key in the static content.

      If there is already a value for the key, this will do nothing.
  
      - parameter key:    The key to set content for
      - parameter value:  The content to set.
      */
    public mutating func setDefaultContent(key: String, value: String) {
      self.staticContent[key] = self.staticContent[key] ?? value
    }
    
    /**
      This method gets the content from a localization plist file.

      The plist file must contain a dictionary with a key "content". That key
      must map to a dictionary containing the content. If the dictionary has
      nested dictionaries within it, they will be collapsed into a single
      dictionary by combining the keys into a key path with a period as the
      separator.

      If a path is not provided, this will look through the bundles for the
      application for one that has a "localization.plist" file, and then use
      that file for the content.

      - parameter path:   The full path to the plist file.
      - returns:          The flattened content dictionary.
      */
    public static func contentFromLocalizationPlist(path: String? = nil) -> [String:String] {
      let path = path ?? {
        for bundle in NSBundle.allBundles() {
          var bundlePath = bundle.resourcePath ?? "."
          bundlePath += "/localization.plist"
          if NSFileManager.defaultManager().fileExistsAtPath(bundlePath) {
            return bundlePath
          }
        }
        return "."
      }()
      
      if let data = NSData(contentsOfFile: path) {
        do {
         let plist = try NSPropertyListSerialization.propertyListWithData(data, options: [.Immutable], format: nil)
          if let dictionary = plist as? NSDictionary,
            let contentDictionary = dictionary["content"] as? NSDictionary {
              return flattenDictionary(contentDictionary)
          }
        }
        catch {
          
        }
      }
      return [:]
    }
  }
  
  /**
    The IP Address that the application listens on.
  
    This is deprecated. The IP address is now stored on the configuration setting.
    */
  @available(*, deprecated, message="This is deprecated. The IP address is now stored in the configuration")
  public var ipAddress: (Int,Int,Int,Int) {
    get {
      return Application.configuration.ipAddress
    }
    set {
      Application.configuration.ipAddress = newValue
    }
  }
  
  /**
    The port that the application listens on.
  
    This is deprecated. The port is now stored in the configuration settings.
    */
  @available(*, deprecated, message="This is deprecated. The port is now stored in the configuration") public var port: Int {
    get {
      return Application.configuration.port
    }
    set {
      Application.configuration.port = newValue
    }
  }
  
  /**
    The routes that process requests for the app.
  
    This has been deprecated in favor of getting the load and shared methods on
    RouteSet.
    */
  @available(*, deprecated, message="Use the shared route set instead") public var routeSet: RouteSet {
    get {
      return RouteSet.shared()
    }
    set {
      RouteSet.load {
        routes in
        for route in newValue.routes {
          let path = route.pathPattern
          routes.addRoute(path.substringFromIndex(advance(path.startIndex, 1)), method: route.method, handler: route.handler, description: route.description, controller: route.controller, actionName: route.actionName)
        }
      }
    }
  }
  
  /** The formatters that we have available for dates. */
  @available(*, deprecated, message="You should use the TimeFormat class instead")
  public var dateFormatters: [String:NSDateFormatter] {
    get {
      return _dateFormatters
    }
    set {
      _dateFormatters = newValue
    }
  }
  
  private var _dateFormatters: [String:NSDateFormatter] = [:]
  
  /** The subclasses that we've registered for certain critical base classes. */
  private var registeredSubtypes: [String:[Any.Type]] = [:]
  
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
  
    This has been deprecated in favor of the static configuration variable.
    */
  @available(*, deprecated, message="This has been deprecated in favor of the static configuration variable") public let configuration = ConfigurationSetting()
  
  /**
    The configuration settings for the application.
  
    We don't guarantee thread safety for setting this, so it is best to only
    change this variables on the main thread, before starting the application.
    */
  public static var configuration = Configuration()
  
  /** Whether this application is being loaded as part of a test bundle. */
  private let testing: Bool
    
  /**
    This method initializes the application.
  
    This implementation parses command-line arguments, loads date formatters,
    and registers all the subclasses of Task and AlterationScript for use in
    running scripts.
  
    This also loads configuration settings in the old format from the
    localization, sessions, and database plist files. This behavior is
    deprecated, and will be removed in a future release. Instead, you should
    set configuration in code prior to starting the application.
  
    - parameter testing:    Whether this application is being loaded as part of
                            a test bundle. This is set to true in test cases
                            that subclass TailorTestCase.
    */
  public required init(testing: Bool = false) {
    self.testing = testing
    
    self.loadDateFormatters()
    self.registerSubtypes(TaskType.self) { $0 is TaskType.Type }
    self.registerSubtypes(AlterationScript.self) { $0 is AlterationScript.Type }
    
    if NSProcessInfo.processInfo().environment["TestBundleLocation"] != nil {
      self.command = "run_tests"
      self.flags = [:]
    }
    else if testing {
      self.command = "tailor.exit"
      self.flags = [:]
    }
    else if let arguments = APPLICATION_ARGUMENTS {
      self.command = arguments.0
      self.flags = arguments.1
    }
    else {
      self.extractArguments()
    }
    APPLICATION_ARGUMENTS = (self.command, self.flags)
    
    func propertyList(section: String) -> NSDictionary {
      let file = self.rootPath() + "/" + section + ".plist"
      if let data = NSData(contentsOfFile: file) {
        do {
          let plist = try NSPropertyListSerialization.propertyListWithData(data, options: [.Immutable], format: nil)
          if let dictionary = plist as? NSDictionary {
            return dictionary
          }
        }
        catch {
          
        }
      }
      return NSDictionary()
    }
    
    if Application.configuration.staticContent.isEmpty {
      Application.configuration.staticContent = Application.Configuration.contentFromLocalizationPlist()
    }
    
    let localizationConfig = propertyList("localization")
    if let className = localizationConfig["class"] as? String {
      if let klass = NSClassFromString(className) as? LocalizationSource.Type {
        Application.configuration.localization = { return klass.init(locale: $0) }
      }
    }
    
    let databaseConfig = propertyList("database")
    if let className = databaseConfig["class"] as? String,
      let databaseOptions = databaseConfig as? [String:String],
      let klass = NSClassFromString(className) as? DatabaseDriver.Type {
        Application.configuration.databaseDriver = { return klass.init(config: databaseOptions) }
    }
    
    let sessionConfig = propertyList("sessions")
    if let key = sessionConfig["encryptionKey"] as? String {
      Application.configuration.sessionEncryptionKey = key
    }
    
    Application.configuration.setDefaultContent("en.model.errors.blank", value: "cannot be blank")
    Application.configuration.setDefaultContent("en.model.errors.blank", value: "cannot be blank")
    Application.configuration.setDefaultContent("en.model.errors.too_high", value: "cannot be more than \\(max)")
    Application.configuration.setDefaultContent("en.model.errors.too_low", value: "cannot be less than \\(min)")
    Application.configuration.setDefaultContent("en.model.errors.non_numeric", value: "must be a number")
    Application.configuration.setDefaultContent("en.model.errors.taken", value: "is already taken")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.full.1", value: "January")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.full.2", value: "February")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.full.3", value: "March")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.full.4", value: "April")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.full.5", value: "May")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.full.6", value: "June")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.full.7", value: "July")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.full.8", value: "August")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.full.9", value: "September")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.full.10", value: "October")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.full.11", value: "November")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.full.12", value: "December")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.abbreviated.1", value: "Jan")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.abbreviated.2", value: "Feb")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.abbreviated.3", value: "Mar")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.abbreviated.4", value: "Apr")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.abbreviated.5", value: "May")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.abbreviated.6", value: "Jun")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.abbreviated.7", value: "Jul")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.abbreviated.8", value: "Aug")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.abbreviated.9", value: "Sep")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.abbreviated.10", value: "Oct")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.abbreviated.11", value: "Nov")
    Application.configuration.setDefaultContent("en.dates.gregorian.month_names.abbreviated.12", value: "Dec")
    Application.configuration.setDefaultContent("en.dates.gregorian.week_day_names.full.1", value: "Sunday")
    Application.configuration.setDefaultContent("en.dates.gregorian.week_day_names.full.2", value: "Monday")
    Application.configuration.setDefaultContent("en.dates.gregorian.week_day_names.full.3", value: "Tuesday")
    Application.configuration.setDefaultContent("en.dates.gregorian.week_day_names.full.4", value: "Wednesday")
    Application.configuration.setDefaultContent("en.dates.gregorian.week_day_names.full.5", value: "Thursday")
    Application.configuration.setDefaultContent("en.dates.gregorian.week_day_names.full.6", value: "Friday")
    Application.configuration.setDefaultContent("en.dates.gregorian.week_day_names.full.7", value: "Saturday")
    Application.configuration.setDefaultContent("en.dates.gregorian.week_day_names.abbreviated.1", value: "Sun")
    Application.configuration.setDefaultContent("en.dates.gregorian.week_day_names.abbreviated.2", value: "Mon")
    Application.configuration.setDefaultContent("en.dates.gregorian.week_day_names.abbreviated.3", value: "Tue")
    Application.configuration.setDefaultContent("en.dates.gregorian.week_day_names.abbreviated.4", value: "Wed")
    Application.configuration.setDefaultContent("en.dates.gregorian.week_day_names.abbreviated.5", value: "Thu")
    Application.configuration.setDefaultContent("en.dates.gregorian.week_day_names.abbreviated.6", value: "Fri")
    Application.configuration.setDefaultContent("en.dates.gregorian.week_day_names.abbreviated.7", value: "Sat")
  }
  
  /** The application that we are running. */
  public class func sharedApplication() -> Application {
    return NSThread.currentThread().threadDictionary["SHARED_APPLICATION"] as? Application ?? {
      var applicationClass = self
      for bundle in NSBundle.allBundles() {
        for key in ["NSPrincipalClass", "TailorApplicationClass"] {
          if let className = bundle.infoDictionary?[key] as? String,
            let bundleClass = NSClassFromString(className) as? Application.Type {
            applicationClass = bundleClass
          }
        }
      }
      let application = applicationClass.init()
      NSThread.currentThread().threadDictionary["SHARED_APPLICATION"] = application
      return application
    }()
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
    
    for task in self.registeredTasks() {
      if task.commandName == command {
        task.runTask()
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
    Connection.startServer(Application.configuration.ipAddress, port: Application.configuration.port, handler: { RouteSet.shared().handleRequest($0, callback: $1) })
  }
  
  /** Starts a version of this application as the shared application. */
  public class func start() {
    self.sharedApplication().start()
  }
  
  /**
    This method opens a database connection.
    
    This will pull the `database` section of the application's configuration,
    and look for a field called `class`. If this field exists and has the name
    of a class that conforms to the `DatabaseDriver` protocol, then this will
    return an instance of the class, initialized with the rest of the database
    configuration.
  
    If this cannot find a database driver from the configuration, it will raise
    a fatal error.

    - returns:   The connection
    */
  public func openDatabaseConnection() -> DatabaseDriver {
    guard let connection = Application.configuration.databaseDriver?() else {
      fatalError("Cannot open a database connection because there is no database configuration")
    }
    
    return connection
  }
  
  //MARK: - Loading
  
  /**
    This method extracts the command-line arguments to the current executable
    as a list of strings.

    - returns:
      The arguments.
    */
  public class func commandLineArguments() -> [String] {
    if Process.argc < 2 {
      return []
    }
    
    var arguments = [String]()
    for indexOfArgument in 1..<Process.argc {
      if let argument = String.fromCString(Process.unsafeArgv[Int(indexOfArgument)]) {
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
    
    - returns:   The command and the arguments.
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
    This method prompts for a command from the standard input.

    It will print out the available commands and read a line of input from the
    prompt.

    - returns:   The input from the user.
    */
  public func promptForCommand() -> String {
    print("Please provide a task by name, or from the following list")
    
    let tasks = self.registeredTasks().sort {
      task1, task2 in
      task1.commandName.compare(task2.commandName) == NSComparisonResult.OrderedAscending
    }
    
    for (index,task) in tasks.enumerate() {
      print("\(index + 1). \(task.commandName)\n", appendNewline: false)
    }
    let keyboard = NSFileHandle.fileHandleWithStandardInput()
    let inputData = keyboard.availableData
    let commandLine = NSString(data: inputData, encoding:NSUTF8StringEncoding)?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) ?? ""
    
    let int = Int((commandLine as NSString).intValue)
    if int > 0 && int <= tasks.count {
      return tasks[int - 1].commandName
    }
    else {
      return commandLine
    }
  }
  
  /**
    This method gets the command and flags from the command-line arguments.
    
    If the command doesn't match a task, this will prompt the user to put in
    a task on the command line, either by name or by number. It will keep
    prompting until it gets a valid task.
    */
  private func extractArguments() {
    var arguments = self.dynamicType.commandLineArguments()
    (self.command, self.flags) = self.dynamicType.parseArguments(arguments)
    
    let tasks = self.registeredTasks()
    while (tasks.filter { $0.commandName == self.command }).isEmpty {
      let commandLine = self.promptForCommand()
      var inQuotes = false
      arguments = split(commandLine.characters) {
        (character: Character) -> Bool in
        if character == "\"" {
          inQuotes = !inQuotes
        }
        return character == " " && !inQuotes
        }.map { String($0).stringByReplacingOccurrencesOfString("\"", withString: "") }
      (self.command, self.flags) = self.dynamicType.parseArguments(arguments)
    }

  }
  
  /**
    This method loads the default date formatters.
    */
  private func loadDateFormatters() {
    self._dateFormatters["short"] = NSDateFormatter()
    self._dateFormatters["long"] = NSDateFormatter()
    self._dateFormatters["shortDate"] = NSDateFormatter()
    self._dateFormatters["longDate"] = NSDateFormatter()
    self._dateFormatters["db"] = NSDateFormatter()
    
    self._dateFormatters["short"]?.dateFormat = "hh:mm Z"
    self._dateFormatters["long"]?.dateFormat = "dd MMMM, yyyy, hh:mm z"
    
    self._dateFormatters["shortDate"]?.dateFormat = "dd MMMM"
    self._dateFormatters["longDate"]?.dateFormat = "dd MMMM, yyyy"
    
    self._dateFormatters["db"]?.dateFormat = "yyyy-MM-dd HH:mm:ss"
  }
  
  /**
    This method loads all the subtypes of the provided type into the
    application's registered subtype list.
    
    The Application initializer uses this to identify all the tasks and
    alterations, but subclasses can invoke it with other types that they want
    to dynamically crawl.
    
    The registered subtype list will include the types passed in.
    
    - parameter types:   The types to get subtypes of.
    */
  private func registerSubtypes(parentType: Any.Type, matcher: (AnyClass->Bool)) {
    let classCount = objc_getClassList(nil, 0)
    var allClasses = UnsafeMutablePointer<AnyClass?>(calloc(sizeof(AnyClass), Int(classCount)))
    
    objc_getClassList(AutoreleasingUnsafeMutablePointer<AnyClass?>(allClasses), classCount)
    
    for _ in 0..<classCount {
      guard let type : AnyClass = allClasses.memory else { continue }
      
      allClasses = advance(allClasses, 1)
      
      if matcher(type) {
        let key = typeName(parentType)
        var subtypes = self.registeredSubtypes[key] ?? []
        subtypes.append(type)
        self.registeredSubtypes[key] = subtypes
      }
    }
  }
  
  /**
    This method loads all the subclasses of the provided classes into the
    application's registered subclass list.

    The Application initializer uses this to identify all the tasks and
    annotations, but subclasses can invoke it with other classes that they want
    to dynamically crawl.

    The registered subclass list will include the types passed in.

    - parameter types:   The types to get subclasses of.
    */
  public func registerSubclasses(types: AnyClass...) {
    for type in types {
      self.registerSubtypes(type) {
        return class_getClassMethod($0, Selector("isSubclassOfClass:")) != nil && $0.isSubclassOfClass(type)
      }
    }
  }
  
  /**
    This method fetches types that conform to the AlterationScript protocol.
    - returns:  The types.
    */
  public func registeredAlterations() -> [AlterationScript.Type] {
    let description = typeName(AlterationScript.self)
    let classes = self.registeredSubtypes[description] ?? []
    return removeNils(classes.map { $0 as? AlterationScript.Type })
  }
  
  /**
    This method fetches types that conform to the TaskType protocol.
    - returns: The types.
    */
  public func registeredTasks() -> [TaskType.Type] {
    let description = typeName(TaskType.self)
    let classes = self.registeredSubtypes[description] ?? []
    return removeNils(classes.map { $0 as? TaskType.Type })
  }
  
  /**
    This method fetches subclasses of a type.
    
    The type must have previously been passed in to registerSubtypes to load
    the list.
    
    - parameter type:   The type to get subclasses of.
    - returns:          The subclasses of the type.
    */
  @available(*, deprecated) public func registeredSubclassList<ParentType>(type: ParentType.Type) -> [ParentType.Type] {
    return self.registeredSubtypeList(type)
  }
  
  /**
    This method fetches subtypes of a type.
    
    The type must have previously been passed in to registerSubtypes to load
    the list.
    
    - parameter type:   The type to get subclasses of.
    - returns:          The subclasses of the type.
  */
  public func registeredSubtypeList<ParentType>(type: ParentType.Type) -> [ParentType.Type] {
    let description = typeName(ParentType.self)
    let classes = self.registeredSubtypes[description] ?? []
    return removeNils(classes.map { $0 as? ParentType.Type })
  }
  
  //MARK: - Configuration
  
  /**
    The path to the root of the application.
  
    This defaults to the resource path from the main bundle.
  
    For application's that are loaded in test cases, this will use the resource
    path from the first XCTest bundle in the active bundle list.
    */
  public func rootPath() -> String {
    if testing {
      for bundle in NSBundle.allBundles() {
        if bundle.bundlePath.hasSuffix(".xctest") {
          return bundle.resourcePath ?? "."
        }
      }
      return "."
    }
    else {
      return NSBundle.mainBundle().resourcePath ?? "."
    }
  }
  
  /**
    This method loads configuration from a file into the application's settings.
  
    The settings will be put into the configuration with a prefix taken from the
    filename of the path.
  
    This has been deprecated in favor of the static configuration variable.
  
    - parameter path:     The path to the file, relative to the application's
                          root path.
    */
  @available(*, deprecated, message="Use the static configuration variable instead") public func loadConfigFromFile(path: String) {
    let name = path.lastPathComponent.stringByDeletingPathExtension
    let fullPath = self.rootPath() + "/" + path
    self.configuration.child(name).addDictionary(ConfigurationSetting(contentsOfFile: fullPath).toDictionary())
  }
  
  /**
    This method constructs a localization based on the configuration settings.
  
    The localization class name will be taken from the `localization.class`
    setting. It will default to `PropertyListLocalization`.
  
    This has been deprecated in favor of the static configuration variable.
  
    - parameter locale:     The locale for the localization
    - returns:              The localization
    */
   public func localization(locale: String) -> LocalizationSource {
    return Application.configuration.localization(locale)
  }
}

/** The arguments for the application that we are running. */
public var APPLICATION_ARGUMENTS : (String, [String:String])? = nil
