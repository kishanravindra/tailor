import Foundation
import XCTest
import Tailor
import TailorTesting

class ApplicationTests : TailorTestCase {
  //MARK: Initialization
  
  var application: Application!
  override func setUp() {
    super.setUp()
    application = Application.sharedApplication()
  }

  func testInitializationSetsInstanceVariables() {
    application = Application()
    let address = application.ipAddress
    XCTAssertTrue(
      address.0 == 0 &&
      address.1 == 0 &&
      address.2 == 0 &&
      address.3 == 0
      , "initalizes IP address to dummy address")
    self.assert(application.port, equals: 8080, message: "initializes port to HTTP Alt")
    self.assert(application.routeSet.routes.count, equals: 0, message: "initializes route set to an empty one")
    self.assert(application.rootPath(), equals: ".", message: "initalizes root path to the current path")
  }
  
  func testInitializationSetsDateFormatters() {
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
  
  func testInitializationWithoutSharedArgumentsReadsFromPrompt() {
    class TestApplication: Application {
      var commands = ["tailor.exit a=5"]
      override func promptForCommand() -> String {
        return commands.removeLast()
      }
    }
    
    APPLICATION_ARGUMENTS = nil
    let application = TestApplication()
    self.assert(application.command, equals: "tailor.exit", message: "sets the command from the prompt")
    self.assert(application.flags, equals: ["a": "5"], message: "sets the flags from the prompt")
  }
  
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
  
  func testSharedApplicationReusesApplication() {
    let application1 = Application.sharedApplication()
    application1.configuration["test.identity"] = "success"
    let application2 = Application.sharedApplication()
    self.assert(application2.configuration["test.identity"], equals: "success")
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
    let types = application.registeredSubclassList(TestClassWithSubclasses)
    let ids = types.map { $0.id() }
    self.assert(ids.sort(), equals: [1, 2, 3], message: "registers all subclasses of the type given, including the type itself")
  }
  
  //MARK: - Configuration
  
  func testLoadConfigPutsContentsInConfiguration() {
    application.loadConfigFromFile("Info.plist")
    let value = application.configuration["Info.CFBundlePackageType"]
    self.assert(value, equals: "BNDL", message: "has the setting from the file")
  }
  
  func testLocalizationBuildsLocalizationFromClassName() {
    application.configuration["localization.class"] = "Tailor.DatabaseLocalization"
    let localization = application.localization("en")
    self.assert(localization.locale, equals: "en", message: "sets the localization")
    XCTAssertNotNil(localization as? DatabaseLocalization, "uses the class from the configuration")
    application.configuration["localization.class"] = "Tailor.PropertyListLocalization"
  }
}