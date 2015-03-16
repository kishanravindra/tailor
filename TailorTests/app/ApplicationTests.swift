import Foundation
import XCTest
import Tailor

class ApplicationTests : XCTestCase {
  //MARK: Initialization
  
  var application: Application!
  override func setUp() {
    TestApplication.start()
    application = TestApplication.sharedApplication()
  }

  func testInitializationSetsInstanceVariables() {
    application = Application(arguments: ["tailor.exit"])
    let address = application.ipAddress
    XCTAssertTrue(
      address.0 == 0 &&
      address.1 == 0 &&
      address.2 == 0 &&
      address.3 == 0
      , "initalizes IP address to dummy address")
    XCTAssertEqual(application.port, 8080, "initializes port to HTTP Alt")
    XCTAssertEqual(application.routeSet.routes.count, 0, "initializes route set to an empty one")
    XCTAssertEqual(application.rootPath(), ".", "initalizes root path to the current path")
  }
  
  func testInitializationSetsArguments() {
    application = Application(arguments: ["tailor.exit", "environment=production", "var=5", "verbose"])
    XCTAssertEqual(application.arguments, ["tailor.exit", "environment=production", "var=5", "verbose"], "stores arguments array")
    XCTAssertEqual(application.command, "tailor.exit", "parses command")
    XCTAssertNotNil(application.flags["environment"], "parses the environment flag")
    XCTAssertEqual(application.flags["environment"]!, "production", "parses the environment flag correctly")
    XCTAssertNotNil(application.flags["var"], "parses the var flag")
    XCTAssertEqual(application.flags["var"]!, "5", "parses the flag properly")
    XCTAssertNotNil(application.flags["verbose"], "parses a flag with no argument")
    XCTAssertEqual(application.flags["verbose"]!, "1", "sets a flag with no argument to 1")
  }
  
  func testInitializationSetsDateFormatters() {
    XCTAssertNotNil(application.dateFormatters["short"]?.dateFormat, "sets a short time format")
    XCTAssertEqual(application.dateFormatters["short"]!.dateFormat!, "hh:mm Z", "sets the short time format properly")
    
    XCTAssertNotNil(application.dateFormatters["long"]?.dateFormat, "sets a long time format")
    XCTAssertEqual(application.dateFormatters["long"]!.dateFormat!, "dd MMMM, yyyy, hh:mm z", "sets a long time format properly")
    
    XCTAssertNotNil(application.dateFormatters["shortDate"]?.dateFormat, "sets a short date format")
    XCTAssertEqual(application.dateFormatters["shortDate"]!.dateFormat!, "dd MMMM", "sets a short date format properly")
    
    
    XCTAssertNotNil(application.dateFormatters["longDate"]?.dateFormat, "sets a long date format")
    XCTAssertEqual(application.dateFormatters["longDate"]!.dateFormat!, "dd MMMM, yyyy", "sets a long date format properly")
    
    XCTAssertNotNil(application.dateFormatters["db"]?.dateFormat, "sets a db date format")
    XCTAssertEqual(application.dateFormatters["db"]!.dateFormat!, "yyyy-MM-dd HH:mm:ss", "sets a db date format properly")
  }
  
  func testParseArgumentsWithNoArgumentsReadsFromPrompt() {
    class TestApplication: Application {
      var commands = ["tailor.exit a=5"]
      override func promptForCommand() -> String {
        return commands.removeLast()
      }
    }
    
    let application = TestApplication(arguments: [""])
    XCTAssertEqual(application.command, "tailor.exit", "sets the command from the prompt")
    XCTAssertEqual(application.flags, ["a": "5"], "sets the flags from the prompt")
  }
  
  func testParseArgumentsRepeatedlyPromptsUntilValidTaskAppears() {
    class TestApplication: Application {
      var commands = ["tailor.exit a=7", "tailor.wait"]
      override func promptForCommand() -> String {
        return commands.removeLast()
      }
    }
    
    let application = TestApplication(arguments: [""])
    XCTAssertEqual(application.command, "tailor.exit", "sets the command from the prompt")
    XCTAssertEqual(application.flags, ["a": "7"], "sets the flags from the prompt")
  }
  
  func testParseArgumentsWithSpacesInQuotesKeepsQuotedSectionTogether() {
    class TestApplication: Application {
      var commands = ["tailor.exit a=\"b + c\" d=23"]
      override func promptForCommand() -> String {
        return commands.removeLast()
      }
    }
    
    let application = TestApplication(arguments: [""])
    XCTAssertEqual(application.flags, ["a": "b + c", "d": "23"], "keeps the quoted flags together")
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
    var ids = types.map { $0.id() }
    XCTAssertEqual(sorted(ids), [1, 2, 3], "registers all subclasses of the type given, including the type itself")
  }
  
  //MARK: - Configuration
  
  func testLoadConfigPutsContentsInConfiguration() {
    application.loadConfigFromFile("Info.plist")
    let value = application.configuration["Info.CFBundlePackageType"]
    XCTAssertNotNil(value, "has a setting")
    if value != nil {
      XCTAssertEqual(value!, "BNDL", "has the setting from the file")
    }
  }
  
  func testLocalizationBuildsLocalizationFromClassName() {
    application.configuration["localization.class"] = "Tailor.DatabaseLocalization"
    let localization = application.localization("en")
    XCTAssertEqual(localization.locale, "en", "sets the localization")
    XCTAssertNotNil(localization as? DatabaseLocalization, "uses the class from the configuration")
    application.configuration["localization.class"] = "Tailor.PropertyListLocalization"
  }
}