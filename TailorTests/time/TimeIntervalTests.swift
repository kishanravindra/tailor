import XCTest
import TailorTesting
import Tailor

class TimeIntervalTests: XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
  func testInvertInvertsAllComponents() {
    let interval1 = TimeInterval(years: 1, months: 5, days: -10)
    let interval2 = interval1.invert()
    assert(interval2.years, equals: -1)
    assert(interval2.months, equals: -5)
    assert(interval2.days, equals: 10)
  }
  
  func testCanAddTwoTimeIntervals() {
    let interval1 = TimeInterval(years: 1, months: 5, days: 3)
    let interval2 = TimeInterval(months: 1, days: -2, minutes: 10)
    let interval3 = interval1 + interval2
    assert(interval3.years, equals: 1)
    assert(interval3.months, equals: 6)
    assert(interval3.days, equals: 1)
    assert(interval3.minutes, equals: 10)
  }
  
  func testCanSubtractTwoTimeIntervals() {
    let interval1 = TimeInterval(years: 1, months: 5, days: 3)
    let interval2 = TimeInterval(months: 1, days: -2, minutes: 10)
    let interval3 = interval1 - interval2
    assert(interval3.years, equals: 1)
    assert(interval3.months, equals: 4)
    assert(interval3.days, equals: 5)
    assert(interval3.minutes, equals: -10)
  }
  
  func testCanAddTimeIntervalToTimestamp() {
    let timestamp = Timestamp(epochSeconds: 1431788231, timeZone: TimeZone(name: "UTC"), calendar: GregorianCalendar())
    let result = timestamp + TimeInterval(years: 1, months: 6, days: 20)
    assert(result.year, equals: 2016)
    assert(result.month, equals: 12)
    assert(result.day, equals: 6)
    assert(result.hour, equals: 14)
    assert(result.minute, equals: 57)
    assert(result.second, equals: 11)
  }
  
  func testCanSubtractTimeIntervalFromTimestamp() {
    let timestamp = Timestamp(epochSeconds: 1431788231, timeZone: TimeZone(name: "UTC"), calendar: GregorianCalendar())
    let result = timestamp - TimeInterval(months: 3, days: 20, hours: 5)
    assert(result.year, equals: 2015)
    assert(result.month, equals: 1)
    assert(result.day, equals: 27)
    assert(result.hour, equals: 9)
    assert(result.minute, equals: 57)
    assert(result.second, equals: 11)
  }
  
  func testDescriptionIncludesNonZeroComponents() {
    let interval = TimeInterval(months: 2, days: 1, hours: 14, nanoseconds: 1.25)
    let description = interval.description
    assert(description, equals: "2 months, 1 day, 14 hours, 1.25000 nanoseconds")
  }
  
  func testCanGetIntervalFromIntegerShorthand() {
    assert(5.years, equals: TimeInterval(years: 5))
    assert(11.months, equals: TimeInterval(months: 11))
    assert(20.days, equals: TimeInterval(days: 20))
    assert(3.hours, equals: TimeInterval(hours: 3))
    assert(15.minutes, equals: TimeInterval(minutes: 15))
    assert(30.seconds, equals: TimeInterval(seconds: 30))
    assert(1500.nanoseconds, equals: TimeInterval(nanoseconds: 1500))
    assert(7.5.nanoseconds, equals: TimeInterval(nanoseconds: 7.5))
    assert(1.year, equals: TimeInterval(years: 1))
    assert(1.month, equals: TimeInterval(months: 1))
    assert(1.day, equals: TimeInterval(days: 1))
    assert(1.hour, equals: TimeInterval(hours: 1))
    assert(1.minute, equals: TimeInterval(minutes: 1))
    assert(1.second, equals: TimeInterval(seconds: 1))
    assert(1.nanosecond, equals: TimeInterval(nanoseconds: 1))
    assert(1.0.nanosecond, equals: TimeInterval(nanoseconds: 1))
    assert(1.1.nanoseconds, equals: TimeInterval(nanoseconds: 1.1))
  }
  
  func testFromNowGetsThatIntervalFromCurrentTime() {
    let timestamp1 = Timestamp.now()
    let timestamp2 = (1.hour + 30.minutes).fromNow
    let interval = timestamp2.epochSeconds - timestamp1.epochSeconds
    assert(interval, within: 1, of: 5400)
  }
  
  func testAgoGetsThatIntervalFromCurrentTime() {
    let timestamp1 = Timestamp.now()
    let timestamp2 = 3.hours.ago
    let interval = timestamp2.epochSeconds - timestamp1.epochSeconds
    assert(interval, within: 1, of: -10800)
  }
  
  func testTotalCanGetNumberOfYears() {
    var interval = 2.years + 5.months
    assert(interval.total(.Years), equals: 2)
    interval = interval + 10.months
    assert(interval.total(.Years), equals: 3)
  }
  
  func testTotalCanGetNumberOfMonths() {
    var interval = 2.years + 5.months + 20.days
    assert(interval.total(.Months), equals: 29)
    interval = interval + 20.days
    assert(interval.total(.Months), equals: 30)
  }
  
  func testTotalCanGetNumberOfDays() {
    var interval = 2.years + 5.months + 20.days + 14.hours
    Timestamp.freeze(at: Timestamp(epochSeconds: 1448840916))
    assert(interval.total(.Days), equals: 890)
    interval = interval + 20.hours
    assert(interval.total(.Days), equals: 891)
  }
  
  func testTotalCanGetNumberOfHours() {
    var interval = 2.years + 5.months + 20.days + 14.hours + 35.minutes
    Timestamp.freeze(at: Timestamp(epochSeconds: 1448840916))
    assert(interval.total(.Hours), equals: 21374)
    interval = interval + 40.minutes
    assert(interval.total(.Hours), equals: 21375)
  }
  
  func testTotalCanGetNumberOfMinutes() {
    var interval = 2.years + 5.months + 20.days
    interval = interval + 14.hours + 35.minutes + 17.seconds
    Timestamp.freeze(at: Timestamp(epochSeconds: 1448840916))
    assert(interval.total(.Minutes), equals: 1282475)
    interval = interval + 50.seconds
    assert(interval.total(.Minutes), equals: 1282476)
  }
  
  func testTotalCanGetNumberOfSeconds() {
    var interval = 2.years + 5.months + 20.days
    interval = interval + 14.hours + 35.minutes + 17.seconds + 500000000.nanoseconds
    Timestamp.freeze(at: Timestamp(epochSeconds: 1448840916))
    assert(interval.total(.Seconds), equals: 76948517)
    interval = interval + 600000000.nanoseconds
    assert(interval.total(.Seconds), equals: 76948518)
  }
  
  func testTotalCanGetNumberOfNanoseconds() {
    var interval = 2.years + 5.months + 20.days
    interval = interval + 14.hours + 35.minutes + 17.seconds + 500000000.nanoseconds
    Timestamp.freeze(at: Timestamp(epochSeconds: 1448840916))
    assert(interval.total(.Nanoseconds), equals: 76948517500000000)
  }
}
