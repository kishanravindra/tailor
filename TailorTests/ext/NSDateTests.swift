import XCTest
import Tailor
import TailorTesting

class NSDateTests: TailorTestCase {
  override func setUp() {
    Application.start()
    let application = TestApplication.sharedApplication()
    application.dateFormatters["long"]?.timeZone = NSTimeZone(name: "UTC")
  }
  func testInitalizationWithComponentsSetsComponents() {
    let date = NSDate(year: 2015, month: 1, day: 1, hour: 19, minute: 29, second: 30)
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.componentsInTimeZone(NSTimeZone.systemTimeZone(), fromDate: date)
    assert(components.year, equals: 2015, message: "sets the year")
    assert(components.month, equals: 1, message: "sets the month")
    assert(components.day, equals: 1, message: "sets the day")
    assert(components.hour, equals: 19, message: "sets the hour")
    assert(components.minute, equals: 29, message: "sets the minute")
    assert(components.second, equals: 30, message: "sets the second")
  }
  
  func testInitializationWithTimeZoneDoesTimeZoneConversion() {
    let date = NSDate(year: 2015, month: 1, day: 1, hour: 19, minute: 29, second: 30, timeZone: NSTimeZone(name: "US/Central"))
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.componentsInTimeZone(NSTimeZone(name: "US/Pacific") ?? NSTimeZone.systemTimeZone(), fromDate: date)
    assert(components.year, equals: 2015, message: "sets the year")
    assert(components.month, equals: 1, message: "sets the month")
    assert(components.day, equals: 1, message: "sets the day")
    assert(components.hour, equals: 17, message: "sets the hour")
    assert(components.minute, equals: 29, message: "sets the minute")
    assert(components.second, equals: 30, message: "sets the second")
  }
  
  func testFormatGetsFormattedStringBasedOnApplicationFormat() {
    let date = NSDate(timeIntervalSince1970: 1234512345)
    let string = date.format("long")
    XCTAssertNotNil(string, "gets a formatted string")
    if string != nil { assert(string!, equals: "13 February, 2009, 08:05 GMT", message: "gets the date formatted with the specified date format") }
  }
  
  func testFormatGetsFormattedStringBasedOnTimeZone() {
    let date = NSDate(timeIntervalSince1970: 1234512345)
    let string = date.format("long", timeZone: NSTimeZone(name: "US/Pacific"))
    XCTAssertNotNil(string, "gets a formatted string")
    if string != nil { assert(string!, equals: "13 February, 2009, 00:05 PST", message: "gets the date formatted with the specified date format") }
  }
  
  func testFormatWithTimeZoneDoesNotChangeTimeZonePermanently() {
    let date = NSDate(timeIntervalSince1970: 1234512345)
    let string = date.format("long", timeZone: NSTimeZone(name: "US/Pacific"))
    let zone = Application.sharedApplication().dateFormatters["long"]?.timeZone
    XCTAssertNotNil(zone, "still has a time zone")
    if zone != nil { assert(zone!.name, equals: "GMT", message: "leaves the original time zone in place") }
  }
  
  func testFormatWithGetsFormattedStringBasedOnTimeZoneNamed() {
    let date = NSDate(timeIntervalSince1970: 1234512345)
    let string = date.format("long", timeZoneNamed: "US/Mountain")
    XCTAssertNotNil(string, "gets a formatted string")
    if string != nil { assert(string!, equals: "13 February, 2009, 01:05 MST", message: "gets the date formatted with the specified date format") }
  }
  
  func testDateFormatterInitializerSetsComponents() {
    let components = NSDateComponents(year: 2015, month: 1, day: 1, hour: 19, minute: 29, second: 30, timeZone: NSTimeZone(name: "Europe/Rome"))
    assert(components.year, equals: 2015, message: "sets the year")
    assert(components.month, equals: 1, message: "sets the month")
    assert(components.day, equals: 1, message: "sets the day")
    assert(components.hour, equals: 19, message: "sets the hour")
    assert(components.minute, equals: 29, message: "sets the minute")
    assert(components.second, equals: 30, message: "sets the second")
    XCTAssertNotNil(components.timeZone)
    if components.timeZone != nil { assert(components.timeZone!.name, equals: "Europe/Rome", message: "sets the time zone") }
  }
}
