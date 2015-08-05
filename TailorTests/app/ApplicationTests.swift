import Foundation
import XCTest
@testable import Tailor
import TailorTesting
import TailorSqlite

class ApplicationTests : TailorTestCase {
  
  class TestApplicationOne: Application {
    
  }
  
  class TestApplicationTwo: Application {
    
  }
  //MARK: Initialization
  
  var application: Application!
  override func setUp() {
    super.setUp()
    application = Application.sharedApplication()
    APPLICATION_ARGUMENTS = ("tailor.exit", [:])
  }
  
  override func tearDown() {
    NSThread.currentThread().threadDictionary.removeObjectForKey("SHARED_APPLICATION")
    super.tearDown()
  }
  
  @available(*, deprecated) func testInitializationSetsStaticContentFromLocalizationFile() {
    self.assert(Application.configuration.staticContent["en.key1"], equals: "value1")
    self.assert(Application.configuration.staticContent["en.key2.key3"], equals: "value3")
  }
  
  @available(*, deprecated) func testInitializationSetsLocalizationClassFromLocalizationFile() {
    self.assert(Application.configuration.localization("en") is DatabaseLocalization)
  }
  
  @available(*, deprecated) func testInitializationSetsDatabaseDriverClassFromDatabaseFile() {
    if let driver = Application.configuration.databaseDriver?() {
      assert(driver is SqliteConnection)
    }
    else {
      assert(false, message: "Did not have a database driver")
    }
  }
  
  @available(*, deprecated) func testInitializationSetsSessionKeyFromSessionFile() {
    self.assert(Application.configuration.sessionEncryptionKey, equals: "0FC7ECA7AADAD635DCC13A494F9A2EA8D8DAE366382CDB3620190F6F20817124")
  }
  
  @available(*, deprecated) func testInitializationSetsDateFormatters() {
    self.assert(application.dateFormatters["short"]?.dateFormat, equals: "hh:mm Z", message: "sets the short time format properly")
    self.assert(application.dateFormatters["long"]?.dateFormat, equals: "dd MMMM, yyyy, hh:mm z", message: "sets a long time format properly")
    self.assert(application.dateFormatters["shortDate"]?.dateFormat, equals: "dd MMMM", message: "sets a short date format properly")
    self.assert(application.dateFormatters["longDate"]?.dateFormat, equals: "dd MMMM, yyyy", message: "sets a long date format properly")
    self.assert(application.dateFormatters["db"]?.dateFormat, equals: "yyyy-MM-dd HH:mm:ss", message: "sets a db date format properly")
  }
  
  func testInitializationWithSharedArgumentsSetsArguments() {
    APPLICATION_ARGUMENTS = ("tailor.exit", ["a": "25"])
    let application = Application()
    self.assert(application.command, equals: "tailor.exit")
    self.assert(application.flags, equals: ["a": "25"])
  }
  
  func testInitializationWithTestBundleLocationRunsTests() {
    NSProcessInfo.stubMethod("environment", result: ["TestBundleLocation": "/test/path"]) {
      let application = Application()
      self.assert(application.command, equals: "run_tests")
      self.assert(application.flags, equals: [:])
    }
  }
  
  func testInitializationWithoutSharedArgumentsReadsFromPrompt() {
    APPLICATION_ARGUMENTS = nil
    class TestApplication: Application {
      var commands = ["tailor.exit a=5"]
      override func promptForCommand() -> String {
        return commands.removeLast()
      }
    }
    
    let application = TestApplication()
    self.assert(application.command, equals: "tailor.exit", message: "sets the command from the prompt")
    self.assert(application.flags, equals: ["a": "5"], message: "sets the flags from the prompt")
  }
  
  func testDefaultConfigurationHasDefaultIpAddress() {
    let address = Application.Configuration().ipAddress
    assert(address.0, equals: 0)
    assert(address.1, equals: 0)
    assert(address.2, equals: 0)
    assert(address.3, equals: 0)
  }
  
  func testDefaultConfigurationHasDefaultPort() {
    assert(Application.Configuration().port, equals: 8080)
  }
  
  func testDefaultConfigurationHasPropertyListLocalization() {
    assert(Application.Configuration().localization("en") is PropertyListLocalization)
  }
  
  func testDefaultConfigurationHasNoStaticContent() {
    assert(Application.Configuration().staticContent, equals: [:])
  }
  
  func testDefaultConfigurationHasNoDatabaseDriver() {
    assert(isNil: Application.Configuration().databaseDriver)
  }
  
  func testFlattenDictionaryCombinesStringKeys() {
    let result = Application.Configuration.flattenDictionary([
      "key1": "value1",
      "key2": [
        "key3": "value3",
        "key4": "value4"
      ]
    ])
    assert(result, equals: [
      "key1": "value1",
      "key2.key3": "value3",
      "key2.key4": "value4"
    ])
  }
  
  func testFlattenDictionaryIgnoresArray() {
    let result = Application.Configuration.flattenDictionary([
      "key1": "value1",
      "key2": ["value2", "value4"]
      ])
    assert(result, equals: [
      "key1": "value1"
      ])
    
  }
  
  func testFlattenDictionaryIgnoresNonStringKeys() {
    let result = Application.Configuration.flattenDictionary([
      "key1": "value1",
      2: "value2"
      ])
    assert(result, equals: [
      "key1": "value1"
      ])
  }
  
  func testSetDefaultContentSetsValueInContent() {
    let configuration = Application.Configuration()
    configuration.setDefaultContent("en.key1", value: "value1")
    assert(configuration.staticContent["en.key1"], equals: "value1")
  }
  
  func testSetDefaultContentKeepsExistingValue() {
    let configuration = Application.Configuration()
    configuration.staticContent["en.key1"] = "value1"
    configuration.setDefaultContent("en.key1", value: "value2")
    assert(configuration.staticContent["en.key1"], equals: "value1")
  }
  
  func testConfigurationFromFileGetsConfiguration() {
    let content = Application.Configuration.configurationFromFile("goodPlist")
    assert(content, equals: [
      "en.key1": "value1",
      "en.key2.key3": "value3"
    ])
  }
  
  func testConfigurationFromFileWithMissingFileGetsEmptyDictionary() {
    let content = Application.Configuration.configurationFromFile("badPath")
    assert(content.isEmpty)
  }
  
  func testConfigurationFromFileWithNonPlistFileGetsEmptyDictionary() {
    let content = Application.Configuration.configurationFromFile("invalidPlist")
    assert(content.isEmpty)
  }
  
  func testConfigurationFromFileWithNonDictionaryFileGetsEmptyDictionary() {
    let content = Application.Configuration.configurationFromFile("arrayPlist")
    assert(content.isEmpty)
  }
  
  func testConfigurationFromFileWithoutResourcePathGetsEmptyDictionary() {
    let path: NSString? = nil
    NSBundle.stubMethod("resourcePath", result: path) {
      let content = Application.Configuration.configurationFromFile("goodPlist")
      assert(content.isEmpty)
    }
  }
  
  @available(*, deprecated) func testIpAddressGetsValueFromConfigurationSettings() {
    application = Application()
    Application.configuration.ipAddress = (127,0,0,1)
    assert(application.ipAddress.0, equals: 127)
    assert(application.ipAddress.1, equals: 0)
    assert(application.ipAddress.2, equals: 0)
    assert(application.ipAddress.3, equals: 1)
  }
  
  @available(*, deprecated) func testSettingIpAddressChangesConfigurationSetting() {
    application = Application()
    Application.configuration.ipAddress = (0,0,0,0)
    application.ipAddress = (127,0,0,1)
    assert(application.ipAddress.0, equals: 127)
    assert(application.ipAddress.1, equals: 0)
    assert(application.ipAddress.2, equals: 0)
    assert(application.ipAddress.3, equals: 1)
    assert(Application.configuration.ipAddress.0, equals: 127)
    assert(Application.configuration.ipAddress.1, equals: 0)
    assert(Application.configuration.ipAddress.2, equals: 0)
    assert(Application.configuration.ipAddress.3, equals: 1)
  }
  
  @available(*, deprecated) func testPortGetsValueFromConfigurationSettings() {
    application = Application()
    Application.configuration.port = 3000
    assert(application.port, equals: 3000)
  }
  
  @available(*, deprecated) func testSettingPortChangesConfigurationSetting() {
    application = Application()
    application.port = 3000
    assert(Application.configuration.port, equals: 3000)
    assert(application.port, equals: 3000)
  }
  
  @available(*, deprecated) func testGettingRouteSetGetsSharedRouteSet() {
    RouteSet.load {
      (inout routes: RouteSet)->Void in
      routes.addRoute("test1", method: "GET", handler: {
        request,callback in
      })
    }
    assert(application.routeSet.routes.count, equals: 1)
  }
  
  @available(*, deprecated) func testSettingRouteSetSetsSharedRouteSet() {
    let routes = RouteSet()
    
    routes.addRoute("test1", method: "GET", handler: {
      request,callback in
    })
    
    application.routeSet = routes
    assert(RouteSet.shared().routes.count, equals: 1)
  }
  
  @available(*, deprecated) func testCanSetDateFormattersOnApplication() {
    let application = Application()
    let formatter = NSDateFormatter()
    application.dateFormatters["test"] = formatter
    assert(application.dateFormatters["test"], equals: formatter)
  }
  
  func testSharedApplicationReusesApplication() {
    let application1 = Application.sharedApplication()
    let application2 = Application.sharedApplication()
    self.assert(application1 === application2)
  }
  
  func testSharedApplicationWithPrincipalClassUsesThatClass() {
    NSBundle.stubMethod("infoDictionary", result: ["NSPrincipalClass": NSStringFromClass(TestApplicationOne.self)]) {
      NSThread.currentThread().threadDictionary.removeObjectForKey("SHARED_APPLICATION")
     assert(Application.sharedApplication() is TestApplicationOne)
    }
  }
  
  func testSharedApplicationWithTailorApplicationClassUsesThatClass() {
    NSBundle.stubMethod("infoDictionary", result: ["TailorApplicationClass": NSStringFromClass(TestApplicationTwo.self)]) {
      NSThread.currentThread().threadDictionary.removeObjectForKey("SHARED_APPLICATION")
      assert(Application.sharedApplication() is TestApplicationTwo)
    }

  }
  
  func testSharedApplicationWithNoClassInBundleCreatesApplication() {
    NSBundle.stubMethod("infoDictionary", result: [:]) {
      NSThread.currentThread().threadDictionary.removeObjectForKey("SHARED_APPLICATION")
      assert(!(Application.sharedApplication() is TestApplicationOne))
      assert(!(Application.sharedApplication() is TestApplicationTwo))
    }
  }
  
  func testStartMethodRunsTaskFromCommand() {
    class TestTask: TaskType {
      static let commandName: String = "application_test_task_1"
      static var hasRun = false
      static func runTask() {
        hasRun = true
      }
    }
    APPLICATION_ARGUMENTS = ("application_test_task_1", [:])
    let application = Application()
    application.start()
    assert(TestTask.hasRun)
  }
  
  func testClassStartMethodRunsTaskOnSharedApplication() {
    NSThread.currentThread().threadDictionary.removeObjectForKey("SHARED_APPLICATION")
    class TestTask: TaskType {
      static let commandName: String = "application_test_task_2"
      static var hasRun = false
      static func runTask() {
        hasRun = true
      }
    }
    APPLICATION_ARGUMENTS = ("application_test_task_2", [:])
    Application.start()
    assert(TestTask.hasRun)
  }
  
  @available(*, deprecated) func testOpenDatabaseConnectionGetsConnectionFromConfig() {
    let application = Application()
    final class ApplicationTestConnection: DatabaseConnection {
      let name: String
      
      required init(config: [String:String]) {
        self.name = config["name"] ?? "Anonymous"
        super.init(config: config)
      }
    }
    
    Application.configuration.databaseDriver = { return ApplicationTestConnection(config: ["name": "My Connection"]) }
    
    let connection = application.openDatabaseConnection()
    
    if let castConnection = connection as? ApplicationTestConnection {
      assert(castConnection.name, equals: "My Connection")
    }
    else {
      assert(false, message: "Did not have correct class for connection")
    }
  }
  
  //MARK: Loading
  
  func testParseArgumentsRepeatedlyPromptsUntilValidTaskAppears() {
    class TestApplication: Application {
      var commands = ["tailor.exit a=7", "tailor.wait"]
      override func promptForCommand() -> String {
        return commands.removeLast()
      }
    }
    
    APPLICATION_ARGUMENTS = nil
    let application = TestApplication()
    self.assert(application.command, equals: "tailor.exit", message: "sets the command from the prompt")
    self.assert(application.flags, equals: ["a": "7"], message: "sets the flags from the prompt")
  }
  
  func testParseArgumentsWithSpacesInQuotesKeepsQuotedSectionTogether() {
    class TestApplication: Application {
      var commands = ["tailor.exit a=\"b + c\" d=23"]
      override func promptForCommand() -> String {
        return commands.removeLast()
      }
    }
    
    APPLICATION_ARGUMENTS = nil
    let application = TestApplication()
    self.assert(application.flags, equals: ["a": "b + c", "d": "23"], message: "keeps the quoted flags together")
  }
  
  func testParseArgumentsWithoutAssignmentSetsFlagToOne() {
    class TestApplication: Application {
      var commands = ["tailor.exit a=b c"]
      override func promptForCommand() -> String {
        return commands.removeLast()
      }
    }
    
    APPLICATION_ARGUMENTS = nil
    let application = TestApplication()
    self.assert(application.flags, equals: ["a": "b", "c": "1"])
  }
  
  func testPromptForCommandGetsCommandByName() {
    let standardInput = NSPipe()
    NSFileHandle.stubClassMethod("fileHandleWithStandardInput", result: standardInput.fileHandleForReading) {
      let command = "custom_task a=b c"
      standardInput.fileHandleForWriting.writeData(NSData(bytes: command.utf8))
      standardInput.fileHandleForWriting.closeFile()
      assert(application.promptForCommand(), equals: command)
    }
  }
  
  func testPromptForCommandGetsCommandByNumber() {
    let standardInput = NSPipe()
    NSFileHandle.stubClassMethod("fileHandleWithStandardInput", result: standardInput.fileHandleForReading) {
      let command = "3"
      standardInput.fileHandleForWriting.writeData(NSData(bytes: command.utf8))
      standardInput.fileHandleForWriting.closeFile()
      assert(application.promptForCommand(), equals: "command_name_test_task")
    }
  }
  
  func testPromptForCommandWithInvalidDataReturnsEmptyString() {
    let standardInput = NSPipe()
    NSFileHandle.stubClassMethod("fileHandleWithStandardInput", result: standardInput.fileHandleForReading) {
      standardInput.fileHandleForWriting.writeData(NSData(bytes: [0xD8, 0x00]))
      standardInput.fileHandleForWriting.closeFile()
      assert(application.promptForCommand(), equals: "")
    }
  }
  
  //MARK: Getting Subclasses
  
  func testCanRegisterCustomSubclasses() {
    class TestClassWithSubclasses {
      class func id() -> Int { return 1 }
    }
    
    class TestSubclass1 : TestClassWithSubclasses {
      override class func id() -> Int { return 2 }
    }
    
    class TestSubclass2 : TestClassWithSubclasses {
      override class func id() -> Int { return 3 }
    }
    
    application.registerSubclasses(TestClassWithSubclasses)
    let types = application.registeredSubtypeList(TestClassWithSubclasses)
    let ids = types.map { $0.id() }
    self.assert(ids.sort(), equals: [1, 2, 3], message: "registers all subclasses of the type given, including the type itself")
  }
  
  func testRegisteredAlterationsGetsAlterations() {
    let alterations = application.registeredAlterations().map { $0.name }
    assert(alterations.contains("TailorTests.AlterationTests.FirstAlteration"))
  }
  
  func testRegisteredAlterationsWithNoAlterationsRegisteredGetsEmptyList() {
    application.clearRegisteredSubtypes()
    assert(application.registeredAlterations().isEmpty)
  }
  
  func testRegisteredTasksGetsTasks() {
    let tasks = application.registeredTasks().map { $0.commandName }
    assert(tasks.contains("run_tests"))
  }
  
  func testRegisteredTasksWithNoTasksRegisteredGetsEmptyList() {
    application.clearRegisteredSubtypes()
    let tasks = application.registeredTasks().map { $0.commandName }
    assert(tasks.isEmpty)
  }
  
  func testRegisteredSubtypeListGetsSubtypes() {
    class TestClassOne {
      class func name() -> String {
        return NSStringFromClass(self)
      }
    }
    class TestClassTwo: TestClassOne {
      
    }
    application.registerSubclasses(TestClassOne.self)
    let names = application.registeredSubtypeList(TestClassOne.self).map { $0.name() }.sort()
    assert(names, equals: [TestClassOne.name(), TestClassTwo.name()])
  }
  
  func testRegisteredSubtypeListWithNoTypesRegisteredGetsEmptyList() {
    class TestClassOne {
      class func name() -> String {
        return NSStringFromClass(self)
      }
    }
    class TestClassTwo: TestClassOne {
      
    }
    application.clearRegisteredSubtypes()
    let names = application.registeredSubtypeList(TestClassOne.self).map { $0.name() }.sort()
    assert(names.isEmpty)
  }
  
  //MARK: - Configuration
  
  @available(*, deprecated) func testLoadConfigPutsContentsInConfiguration() {
    application.loadConfigFromFile("TestConfig.plist")
    let value = application.configuration["TestConfig.test_key"]
    self.assert(value, equals: "test_value", message: "has the setting from the file")
  }
  
  func testLocalizationBuildsLocalizationFromFunctionInConfiguration() {
    Application.configuration.localization = { DatabaseLocalization(locale: $0) }
    let localization = application.localization("en")
    self.assert(localization.locale, equals: "en", message: "sets the localization")
    assert(isNotNil: localization as? DatabaseLocalization, message: "uses the class from the configuration")
    Application.configuration = .init()
  }
  
  func testLocalizationWithNoSettingIsPropertyListLocalization() {
    Application.configuration = Application.Configuration()
    let localization = application.localization("en")
    assert(localization is PropertyListLocalization)
  }
  
  func testProjectPathReadsTailorProjectFolderSetting() {
    assert(Application.projectPath, equals: PROJECT_DIR)
  }
  
  func testProjectPathWithNoSettingIsCurrentPath() {
    NSBundle.stubMethod("infoDictionary", result: NSDictionary()) {
      assert(Application.projectPath, equals: ".")
    }
  }
  
  func testProjectPathWithNonExistantPathIsCurrentPath() {
    NSBundle.stubMethod("infoDictionary", result: ["TailorProjectPath": "/badpath"]) {
      assert(Application.projectPath, equals: ".")
    }
  }
  
  func testProjectNameReadsBundleName() {
    assert(Application.projectName, equals: "TailorTests")
  }
  
  func testProjectNameWithNoBundleNameIsApplication() {
    NSBundle.stubMethod("infoDictionary", result: NSDictionary()) {
      assert(Application.projectName, equals: "Application")
    }
  }
}