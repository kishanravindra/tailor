@testable import Tailor
import Foundation
import XCTest
import TailorTesting
import TailorSqlite

struct TestApplication : XCTestCase, TailorTestable {
  //MARK: Initialization
  
  var application = Application.sharedApplication()

  var allTests: [(String, () throws -> Void)] {
    return [      
      ("testInitializationWithSharedArgumentsSetsArguments", testInitializationWithSharedArgumentsSetsArguments),
      // ("testInitializationWithoutSharedArgumentsReadsFromPrompt", testInitializationWithoutSharedArgumentsReadsFromPrompt),
      ("testDefaultConfigurationHasDefaultIpAddress", testDefaultConfigurationHasDefaultIpAddress),
      ("testDefaultConfigurationHasDefaultPort", testDefaultConfigurationHasDefaultPort),
      ("testDefaultConfigurationHasPropertyListLocalization", testDefaultConfigurationHasPropertyListLocalization),
      ("testDefaultConfigurationHasNoStaticContent", testDefaultConfigurationHasNoStaticContent),
      ("testDefaultConfigurationHasNoDatabaseDriver", testDefaultConfigurationHasNoDatabaseDriver),
      ("testDefaultConfigurationBuildLocalizationFromRequestHeaders", testDefaultConfigurationBuildLocalizationFromRequestHeaders),
      ("testLocalizationFromContentPreferencesSetsLocaleFromAvailableLocales", testLocalizationFromContentPreferencesSetsLocaleFromAvailableLocales),
      ("testLocalizationFromContentPreferencesSetsLocaleWithNoAvailableLocalesDefaultsToEnglish", testLocalizationFromContentPreferencesSetsLocaleWithNoAvailableLocalesDefaultsToEnglish),
      ("testLocalizationFromContentPreferencesWithNoLanguageHeaderDefaultsToEnglish", testLocalizationFromContentPreferencesWithNoLanguageHeaderDefaultsToEnglish),
      ("testFlattenDictionaryCombinesStringKeys", testFlattenDictionaryCombinesStringKeys),
      ("testFlattenDictionaryIgnoresArray", testFlattenDictionaryIgnoresArray),
      ("testFlattenDictionaryIgnoresNonStringKeys", testFlattenDictionaryIgnoresNonStringKeys),
      ("testSetDefaultContentSetsValueInContent", testSetDefaultContentSetsValueInContent),
      ("testSetDefaultContentKeepsExistingValue", testSetDefaultContentKeepsExistingValue),
      ("testConfigurationFromFileGetsConfiguration", testConfigurationFromFileGetsConfiguration),
      ("testConfigurationFromFileWithMissingFileGetsEmptyDictionary", testConfigurationFromFileWithMissingFileGetsEmptyDictionary),
      ("testConfigurationFromFileWithNonPlistFileGetsEmptyDictionary", testConfigurationFromFileWithNonPlistFileGetsEmptyDictionary),
      ("testConfigurationFromFileWithNonDictionaryFileGetsEmptyDictionary", testConfigurationFromFileWithNonDictionaryFileGetsEmptyDictionary),
      ("testSharedApplicationReusesApplication", testSharedApplicationReusesApplication),
      ("testStartMethodRunsTaskFromCommand", testStartMethodRunsTaskFromCommand),
      // ("testClassStartMethodRunsTaskOnSharedApplication", testClassStartMethodRunsTaskOnSharedApplication),
      // ("testParseArgumentsRepeatedlyPromptsUntilValidTaskAppears", testParseArgumentsRepeatedlyPromptsUntilValidTaskAppears),
      // ("testParseArgumentsWithSpacesInQuotesKeepsQuotedSectionTogether", testParseArgumentsWithSpacesInQuotesKeepsQuotedSectionTogether),
      // ("testParseArgumentsWithoutAssignmentSetsFlagToOne", testParseArgumentsWithoutAssignmentSetsFlagToOne),
      // ("testPromptForCommandGetsCommandByName", testPromptForCommandGetsCommandByName),
      // ("testPromptForCommandGetsCommandByNumber", testPromptForCommandGetsCommandByNumber),
      // ("testPromptForCommandWithInvalidDataReturnsEmptyString", testPromptForCommandWithInvalidDataReturnsEmptyString),
      ("testLocalizationWithNoSettingIsPropertyListLocalization", testLocalizationWithNoSettingIsPropertyListLocalization),
    ]
  }

  init() {
    NSThread.currentThread().threadDictionary.removeValueForKey("SHARED_APPLICATION")
    self.application = Application.sharedApplication()
    APPLICATION_ARGUMENTS = ("tailor.exit", [:])
  }
  
  func tearDown() {
    NSThread.currentThread().threadDictionary.removeValueForKey("SHARED_APPLICATION")
  }
  
  func withStandardInput(input: [String], block: Void->Void) {
    XCTFail("withStandardInput not supported")
    /*
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
    */
  }
  
  func testInitializationWithSharedArgumentsSetsArguments() {
    APPLICATION_ARGUMENTS = ("tailor.exit", ["a": "25"])
    let application = Application()
    self.assert(application.command, equals: "tailor.exit")
    self.assert(application.flags, equals: ["a": "25"])
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
  
  func testDefaultConfigurationBuildLocalizationFromRequestHeaders() {
    PropertyListLocalization.availableLocales = ["en", "fr"]
    let request = Request(headers: ["Accept-Language": "fr, en"])
    let configuration = Application.Configuration()
    let localization = configuration.localizationForRequest(request)
    assert(localization is PropertyListLocalization)
    assert(localization.locale, equals: "fr")
  }
  
  func testLocalizationFromContentPreferencesSetsLocaleFromAvailableLocales() {
    PropertyListLocalization.availableLocales = ["en", "fr"]
    let request = Request(headers: ["Accept-Language": "fr, en"])
    let localization = Application.configuration.localizationFromContentPreferences(request)
    assert(localization.locale, equals: "fr")
  }
  
  func testLocalizationFromContentPreferencesSetsLocaleWithNoAvailableLocalesDefaultsToEnglish() {
    PropertyListLocalization.availableLocales = ["en", "fr"]
    let request = Request(headers: ["Accept-Language": "es-MX,es"])
    let localization = Application.configuration.localizationFromContentPreferences(request)
    assert(localization.locale, equals: "en")
  }
  
  func testLocalizationFromContentPreferencesWithNoLanguageHeaderDefaultsToEnglish() {
    PropertyListLocalization.availableLocales = ["en", "fr"]
    let request = Request()
    let localization = Application.configuration.localizationFromContentPreferences(request)
    assert(localization.locale, equals: "en")
  }
  
  func testFlattenDictionaryCombinesStringKeys() {
    let result = Application.Configuration.flattenDictionary([
      "key1".bridge(): "value1".bridge(),
      "key2".bridge(): [
        "key3".bridge(): "value3".bridge(),
        "key4".bridge(): "value4".bridge()
      ].bridge()
    ])
    assert(result, equals: [
      "key1": "value1",
      "key2.key3": "value3",
      "key2.key4": "value4"
    ])
  }
  
  func testFlattenDictionaryIgnoresArray() {
    let result = Application.Configuration.flattenDictionary([
      "key1".bridge(): "value1".bridge(),
      "key2".bridge(): ["value2".bridge(), "value4".bridge()].bridge()
      ])
    assert(result, equals: [
      "key1": "value1"
      ])
    
  }
  
  func testFlattenDictionaryIgnoresNonStringKeys() {
    let result = Application.Configuration.flattenDictionary([
      "key1".bridge(): "value1".bridge(),
      NSNumber(int: 2): "value2".bridge()
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
    TypeInventory.shared.registerSubtypes(TaskType.self, subtypes: [TestTask.self])
    let application = Application()
    application.start()
    assert(TestTask.hasRun)
  }
  
  func testClassStartMethodRunsTaskOnSharedApplication() {
    NSThread.currentThread().threadDictionary.removeValueForKey("SHARED_APPLICATION")
    class TestTask: TaskType {
      static let commandName: String = "application_test_task_2"
      static var hasRun = false
      static func runTask() {
        hasRun = true
      }
    }
    APPLICATION_ARGUMENTS = ("application_test_task_2", [:])
    //Application.start()
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
  
  //MARK: - Configuration
  
  func testLocalizationWithNoSettingIsPropertyListLocalization() {
    Application.configuration = Application.Configuration()
    let localization = Application.configuration.localization("en")
    assert(localization is PropertyListLocalization)
  }
}