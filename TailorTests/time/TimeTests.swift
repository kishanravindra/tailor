import Tailor
import TailorTesting

class TimeTests: TailorTestCase {
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
  
  func testTimeGetsDescription() {
    let time1 = Time(hour: 17, minute: 22, second: 15, nanosecond: 1.5, timeZone: TimeZone(name: "US/Eastern"))
    assert(time1.description, equals: "17:22:15 US/Eastern")
  }
}
