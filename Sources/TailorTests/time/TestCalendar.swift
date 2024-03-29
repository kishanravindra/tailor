import XCTest
import Tailor
import TailorTesting
import Foundation

struct TestCalendar: XCTestCase, TailorTestable {
  var allTests: [(String, () throws -> Void)] { return [
    ("testGregorianCalendarIsLeapYearForMultiplesOfFour", testGregorianCalendarIsLeapYearForMultiplesOfFour),
    ("testGregorianCalendarIsNotLeapYearForMultiplesOfOneHundred", testGregorianCalendarIsNotLeapYearForMultiplesOfOneHundred),
    ("testGregorianCalendarIsLeapYearForMultiplesOfFourHundred", testGregorianCalendarIsLeapYearForMultiplesOfFourHundred),
    ("testGregorianCalendarHasTwelveMonths", testGregorianCalendarHasTwelveMonths),
    ("testGregorianCalendarHasCorrectDayCounts", testGregorianCalendarHasCorrectDayCounts),
    ("testGregorianCalendarHasCorrectMonthsInNormalYear", testGregorianCalendarHasCorrectMonthsInNormalYear),
    ("testGregorianCalendarHasCorrectMonthsInLeapYear", testGregorianCalendarHasCorrectMonthsInLeapYear),
    ("testGregorianCalendarGetsZeroForInvalidMonths", testGregorianCalendarGetsZeroForInvalidMonths),
    ("testGregorianCalendarGetsCorrectLocalTimes", testGregorianCalendarGetsCorrectLocalTimes),
    ("testGregorianCalendarGetsCorrectTimestamps", testGregorianCalendarGetsCorrectTimestamps),
    ("testIslamicCalendarIsLeapYearForCorrectYearsInCycle", testIslamicCalendarIsLeapYearForCorrectYearsInCycle),
    ("testIslamicCalendarHasCorrectDaysForNormalYear", testIslamicCalendarHasCorrectDaysForNormalYear),
    ("testIslamicCalendarHasCorrectDaysForLeapYear", testIslamicCalendarHasCorrectDaysForLeapYear),
    //("testIslamicCalendarGetsCorrectLocalTimes", testIslamicCalendarGetsCorrectLocalTimes),
    //("testIslamicCalendarGetsCorrectTimestamps", testIslamicCalendarGetsCorrectTimestamps),
    ("testHebrewCalendarGetsCorrectLocalTimes", testHebrewCalendarGetsCorrectLocalTimes),
    ("testHebrewCalendarGetsCorrectTimestamps", testHebrewCalendarGetsCorrectTimestamps),
    ("testIdenticalCalendarsAreEqual", testIdenticalCalendarsAreEqual),
    ("testCalendarsForDifferentTypesAreNotEqual", testCalendarsForDifferentTypesAreNotEqual),
    ("testCalendarsForDifferentYearsAreUnequal", testCalendarsForDifferentYearsAreUnequal),
  ]}

  func setUp() {
    setUpTestCase()
  }
  
  func checkTimestamps(timestamps: [Double], foundationCalendar: NSCalendar, calendar: Calendar, zoneName: String, file: String = #file, line: UInt = #line) {
    let foundationCalendar = foundationCalendar
    foundationCalendar.timeZone = NSTimeZone(name: zoneName)!
    let timeZone = TimeZone(name: zoneName)
    
    for number in timestamps {
      let foundationDate = NSDate(timeIntervalSince1970: Double(number))
      let foundationDateComponents = foundationCalendar.components([.Year, .Month, .Day, .Hour, .Minute, .Second, .Weekday], fromDate: foundationDate)!
      if calendar is HebrewCalendar && calendar.inYear(foundationDateComponents.year).months == 12 && foundationDateComponents.month > 6 {
        foundationDateComponents.month -= 1
      }
      let timestamp = Timestamp(epochSeconds: number, timeZone: timeZone, calendar: calendar)
      if timestamp.year != foundationDateComponents.year ||
        timestamp.month != foundationDateComponents.month ||
        timestamp.day != foundationDateComponents.day ||
        timestamp.hour != foundationDateComponents.hour ||
        timestamp.minute != foundationDateComponents.minute ||
        timestamp.second != foundationDateComponents.second ||
        timestamp.weekDay != foundationDateComponents.weekday {
          let foundationDescription = NSString(format: "%04i-%02i-%02i %02i:%02i:%02i (%02i)", foundationDateComponents.year, foundationDateComponents.month, foundationDateComponents.day, foundationDateComponents.hour, foundationDateComponents.minute, foundationDateComponents.second, foundationDateComponents.weekday)
          var description = "Incorrect date for timestamp \(number)"
          let gregorianTimestamp = timestamp.inCalendar(GregorianCalendar())
          description += " \(gregorianTimestamp.format(TimeFormat.Database)): "
          description += "Expected \(foundationDescription), but got \(timestamp.format(TimeFormat.Database)) (\(timestamp.weekDay))"
          assert(false, message: description)
      }
    }
  }
  
  func checkLocalDates(dates: [(Int,Int,Int,Int,Int,Int)], foundationCalendar: NSCalendar, calendar: Calendar, zoneName: String, file: String = #file, line: UInt = #line) {
    
    let foundationCalendar = foundationCalendar
    foundationCalendar.timeZone = NSTimeZone(name: zoneName)!
    let timeZone = TimeZone(name: zoneName)
    
    for date in dates {
      let foundationDateComponents = NSDateComponents()
      foundationDateComponents.year = date.0
      foundationDateComponents.month = date.1
      foundationDateComponents.day = date.2
      foundationDateComponents.hour = date.3
      foundationDateComponents.minute = date.4
      foundationDateComponents.second = date.5
      if calendar is HebrewCalendar && calendar.inYear(date.0).months == 12 && date.1 > 5 {
        foundationDateComponents.month += 1
      }
      
      let foundationDate = foundationCalendar.dateFromComponents(foundationDateComponents)!
      let timestamp = Timestamp(year: date.0, month: date.1, day: date.2, hour: date.3, minute: date.4, second: date.5, nanosecond: 0.0, timeZone: timeZone, calendar: calendar)
      let gap = timestamp.epochSeconds - foundationDate.timeIntervalSince1970
      if gap > 0.01 || gap < -0.01 {
        let foundationDescription = NSString(format: "%04i-%02i-%02i %02i:%02i:%02i", foundationDateComponents.year, foundationDateComponents.month, foundationDateComponents.day, foundationDateComponents.hour, foundationDateComponents.minute, foundationDateComponents.second)
        var description = "Incorrect timestamp for \(foundationDescription): "
        description += "Expected \(foundationDate.timeIntervalSince1970), "
        description += "but got \(timestamp.epochSeconds)"
        assert(false, message: description)
      }
    }
  }
  //MARK: - Gregorian Calendar
  
  func testGregorianCalendarIsLeapYearForMultiplesOfFour() {
    XCTAssertTrue(GregorianCalendar.isLeapYear(1960))
    XCTAssertTrue(GregorianCalendar.isLeapYear(1964))
    XCTAssertTrue(GregorianCalendar.isLeapYear(1968))
    XCTAssertFalse(GregorianCalendar.isLeapYear(1961))
    XCTAssertFalse(GregorianCalendar.isLeapYear(1962))
    XCTAssertFalse(GregorianCalendar.isLeapYear(1963))
    XCTAssertFalse(GregorianCalendar.isLeapYear(1965))
    XCTAssertFalse(GregorianCalendar.isLeapYear(1966))
    XCTAssertFalse(GregorianCalendar.isLeapYear(1967))
    XCTAssertFalse(GregorianCalendar.isLeapYear(1969))
    XCTAssertFalse(GregorianCalendar.isLeapYear(1970))
    XCTAssertFalse(GregorianCalendar.isLeapYear(1971))
  }
  
  func testGregorianCalendarIsNotLeapYearForMultiplesOfOneHundred() {
    XCTAssertFalse(GregorianCalendar.isLeapYear(1700))
    XCTAssertFalse(GregorianCalendar.isLeapYear(1800))
    XCTAssertFalse(GregorianCalendar.isLeapYear(1900))
  }
  
  func testGregorianCalendarIsLeapYearForMultiplesOfFourHundred() {
    XCTAssertTrue(GregorianCalendar.isLeapYear(1600))
    XCTAssertTrue(GregorianCalendar.isLeapYear(2000))
  }
  
  func testGregorianCalendarHasTwelveMonths() {
    assert(GregorianCalendar(2012).months, equals: 12)
    assert(GregorianCalendar(2013).months, equals: 12)
  }
  
  func testGregorianCalendarHasCorrectDayCounts() {
    assert(GregorianCalendar(2012).days, equals: 366, message: "has 366 days in leap year")
    assert(GregorianCalendar(2013).days, equals: 365, message: "has 365 days in normal year")
    
  }
  
  func testGregorianCalendarHasCorrectMonthsInNormalYear() {
    let calendar = GregorianCalendar(2013)
    assert(calendar.daysInMonth(1), equals: 31)
    assert(calendar.daysInMonth(2), equals: 28)
    assert(calendar.daysInMonth(3), equals: 31)
    assert(calendar.daysInMonth(4), equals: 30)
    assert(calendar.daysInMonth(5), equals: 31)
    assert(calendar.daysInMonth(6), equals: 30)
    assert(calendar.daysInMonth(7), equals: 31)
    assert(calendar.daysInMonth(8), equals: 31)
    assert(calendar.daysInMonth(9), equals: 30)
    assert(calendar.daysInMonth(10), equals: 31)
    assert(calendar.daysInMonth(11), equals: 30)
    assert(calendar.daysInMonth(12), equals: 31)
  }
  
  func testGregorianCalendarHasCorrectMonthsInLeapYear() {
    let calendar = GregorianCalendar(2012)
    assert(calendar.daysInMonth(1), equals: 31)
    assert(calendar.daysInMonth(2), equals: 29)
    assert(calendar.daysInMonth(3), equals: 31)
    assert(calendar.daysInMonth(4), equals: 30)
    assert(calendar.daysInMonth(5), equals: 31)
    assert(calendar.daysInMonth(6), equals: 30)
    assert(calendar.daysInMonth(7), equals: 31)
    assert(calendar.daysInMonth(8), equals: 31)
    assert(calendar.daysInMonth(9), equals: 30)
    assert(calendar.daysInMonth(10), equals: 31)
    assert(calendar.daysInMonth(11), equals: 30)
    assert(calendar.daysInMonth(12), equals: 31)
  }
  
  func testGregorianCalendarGetsZeroForInvalidMonths() {
    let calendar = GregorianCalendar(2013)
    assert(calendar.daysInMonth(13), equals: 0)
  }
  
  func testGregorianCalendarGetsCorrectLocalTimes() {
    let timestamps = [-851843061.0, 814901765.0, -979057837.0, 479095593.0, 616307988.0]
    self.checkTimestamps(timestamps, foundationCalendar: NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!, calendar: GregorianCalendar(), zoneName: "UTC")
  }
  
  func testGregorianCalendarGetsCorrectTimestamps() {
    let dates = [(1944, 8, 16, 21, 36, 37), (1999, 2, 22, 19, 18, 57), (2000, 4, 7, 14, 1, 9), (1973, 9, 23, 12, 56, 44), (1995, 7, 7, 17, 25, 14)]
    self.checkLocalDates(dates, foundationCalendar: NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!, calendar: GregorianCalendar(), zoneName: "UTC")
  }
  
  //MARK: - Islamic Calendar
  
  func testIslamicCalendarIsLeapYearForCorrectYearsInCycle() {
    XCTAssertFalse(IslamicCalendar.isLeapYear(1380))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1381))
    XCTAssertTrue(IslamicCalendar.isLeapYear(1382))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1383))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1384))
    XCTAssertTrue(IslamicCalendar.isLeapYear(1385))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1386))
    XCTAssertTrue(IslamicCalendar.isLeapYear(1387))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1388))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1389))
    XCTAssertTrue(IslamicCalendar.isLeapYear(1390))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1391))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1392))
    XCTAssertTrue(IslamicCalendar.isLeapYear(1393))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1394))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1395))
    XCTAssertTrue(IslamicCalendar.isLeapYear(1396))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1397))
    XCTAssertTrue(IslamicCalendar.isLeapYear(1398))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1399))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1400))
    XCTAssertTrue(IslamicCalendar.isLeapYear(1401))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1402))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1403))
    XCTAssertTrue(IslamicCalendar.isLeapYear(1404))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1405))
    XCTAssertTrue(IslamicCalendar.isLeapYear(1406))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1407))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1408))
    XCTAssertTrue(IslamicCalendar.isLeapYear(1409))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1410))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1411))
    XCTAssertTrue(IslamicCalendar.isLeapYear(1412))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1413))
    XCTAssertFalse(IslamicCalendar.isLeapYear(1414))
    XCTAssertTrue(IslamicCalendar.isLeapYear(1415))
  }
  
  func testIslamicCalendarHasCorrectDaysForNormalYear() {
    let calendar = IslamicCalendar(1380)
    assert(calendar.daysInMonth(1), equals: 30)
    assert(calendar.daysInMonth(2), equals: 29)
    assert(calendar.daysInMonth(3), equals: 30)
    assert(calendar.daysInMonth(4), equals: 29)
    assert(calendar.daysInMonth(5), equals: 30)
    assert(calendar.daysInMonth(6), equals: 29)
    assert(calendar.daysInMonth(7), equals: 30)
    assert(calendar.daysInMonth(8), equals: 29)
    assert(calendar.daysInMonth(9), equals: 30)
    assert(calendar.daysInMonth(10), equals: 29)
    assert(calendar.daysInMonth(11), equals: 30)
    assert(calendar.daysInMonth(12), equals: 29)
  }
  
  func testIslamicCalendarHasCorrectDaysForLeapYear() {
    let calendar = IslamicCalendar(1382)
    assert(calendar.daysInMonth(1), equals: 30)
    assert(calendar.daysInMonth(2), equals: 29)
    assert(calendar.daysInMonth(3), equals: 30)
    assert(calendar.daysInMonth(4), equals: 29)
    assert(calendar.daysInMonth(5), equals: 30)
    assert(calendar.daysInMonth(6), equals: 29)
    assert(calendar.daysInMonth(7), equals: 30)
    assert(calendar.daysInMonth(8), equals: 29)
    assert(calendar.daysInMonth(9), equals: 30)
    assert(calendar.daysInMonth(10), equals: 29)
    assert(calendar.daysInMonth(11), equals: 30)
    assert(calendar.daysInMonth(12), equals: 30)
  }
  
  func testIslamicCalendarGetsCorrectLocalTimes() {
    let timestamps = [-329028905.0, 1017705730.0, 562374912.0, -360559748.0, 222154562.0]
    self.checkTimestamps(timestamps, foundationCalendar: NSCalendar(calendarIdentifier: NSCalendarIdentifierIslamicTabular)!, calendar: IslamicCalendar(), zoneName: "UTC")
  }
  
  func testIslamicCalendarGetsCorrectTimestamps() {
    let dates = [(1427, 11, 18, 4, 37, 6), (1426, 6, 10, 0, 2, 7), (1415, 1, 21, 16, 39, 15), (1377, 5, 11, 16, 31, 20), (1418, 2, 25, 7, 29, 12)]
    self.checkLocalDates(dates, foundationCalendar: NSCalendar(calendarIdentifier: NSCalendarIdentifierIslamicTabular)!, calendar: IslamicCalendar(), zoneName: "UTC")
  }
  
  func testHebrewCalendarGetsCorrectLocalTimes() {
    let timestamps = [16807.0, -1622650073.0, -1144108930.0, -101027544.0, 1458777923.0, 823564440.0, -1784484492.0, 114807987.0, 1441282327.0, -823378840.0]
    
    self.checkTimestamps(timestamps, foundationCalendar: NSCalendar(calendarIdentifier: NSCalendarIdentifierHebrew)!, calendar: HebrewCalendar(), zoneName: "UTC")
  }
  
  func testHebrewCalendarGetsCorrectTimestamps() {
    let dates = [(5707, 7, 18, 4, 37, 6), (5749, 13, 10, 0, 2, 7), (5773, 1, 21, 16, 39, 15), (5758, 5, 11, 16, 31, 20), (5730, 2, 25, 7, 29, 12)]
    self.checkLocalDates(dates, foundationCalendar: NSCalendar(calendarIdentifier: NSCalendarIdentifierHebrew)!, calendar: HebrewCalendar(), zoneName: "UTC")
  }
  
  //MARK: - Free Functions
  
  func testIdenticalCalendarsAreEqual() {
    assert(GregorianCalendar() == GregorianCalendar())
    assert(IslamicCalendar() == IslamicCalendar())
  }
  
  func testCalendarsForDifferentTypesAreNotEqual() {
    assert(GregorianCalendar() != IslamicCalendar())
  }
  
  func testCalendarsForDifferentYearsAreUnequal() {
    assert(GregorianCalendar(1) != GregorianCalendar(2))
  }
}