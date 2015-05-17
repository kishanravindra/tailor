import XCTest
import TailorTesting
import Tailor

class TimeFormatTests: TailorTestCase {
  var timestampSeconds = 1431788231.0
  var timestamp: Timestamp { return Timestamp(epochSeconds: timestampSeconds, timeZone: TimeZone(name: "UTC")) }
  var formatter: TimeFormatter! = nil
  var formatted: String? { return formatter?.formatTime(timestamp) }
  
  //MARK: - Time Format Components
  
  func testTimeFormatComponentWithLiteralGetsLiteral() {
    formatter = TimeFormatComponent.Literal(" - ")
    assert(formatted, equals: " - ")
  }
  
  func testTimeFormatComponentWithYearGetsFourDigitYear() {
    formatter = TimeFormatComponent.Year
    assert(formatted, equals: "2015")
  }
  
  func testTimeFormatComponentWithSixDigitYearPadsYear() {
    formatter = TimeFormatComponent.YearWith(padding: ":", length: 6, truncate: false)
    assert(formatted, equals: "::2015")
  }
  
  func testFormatComponentWithTwoDigitYearTruncatesYear() {
    formatter = TimeFormatComponent.YearWith(padding: "0", length: 2, truncate: true)
    assert(formatted, equals: "15")
  }
  
  func testFormatComponentWithYearWithNilPaddingDoesNotPadYear() {
    formatter = TimeFormatComponent.YearWith(padding: nil, length: 6, truncate: true)
    assert(formatted, equals: "2015")
  }
  
  func testFormatComponentWithMonthGetsTwoDigitMonth() {
    formatter = TimeFormatComponent.Month
    assert(formatted, equals: "05")
  }
  
  func testFormatComponentWithMonthWithNilPaddingDoesNotPadMonth() {
    formatter = TimeFormatComponent.MonthWith(padding: nil)
    assert(formatted, equals: "5")
  }
  
  func testFormatComponentWithSpacePaddingPadsMonth() {
    formatter = TimeFormatComponent.MonthWith(padding: " ")
    assert(formatted, equals: " 5")
  }
  
  func testFormatComponentWithTwoDigitMonthGetsTwoDigitMonth() {
    timestampSeconds += 86400 * 180
    formatter = TimeFormatComponent.Month
    assert(formatted, equals: "11")
  }
  
  func testFormatComponentWithDayGetsTwoDigitDay() {
    timestampSeconds -= 86400 * 10
    formatter = TimeFormatComponent.Day
    assert(formatted, equals: "06")
  }
  
  func testFormatComponentWithDayWithNilPaddingDoesNotPadDay() {
    timestampSeconds -= 86400 * 10
    formatter = TimeFormatComponent.DayWith(padding: nil)
    assert(formatted, equals: "6")
  }
  
  func testFormatComponentWithDayWithSpacePaddingPadsDay() {
    timestampSeconds -= 86400 * 10
    formatter = TimeFormatComponent.DayWith(padding: " ")
    assert(formatted, equals: " 6")
  }
  
  func testFormatComponentWithTwoDigitDayDoesNotPadDay() {
    formatter = TimeFormatComponent.Day
    assert(formatted, equals: "16")
  }
  
  func testFormatComponentWithHourGets24HourTime() {
    formatter = TimeFormatComponent.Hour
    assert(formatted, equals: "14")
  }
  
  func testFormatComponentWithHourBeforeNoonIsZeroPadded() {
    timestampSeconds -= 3600 * 5
    formatter = TimeFormatComponent.Hour
    assert(formatted, equals: "09")
  }
  
  func testFormatComponentWithHourWithTwelveHourTimeUsesTwelveHourTime() {
    formatter = TimeFormatComponent.HourWith(twelveHour: true, padding: "0")
    assert(formatted, equals: "02")
  }
  
  func testFormatComponentWithHourWithNilPaddingDoesNotPad() {
    formatter = TimeFormatComponent.HourWith(twelveHour: true, padding: nil)
    assert(formatted, equals: "2")
  }
  
  func testFormatComponentWithMinuteGetsTwoDigitMinute() {
    formatter = TimeFormatComponent.Minute
    assert(formatted, equals: "57")
  }
  
  func testFormatComponentWithSecondGetsTwoDigitSecond() {
    formatter = TimeFormatComponent.Seconds
    assert(formatted, equals: "11")
  }
  
  func testFormatComponentWithEpochSecondsGetsFullTimestamp() {
    formatter = TimeFormatComponent.EpochSeconds
    assert(formatted, equals: "1431788231")
  }
  
  func testFormatComponentWIthTimeZoneGetsAbbreviation() {
    formatter = TimeFormatComponent.TimeZone
    assert(formatted, equals: "UTC")
    assert(formatter?.formatTime(timestamp.inTimeZone("US/Eastern")), equals: "EDT")
  }
  
  func testFormatComponentWithTimeZoneOffsetGetsOffset() {
    formatter = TimeFormatComponent.TimeZoneOffset
    assert(formatted, equals: "+0000")
    assert(formatter?.formatTime(timestamp.inTimeZone("US/Eastern")), equals: "-0400")
    assert(formatter?.formatTime(timestamp.inTimeZone("Europe/Rome")), equals: "+0200")
  }
  
  func testFormatComponentWithMeridianGetsAmOrPm() {
    formatter = TimeFormatComponent.Meridian
    assert(formatted, equals: "PM")
    timestampSeconds -= 3600 * 6
    assert(formatted, equals: "AM")
  }
  
  func testFormatWithMultipleComponentsCombinesResults() {
    formatter = TimeFormat(.Year, "-", .Month, " ", .Day)
    assert(formatted, equals: "2015-05 16")
  }
  
  func testFormatWithDatabaseFormatGetsProperFormat() {
    formatter = TimeFormat.Database
    assert(formatted, equals: "2015-05-16 14:57:11 +0000")
  }
  
  func testFormatWithStrftimeUsesStrftimeFormat() {
    let formats = ["%d", "%D", "%e", "%F", "%H", "%I", "%k", "%l", "%M", "%m", "%n", "%p", "%R", "%s", "%S", "%t", "%T", "%y", "%Y", "%z", "%Z", "%%", "%Y-%m-%d", "%I%n%m"]
    var cString = [CChar](count: 1024, repeatedValue: 0)
    let timeZone = TimeZone(name: NSTimeZone.systemTimeZone().name)
    
    for value in [timestampSeconds, timestampSeconds + 3600 * 5] {
      let localTimestamp = Timestamp(epochSeconds: value, timeZone: timeZone)
      var cTime = Int(value)
      var cLocalTime = localtime(&cTime).memory
      
      for format in formats {
        var cFormat = format.cStringUsingEncoding(NSASCIIStringEncoding)!
        strftime(&cString, 1024, &cFormat, &cLocalTime)
        let foundationString = NSString(CString: cString, encoding: NSASCIIStringEncoding)!
        let string = localTimestamp.format(TimeFormat(strftime: format))
        assert(string, equals: foundationString, message: "Got right result for format \(format)")
      }
    }
  }
}