import XCTest
import Tailor

class NSDateTests: XCTestCase {
  override func setUp() {
    Application.start()
    let application = TestApplication.sharedApplication()
    application.dateFormatters["long"]?.timeZone = NSTimeZone(name: "UTC")
  }
  func testInitalizationWithComponentsSetsComponents() {
    let date = NSDate(year: 2015, month: 1, day: 1, hour: 19, minute: 29, second: 30)
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.componentsInTimeZone(NSTimeZone.systemTimeZone(), fromDate: date)
    XCTAssertEqual(components.year, 2015, "sets the year")
    XCTAssertEqual(components.month, 1, "sets the month")
    XCTAssertEqual(components.day, 1, "sets the day")
    XCTAssertEqual(components.hour, 19, "sets the hour")
    XCTAssertEqual(components.minute, 29, "sets the minute")
    XCTAssertEqual(components.second, 30, "sets the second")
  }
  
  func testInitializationWithTimeZoneDoesTimeZoneConversion() {
    let date = NSDate(year: 2015, month: 1, day: 1, hour: 19, minute: 29, second: 30, timeZone: NSTimeZone(name: "US/Central"))
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.componentsInTimeZone(NSTimeZone(name: "US/Pacific") ?? NSTimeZone.systemTimeZone(), fromDate: date)
    XCTAssertEqual(components.year, 2015, "sets the year")
    XCTAssertEqual(components.month, 1, "sets the month")
    XCTAssertEqual(components.day, 1, "sets the day")
    XCTAssertEqual(components.hour, 17, "sets the hour")
    XCTAssertEqual(components.minute, 29, "sets the minute")
    XCTAssertEqual(components.second, 30, "sets the second")
  }
  
  func testFormatGetsFormattedStringBasedOnApplicationFormat() {
    let date = NSDate(timeIntervalSince1970: 1234512345)
    let string = date.format("long")
    XCTAssertNotNil(string, "gets a formatted string")
    if string != nil { XCTAssertEqual(string!, "13 February, 2009, 08:05 GMT", "gets the date formatted with the specified date format") }
  }
  
  func testFormatGetsFormattedStringBasedOnTimeZone() {
    let date = NSDate(timeIntervalSince1970: 1234512345)
    let string = date.format("long", timeZone: NSTimeZone(name: "US/Pacific"))
    XCTAssertNotNil(string, "gets a formatted string")
    if string != nil { XCTAssertEqual(string!, "13 February, 2009, 00:05 PST", "gets the date formatted with the specified date format") }
  }
  
  func testFormatWithTimeZoneDoesNotChangeTimeZonePermanently() {
    let date = NSDate(timeIntervalSince1970: 1234512345)
    let string = date.format("long", timeZone: NSTimeZone(name: "US/Pacific"))
    let zone = Application.sharedApplication().dateFormatters["long"]?.timeZone
    XCTAssertNotNil(zone, "still has a time zone")
    if zone != nil { XCTAssertEqual(zone!.name, "GMT", "leaves the original time zone in place") }
  }
  
  func testFormatWithGetsFormattedStringBasedOnTimeZoneNamed() {
    let date = NSDate(timeIntervalSince1970: 1234512345)
    let string = date.format("long", timeZoneNamed: "US/Mountain")
    XCTAssertNotNil(string, "gets a formatted string")
    if string != nil { XCTAssertEqual(string!, "13 February, 2009, 01:05 MST", "gets the date formatted with the specified date format") }
  }
  
  func testDateFormatterInitializerSetsComponents() {
    let components = NSDateComponents(year: 2015, month: 1, day: 1, hour: 19, minute: 29, second: 30, timeZone: NSTimeZone(name: "Europe/Rome"))
    XCTAssertEqual(components.year, 2015, "sets the year")
    XCTAssertEqual(components.month, 1, "sets the month")
    XCTAssertEqual(components.day, 1, "sets the day")
    XCTAssertEqual(components.hour, 19, "sets the hour")
    XCTAssertEqual(components.minute, 29, "sets the minute")
    XCTAssertEqual(components.second, 30, "sets the second")
    XCTAssertNotNil(components.timeZone)
    if components.timeZone != nil { XCTAssertEqual(components.timeZone!.name, "Europe/Rome", "sets the time zone") }
  }
}
