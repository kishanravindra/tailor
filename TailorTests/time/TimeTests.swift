import Tailor
import TailorTesting
import XCTest

class TimeTests: XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
  func testTimesAreEqualWithSameInfo() {
    let time1 = Time(hour: 17, minute: 22, second: 15, nanosecond: 1.5)
    let time2 = Time(hour: 17, minute: 22, second: 15, nanosecond: 1.5)
    assert(time1 == time2)
  }
  
  func testTimesWithDifferentHoursAreUnequal() {
    let time1 = Time(hour: 17, minute: 22, second: 15, nanosecond: 1.5)
    let time2 = Time(hour: 13, minute: 22, second: 15, nanosecond: 1.5)
    assert(time1 != time2)
  }
  
  func testTimesWithDifferentMinutesAreUnequal() {
    let time1 = Time(hour: 17, minute: 20, second: 15, nanosecond: 1.5)
    let time2 = Time(hour: 17, minute: 22, second: 15, nanosecond: 1.5)
    assert(time1 != time2)
  }
  
  func testTimesWithDifferentSecondsAreUnequal() {
    let time1 = Time(hour: 17, minute: 22, second: 15, nanosecond: 1.5)
    let time2 = Time(hour: 17, minute: 22, second: 10, nanosecond: 1.5)
    assert(time1 != time2)
  }
  
  func testTimesWithDifferentNanosecondsAreUnequal() {
    let time1 = Time(hour: 17, minute: 22, second: 15, nanosecond: 1.5)
    let time2 = Time(hour: 17, minute: 22, second: 15, nanosecond: 1.0)
    assert(time1 != time2)
  }
  
  func testTimesWithDifferentTimeZonesAreUnequal() {
    let time1 = Time(hour: 17, minute: 22, second: 15, nanosecond: 1.5, timeZone: TimeZone(name: "US/Eastern"))
    let time2 = Time(hour: 17, minute: 22, second: 15, nanosecond: 1.5, timeZone: TimeZone(name: "US/Pacific"))
    assert(time1 != time2)
  }
  
  func testTimeIsLessThanTimeWithLargerHour() {
    let time1 = Time(hour: 17, minute: 22, second: 15, nanosecond: 1.5)
    let time2 = Time(hour: 18, minute: 22, second: 15, nanosecond: 1.5)
    assert(time1 < time2)
    assert(!(time2 < time1))
  }
  
  func testTimeIsLessThanTimeWithLargerMinute() {
    let time1 = Time(hour: 17, minute: 22, second: 15, nanosecond: 1.5)
    let time2 = Time(hour: 17, minute: 23, second: 15, nanosecond: 1.5)
    assert(time1 < time2)
    assert(!(time2 < time1))
  }
  
  func testTimeIsLessThanTimeWithLargerSecond() {
    let time1 = Time(hour: 17, minute: 22, second: 15, nanosecond: 1.5)
    let time2 = Time(hour: 17, minute: 22, second: 20, nanosecond: 1.5)
    assert(time1 < time2)
    assert(!(time2 < time1))
  }
  
  func testTimeIsLessThanTimeWithLargerNanoecond() {
    let time1 = Time(hour: 17, minute: 22, second: 15, nanosecond: 1.5)
    let time2 = Time(hour: 17, minute: 22, second: 15, nanosecond: 2.5)
    assert(time1 < time2)
    assert(!(time2 < time1))
  }
  
  func testTimeIsLessThanTimeWithLargerHourButSmallerSecond() {
    let time1 = Time(hour: 17, minute: 22, second: 15, nanosecond: 1.5)
    let time2 = Time(hour: 19, minute: 20, second: 15, nanosecond: 1.5)
    assert(time1 < time2)
    assert(!(time2 < time1))
  }
  
  func testTimeIsLessThanTimeWithLargerMinuteButSmallerSecond() {
    let time1 = Time(hour: 17, minute: 22, second: 15, nanosecond: 1.5)
    let time2 = Time(hour: 17, minute: 25, second: 10, nanosecond: 1.5)
    assert(time1 < time2)
    assert(!(time2 < time1))
  }
  
  func testTodayGetsCurrentDateWithSpecifiedTime() {
    let time = Time(hour: 13, minute: 55, second: 39, nanosecond: 23)
    let timestamp = time.today
    let currentTime = Timestamp.now()
    assert(timestamp.year, equals: currentTime.year)
    assert(timestamp.month, equals: currentTime.month)
    assert(timestamp.day, equals: currentTime.day)
    assert(timestamp.hour, equals: time.hour)
    assert(timestamp.minute, equals: time.minute)
    assert(timestamp.second, equals: time.second)
    assert(timestamp.nanosecond, equals: time.nanosecond)
  }
  
  func testDescriptionGetsDescription() {
    let time1 = Time(hour: 17, minute: 22, second: 15, nanosecond: 1.5, timeZone: TimeZone(name: "US/Eastern"))
    assert(time1.description, equals: "17:22:15 US/Eastern")
  }
  
  func testOClockGetsTimePastHour() {
    let time = 8.oClock(17)
    assert(time.hour, equals: 8)
    assert(time.minute, equals: 17)
    assert(time.second, equals: 0)
    assert(time.nanosecond, equals: 0)
  }
  
  func testThirtyGetsTimePastHour() {
    let time = 14.thirty
    assert(time.hour, equals: 14)
    assert(time.minute, equals: 30)
    assert(time.second, equals: 0)
    assert(time.nanosecond, equals: 0)
  }
  
  //MARK: - Time Intervals
  
  func testAddingIntervalCanAddSimpleInterval() {
    let time = Time(hour: 14, minute: 15, second: 39, nanosecond: 15)
    let time2 = time.byAddingInterval(TimeInterval(days: 10, hours: 3, minutes: 20, seconds: 5, nanoseconds: 40))
    assert(time2.hour, equals: 17)
    assert(time2.minute, equals: 35)
    assert(time2.second, equals: 44)
    assert(time2.nanosecond, equals: 55)
  }
  
  func testAddingIntervalCanRollOverIntervals() {
    let time = Time(hour: 14, minute: 15, second: 39, nanosecond: 15)
    let time2 = time.byAddingInterval(TimeInterval(hours: 10, minutes: 70, seconds: 150))
    assert(time2.hour, equals: 1)
    assert(time2.minute, equals: 28)
    assert(time2.second, equals: 9)
    assert(time2.nanosecond, equals: 15)
  }
  
  func testAddingIntervalCanHandleNegativeInterval() {
    let time = Time(hour: 14, minute: 15, second: 39, nanosecond: 15)
    let time2 = time.byAddingInterval(TimeInterval(days: 10, hours: 3, minutes: 20, seconds: 5, nanoseconds: 40).invert())
    assert(time2.hour, equals: 10)
    assert(time2.minute, equals: 55)
    assert(time2.second, equals: 33)
    assert(time2.nanosecond, equals: 999999975.0)
  }
  
  func testIntervalSinceCanGetPositiveInterval() {
    let time1 = Time(hour: 14, minute: 15, second: 39, nanosecond: 15)
    let time2 = Time(hour: 12, minute: 4, second: 18, nanosecond: 3)
    let interval = time1.intervalSince(time2)
    assert(interval.days, equals: 0)
    assert(interval.hours, equals: 2)
    assert(interval.minutes, equals: 11)
    assert(interval.seconds, equals: 21)
    assert(interval.nanoseconds, equals: 12)
  }
  
  func testIntervalSinceCanGetMixedInterval() {
    let time1 = Time(hour: 14, minute: 15, second: 39, nanosecond: 15)
    let time2 = Time(hour: 12, minute: 44, second: 33, nanosecond: 19)
    let interval = time1.intervalSince(time2)
    assert(interval.days, equals: 0)
    assert(interval.hours, equals: 1)
    assert(interval.minutes, equals: 31)
    assert(interval.seconds, equals: 5)
    assert(interval.nanoseconds, equals: 999999996)
  }
  
  func testIntervalSinceCanGetNegativeInterval() {
    let time1 = Time(hour: 14, minute: 15, second: 39, nanosecond: 15)
    let time2 = Time(hour: 15, minute: 44, second: 33, nanosecond: 19)
    let interval = time1.intervalSince(time2)
    assert(interval.days, equals: 0)
    assert(interval.hours, equals: -1)
    assert(interval.minutes, equals: -28)
    assert(interval.seconds, equals: -54)
    assert(interval.nanoseconds, equals: -4)
  }
  
  func testTimeSupportsArithmeticOperators() {
    let time = Time(hour: 14, minute: 15, second: 39, nanosecond: 15)
    let time2 = time + 2.hours + 4.minutes
    assert(time2.hour, equals: 16)
    assert(time2.minute, equals: 19)
    
    let interval = time2 - time
    assert(interval.hours, equals: 2)
    assert(interval.minutes, equals: 4)
    assert(interval.seconds, equals: 0)
  }
}
