import Tailor
import TailorTesting

class DateTests: TailorTestCase {
  func testDatesAreEqualWithSameInfo() {
    let date1 = Date(year: 2008, month: 9, day: 17)
    let date2 = Date(year: 2008, month: 9, day: 17)
    assert(date1 == date2)
  }
  
  func testDatesAreInequalWithDifferentYears() {
    let date1 = Date(year: 2008, month: 9, day: 17)
    let date2 = Date(year: 2009, month: 9, day: 17)
    assert(date1 != date2)
  }
  
  func testDatesAreInequalWithDifferentMonths() {
    let date1 = Date(year: 2008, month: 9, day: 17)
    let date2 = Date(year: 2008, month: 10, day: 17)
    assert(date1 != date2)
  }
  
  func testDatesAreInequalWithDifferentDays() {
    let date1 = Date(year: 2008, month: 9, day: 17)
    let date2 = Date(year: 2008, month: 9, day: 14)
    assert(date1 != date2)
  }
  
  func testDatesAreInequalWithDifferentCalendars() {
    let date1 = Date(year: 2008, month: 9, day: 17, calendar: GregorianCalendar())
    let date2 = Date(year: 2008, month: 9, day: 17, calendar: IslamicCalendar())
    assert(date1 != date2)
  }
  
  func testDateIsBeforeDateWithLaterYear() {
    let date1 = Date(year: 2049, month: 6, day: 10)
    let date2 = Date(year: 2050, month: 6, day: 10)
    assert(date1 < date2)
  }
  
  func testDateIsAfterDateWithEarlierYear() {
    let date1 = Date(year: 2050, month: 6, day: 10)
    let date2 = Date(year: 2049, month: 6, day: 10)
    assert(date1 > date2)
  }
  
  func testDateIsBeforeDateWithLaterMonth() {
    let date1 = Date(year: 2049, month: 6, day: 10)
    let date2 = Date(year: 2049, month: 7, day: 10)
    assert(date1 < date2)
  }
  
  func testDateIsBeforeDateWithLaterDay() {
    let date1 = Date(year: 2049, month: 6, day: 10)
    let date2 = Date(year: 2049, month: 6, day: 11)
    assert(date1 < date2)
  }
  
  func testDateIsAfterDateWithLaterDayInEarlierMonth() {
    let date1 = Date(year: 2049, month: 6, day: 10)
    let date2 = Date(year: 2049, month: 4, day: 15)
    assert(date1 > date2)
  }
  
  func testDateIsAfterDateWithLaterMonthInEarlierYear() {
    let date1 = Date(year: 2049, month: 6, day: 10)
    let date2 = Date(year: 2048, month: 7, day: 10)
    assert(date1 > date2)
  }
  
  func testDescriptionGetsFormattedDate() {
    let date = Date(year: 2038, month: 01, day: 30)
    assert(date.description, equals: "2038-01-30")
  }
  
  func testBeginningOfDayGetsTimestampAtZeroHour() {
    let date = Date(year: 2009, month: 11, day: 16)
    let timestamp = date.beginningOfDay(TimeZone(name: "US/Pacific"))
    assert(timestamp.year, equals: date.year)
    assert(timestamp.month, equals: date.month)
    assert(timestamp.day, equals: date.day)
    assert(timestamp.hour, equals: 0)
    assert(timestamp.minute, equals: 0)
    assert(timestamp.second, equals: 0)
    assert(timestamp.nanosecond, equals: 0)
    assert(timestamp.epochSeconds, equals: 1258358400)
  }
  
  func testEndOfDayGetsTimestampAtLastHour() {
    let date = Date(year: 2022, month: 3, day: 3)
    let timestamp = date.endOfDay(TimeZone(name: "US/Eastern"))
    assert(timestamp.year, equals: date.year)
    assert(timestamp.month, equals: date.month)
    assert(timestamp.day, equals: date.day)
    assert(timestamp.hour, equals: 23)
    assert(timestamp.minute, equals: 59)
    assert(timestamp.second, equals: 59)
    assert(timestamp.nanosecond, equals: 0)
    assert(timestamp.epochSeconds, equals: 1646369999)
  }
  
  func testTodayGetsCurrentDate() {
    let timestamp = Timestamp.now()
    let date = Date.today()
    assert(date.year, equals: timestamp.year)
    assert(date.month, equals: timestamp.month)
    assert(date.day, equals: timestamp.day)
  }
}
