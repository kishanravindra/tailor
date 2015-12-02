import TailorTesting
import Tailor
import XCTest

class TimestampTests: XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
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
    assert(timestamp.weekDay, equals: 2)
    assert(timestamp.timeZone.name, equals: "America/Sao_Paulo")
    assert(timestamp.calendar is GregorianCalendar)
  }
  
  func testInitializationWithEpochSecondsOfZeroGetsEpochTime() {
    let timestamp = Timestamp(epochSeconds: 0, timeZone: TimeZone(name: "UTC"), calendar: GregorianCalendar())
    assert(timestamp.epochSeconds, equals: 0)
    assert(timestamp.year, equals: 1970)
    assert(timestamp.month, equals: 1)
    assert(timestamp.day, equals: 1)
    assert(timestamp.hour, equals: 0)
    assert(timestamp.minute, equals: 0)
    assert(timestamp.second, equals: 0)
    assert(timestamp.nanosecond, equals: 0)
    assert(timestamp.weekDay, equals: 5)
    assert(timestamp.timeZone.name, equals: "UTC")
    assert(timestamp.calendar is GregorianCalendar)
  }
  
  func testInitializationWithNegativeSecondsSetsLocalComponents() {
    let timestamp = Timestamp(epochSeconds: -1127455774, timeZone: TimeZone(name: "Europe/Rome"))
    assert(timestamp.epochSeconds, equals: -1127455774)
    assert(timestamp.year, equals: 1934)
    assert(timestamp.month, equals: 4)
    assert(timestamp.day, equals: 10)
    assert(timestamp.hour, equals: 18)
    assert(timestamp.minute, equals: 50)
    assert(timestamp.second, equals: 26)
    assert(timestamp.nanosecond, equals: 0)
    assert(timestamp.weekDay, equals: 3)
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
    assert(timestamp.weekDay, equals: 4)
    assert(timestamp.timeZone.name, equals: "Asia/Baku")
    assert(timestamp.epochSeconds, equals: 715384491)
    assert(timestamp.calendar is GregorianCalendar)
  }
  
  func testInitializationWithLocalComponentsBefore1970SetsTimestamp() {
    let timestamp = Timestamp(
      year: 1952,
      month: 4,
      day: 27,
      hour: 1,
      minute: 49,
      second: 24,
      nanosecond: 0,
      timeZone: TimeZone(name: "Europe/Moscow")
    )
    assert(timestamp.year, equals: 1952)
    assert(timestamp.month, equals: 4)
    assert(timestamp.day, equals: 27)
    assert(timestamp.hour, equals: 1)
    assert(timestamp.minute, equals: 49)
    assert(timestamp.second, equals: 24)
    assert(timestamp.weekDay, equals: 7)
    assert(timestamp.timeZone.name, equals: "Europe/Moscow")
    assert(timestamp.epochSeconds, equals: -557975436)
    assert(timestamp.calendar is GregorianCalendar)
  }
  
  func testInitializationCanHandleJumpAroundDaylightSavingTime() {
    let timestamp = Timestamp(
      year: 2015,
      month: 3,
      day: 8,
      hour: 3,
      minute: 54,
      second: 51,
      nanosecond: 0,
      timeZone: TimeZone(name: "US/Eastern")
    )
    assert(timestamp.year, equals: 2015)
    assert(timestamp.month, equals: 3)
    assert(timestamp.day, equals: 8)
    assert(timestamp.hour, equals: 3)
    assert(timestamp.minute, equals: 54)
    assert(timestamp.second, equals: 51)
    assert(timestamp.weekDay, equals: 1)
    assert(timestamp.timeZone.name, equals: "US/Eastern")
    assert(timestamp.epochSeconds, equals: 1425801291.0)
    assert(timestamp.calendar is GregorianCalendar)
  }
  
  //MARK: - Transformations
  
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
  
  func testChangeCanChangeTimeComponents() {
    let timestamp1 = Timestamp(year: 2003, month: 7, day: 19, hour: 12, minute: 13, second: 6, timeZone: TimeZone(name: "UTC"), calendar: GregorianCalendar())
    let timestamp2 = timestamp1.change(year: 2004, month: 5, minute: 25)
    assert(timestamp2.year, equals: 2004)
    assert(timestamp2.month, equals: 5)
    assert(timestamp2.day, equals: 19)
    assert(timestamp2.hour, equals: 12)
    assert(timestamp2.minute, equals: 25)
    assert(timestamp2.second, equals: 6)
    assert(timestamp2.epochSeconds, equals: 1084969506)
    let timestamp3 = timestamp1.change(hour: 13)
    assert(timestamp3.year, equals: 2003)
    assert(timestamp3.month, equals: 7)
    assert(timestamp3.day, equals: 19)
    assert(timestamp3.hour, equals: 13)
    assert(timestamp3.minute, equals: 13)
    assert(timestamp3.second, equals: 6)
    assert(timestamp3.epochSeconds, equals: 1058620386)
  }
  
  func testAddingIntervalCanAddSimpleInterval() {
    let timestamp1 = Timestamp(year: 2014, month: 3, day: 16, hour: 12, minute: 34, second: 10, nanosecond: 11.5, timeZone: TimeZone(name: "UTC"))
    let timestamp2 = timestamp1.byAddingInterval(TimeInterval(years: 1, months: 2, days: 1, hours: 2, minutes: 1, seconds: 2, nanoseconds: 1))
    assert(timestamp2.year, equals: 2015)
    assert(timestamp2.month, equals: 5)
    assert(timestamp2.day, equals: 17)
    assert(timestamp2.hour, equals: 14)
    assert(timestamp2.minute, equals: 35)
    assert(timestamp2.second, equals: 12)
    assert(timestamp2.nanosecond, equals: 12.5)
    assert(timestamp2.weekDay, equals: 1)
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
  
  func testAddingIntervalCanRollBackToPreviousMonth() {
    let timestamp = Timestamp(year: 2015, month: 12, day: 1, hour: 18, minute: 36)
    let timestamp2 = timestamp.byAddingInterval(TimeInterval(days: -1))
    assert(timestamp2.year, equals: 2015)
    assert(timestamp2.month, equals: 11)
    assert(timestamp2.day, equals: 30)
    assert(timestamp2.hour, equals: 18)
    assert(timestamp2.minute, equals: 36)
  }
  
  func testAddingIntervalCanAddAndSubtractAtOnce() {
    let timestamp1 = Timestamp(year: 2015, month: 3, day: 16, hour: 12, minute: 34, second: 10, nanosecond: 0, timeZone: TimeZone(name: "UTC"))
    let timestamp2 = timestamp1.byAddingInterval(TimeInterval(months: 1, days: -20))
    assert(timestamp2.month, equals: 3)
    assert(timestamp2.day, equals: 27)
    assert(timestamp2.epochSeconds, equals: 1427459650)
  }
  
  func testIntervalSinceGetsIntervalSinceEarlierTime() {
    let timestamp1 = Timestamp(epochSeconds: 1585493070, timeZone: TimeZone(name: "UTC"), calendar: GregorianCalendar())
    let timestamp2 = Timestamp(epochSeconds: 805937697, timeZone: TimeZone(name: "UTC"), calendar: GregorianCalendar())
    let interval = timestamp1.intervalSince(timestamp2)
    assert(interval.years, equals: 24)
    assert(interval.months, equals: 8)
    assert(interval.days, equals: 12)
    assert(interval.hours, equals: 15)
    assert(interval.minutes, equals: 9)
    assert(interval.seconds, equals: 33)
    assert(timestamp2 + interval, equals: timestamp1)
  }
  
  func testIntervalSinceGetsIntervalUntilLaterTime() {
    let timestamp1 = Timestamp(epochSeconds: 1442736307, timeZone: TimeZone(name: "UTC"), calendar: GregorianCalendar())
    let timestamp2 = Timestamp(epochSeconds: 1891353078, timeZone: TimeZone(name: "UTC"), calendar: GregorianCalendar())
    let interval = timestamp1.intervalSince(timestamp2)
    assert(interval.years, equals: -14)
    assert(interval.months, equals: -2)
    assert(interval.days, equals: -17)
    assert(interval.hours, equals: -7)
    assert(interval.minutes, equals: -46)
    assert(interval.seconds, equals: -11)
    assert(timestamp2 + interval, equals: timestamp1)
  }
  
  func testIntervalSinceWithDifferentTimeZoneCompensatesForTimeZones() {
    let timestamp1 = Timestamp(epochSeconds: 1664264871, timeZone: TimeZone(name: "UTC"), calendar: GregorianCalendar())
    let timestamp2 = Timestamp(epochSeconds: 1229410746, timeZone: TimeZone(name: "US/Eastern"), calendar: GregorianCalendar())
    let interval = timestamp1.intervalSince(timestamp2)
    assert(interval.years, equals: 13)
    assert(interval.months, equals: 9)
    assert(interval.days, equals: 11)
    assert(interval.hours, equals: 0)
    assert(interval.minutes, equals: 48)
    assert(interval.seconds, equals: 45)
    assert(timestamp2.inTimeZone("UTC") + interval, equals: timestamp1)
  }
  
  func testIntervalSinceWithDifferentCalendarCompensatesForCalendar() {
    let timestamp1 = Timestamp(epochSeconds: 1507479210, timeZone: TimeZone(name: "UTC"), calendar: GregorianCalendar())
    let timestamp2 = Timestamp(epochSeconds: 1197994550, timeZone: TimeZone(name: "UTC"), calendar: IslamicCalendar())
    let interval = timestamp1.intervalSince(timestamp2)
    assert(interval.years, equals: 9)
    assert(interval.months, equals: 9)
    assert(interval.days, equals: 19)
    assert(interval.hours, equals: 23)
    assert(interval.minutes, equals: 57)
    assert(interval.seconds, equals: 40)
    assert(timestamp2.inCalendar(GregorianCalendar()) + interval, equals: timestamp1)
  }
  
  func testIntervalSinceCompensatesForHigherNanoseconds() {
    let timestamp1 = Timestamp(epochSeconds: 1442736307.6, timeZone: TimeZone(name: "UTC"), calendar: GregorianCalendar())
    let timestamp2 = Timestamp(epochSeconds: 1891353078.5, timeZone: TimeZone(name: "UTC"), calendar: GregorianCalendar())
    let interval = timestamp1.intervalSince(timestamp2)
    assert(interval.years, equals: -14)
    assert(interval.months, equals: -2)
    assert(interval.days, equals: -17)
    assert(interval.hours, equals: -7)
    assert(interval.minutes, equals: -46)
    assert(interval.seconds, equals: -10)
    assert(interval.nanoseconds, within: 100, of: -900000000)
    assert(timestamp2 + interval, equals: timestamp1)
  }
  
  //MARK: - Formatting
  
  func testFormatMethodFormatsTime() {
    let timestamp = Timestamp(epochSeconds: 1427459650)
    let formattedString = timestamp.format(TimeFormat.Full)
    assert(formattedString, equals: TimeFormat.Full.format(timestamp))
  }
  
  func testDescriptionGetsDatabaseFormattedTime() {
    let timestamp = Timestamp(epochSeconds: 1427459650)
    let formattedString = timestamp.description
    assert(formattedString, equals: TimeFormat.Database.format(timestamp))
  }
  
  //MARK: - Foundation Support
  
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
  
  func testFreezeMethodFreezesCurrentTime() {
    Timestamp.unfreeze()
    let time1 = Timestamp.now()
    Timestamp.freeze()
    let time2 = Timestamp.now()
    NSThread.sleepForTimeInterval(0.5)
    let time3 = Timestamp.now()
    self.assert(time2, equals: time3)
    Timestamp.unfreeze()
    let time4 = Timestamp.now()
    assert(time4, doesNotEqual: time1)
  }
  
  func testFreezeMethodWithNewValueFreezesAtThatValue() {
    Timestamp.unfreeze()
    let time1 = 30.minutes.ago
    Timestamp.freeze(at: time1)
    let time2 = Timestamp.now()
    assert(time2, equals: time1)
    Timestamp.unfreeze()
    let time3 = Timestamp.now()
    self.assert(time3, doesNotEqual: time1)
  }
  
  //MARK: - Components
  
  func testDateCreatesDateWithDateInformation() {
    let timestamp = Timestamp(epochSeconds: 696737986, timeZone: TimeZone(name: "US/Eastern"))
    let date = timestamp.date
    assert(date.year, equals: 1992)
    assert(date.month, equals: 1)
    assert(date.day, equals: 29)
  }
  
  func testTimeCreatesTimeWithTimeInformation() {
    let timestamp = Timestamp(epochSeconds: 864808163, timeZone: TimeZone(name: "UTC"))
    let time = timestamp.time
    assert(time.hour, equals: 8)
    assert(time.minute, equals: 29)
    assert(time.second, equals: 23)
    assert(time.timeZone.name, equals: "UTC")
  }

  //MARK: - Comparison
  
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
