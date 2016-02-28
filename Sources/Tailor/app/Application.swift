import Foundation
#if os(Linux)
  import Glibc
#endif

/**
  This class represents a web application.
  */
public final class Application {
  /**
    This structure provides the configuration settings for an application.
    */
  public final class Configuration {
    /** The port that the application listens on. */
    public var port = 8080
    
    /** The IP address that the application listens on. */
    public var ipAddress = (0,0,0,0)
    
    /** A function for creating the localization for a given locale. */
    public var localization: (String->LocalizationSource) = { PropertyListLocalization(locale: $0) }
    
    /** Whether we should log all the queries for debugging purposes. */
    public var logQueries: Bool = true
    
    /** The path to the application's resources. */
    public var resourcePath = "./Resources"
    
    /** The name of the application's resources. */
    public var projectName = "Application"
    
    /**
      A function for fetching the localization for a given request.
    
      The default implementation gets the locale from the request headers, using
      the `localizationFromContentPreferences` method. It will also use the
      `localization` field to get the localization source using that locale. If
      you only need to customize the type of localization source, for instance
      to use a database instead of a property list, you should change the
      `localization` field. If you need to change what part of the request we
      look at for the locale, for instance to get the locale from a part of the
      request path, you should change this field.
      */
    public var localizationForRequest: (Request->LocalizationSource) = { return Application.configuration.localizationFromContentPreferences($0) }
    
    /**
      This method gets the localization for a given request from the content
      preferences in the request.
    
      This will read the Accept-Language header from the request, and compare it
      against the available locales from the localization source specified in
      the `localization` field. It will then use that `localization` field to
      build a new localization with the best match for the locale. If there is
      no match with the available locales and the acceptable languages, this
      will default to English.
    
      - parameter request:    The request that we are building a localization
                              for.
      - returns:              The localization for the request.
      */
    public func localizationFromContentPreferences(request: Request) -> LocalizationSource {
      let localization = self.localization("en")
      let locales = localization.dynamicType.availableLocales
      let preferredLocale = Request.ContentPreference(fromHeader: request.headers["Accept-Language"] ?? "").bestMatch(locales) ?? "en"
      return self.localization(preferredLocale)
    }
    
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
      The maximum period of inactivity before a session should expire.
      */
    public var sessionLifetime = 1.hour
    
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
      The type that models users of the application.

      This is used to fetch users from the session in controllers.
      */
    public var userType: UserType.Type? = nil
    
    /**
      The maximum number of times that a user can try to log in with the wrong
      password before their account is locked.

      This is only used if your user type conforms to `LockableUserType`.
      */
    public var failedLoginLimit = 5
    
    /**
      This initializer creates a configuration setting object with the default
      values.
      */
    public init() {
      //FIXME
      //self.configure()
    }
    
    /**
      This method provides the configuration.

      This implementation is empty, but your apps can override it in an
      extension to provide your custom configuration.

      This can also be a convenient place to load your routes.
    
      This will be run once during the initialization of the configuration,
      which will be done while the application is starting.
      */
    public dynamic func configure() {
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
        let keyString: String
        if let s = key as? NSString { keyString = s.bridge() }
        else { continue }

        if let s = value as? NSString {
          result[keyString] = s.bridge()
        }
        else if let d = value as? NSDictionary {
          for (innerKey, innerValue) in flattenDictionary(d) {
            result[keyString + "." + innerKey] = innerValue
          }
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
    public func setDefaultContent(key: String, value: String) {
      self.staticContent[key] = self.staticContent[key] ?? value
    }
    
    /**
      This method gets the path to a config plist.

      - parameter name:   The name of the file, not including the extension.
      - returns:          The path to the file, or nil if the file could not be
                          found.
      */
    internal static func pathForConfigFile(name: String) -> String? {
      return Application.configuration.resourcePath + "/config/\(name).plist"
    }
    
    /**
      This method extracts the configuration from a plist file.
      
      This will look through the bundles for the application for one that has a
      "\(name).plist" file, extract a property list dictionary from it, and then
      flatten it into a dictionary mapping strings to strings.

      If any part of this fails, this will return an empty dictionary.
      
      - parameter name:   The name of the plist file, not including the
                          extension.
      - returns:          The flattened config dictionary.
      */
    public static func configurationFromFile(name: String) -> [String:String] {
      if let path = pathForConfigFile(name),
        let data = NSData(contentsOfFile: path) {
        do {
         let plist = try NSPropertyListSerialization.propertyListWithData(data, options: [.Immutable], format: nil)
          if let dictionary = plist as? [String: Any] {
            return flattenDictionary(dictionary.bridge())
          }
        }
        catch {
          
        }
      }
      return [:]
    }
    
    /**
      This method loads the default content provided by the framework.
      */
    public func loadDefaultContent() {
      setDefaultContent("en.model.errors.blank", value: "cannot be blank")
      setDefaultContent("en.model.errors.too_high", value: "cannot be more than \\(max)")
      setDefaultContent("en.model.errors.too_low", value: "cannot be less than \\(min)")
      setDefaultContent("en.model.errors.non_numeric", value: "must be a number")
      setDefaultContent("en.model.errors.taken", value: "is already taken")
      setDefaultContent("en.dates.gregorian.month_names.full.1", value: "January")
      setDefaultContent("en.dates.gregorian.month_names.full.2", value: "February")
      setDefaultContent("en.dates.gregorian.month_names.full.3", value: "March")
      setDefaultContent("en.dates.gregorian.month_names.full.4", value: "April")
      setDefaultContent("en.dates.gregorian.month_names.full.5", value: "May")
      setDefaultContent("en.dates.gregorian.month_names.full.6", value: "June")
      setDefaultContent("en.dates.gregorian.month_names.full.7", value: "July")
      setDefaultContent("en.dates.gregorian.month_names.full.8", value: "August")
      setDefaultContent("en.dates.gregorian.month_names.full.9", value: "September")
      setDefaultContent("en.dates.gregorian.month_names.full.10", value: "October")
      setDefaultContent("en.dates.gregorian.month_names.full.11", value: "November")
      setDefaultContent("en.dates.gregorian.month_names.full.12", value: "December")
      setDefaultContent("en.dates.gregorian.month_names.abbreviated.1", value: "Jan")
      setDefaultContent("en.dates.gregorian.month_names.abbreviated.2", value: "Feb")
      setDefaultContent("en.dates.gregorian.month_names.abbreviated.3", value: "Mar")
      setDefaultContent("en.dates.gregorian.month_names.abbreviated.4", value: "Apr")
      setDefaultContent("en.dates.gregorian.month_names.abbreviated.5", value: "May")
      setDefaultContent("en.dates.gregorian.month_names.abbreviated.6", value: "Jun")
      setDefaultContent("en.dates.gregorian.month_names.abbreviated.7", value: "Jul")
      setDefaultContent("en.dates.gregorian.month_names.abbreviated.8", value: "Aug")
      setDefaultContent("en.dates.gregorian.month_names.abbreviated.9", value: "Sep")
      setDefaultContent("en.dates.gregorian.month_names.abbreviated.10", value: "Oct")
      setDefaultContent("en.dates.gregorian.month_names.abbreviated.11", value: "Nov")
      setDefaultContent("en.dates.gregorian.month_names.abbreviated.12", value: "Dec")
      setDefaultContent("en.dates.gregorian.week_day_names.full.1", value: "Sunday")
      setDefaultContent("en.dates.gregorian.week_day_names.full.2", value: "Monday")
      setDefaultContent("en.dates.gregorian.week_day_names.full.3", value: "Tuesday")
      setDefaultContent("en.dates.gregorian.week_day_names.full.4", value: "Wednesday")
      setDefaultContent("en.dates.gregorian.week_day_names.full.5", value: "Thursday")
      setDefaultContent("en.dates.gregorian.week_day_names.full.6", value: "Friday")
      setDefaultContent("en.dates.gregorian.week_day_names.full.7", value: "Saturday")
      setDefaultContent("en.dates.gregorian.week_day_names.abbreviated.1", value: "Sun")
      setDefaultContent("en.dates.gregorian.week_day_names.abbreviated.2", value: "Mon")
      setDefaultContent("en.dates.gregorian.week_day_names.abbreviated.3", value: "Tue")
      setDefaultContent("en.dates.gregorian.week_day_names.abbreviated.4", value: "Wed")
      setDefaultContent("en.dates.gregorian.week_day_names.abbreviated.5", value: "Thu")
      setDefaultContent("en.dates.gregorian.week_day_names.abbreviated.6", value: "Fri")
      setDefaultContent("en.dates.gregorian.week_day_names.abbreviated.7", value: "Sat")
    }
  }
  
  /** The subclasses that we've registered for certain critical base classes. */
  @available(*, deprecated)
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
  
    We don't guarantee thread safety for setting this, so it is best to only
    change this variables on the main thread, before starting the application.
    */
  public static var configuration = Configuration()
  
  /**
    This method initializes the application.
  
    This implementation parses command-line arguments, loads date formatters,
    and registers all the subclasses of Task and AlterationScript for use in
    running scripts.
    */
  public required init() {
    TypeInventory.shared.registerSubtypes(TaskType.self, subtypes: [ServerTask.self, AlterationsTask.self, ExitTask.self])
    
    if NSProcessInfo.processInfo().environment["TestBundleLocation"] != nil {
      self.command = "run_tests"
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
    Application.configuration.loadDefaultContent()
  }
  
  /** The application that we are running. */
  public class func sharedApplication() -> Application {
    return NSThread.cacheInDictionary("SHARED_APPLICATION") {
      return Application.init()
    }
  }
  
  //MARK: - Running
  
  /**
    This method starts the application.
  
    It looks for a registered task with the command that was invoked when
    starting the application, and runs that task.
  
    If the provided command doesn't have a matching task, this will crash.
    */
  public func start() {
    NSLog("Starting application: %@, %@", command, String(flags))
    
    for task in TypeInventory.shared.registeredTasks {
      if task.commandName == command {
        task.runTask()
        return
      }
    }
    NSLog("Could not find the specified task")
    exit(1)
  }
  
  /** Starts a version of this application as the shared application. */
  public class func start() {
    self.sharedApplication().start()
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
        let flagParts = arguments[indexOfFlag].bridge().componentsSeparatedByString("=")
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
    
    let tasks = TypeInventory.shared.registeredTasks.sort {
      task1, task2 in
      task1.commandName.compare(task2.commandName) == NSComparisonResult.OrderedAscending
    }
    
    for (index,task) in tasks.enumerate() {
      print("\(index + 1). \(task.commandName)\n", terminator: "")
    }
    //FIXME
    //let keyboard = NSFileHandle.fileHandleWithStandardInput()
    //let inputData = keyboard.availableData
    //let commandLine = NSString(data: inputData, encoding:NSUTF8StringEncoding)?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) ?? ""
    let commandLine = "tailor.exit"
    
    let int = Int(commandLine) ?? 0
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
    
    let tasks = TypeInventory.shared.registeredTasks
    while (tasks.filter { $0.commandName == self.command }).isEmpty {
      let commandLine = self.promptForCommand()
      var inQuotes = false
      arguments = commandLine.characters.split() {
        (character: Character) -> Bool in
        if character == "\"" {
          inQuotes = !inQuotes
        }
        return character == " " && !inQuotes
        }.map { String($0).bridge().stringByReplacingOccurrencesOfString("\"", withString: "") }
      (self.command, self.flags) = self.dynamicType.parseArguments(arguments)
    }
  }
  
  /**
    This method loads all the subtypes of the provided type into the
    application's registered subtype list.
    
    The Application initializer uses this to identify all the tasks and
    alterations, but subclasses can invoke it with other types that they want
    to dynamically crawl.
    
    The registered subtype list will include the types passed in.

    This is deprecated in favor of TypeInventory.
    
    - parameter types:   The types to get subtypes of.
    */
  @available(*, deprecated, message="Use TypeInventory instead")
  private func registerSubtypes(parentType: Any.Type, matcher: (AnyClass->Bool)) {
    #if os(OSX)
    let classCount = objc_getClassList(nil, 0)
    var allClasses = Array<AnyClass?>(count: Int(classCount), repeatedValue: nil)
    objc_getClassList(AutoreleasingUnsafeMutablePointer<AnyClass?>(&allClasses), classCount)
    
    for klass in allClasses {
      guard let type : AnyClass = klass else { continue }
      if matcher(type) {
        let key = String(reflecting: parentType)
        var subtypes = self.registeredSubtypes[key] ?? []
        subtypes.append(type)
        self.registeredSubtypes[key] = subtypes
      }
    }
    #endif
  }
  
  /**
    This method removes all types from our list of registered subtypes.

    This is deprecated in favor of TypeInventory.
    */
  @available(*, deprecated, message="Use TypeInventory instead")
  internal func clearRegisteredSubtypes() {
    self.registeredSubtypes = [:]
  }
  
  /**
    This method loads all the subclasses of the provided classes into the
    application's registered subclass list.

    The Application initializer uses this to identify all the tasks and
    annotations, but subclasses can invoke it with other classes that they want
    to dynamically crawl.

    The registered subclass list will include the types passed in.

    This is deprecated in favor of TypeInventory.

    - parameter types:   The types to get subclasses of.
    */
  @available(*, deprecated, message="Use TypeInventory instead")
  public func registerSubclasses(types: AnyClass...) {
  }
  
  /**
    This method fetches types that conform to the AlterationScript protocol.

    This is deprecated in favor of TypeInventory.
    - returns:  The types.
    */
  @available(*, deprecated, message="Use TypeInventory instead")
  public func registeredAlterations() -> [AlterationScript.Type] {
    let description = String(reflecting: AlterationScript.self)
    let classes = self.registeredSubtypes[description] ?? []
    return classes.flatMap { $0 as? AlterationScript.Type }
  }
  
  /**
    This method fetches types that conform to the TaskType protocol.

    This is deprecated in favor of TypeInventory.
    - returns: The types.
    */
  @available(*, deprecated, message="Use TypeInventory instead")
  public func registeredTasks() -> [TaskType.Type] {
    let description = String(reflecting: TaskType.self)
    let classes = self.registeredSubtypes[description] ?? []
    return classes.flatMap { $0 as? TaskType.Type }
  }
    
  /**
    This method fetches subtypes of a type.
    
    The type must have previously been passed in to registerSubtypes to load
    the list.

    This is deprecated in favor of TypeInventory.
    
    - parameter type:   The type to get subclasses of.
    - returns:          The subclasses of the type.
  */
  @available(*, deprecated, message="Use TypeInventory instead")
  public func registeredSubtypeList<ParentType>(type: ParentType.Type) -> [ParentType.Type] {
    let description = String(reflecting: ParentType.self)
    let classes = self.registeredSubtypes[description] ?? []
    return classes.flatMap { $0 as? ParentType.Type }
  }
  
  //MARK: - Configuration
  
  /**
    The path to the root of the application.
  
    This defaults to the resource path from the main bundle.
  
    For application's that are loaded in test cases, this will use the resource
    path from the first XCTest bundle in the active bundle list.
    
    This has been deprecated in favor of the resourcePath from the configuration.
    */
  @available(*, deprecated, message="You should use the resourcePath in the configuration instead")
  public func rootPath() -> String {
    var mainBundle = NSBundle.mainBundle()
    if mainBundle.bundlePath.hasPrefix("/Applications/Xcode") {
      for bundle in NSBundle.allBundles() {
        if bundle.bundlePath.hasSuffix(".xctest") {
          mainBundle = bundle
          break
        }
      }
    }
    return mainBundle.resourcePath ?? "."
  }
  
  /**
    This method gets a key from the bundle's info dictionary.

    This will search through all bundles, to make up for some weird behavior
    in how the main bundle gets assigned in test targets.
    
    - param key:    The key to search for.
    - returns:      The value for that key, or nil if we could not find a value.
    */
  internal static func bundleInfo(key: String) -> String? {
    for bundle in NSBundle.allBundles() {
      if bundle.bundlePath.hasPrefix("/System") {
        continue
      }
      if let bundleInfo = bundle.infoDictionary {
        if let value = bundleInfo[key] as? String {
          return value
        }
      }
    }
    return nil
  }
  
  /**
    This method gets the path to the folder where your project lives in your
    development environment.

    This looks for the value in the TailorProjectPath key in your bundle's
    info dictionary. You should set this to `$PROJECT_PATH` to use the path that
    Xcode already has in the build settings.
  
    If there is no value for that key in the info dictionary, this will be ".".
    
    This has been deprecated in favor of the resourcePath on the configuration.
    */
  @available(*, deprecated, message="You should use the resourcePath on the configuration instead.")
  public static var projectPath: String {
    if let folder = bundleInfo("TailorProjectPath") {
      if NSFileManager.defaultManager().fileExistsAtPath(folder) {
        return folder
      }
    }
    return "."
  }
  
  /**
    This method gets the name of your project, from the CFBundleName key in the
    bundle's info dictionary.

    If there is no value for that key, this will be "Application".
    
    This is deprecated in favor of the projectName on the configuration.
    */
  @available(*, deprecated, message="Use the projectName on the configuration instead.")
  public static var projectName: String {
    return bundleInfo("CFBundleName") ?? "Application"
  }
}

/** The arguments for the application that we are running. */
public var APPLICATION_ARGUMENTS : (String, [String:String])? = nil
