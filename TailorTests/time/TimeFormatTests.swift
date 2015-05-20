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
  
  func testFormatComponentWithMonthNameGetsFullName() {
    timestampSeconds += 86400 * 30
    formatter = TimeFormatComponent.MonthName(abbreviate: false)
    assert(formatted, equals: "June")
  }
  
  func testFormatComponentWithAbbreviateMonthNameGetsAbbreviatedName() {
    timestampSeconds += 86400 * 30
    formatter = TimeFormatComponent.MonthName(abbreviate: true)
    assert(formatted, equals: "Jun")
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
  
  func testFormatComponentWithWeekDayGetsWeekDay() {
    formatter = TimeFormatComponent.WeekDay
    assert(formatted, equals: "7")
  }
  
  func testFormatComponentWithWeekDayNameGetsFullName() {
    formatter = TimeFormatComponent.WeekDayName(abbreviate: false)
    assert(formatted, equals: "Saturday")
  }
  
  func testFormatComponentWithAbbreviatedWeekDayNameGetsAbbreviatedName() {
    formatter = TimeFormatComponent.WeekDayName(abbreviate: true)
    assert(formatted, equals: "Sat")
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
    assert(formatted, equals: "2015-05-16 14:57:11")
  }
  
  func testFormatWithCookieFormatGetsProperFormat() {
    let timestamp = Timestamp(epochSeconds: 1418729233, timeZone: TimeZone(name: "UTC"))
    let formatted = TimeFormat.Cookie.formatTime(timestamp)
    assert(formatted, equals: "Tue, 16 Dec 2014 11:27:13 UTC", message: "formats string using cookie date format")
  }
  
  func testFormatWithFullFormatGetsHumanReadableDateAndTime() {
    let timestamp = Timestamp(epochSeconds: 1157469107, timeZone: TimeZone(name: "UTC"))
    let formatted = TimeFormat.Full.formatTime(timestamp)
    assert(formatted, equals: "5 September, 2006, 15:11:47 UTC")
  }
  
  func testFormatWithFullUsGetsHumanReadableDateAndTime() {
    let timestamp = Timestamp(epochSeconds: 1684782968, timeZone: TimeZone(name: "UTC"))
    let formatted = TimeFormat.FullUS.formatTime(timestamp)
    assert(formatted, equals: "May 22, 2023, 7:16:08 PM UTC")
  }
  
  func testFormatWithFullDateGetsHumanReadableDate() {
    let timestamp = Timestamp(epochSeconds: 1383010760, timeZone: TimeZone(name: "UTC"))
    let formatted = TimeFormat.FullDate.formatTime(timestamp)
    assert(formatted, equals: "29 October, 2013")
  }
  
  func testFormatWithFullDateUsGetsHumanReadableDate() {
    let timestamp = Timestamp(epochSeconds: 803301470, timeZone: TimeZone(name: "UTC"))
    let formatted = TimeFormat.FullDateUS.formatTime(timestamp)
    assert(formatted, equals: "June 16, 1995")
  }
  
  func testFormatWithFullTimeGetsHumanReadableTime() {
    let timestamp = Timestamp(epochSeconds: 1526472439, timeZone: TimeZone(name: "UTC"))
    let formatted = TimeFormat.FullTime.formatTime(timestamp)
    assert(formatted, equals: "12:07:19 UTC")
  }
  
  func testFormatWithFullTimeUsGetsHumanReadableTime() {
    let timestamp = Timestamp(epochSeconds: 1377257661, timeZone: TimeZone(name: "UTC"))
    let formatted = TimeFormat.FullTimeUS.formatTime(timestamp)
    assert(formatted, equals: "11:34:21 AM UTC")
  }
  
  func testFormatWithStrftimeUsesStrftimeFormat() {
    let formats = ["%A", "%a", "%B", "%b", "%d", "%D", "%e", "%F", "%G", "%g", "%h", "%H", "%I", "%k", "%l", "%M", "%m", "%n", "%p", "%r", "%R", "%s", "%S", "%t", "%T", "%v", "%y", "%Y", "%z", "%Z", "%%", "%Y-%m-%d", "%I%n%m"]
    var cString = [CChar](count: 1024, repeatedValue: 0)
    let timeZone = TimeZone(name: NSTimeZone.systemTimeZone().name)
    
    for value in [timestampSeconds, timestampSeconds + 3600 * 5, timestampSeconds + 3600 * 24 * 180] {
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
  
  //MARK: - Parsing
  
  var timeComponents = (year: 0, month: 0, day: 0, hour: 0, minute: 0, second: 0, nanosecond: 0.0)
  let calendar = GregorianCalendar()
  
  func testParseTimeComponentWithLiteralComponentLeavesTimeAlone() {
    formatter = TimeFormatComponent.Literal("Hello")
    let result = formatter.parseTime(from: "Hello, World", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: ", World")
  }
  
  func testParseTimeComponentWithFullMatchReturnsEmptyString() {
    formatter = TimeFormatComponent.Literal("Hello")
    let result = formatter.parseTime(from: "Hello", into: &timeComponents, calendar: calendar)
    assert(result, equals: "")
  }
  
  func testParseTimeComponentWithLiteralComponentWithNonMatchingStringReturnsNil() {
    formatter = TimeFormatComponent.Literal("Hello")
    let result = formatter.parseTime(from: "Goodbye, World", into: &timeComponents, calendar: calendar)
    assert(isNil: result)
  }
  
  func testParseTimeComponentWithYearGetsYear() {
    formatter = TimeFormatComponent.YearWith(padding: "0", length: 4, truncate: false)
    let result = formatter.parseTime(from: "2010-", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 2010)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: "-")
  }
  
  func testParseTimeComponentWithYearWithPaddingGetsYear() {
    formatter = TimeFormatComponent.YearWith(padding: "_", length: 4, truncate: false)
    let result = formatter.parseTime(from: "__99_", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 99)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: "_")
  }
  
  func testParseTimeComponentWithNonNumericCharacterReturnsNil() {
    formatter = TimeFormatComponent.YearWith(padding: "0", length: 4, truncate: false)
    let result = formatter.parseTime(from: "Wednesday", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(isNil: result)
  }
  
  func testParseTimeComponentWithMonthGetsMonth() {
    formatter = TimeFormatComponent.MonthWith(padding: "0")
    let result = formatter.parseTime(from: "123", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 12)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: "3")
  }
  
  func testParseTimeComponentWithPaddedMonthGetsMonth() {
    formatter = TimeFormatComponent.MonthWith(padding: " ")
    let result = formatter.parseTime(from: " 3-", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 3)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: "-")
  }
  
  func testParseTimeComponentWithNonNumericValueIsNil() {
    formatter = TimeFormatComponent.MonthWith(padding: "0")
    let result = formatter.parseTime(from: "bad", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(isNil: result)
  }
  
  func testParseTimeComponentWithMonthNameGetsMonth() {
    formatter = TimeFormatComponent.MonthName(abbreviate: false)
    let result = formatter.parseTime(from: "November 3", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 11)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: " 3")
  }
  
  func testParseTimeComponentWithAbbreviatedMonthNameGetsMonth() {
    formatter = TimeFormatComponent.MonthName(abbreviate: true)
    let result = formatter.parseTime(from: "December 3", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 12)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: "ember 3")
  }
  
  func testParseTimeComponentWithInvalidMonthNameIsNil() {
    formatter = TimeFormatComponent.MonthName(abbreviate: true)
    let result = formatter.parseTime(from: "Wednesday", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(isNil: result)
  }
  
  func testParseTimeComponentWithDayGetsDay() {
    formatter = TimeFormatComponent.DayWith(padding: "0")
    let result = formatter.parseTime(from: "23-12", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 23)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: "-12")
  }
  
  func testParseTimeComponentWithPaddedDayGetsDay() {
    formatter = TimeFormatComponent.DayWith(padding: " ")
    let result = formatter.parseTime(from: " 3-12", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 3)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: "-12")
  }
  
  func testParseTimeComponentWithInvalidDayIsNil() {
    formatter = TimeFormatComponent.DayWith(padding: " ")
    let result = formatter.parseTime(from: "Test", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(isNil: result)
  }
  
  func testParseTimeWith24HourTimeGetsHour() {
    formatter = TimeFormatComponent.HourWith(twelveHour: false, padding: "0")
    let result = formatter.parseTime(from: "13:45", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 13)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: ":45")
  }
  
  func testParseTimeWithPaddedHourTimeGetsHour() {
    formatter = TimeFormatComponent.HourWith(twelveHour: false, padding: "0")
    let result = formatter.parseTime(from: "01:45", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 1)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: ":45")
  }
  
  func testParseTimeWithTwelveHourTimeGetsHour() {
    formatter = TimeFormatComponent.HourWith(twelveHour: true, padding: "0")
    let result = formatter.parseTime(from: "11:45", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 11)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: ":45")
  }
  
  func testParseTimeWithMonthWithInvalidTextReturnsNil() {
    formatter = TimeFormatComponent.HourWith(twelveHour: true, padding: "0")
    let result = formatter.parseTime(from: "twelve o'clock", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(isNil: result)
  }
  
  func testParseTimeWithMinuteGetsMinute() {
    formatter = TimeFormatComponent.Minute
    let result = formatter.parseTime(from: "37 T", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 37)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: " T")
  }
  
  func testParseTimeWithPaddedMinuteGetsMinute() {
    formatter = TimeFormatComponent.Minute
    let result = formatter.parseTime(from: "07 T", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 7)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: " T")
  }
  
  func testParseTimeWithMinuteWithInvalidTextReturnsNil() {
    formatter = TimeFormatComponent.Minute
    let result = formatter.parseTime(from: "forty", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(isNil: result)
  }
  
  func testParseTimeWithSecondGetsSecond() {
    formatter = TimeFormatComponent.Seconds
    let result = formatter.parseTime(from: "37 T", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 37)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: " T")
  }
  
  func testParseTimeWithPaddedSecondGetsSecond() {
    formatter = TimeFormatComponent.Seconds
    let result = formatter.parseTime(from: "07 T", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 7)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: " T")
  }
  
  func testParseTimeWithSecondWithInvalidTextReturnsNil() {
    formatter = TimeFormatComponent.Seconds
    let result = formatter.parseTime(from: "forty", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(isNil: result)
  }
  
  func testParseTimeWithWeekdayWithNumberTextDoesNotChangeTime() {
    formatter = TimeFormatComponent.WeekDay
    let result = formatter.parseTime(from: "1 2", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: " 2")
  }
  
  func testParseTimeWithWeekDayWithInvalidTextReturnsNil() {
    formatter = TimeFormatComponent.WeekDay
    let result = formatter.parseTime(from: "January", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(isNil: result)
  }
  
  func testParseTimeWithWeekDayNameWithValidNameDoesNotChangeTime() {
    formatter = TimeFormatComponent.WeekDayName(abbreviate: false)
    let result = formatter.parseTime(from: "Wednesday at noon", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: " at noon")
  }
  
  func testParseTimeWithWeekDayNameWithInvalidNameReturnsNil() {
    formatter = TimeFormatComponent.WeekDayName(abbreviate: false)
    let result = formatter.parseTime(from: "January", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(isNil: result)
  }
  
  func testParseTimeWithWeekDayNameWithAbbreviatedNameOnlyConsumesAbbreviatedName() {
    formatter = TimeFormatComponent.WeekDayName(abbreviate: true)
    let result = formatter.parseTime(from: "Wednesday", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: "nesday")
  }
  
  func testParseTimeWithTimeZoneDoesNotModifyTime() {
    formatter = TimeFormatComponent.TimeZone
    let result = formatter.parseTime(from: "EST ", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: " ")
  }
  
  func testParseTimeWithTimeZoneWithUnderThreeCharactersReturnsEmptyString() {
    formatter = TimeFormatComponent.TimeZone
    let result = formatter.parseTime(from: "ES", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: "")
  }
  
  func testParseTimeWithTimeZoneOffsetDoesNotModifyTime() {
    formatter = TimeFormatComponent.TimeZoneOffset
    let result = formatter.parseTime(from: "+03:00 Z", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: " Z")
  }
  
  func testParseTimeWithNegativeTimeZoneOffsetDoesNotModifyTime() {
    formatter = TimeFormatComponent.TimeZoneOffset
    let result = formatter.parseTime(from: "-04:00 Z", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: " Z")
  }
  
  func testParseTimeWithTimeZoneOffsetWithInvalidOffsetReturnsNil() {
    formatter = TimeFormatComponent.TimeZoneOffset
    let result = formatter.parseTime(from: "+0300", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(isNil: result)
  }
  
  func testParseTimeWithTimeZoneOffsetWithBadStringReturnsNil() {
    formatter = TimeFormatComponent.TimeZoneOffset
    let result = formatter.parseTime(from: "badstring", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(isNil: result)
  }
  
  func testParseTimeWithMeridianWithAMLeavesHourIntact() {
    timeComponents.hour = 11
    formatter = TimeFormatComponent.Meridian
    let result = formatter.parseTime(from: "AM Z", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 11)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: " Z")
  }
  
  func testParseTimeWithMeridianWithPMAddsTwelveToHour() {
    timeComponents.hour = 11
    formatter = TimeFormatComponent.Meridian
    let result = formatter.parseTime(from: "PM Z", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 23)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: " Z")
  }
  
  func testParseTimeWithMeridianWithBadMeridianReturnsNil() {
    timeComponents.hour = 11
    formatter = TimeFormatComponent.Meridian
    let result = formatter.parseTime(from: "FM Z", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 11)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(isNil: result)
  }
  
  func testParseTimeWithMultipleComponentsParsesAllComponents() {
    formatter = TimeFormat(.Year, "-", .Month, "-", .Day)
    let result = formatter.parseTime(from: "2015-05-12 00:00:00", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 2015)
    assert(timeComponents.month, equals: 5)
    assert(timeComponents.day, equals: 12)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: " 00:00:00")
  }
  
  func testParseTimeWithMultipleComponentsWithMissingComponentsReturnsNil() {
    formatter = TimeFormat(.Year, "-", .Month, "-", .Day)
    let result = formatter.parseTime(from: "2015-May-12 00:00:00", into: &timeComponents, calendar: calendar)
    assert(timeComponents.year, equals: 2015)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(isNil: result)
  }
  
  func testParseTimeToTimestampBuildsTimestamp() {
    let formatter = TimeFormat(.Year, "-", .Month, "-", .Day, " ", .Hour, ":", .Minute, ":", .Seconds)
    let zone = TimeZone(name: "UTC")
    let result = formatter.parseTime("2015-05-12 15:23:11", timeZone: zone, calendar: GregorianCalendar())
    assert(result?.epochSeconds, equals: 1431444191)
    assert(result?.year, equals: 2015)
    assert(result?.month, equals: 5)
    assert(result?.day, equals: 12)
    assert(result?.hour, equals: 15)
    assert(result?.minute, equals: 23)
    assert(result?.second, equals: 11)
  }
  
  func testParseTimeToTimestampWithInvalidStringReturnsNil() {
    let formatter = TimeFormat(.Year, "-", .Month, "-", .Day, " ", .Hour, ":", .Minute, ":", .Seconds)
    let result = formatter.parseTime("2015-May-12 00:00:00")
    assert(isNil: result)
  }
  
  func testParseTimeWithDatabaseFormatCanParseValidTime() {
    let formatter = TimeFormat.Database
    let result = formatter.parseTime("1996-11-12 05:26:09")
    assert(result?.epochSeconds, equals: 847776369)
    assert(result?.year, equals: 1996)
    assert(result?.month, equals: 11)
    assert(result?.day, equals: 12)
    assert(result?.hour, equals: 5)
    assert(result?.minute, equals: 26)
    assert(result?.second, equals: 9)
  }
  
  func testParseTimeWithCookieFormatCanParseValidTime() {
    let formatter = TimeFormat.Cookie
    let result = formatter.parseTime("Fri, 21 Dec 2001 23:11:51 GMT")
    assert(result?.epochSeconds, equals: 1008976311)
    assert(result?.year, equals: 2001)
    assert(result?.month, equals: 12)
    assert(result?.day, equals: 21)
    assert(result?.hour, equals: 23)
    assert(result?.minute, equals: 11)
    assert(result?.second, equals: 51)
  }
}