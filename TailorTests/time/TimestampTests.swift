import TailorTesting
import Tailor

class TimestampTests: TailorTestCase {
  func testInitializationWithEpochSecondsSetsLocalComponents() {
    let timestamp = Timestamp(epochSeconds: 1431346472.5, timeZone: TimeZone(name: "America/Sao_Paulo"), calendar: GregorianCalendar())
    assert(timestamp.epochSeconds, equals: 1431346472.5)
    assert(timestamp.year, equals: 2015)
    assert(timestamp.month, equals: 5)
    assert(timestamp.day, equals: 11)
    assert(timestamp.hour, equals: 9)
    assert(timestamp.minute, equals: 14)
    assert(timestamp.second, equals: 32)
    assert(timestamp.nanosecond, equals: 500000000)
    assert(timestamp.timeZone.name, equals: "America/Sao_Paulo")
    assert(timestamp.calendar is GregorianCalendar)
  }
  
  func testInitializationWithNegativeSecondsSetsLocalComponents() {
    let timestamp = Timestamp(epochSeconds: -1127542174, timeZone: TimeZone(name: "Europe/Rome"))
    assert(timestamp.epochSeconds, equals: -1127542174)
    assert(timestamp.year, equals: 1934)
    assert(timestamp.month, equals: 4)
    assert(timestamp.day, equals: 9)
    assert(timestamp.hour, equals: 18)
    assert(timestamp.minute, equals: 50)
    assert(timestamp.second, equals: 26)
    assert(timestamp.nanosecond, equals: 0)
    assert(timestamp.timeZone.name, equals: "Europe/Rome")
    assert(timestamp.calendar is GregorianCalendar)
  }
  
  func testInitializationWithLocalComponentsSetsTimestamp() {
    let timestamp = Timestamp(
      year: 1992,
      month: 9,
      day: 2,
      hour: 1,
      minute: 54,
      second: 51,
      nanosecond: 0,
      timeZone: TimeZone(name: "Asia/Baku")
    )
    assert(timestamp.year, equals: 1992)
    assert(timestamp.month, equals: 9)
    assert(timestamp.day, equals: 2)
    assert(timestamp.hour, equals: 1)
    assert(timestamp.minute, equals: 54)
    assert(timestamp.second, equals: 51)
    assert(timestamp.timeZone.name, equals: "Asia/Baku")
    assert(timestamp.epochSeconds, equals: 715384491)
    assert(timestamp.calendar is GregorianCalendar)
  }
  
  func testInitializationWithLocalComponentsBefore1970SetsTimestamp() {
    let timestamp = Timestamp(
      year: 1952,
      month: 4,
      day: 30,
      hour: 1,
      minute: 49,
      second: 24,
      nanosecond: 0,
      timeZone: TimeZone(name: "Europe/Moscow")
    )
    assert(timestamp.year, equals: 1952)
    assert(timestamp.month, equals: 4)
    assert(timestamp.day, equals: 30)
    assert(timestamp.hour, equals: 1)
    assert(timestamp.minute, equals: 49)
    assert(timestamp.second, equals: 24)
    assert(timestamp.timeZone.name, equals: "Europe/Moscow")
    assert(timestamp.epochSeconds, equals: -557716236)
    assert(timestamp.calendar is GregorianCalendar)
  }
  
  func testInTimeZoneWithTimeZoneDoesConversion() {
    let timestamp1 = Timestamp(epochSeconds: 498839869, timeZone: TimeZone(name: "US/Eastern"))
    let timestamp2 = timestamp1.inTimeZone(TimeZone(name: "Europe/Lisbon"))
    assert(timestamp1.hour, equals: 10)
    assert(timestamp2.hour, equals: 14)
  }
  
  func testInTimeZoneWithTimeZoneNameDoesConversion() {
    let timestamp1 = Timestamp(epochSeconds: 1047616737, timeZone: TimeZone(name: "US/Eastern"))
    let timestamp2 = timestamp1.inTimeZone("US/Pacific")
    assert(timestamp1.hour, equals: 23)
    assert(timestamp2.hour, equals: 20)
  }
  
  func testTimeInCalendarConvertsToNewCalendarSystem() {
    let timestamp1 = Timestamp(epochSeconds: 981366233, timeZone: TimeZone(name: "US/Eastern"))
    let timestamp2 = timestamp1.inCalendar(IslamicCalendar())
    
    assert(timestamp2.year, equals: 1421)
    assert(timestamp2.month, equals: 11)
    assert(timestamp2.day, equals: 12)
    assert(timestamp2.hour, equals: 4)
    assert(timestamp2.minute, equals: 43)
    assert(timestamp2.second, equals: 53)
  }
  
  func testAddingIntervalcanAddSimpleInterval() {
    let timestamp1 = Timestamp(year: 2014, month: 3, day: 16, hour: 12, minute: 34, second: 10, nanosecond: 11.5, timeZone: TimeZone(name: "UTC"))
    let timestamp2 = timestamp1.byAddingInterval(TimeInterval(years: 1, months: 2, days: 1, hours: 2, minutes: 1, seconds: 2, nanoseconds: 1))
    assert(timestamp2.year, equals: 2015)
    assert(timestamp2.month, equals: 5)
    assert(timestamp2.day, equals: 17)
    assert(timestamp2.hour, equals: 14)
    assert(timestamp2.minute, equals: 35)
    assert(timestamp2.second, equals: 12)
    assert(timestamp2.nanosecond, equals: 12.5)
    assert(timestamp2.epochSeconds, equals: 1431873312.0000000125)
  }
  
  func testAddingIntervalCanHandleExtraDayInLeapYear() {
    let timestamp1 = Timestamp(year: 2015, month: 3, day: 16, hour: 12, minute: 34, second: 10, nanosecond: 0, timeZone: TimeZone(name: "UTC"))
    let timestamp2 = timestamp1.byAddingInterval(TimeInterval(years: 1))
    assert(timestamp2.year, equals: 2016)
    assert(timestamp2.month, equals: 3)
    assert(timestamp2.day, equals: 16)
    assert(timestamp2.epochSeconds, equals: 1458131650)
  }
  
  func testAddingIntervalCanRollOver() {
    let timestamp1 = Timestamp(year: 2015, month: 3, day: 16, hour: 12, minute: 34, second: 10, nanosecond: 0, timeZone: TimeZone(name: "UTC"))
    let timestamp2 = timestamp1.byAddingInterval(TimeInterval(days: 40))
    assert(timestamp2.month, equals: 4)
    assert(timestamp2.day, equals: 25)
    assert(timestamp2.epochSeconds, equals: 1429965250)
  }
  
  func testAddingIntervalCanRollOverYear() {
    let timestamp1 = Timestamp(year: 2015, month: 12, day: 31, hour: 23, minute: 59, second: 59, nanosecond: 500000000, timeZone: TimeZone(name: "UTC"))
    let timestamp2 = timestamp1.byAddingInterval(TimeInterval(nanoseconds: 600000000))
    assert(timestamp2.year, equals: 2016)
    assert(timestamp2.month, equals: 1)
    assert(timestamp2.day, equals: 1)
    assert(timestamp2.hour, equals: 0)
    assert(timestamp2.minute, equals: 0)
    assert(timestamp2.second, equals: 0)
    assert(timestamp2.nanosecond, equals: 100000000)
    assert(timestamp2.epochSeconds, equals: 1451606400.1)
  }
  
  func testAddingIntervalCanAddAndSubtractAtOnce() {
    let timestamp1 = Timestamp(year: 2015, month: 3, day: 16, hour: 12, minute: 34, second: 10, nanosecond: 0, timeZone: TimeZone(name: "UTC"))
    let timestamp2 = timestamp1.byAddingInterval(TimeInterval(months: 1, days: -20))
    assert(timestamp2.month, equals: 3)
    assert(timestamp2.day, equals: 27)
    assert(timestamp2.epochSeconds, equals: 1427459650)
  }
  
  func testFormatMethodFormatsTime() {
    let timestamp = Timestamp(epochSeconds: 1427459650)
    let formattedString = timestamp.format(TimeFormat.Database)
    assert(formattedString, equals: TimeFormat.Database.formatTime(timestamp))
  }
  
  func testNowMethodGetsCurrentTime() {
    let timestamp = Timestamp.now()
    assert(timestamp.epochSeconds, within: 1, of: Double(time(nil)))
  }
  
  func testInitWithFoundationDateUsesTimestampFromDate() {
    let seconds = 1140789600.0
    let foundationDate = NSDate(timeIntervalSince1970: seconds)
    let timestamp = Timestamp(foundationDate: foundationDate)
    assert(timestamp.epochSeconds, equals: seconds)
  }
  
  func testFoundationDateCreatesDateWithTimestamp() {
    let seconds = 1140789600.0
    let timestamp = Timestamp(epochSeconds: seconds)
    let foundationDate = timestamp.foundationDateValue
    assert(foundationDate.timeIntervalSince1970, equals: seconds)
  }

  func testTimestampsAreEqualWithSameInfo() {
    let timestamp1 = Timestamp(epochSeconds: 1018431395, timeZone: TimeZone(name: "US/Pacific"), calendar: GregorianCalendar())
    let timestamp2 = Timestamp(epochSeconds: 1018431395, timeZone: TimeZone(name: "US/Pacific"), calendar: GregorianCalendar())
    assert(timestamp1 == timestamp2)
  }
  
  func testTimestampsWithDifferentZonesAreUnequal() {
    let timestamp1 = Timestamp(epochSeconds: 1018431395, timeZone: TimeZone(name: "US/Pacific"), calendar: GregorianCalendar())
    let timestamp2 = Timestamp(epochSeconds: 1018431395, timeZone: TimeZone(name: "US/Eastern"), calendar: GregorianCalendar())
    assert(timestamp1 != timestamp2)
  }
  
  func testTimestampsWithDifferentCalendarsAreUnequal() {
    let timestamp1 = Timestamp(epochSeconds: 1018431395, timeZone: TimeZone(name: "US/Pacific"), calendar: GregorianCalendar())
    let timestamp2 = Timestamp(epochSeconds: 1018431395, timeZone: TimeZone(name: "US/Pacific"), calendar: IslamicCalendar())
    assert(timestamp1 != timestamp2)
  }
}
