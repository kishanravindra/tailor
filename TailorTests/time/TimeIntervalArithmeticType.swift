@testable import Tailor
import Tailor
import TailorTesting
import XCTest

class TimeIntervalArithmeticType : XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
  func testAdditionAddsInterval() {
    let timestamp1 = Timestamp(year: 2014, month: 3, day: 16, hour: 12, minute: 34, second: 10, nanosecond: 11.5, timeZone: TimeZone(name: "UTC"))
    let timestamp2 = timestamp1 + TimeInterval(years: 1, months: 2, days: 1, hours: 2, minutes: 1, seconds: 2, nanoseconds: 1)
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
  
  func testSubtractionSubtractsInterval() {
    let timestamp1 = Timestamp(year: 2014, month: 3, day: 16, hour: 12, minute: 34, second: 10, nanosecond: 11.5, timeZone: TimeZone(name: "UTC"))
    let timestamp2 = timestamp1 - TimeInterval(years: 1, months: 2, days: 1, hours: 2, minutes: 1, seconds: 2, nanoseconds: 1)
      assert(timestamp2.year, equals: 2013)
      assert(timestamp2.month, equals: 1)
      assert(timestamp2.day, equals: 15)
      assert(timestamp2.hour, equals: 10)
      assert(timestamp2.minute, equals: 33)
      assert(timestamp2.second, equals: 8)
      assert(timestamp2.nanosecond, equals: 10.5)
      assert(timestamp2.weekDay, equals: 3)
      assert(timestamp2.epochSeconds, equals: 1358245988.0)
  }
  
  func testSubtractionBetweenTimestampsGetsIntervalBetweenTimestamps() {
    let timestamp1 = Timestamp(epochSeconds: 1770009956, timeZone: TimeZone(name: "UTC"), calendar: GregorianCalendar())
    let timestamp2 = Timestamp(epochSeconds: 1733629141, timeZone: TimeZone(name: "UTC"), calendar: GregorianCalendar())
    let interval = timestamp1 - timestamp2
    assert(interval.years, equals: 1)
    assert(interval.months, equals: 1)
    assert(interval.days, equals: 25)
    assert(interval.hours, equals: 1)
    assert(interval.minutes, equals: 46)
    assert(interval.seconds, equals: 55)
    assert(timestamp2 + interval, equals: timestamp1)
  }
}