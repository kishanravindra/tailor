import Foundation
import XCTest
@testable import Tailor
import TailorTesting
import TailorSqlite

class ApplicationTests : XCTestCase, TailorTestable {
  //MARK: Initialization
  
  var application: Application!
  override func setUp() {
    super.setUp()
    setUpTestCase()
    NSThread.currentThread().threadDictionary.removeObjectForKey("SHARED_APPLICATION")
    application = Application.sharedApplication()
    APPLICATION_ARGUMENTS = ("tailor.exit", [:])
  }
  
  override func tearDown() {
    NSThread.currentThread().threadDictionary.removeObjectForKey("SHARED_APPLICATION")
    super.tearDown()
  }
  
  func withStandardInput(let input: [String], block: Void->Void) {
    var indexOfInput = input.startIndex
    let implementationBlock: @convention(block) (AnyObject)->AnyObject? = {
      _ in
      let pipe = NSPipe()
      if indexOfInput < input.endIndex {
        pipe.fileHandleForWriting.writeData(NSData(bytes: input[indexOfInput].utf8))
      }
      indexOfInput = indexOfInput.advancedBy(1)
      return pipe.fileHandleForReading
    }
    let method = class_getClassMethod(NSFileHandle.self, Selector("fileHandleWithStandardInput"))
    let oldImplementation = method_getImplementation(method)
    
    
    let newImplementation = imp_implementationWithBlock(unsafeBitCast(implementationBlock, AnyObject.self))
    method_setImplementation(method, newImplementation)
    block()
    method_setImplementation(method, oldImplementation)
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
    withStandardInput(["tailor.exit a=b"]) {
      let application = Application()
      self.assert(application.command, equals: "tailor.exit")
      self.assert(application.flags, equals: ["a": "b"])
    }
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
  
  func testSharedApplicationReusesApplication() {
    let application1 = Application.sharedApplication()
    let application2 = Application.sharedApplication()
    self.assert(application1 === application2)
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
  
  //MARK: Loading
  
  func testParseArgumentsRepeatedlyPromptsUntilValidTaskAppears() {
    withStandardInput(["tailor.wait", "tailor.exit a=7"]) {
      APPLICATION_ARGUMENTS = nil
      let application = Application()
      self.assert(application.command, equals: "tailor.exit", message: "sets the command from the prompt")
      self.assert(application.flags, equals: ["a": "7"], message: "sets the flags from the prompt")
    }
  }
  
  func testParseArgumentsWithSpacesInQuotesKeepsQuotedSectionTogether() {
    withStandardInput(["tailor.exit a=\"b + c\" d=23"]) {
      APPLICATION_ARGUMENTS = nil
      let application = Application()
      self.assert(application.flags, equals: ["a": "b + c", "d": "23"], message: "keeps the quoted flags together")
    }
  }
  
  func testParseArgumentsWithoutAssignmentSetsFlagToOne() {
    withStandardInput(["tailor.exit a=b c"]) {
      APPLICATION_ARGUMENTS = nil
      let application = Application()
      self.assert(application.flags, equals: ["a": "b", "c": "1"])
    }
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
    assert(alterations.contains("TailorTests.AlterationScriptTests.FirstAlteration"))
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
  
  func testLocalizationWithNoSettingIsPropertyListLocalization() {
    Application.configuration = Application.Configuration()
    let localization = Application.configuration.localization("en")
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