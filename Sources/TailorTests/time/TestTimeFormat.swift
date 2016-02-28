import XCTest
import TailorTesting
import Tailor
import Foundation

final class TestTimeFormat: XCTestCase, TailorTestable {
  var timestampSeconds = 1431788231.0
  var timestamp: Timestamp { return Timestamp(epochSeconds: timestampSeconds, timeZone: TimeZone(name: "UTC")) }
  var formatter: TimeFormatter! = nil
  
  var formatted: String? { return formatter?.format(timestamp) }
  
  @available(*, deprecated)
  var allTests: [(String, () throws -> Void)] { return [
    ("testTimeFormatComponentWithLiteralGetsLiteral", testTimeFormatComponentWithLiteralGetsLiteral),
    ("testTimeFormatComponentWithYearGetsFourDigitYear", testTimeFormatComponentWithYearGetsFourDigitYear),
    ("testTimeFormatComponentWithSixDigitYearPadsYear", testTimeFormatComponentWithSixDigitYearPadsYear),
    ("testFormatComponentWithTwoDigitYearTruncatesYear", testFormatComponentWithTwoDigitYearTruncatesYear),
    ("testFormatComponentWithYearWithNilPaddingDoesNotPadYear", testFormatComponentWithYearWithNilPaddingDoesNotPadYear),
    ("testFormatComponentWithMonthGetsTwoDigitMonth", testFormatComponentWithMonthGetsTwoDigitMonth),
    ("testFormatComponentWithMonthWithNilPaddingDoesNotPadMonth", testFormatComponentWithMonthWithNilPaddingDoesNotPadMonth),
    ("testFormatComponentWithSpacePaddingPadsMonth", testFormatComponentWithSpacePaddingPadsMonth),
    ("testFormatComponentWithMonthNameGetsFullName", testFormatComponentWithMonthNameGetsFullName),
    ("testFormatComponentWithAbbreviateMonthNameGetsAbbreviatedName", testFormatComponentWithAbbreviateMonthNameGetsAbbreviatedName),
    ("testFormatComponentsWithMonthNameWithUntranslatedMonthGetsEnglishMonthName", testFormatComponentsWithMonthNameWithUntranslatedMonthGetsEnglishMonthName),
    ("testFormatComponentsWithAbbreviatedMonthNameWithUntranslatedMonthGetsEnglishMonthName", testFormatComponentsWithAbbreviatedMonthNameWithUntranslatedMonthGetsEnglishMonthName),
    ("testFormatComponentsWithMonthNameWithUntranslatedIslamicMonthGetsDefaultMonthName", testFormatComponentsWithMonthNameWithUntranslatedIslamicMonthGetsDefaultMonthName),
    ("testFormatComponentsWithMonthNameWithUntranslateHebrewMonthGetsDefaultMonthName", testFormatComponentsWithMonthNameWithUntranslateHebrewMonthGetsDefaultMonthName),
    ("testFormatComponentsWithMonthNameWithUntranslateHebrewLeapMonthGetsDefaultMonthName", testFormatComponentsWithMonthNameWithUntranslateHebrewLeapMonthGetsDefaultMonthName),
    ("testFormatComponentsWithMonthNameBeyondBoundsGetsMonthNumber", testFormatComponentsWithMonthNameBeyondBoundsGetsMonthNumber),
    ("testFormatComponentWithTwoDigitMonthGetsTwoDigitMonth", testFormatComponentWithTwoDigitMonthGetsTwoDigitMonth),
    ("testFormatComponentWithDayGetsTwoDigitDay", testFormatComponentWithDayGetsTwoDigitDay),
    ("testFormatComponentWithDayWithNilPaddingDoesNotPadDay", testFormatComponentWithDayWithNilPaddingDoesNotPadDay),
    ("testFormatComponentWithDayWithSpacePaddingPadsDay", testFormatComponentWithDayWithSpacePaddingPadsDay),
    ("testFormatComponentWithTwoDigitDayDoesNotPadDay", testFormatComponentWithTwoDigitDayDoesNotPadDay),
    ("testFormatComponentWithHourGets24HourTime", testFormatComponentWithHourGets24HourTime),
    ("testFormatComponentWithHourBeforeNoonIsZeroPadded", testFormatComponentWithHourBeforeNoonIsZeroPadded),
    ("testFormatComponentWithHourWithTwelveHourTimeUsesTwelveHourTime", testFormatComponentWithHourWithTwelveHourTimeUsesTwelveHourTime),
    ("testFormatComponentWithHourWithTwelveHourTimeWithZeroUses12", testFormatComponentWithHourWithTwelveHourTimeWithZeroUses12),
    ("testFormatComponentWithHourWithNilPaddingDoesNotPad", testFormatComponentWithHourWithNilPaddingDoesNotPad),
    ("testFormatComponentWithMinuteGetsTwoDigitMinute", testFormatComponentWithMinuteGetsTwoDigitMinute),
    ("testFormatComponentWithSecondGetsTwoDigitSecond", testFormatComponentWithSecondGetsTwoDigitSecond),
    ("testFormatComponentWithWeekDayGetsWeekDay", testFormatComponentWithWeekDayGetsWeekDay),
    ("testFormatComponentWithWeekDayNameGetsFullName", testFormatComponentWithWeekDayNameGetsFullName),
    ("testFormatComponentsWithWeekDayNameWithUntranslatedNameGetsEnglishName", testFormatComponentsWithWeekDayNameWithUntranslatedNameGetsEnglishName),
    ("testFormatComponentWithAbbreviatedWeekDayNameGetsAbbreviatedName", testFormatComponentWithAbbreviatedWeekDayNameGetsAbbreviatedName),
    ("testFormatComponentsWithAbbreviatedWeekDayNameWithUntranslatedNameGetsEnglishName", testFormatComponentsWithAbbreviatedWeekDayNameWithUntranslatedNameGetsEnglishName),
    ("testFormatComponentsWithAbbreviatedWeekDayNameWithDayOutsideBoundsGetsDayNumber", testFormatComponentsWithAbbreviatedWeekDayNameWithDayOutsideBoundsGetsDayNumber),
    ("testFormatComponentWithEpochSecondsGetsFullTimestamp", testFormatComponentWithEpochSecondsGetsFullTimestamp),
    ("testFormatComponentWithTimeZoneGetsAbbreviation", testFormatComponentWithTimeZoneGetsAbbreviation),
    ("testFormatComponentWithTimeZoneOffsetGetsOffset", testFormatComponentWithTimeZoneOffsetGetsOffset),
    ("testFormatComponentWithMeridianGetsAmOrPm", testFormatComponentWithMeridianGetsAmOrPm),
    ("testFormatWithMultipleComponentsCombinesResults", testFormatWithMultipleComponentsCombinesResults),
    ("testFormatWithMultipleComponentsWithOldMethodCombinesResults", testFormatWithMultipleComponentsWithOldMethodCombinesResults),
    ("testFormatWithDatabaseFormatGetsProperFormat", testFormatWithDatabaseFormatGetsProperFormat),
    ("testFormatDateWithDatabaseFormatGetsProperFormat", testFormatDateWithDatabaseFormatGetsProperFormat),
    ("testFormatTimeWithDatabaseFormatGetsProperFormat", testFormatTimeWithDatabaseFormatGetsProperFormat),
    ("testFormatWithCookieFormatGetsProperFormat", testFormatWithCookieFormatGetsProperFormat),
    ("testFormatWithFullFormatGetsHumanReadableDateAndTime", testFormatWithFullFormatGetsHumanReadableDateAndTime),
    ("testFormatWithFullUsGetsHumanReadableDateAndTime", testFormatWithFullUsGetsHumanReadableDateAndTime),
    ("testFormatWithFullDateGetsHumanReadableDate", testFormatWithFullDateGetsHumanReadableDate),
    ("testFormatWithFullDateUsGetsHumanReadableDate", testFormatWithFullDateUsGetsHumanReadableDate),
    ("testFormatWithFullTimeGetsHumanReadableTime", testFormatWithFullTimeGetsHumanReadableTime),
    ("testFormatWithFullTimeUsGetsHumanReadableTime", testFormatWithFullTimeUsGetsHumanReadableTime),
    ("testFormatWithRfc2822GetsProperFormat", testFormatWithRfc2822GetsProperFormat),
    ("testFormatWithStrftimeUsesStrftimeFormat", testFormatWithStrftimeUsesStrftimeFormat),
    ("testFormatWithStrftimeWithUnsupportedComponentsIsEmpty", testFormatWithStrftimeWithUnsupportedComponentsIsEmpty),
    ("testFormatWithStringLiteralIsLiteral", testFormatWithStringLiteralIsLiteral),
    ("testFormatWithUnicodeScalarLiteralIsLiteral", testFormatWithUnicodeScalarLiteralIsLiteral),
    ("testFormatWithExtendedGraphemeLiteralIsLiteral", testFormatWithExtendedGraphemeLiteralIsLiteral),
    ("testParseTimeComponentWithLiteralComponentLeavesTimeAlone", testParseTimeComponentWithLiteralComponentLeavesTimeAlone),
    ("testParseTimeComponentWithFullMatchReturnsEmptyString", testParseTimeComponentWithFullMatchReturnsEmptyString),
    ("testParseTimeComponentWithLiteralComponentWithNonMatchingStringReturnsNil", testParseTimeComponentWithLiteralComponentWithNonMatchingStringReturnsNil),
    ("testParseTimeComponentWithYearGetsYear", testParseTimeComponentWithYearGetsYear),
    ("testParseTimeComponentWithYearWithPaddingGetsYear", testParseTimeComponentWithYearWithPaddingGetsYear),
    ("testParseTimeComponentWithYearWithNonNumericCharacterReturnsNil", testParseTimeComponentWithYearWithNonNumericCharacterReturnsNil),
    ("testParseTimeComponentWithYearWithTooFewCharactersReturnsNil", testParseTimeComponentWithYearWithTooFewCharactersReturnsNil),
    ("testParseTimeComponentWithTwoDigitYearPutsYearIn1900s", testParseTimeComponentWithTwoDigitYearPutsYearIn1900s),
    ("testParseTimeComponentWithMonthGetsMonth", testParseTimeComponentWithMonthGetsMonth),
    ("testParseTimeComponentWithPaddedMonthGetsMonth", testParseTimeComponentWithPaddedMonthGetsMonth),
    ("testParseTimeComponentWithNonNumericValueIsNil", testParseTimeComponentWithNonNumericValueIsNil),
    ("testParseTimeComponentWithMonthNameGetsMonth", testParseTimeComponentWithMonthNameGetsMonth),
    ("testParseTimeComponentWithAbbreviatedMonthNameGetsMonth", testParseTimeComponentWithAbbreviatedMonthNameGetsMonth),
    ("testParseTimeComponentWithNoTranslationParsesEnglishMonth", testParseTimeComponentWithNoTranslationParsesEnglishMonth),
    ("testParseTimeComponentWithAbbreviatedMonthNameWithNoTranslationParsesEnglishMonth", testParseTimeComponentWithAbbreviatedMonthNameWithNoTranslationParsesEnglishMonth),
    ("testParseTimeComponentWithMonthOutsideBoundsParsesMonthNumber", testParseTimeComponentWithMonthOutsideBoundsParsesMonthNumber),
    ("testParseTimeComponentWithInvalidMonthNameIsNil", testParseTimeComponentWithInvalidMonthNameIsNil),
    ("testParseTimeComponentWithMonthNumberWithinBoundsIsNil", testParseTimeComponentWithMonthNumberWithinBoundsIsNil),
    ("testParseTimeComponentWithDayGetsDay", testParseTimeComponentWithDayGetsDay),
    ("testParseTimeComponentWithPaddedDayGetsDay", testParseTimeComponentWithPaddedDayGetsDay),
    ("testParseTimeComponentWithInvalidDayIsNil", testParseTimeComponentWithInvalidDayIsNil),
    ("testParseTimeWith24HourTimeGetsHour", testParseTimeWith24HourTimeGetsHour),
    ("testParseTimeWithPaddedHourTimeGetsHour", testParseTimeWithPaddedHourTimeGetsHour),
    ("testParseTimeWithTwelveHourTimeGetsHour", testParseTimeWithTwelveHourTimeGetsHour),
    ("testParseTimeWithMonthWithInvalidTextReturnsNil", testParseTimeWithMonthWithInvalidTextReturnsNil),
    ("testParseTimeWithMinuteGetsMinute", testParseTimeWithMinuteGetsMinute),
    ("testParseTimeWithPaddedMinuteGetsMinute", testParseTimeWithPaddedMinuteGetsMinute),
    ("testParseTimeWithMinuteWithInvalidTextReturnsNil", testParseTimeWithMinuteWithInvalidTextReturnsNil),
    ("testParseTimeWithSecondGetsSecond", testParseTimeWithSecondGetsSecond),
    ("testParseTimeWithPaddedSecondGetsSecond", testParseTimeWithPaddedSecondGetsSecond),
    ("testParseTimeWithSecondWithInvalidTextReturnsNil", testParseTimeWithSecondWithInvalidTextReturnsNil),
    ("testParseTimeWithWeekdayWithNumberTextDoesNotChangeTime", testParseTimeWithWeekdayWithNumberTextDoesNotChangeTime),
    ("testParseTimeWithWeekDayWithInvalidTextReturnsNil", testParseTimeWithWeekDayWithInvalidTextReturnsNil),
    ("testParseTimeWithWeekDayNameWithValidNameDoesNotChangeTime", testParseTimeWithWeekDayNameWithValidNameDoesNotChangeTime),
    ("testParseTimeWithWeekDayNameWithValidNameWithNoTranslationDoesNotChangeTime", testParseTimeWithWeekDayNameWithValidNameWithNoTranslationDoesNotChangeTime),
    ("testParseTimeWithWeekDayNameWithInvalidNameReturnsNil", testParseTimeWithWeekDayNameWithInvalidNameReturnsNil),
    ("testParseTimeWithWeekDayNameWithAbbreviatedNameOnlyConsumesAbbreviatedName", testParseTimeWithWeekDayNameWithAbbreviatedNameOnlyConsumesAbbreviatedName),
    ("testParseTimeWithWeekDayNameWithAbbreviatedNameWithNoTranslationOnlyConsumesAbbreviatedName", testParseTimeWithWeekDayNameWithAbbreviatedNameWithNoTranslationOnlyConsumesAbbreviatedName),
    ("testParseTimeWithEpochSecondsReturnsNil", testParseTimeWithEpochSecondsReturnsNil),
    ("testParseTimeWithTimeZoneSetsTimeZone", testParseTimeWithTimeZoneSetsTimeZone),
    ("testParseTimeWithTimeZoneWithUnderThreeCharactersReturnsNil", testParseTimeWithTimeZoneWithUnderThreeCharactersReturnsNil),
    ("testParseTimeWithTimeZoneOffsetDoesNotModifyTime", testParseTimeWithTimeZoneOffsetDoesNotModifyTime),
    ("testParseTimeWithNegativeTimeZoneOffsetDoesNotModifyTime", testParseTimeWithNegativeTimeZoneOffsetDoesNotModifyTime),
    ("testParseTimeWithTimeZoneOffsetWithInvalidOffsetReturnsNil", testParseTimeWithTimeZoneOffsetWithInvalidOffsetReturnsNil),
    ("testParseTimeWithTimeZoneOffsetWithBadStringReturnsNil", testParseTimeWithTimeZoneOffsetWithBadStringReturnsNil),
    ("testParseTimeWithTimeZoneOffsetWithNonNumericHourReturnsNil", testParseTimeWithTimeZoneOffsetWithNonNumericHourReturnsNil),
    ("testParseTimeWithMeridianWithAMLeavesHourIntact", testParseTimeWithMeridianWithAMLeavesHourIntact),
    ("testParseTimeWithMeridianWithPMAddsTwelveToHour", testParseTimeWithMeridianWithPMAddsTwelveToHour),
    ("testParseTimeWithMeridianWithBadMeridianReturnsNil", testParseTimeWithMeridianWithBadMeridianReturnsNil),
    ("testParseTimeWithMeridianWithOneLetterReturnsNil", testParseTimeWithMeridianWithOneLetterReturnsNil),
    ("testParseTimeWithMultipleComponentsParsesAllComponents", testParseTimeWithMultipleComponentsParsesAllComponents),
    ("testParseTimeWithMultipleComponentsWithOldMethodParsesAllComponents", testParseTimeWithMultipleComponentsWithOldMethodParsesAllComponents),
    ("testParseTimeWithMultipleComponentsWithMissingComponentsReturnsNil", testParseTimeWithMultipleComponentsWithMissingComponentsReturnsNil),
    ("testParseTimestampBuildsTimestamp", testParseTimestampBuildsTimestamp),
    ("testParseDateBuildsDate", testParseDateBuildsDate),
    ("testParseTimeBuildsTime", testParseTimeBuildsTime),
    ("testParseTimeAsTimestampBuildsTimestamp", testParseTimeAsTimestampBuildsTimestamp),
    ("testParseTimeToTimestampWithTimeZoneInFormatUsesThatTimeZone", testParseTimeToTimestampWithTimeZoneInFormatUsesThatTimeZone),
    ("testParseTimestampWithInvalidStringReturnsNil", testParseTimestampWithInvalidStringReturnsNil),
    ("testParseDateWithInvalidStringReturnsNil", testParseDateWithInvalidStringReturnsNil),
    ("testParseTimeWithInvalidStringReturnsNil", testParseTimeWithInvalidStringReturnsNil),
    ("testParseTimeWithDatabaseFormatCanParseValidTime", testParseTimeWithDatabaseFormatCanParseValidTime),
    ("testParseTimeWithCookieFormatCanParseValidTime", testParseTimeWithCookieFormatCanParseValidTime),
    ("testParseTimeWithRfc822CanParseValidTime", testParseTimeWithRfc822CanParseValidTime),
    ("testParseTimeWithRfc850CanParseValidTime", testParseTimeWithRfc850CanParseValidTime),
    ("testParseTimeWithPosixFormatCanParseValidTime", testParseTimeWithPosixFormatCanParseValidTime),
  ]}

  func setUp() {
    setUpTestCase()
    timestampSeconds = 1431788231.0
    formatter = nil
    timeComponents = (year: 0, month: 0, day: 0, weekDay: 0, hour: 0, minute: 0, second: 0, nanosecond: 0.0, epochSeconds: 0.0, calendar: GregorianCalendar(), timeZone: TimeZone(name: "UTC"))
  
    Application.configuration.localization = { PropertyListLocalization(locale: $0) }
  }
  
  func tearDown() {
    Application.configuration.staticContent = [:]
    Application.configuration.loadDefaultContent()
  }
  
  struct WeirdCalendar: Calendar {
    let year: Int
    let days = 300
    let months = 13
    let hoursPerDay = 24
    let minutesPerHour = 60
    let secondsPerMinute = 60
    let identifier = "weird_calendar"
    
    func inYear(year: Int) -> Calendar {
      return WeirdCalendar(year: year)
    }
    
    func daysInMonth(month: Int) -> Int {
      return month == 1 ? 24 : 23
    }
    
    var daysInWeek: Int { return 8 }
    let unixEpochTime = (1970, 0.0, 1)
    
    let monthNames = ["January", "February", "March"]
    let abbreviatedMonthNames = [String]()
    let dayNames = [String]()
    let abbreviatedDayNames = [String]()
  }
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
    Application.configuration.staticContent["en.dates.gregorian.month_names.full.6"] = "junio"
    timestampSeconds += 86400 * 30
    formatter = TimeFormatComponent.MonthName(abbreviate: false)
    assert(formatted, equals: "junio")
  }
  
  func testFormatComponentWithAbbreviateMonthNameGetsAbbreviatedName() {
    Application.configuration.staticContent["en.dates.gregorian.month_names.abbreviated.6"] = "jun"
    timestampSeconds += 86400 * 30
    formatter = TimeFormatComponent.MonthName(abbreviate: true)
    assert(formatted, equals: "jun")
  }
  
  func testFormatComponentsWithMonthNameWithUntranslatedMonthGetsEnglishMonthName() {
    Application.configuration.staticContent = [:]
    timestampSeconds += 86400 * 30
    let formatter = TimeFormatComponent.MonthName(abbreviate: false)
    let formatted = formatter.format(timestamp)
    assert(formatted, equals: "June")
  }
  
  func testFormatComponentsWithAbbreviatedMonthNameWithUntranslatedMonthGetsEnglishMonthName() {
    Application.configuration.staticContent = [:]
    timestampSeconds += 86400 * 30
    let formatter = TimeFormatComponent.MonthName(abbreviate: true)
    let formatted = formatter.format(timestamp)
    assert(formatted, equals: "Jun")
  }
  
  func testFormatComponentsWithMonthNameWithUntranslatedIslamicMonthGetsDefaultMonthName() {
    Application.configuration.staticContent = [:]
    timestampSeconds += 86400 * 30
    let timestamp = self.timestamp.inCalendar(IslamicCalendar())
    let formatter = TimeFormatComponent.MonthName(abbreviate: false)
    let formatted = formatter.format(timestamp)
    assert(formatted, equals: "Sha‘bān")
  }
  
  func testFormatComponentsWithMonthNameWithUntranslateHebrewMonthGetsDefaultMonthName() {
    Application.configuration.staticContent = [:]
    let timestamp = self.timestamp.inCalendar(HebrewCalendar())
    let formatter = TimeFormatComponent.MonthName(abbreviate: false)
    let formatted = formatter.format(timestamp)
    assert(formatted, equals: "Iyar")
  }
  
  func testFormatComponentsWithMonthNameWithUntranslateHebrewLeapMonthGetsDefaultMonthName() {
    Application.configuration.staticContent = [:]
    timestampSeconds += 86400 * 30 * 10
    let timestamp = self.timestamp.inCalendar(HebrewCalendar())
    let formatter = TimeFormatComponent.MonthName(abbreviate: false)
    let formatted = formatter.format(timestamp)
    assert(formatted, equals: "Adar II")
  }
  
  func testFormatComponentsWithMonthNameBeyondBoundsGetsMonthNumber() {
    let timestamp = self.timestamp.inCalendar(WeirdCalendar(year: 0)).change(month: 13)
    let formatter = TimeFormatComponent.MonthName(abbreviate: false)
    let formatted = formatter.format(timestamp)
    assert(formatted, equals: "13")
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
  
  func testFormatComponentWithHourWithTwelveHourTimeWithZeroUses12() {
    timestampSeconds -= 3600 * 14
    formatter = TimeFormatComponent.HourWith(twelveHour: true, padding: "0")
    assert(formatted, equals: "12")
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
    Application.configuration.staticContent["en.dates.gregorian.week_day_names.full.7"] = "Sabado"
    formatter = TimeFormatComponent.WeekDayName(abbreviate: false)
    assert(formatted, equals: "Sabado")
  }
  
  func testFormatComponentsWithWeekDayNameWithUntranslatedNameGetsEnglishName() {
    Application.configuration.staticContent = [:]
    let formatter = TimeFormatComponent.WeekDayName(abbreviate: false)
    let formatted = formatter.format(timestamp)
    assert(formatted, equals: "Saturday")
  }
  
  func testFormatComponentWithAbbreviatedWeekDayNameGetsAbbreviatedName() {
    Application.configuration.staticContent["en.dates.gregorian.week_day_names.abbreviated.7"] = "Sab"
    formatter = TimeFormatComponent.WeekDayName(abbreviate: true)
    assert(formatted, equals: "Sab")
  }
  
  func testFormatComponentsWithAbbreviatedWeekDayNameWithUntranslatedNameGetsEnglishName() {
    Application.configuration.staticContent = [:]
    let formatter = TimeFormatComponent.WeekDayName(abbreviate: true)
    let formatted = formatter.format(timestamp)
    assert(formatted, equals: "Sat")
  }
  
  func testFormatComponentsWithAbbreviatedWeekDayNameWithDayOutsideBoundsGetsDayNumber() {
    var timestamp = self.timestamp.inCalendar(WeirdCalendar(year: 0))
    timestamp = timestamp + (8 - timestamp.weekDay).days
    Application.configuration.staticContent = [:]
    let formatter = TimeFormatComponent.WeekDayName(abbreviate: true)
    let formatted = formatter.format(timestamp)
    assert(formatted, equals: "8")
  }
  
  func testFormatComponentWithEpochSecondsGetsFullTimestamp() {
    formatter = TimeFormatComponent.EpochSeconds
    assert(formatted, equals: "1431788231")
  }
  
  func testFormatComponentWithTimeZoneGetsAbbreviation() {
    formatter = TimeFormatComponent.TimeZone
    assert(formatted, equals: "UTC")
    assert(formatter?.format(timestamp.inTimeZone("US/Eastern")), equals: "EDT")
  }
  
  func testFormatComponentWithTimeZoneOffsetGetsOffset() {
    formatter = TimeFormatComponent.TimeZoneOffset
    assert(formatted, equals: "+0000")
    assert(formatter?.format(timestamp.inTimeZone("US/Eastern")), equals: "-0400")
    assert(formatter?.format(timestamp.inTimeZone("Europe/Rome")), equals: "+0200")
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
  
  @available(*, deprecated)
  func testFormatWithMultipleComponentsWithOldMethodCombinesResults() {
    formatter = TimeFormat(.Year, "-", .Month, " ", .Day)
    let formatted = formatter.formatTime(timestamp)
    assert(formatted, equals: "2015-05 16")
  }
  
  func testFormatWithDatabaseFormatGetsProperFormat() {
    formatter = TimeFormat.Database
    assert(formatted, equals: "2015-05-16 14:57:11")
  }
  
  func testFormatDateWithDatabaseFormatGetsProperFormat() {
    assert(TimeFormat.Database.format(timestamp.date), equals: "2015-05-16 00:00:00")
    assert(TimeFormat.DatabaseDate.format(timestamp.date), equals: "2015-05-16")
  }
  
  func testFormatTimeWithDatabaseFormatGetsProperFormat() {
    assert(TimeFormat.Database.format(timestamp.time), equals: "0000-00-00 14:57:11")
    assert(TimeFormat.DatabaseTime.format(timestamp.time), equals: "14:57:11")
  }
  
  func testFormatWithCookieFormatGetsProperFormat() {
    let timestamp = Timestamp(epochSeconds: 1418729233, timeZone: TimeZone(name: "UTC"))
    let formatted = TimeFormat.Cookie.format(timestamp)
    assert(formatted, equals: "Tue, 16 Dec 2014 11:27:13 UTC", message: "formats string using cookie date format")
  }
  
  func testFormatWithFullFormatGetsHumanReadableDateAndTime() {
    let timestamp = Timestamp(epochSeconds: 1157469107, timeZone: TimeZone(name: "UTC"))
    let formatted = TimeFormat.Full.format(timestamp)
    assert(formatted, equals: "5 September, 2006, 15:11:47 UTC")
  }
  
  func testFormatWithFullUsGetsHumanReadableDateAndTime() {
    let timestamp = Timestamp(epochSeconds: 1684782968, timeZone: TimeZone(name: "UTC"))
    let formatted = TimeFormat.FullUS.format(timestamp)
    assert(formatted, equals: "May 22, 2023, 7:16:08 PM UTC")
  }
  
  func testFormatWithFullDateGetsHumanReadableDate() {
    let timestamp = Timestamp(epochSeconds: 1383010760, timeZone: TimeZone(name: "UTC"))
    let formatted = TimeFormat.FullDate.format(timestamp)
    assert(formatted, equals: "29 October, 2013")
  }
  
  func testFormatWithFullDateUsGetsHumanReadableDate() {
    let timestamp = Timestamp(epochSeconds: 803301470, timeZone: TimeZone(name: "UTC"))
    let formatted = TimeFormat.FullDateUS.format(timestamp)
    assert(formatted, equals: "June 16, 1995")
  }
  
  func testFormatWithFullTimeGetsHumanReadableTime() {
    let timestamp = Timestamp(epochSeconds: 1526472439, timeZone: TimeZone(name: "UTC"))
    let formatted = TimeFormat.FullTime.format(timestamp)
    assert(formatted, equals: "12:07:19 UTC")
  }
  
  func testFormatWithFullTimeUsGetsHumanReadableTime() {
    let timestamp = Timestamp(epochSeconds: 1377257661, timeZone: TimeZone(name: "UTC"))
    let formatted = TimeFormat.FullTimeUS.format(timestamp)
    assert(formatted, equals: "11:34:21 AM UTC")
  }
  
  func testFormatWithRfc2822GetsProperFormat() {
    let timestamp = Timestamp(epochSeconds: 1412440809, timeZone: TimeZone(name: "US/Eastern"))
    let formatted = TimeFormat.Rfc2822.format(timestamp)
    assert(formatted, equals: "4 Oct 2014 12:40:09 -0400")
  }
  
  func testFormatWithStrftimeUsesStrftimeFormat() {
    let formats = ["%A", "%a", "%B", "%b", "%d", "%D", "%e", "%F", "%G", "%g", "%h", "%H", "%I", "%k", "%l", "%M", "%m", "%n", "%p", "%r", "%R", "%s", "%S", "%t", "%T", "%y", "%Y", "%z", "%Z", "%%", "%Y-%m-%d", "%I%n%m"]
    var cString = [CChar](count: 1024, repeatedValue: 0)
    let timeZone = TimeZone(name: NSTimeZone.systemTimeZone().name)
    
    for value in [timestampSeconds, timestampSeconds + 3600 * 5, timestampSeconds + 3600 * 24 * 180] {
      let localTimestamp = Timestamp(epochSeconds: value, timeZone: timeZone)
      var cTime = Int(value)
      var cLocalTime = localtime(&cTime).memory
      
      for format in formats {
        var cFormat = format.cStringUsingEncoding(NSASCIIStringEncoding)!
        strftime(&cString, 1024, &cFormat, &cLocalTime)
        let foundationString = NSString(CString: cString, encoding: NSASCIIStringEncoding)!.bridge()
        let string = localTimestamp.format(TimeFormat(strftime: format))
        assert(string, equals: foundationString, message: "Got right result for format \(format)")
      }
    }
  }
  
  func testFormatWithStrftimeWithUnsupportedComponentsIsEmpty() {
    let format = "%C%j%U%u%V%W%w%X%x%+%q"
    let string = timestamp.format(TimeFormat(strftime: format))
    assert(string, equals: format)
  }
  
  func testFormatWithStringLiteralIsLiteral() {
    formatter = TimeFormatComponent(stringLiteral: "abc")
    assert(formatted, equals: "abc")
  }
  
  func testFormatWithUnicodeScalarLiteralIsLiteral() {
    formatter = TimeFormatComponent(unicodeScalarLiteral: "abc")
    assert(formatted, equals: "abc")
  }
  
  func testFormatWithExtendedGraphemeLiteralIsLiteral() {
    formatter = TimeFormatComponent(extendedGraphemeClusterLiteral: "abc")
    assert(formatted, equals: "abc")
  }
  
  //MARK: - Parsing
  
  var timeComponents: TimeFormat.TimeComponentContainer = (year: 0, month: 0, day: 0, weekDay: 0, hour: 0, minute: 0, second: 0, nanosecond: 0.0, epochSeconds: 0.0, calendar: GregorianCalendar(), timeZone: TimeZone(name: "UTC"))
  let calendar = GregorianCalendar()
  
  func testParseTimeComponentWithLiteralComponentLeavesTimeAlone() {
    formatter = TimeFormatComponent.Literal("Hello")
    let result = formatter.parse(from: "Hello, World", into: &timeComponents)
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
    let result = formatter.parse(from: "Hello", into: &timeComponents)
    assert(result, equals: "")
  }
  
  func testParseTimeComponentWithLiteralComponentWithNonMatchingStringReturnsNil() {
    formatter = TimeFormatComponent.Literal("Hello")
    let result = formatter.parse(from: "Goodbye, World", into: &timeComponents)
    assert(isNil: result)
  }
  
  func testParseTimeComponentWithYearGetsYear() {
    formatter = TimeFormatComponent.YearWith(padding: "0", length: 4, truncate: false)
    let result = formatter.parse(from: "2010-", into: &timeComponents)
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
    let result = formatter.parse(from: "__99_", into: &timeComponents)
    assert(timeComponents.year, equals: 99)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: "_")
  }
  
  func testParseTimeComponentWithYearWithNonNumericCharacterReturnsNil() {
    formatter = TimeFormatComponent.YearWith(padding: "0", length: 4, truncate: false)
    let result = formatter.parse(from: "Wednesday", into: &timeComponents)
    assert(timeComponents.year, equals: 0)
    assert(isNil: result)
  }
  
  func testParseTimeComponentWithYearWithTooFewCharactersReturnsNil() {
    formatter = TimeFormatComponent.YearWith(padding: "0", length: 4, truncate: false)
    let result = formatter.parse(from: "201", into: &timeComponents)
    assert(timeComponents.year, equals: 0)
    assert(isNil: result)
  }
  
  func testParseTimeComponentWithTwoDigitYearPutsYearIn1900s() {
    formatter = TimeFormatComponent.YearWith(padding: "0", length: 2, truncate: false)
    let result = formatter.parse(from: "75-", into: &timeComponents)
    assert(timeComponents.year, equals: 1975)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: "-")
  }
  
  func testParseTimeComponentWithMonthGetsMonth() {
    formatter = TimeFormatComponent.MonthWith(padding: "0")
    let result = formatter.parse(from: "123", into: &timeComponents)
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
    let result = formatter.parse(from: " 3-", into: &timeComponents)
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
    let result = formatter.parse(from: "bad", into: &timeComponents)
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
    Application.configuration.staticContent["en.dates.gregorian.month_names.full.11"] = "noviembre"
    formatter = TimeFormatComponent.MonthName(abbreviate: false)
    let result = formatter.parse(from: "noviembre 3", into: &timeComponents)
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
    Application.configuration.staticContent["en.dates.gregorian.month_names.abbreviated.12"] = "dez"
    formatter = TimeFormatComponent.MonthName(abbreviate: true)
    let result = formatter.parse(from: "dezo 3", into: &timeComponents)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 12)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: "o 3")
  }
  
  func testParseTimeComponentWithNoTranslationParsesEnglishMonth() {
    Application.configuration.staticContent = [:]
    formatter = TimeFormatComponent.MonthName(abbreviate: false)
    let result = formatter.parse(from: "November 3", into: &timeComponents)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 11)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: " 3")
  }
  
  func testParseTimeComponentWithAbbreviatedMonthNameWithNoTranslationParsesEnglishMonth() {
    Application.configuration.staticContent = [:]
    formatter = TimeFormatComponent.MonthName(abbreviate: true)
    let result = formatter.parse(from: "December 3", into: &timeComponents)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 12)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: "ember 3")
  }
  
  func testParseTimeComponentWithMonthOutsideBoundsParsesMonthNumber() {
    formatter = TimeFormatComponent.MonthName(abbreviate: false)
    timeComponents.calendar = WeirdCalendar(year: 0)
    let result = formatter.parse(from: "13 15", into: &timeComponents)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 13)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: " 15")
  }
  
  func testParseTimeComponentWithInvalidMonthNameIsNil() {
    formatter = TimeFormatComponent.MonthName(abbreviate: true)
    let result = formatter.parse(from: "noviembre", into: &timeComponents)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(isNil: result)
  }
  
  func testParseTimeComponentWithMonthNumberWithinBoundsIsNil() {
    formatter = TimeFormatComponent.MonthName(abbreviate: true)
    let result = formatter.parse(from: "12 14", into: &timeComponents)
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
    let result = formatter.parse(from: "23-12", into: &timeComponents)
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
    let result = formatter.parse(from: " 3-12", into: &timeComponents)
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
    let result = formatter.parse(from: "Test", into: &timeComponents)
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
    let result = formatter.parse(from: "13:45", into: &timeComponents)
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
    let result = formatter.parse(from: "01:45", into: &timeComponents)
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
    let result = formatter.parse(from: "11:45", into: &timeComponents)
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
    let result = formatter.parse(from: "twelve o'clock", into: &timeComponents)
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
    let result = formatter.parse(from: "37 T", into: &timeComponents)
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
    let result = formatter.parse(from: "07 T", into: &timeComponents)
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
    let result = formatter.parse(from: "forty", into: &timeComponents)
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
    let result = formatter.parse(from: "37 T", into: &timeComponents)
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
    let result = formatter.parse(from: "07 T", into: &timeComponents)
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
    let result = formatter.parse(from: "forty", into: &timeComponents)
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
    let result = formatter.parse(from: "1 2", into: &timeComponents)
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
    let result = formatter.parse(from: "January", into: &timeComponents)
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
    let result = formatter.parse(from: "Wednesday at noon", into: &timeComponents)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: " at noon")
  }
  
  func testParseTimeWithWeekDayNameWithValidNameWithNoTranslationDoesNotChangeTime() {
    Application.configuration.staticContent = [:]
    formatter = TimeFormatComponent.WeekDayName(abbreviate: false)
    let result = formatter.parse(from: "Wednesday at noon", into: &timeComponents)
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
    let result = formatter.parse(from: "January", into: &timeComponents)
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
    let result = formatter.parse(from: "Wednesday", into: &timeComponents)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: "nesday")
  }
  
  func testParseTimeWithWeekDayNameWithAbbreviatedNameWithNoTranslationOnlyConsumesAbbreviatedName() {
    Application.configuration.staticContent = [:]
    formatter = TimeFormatComponent.WeekDayName(abbreviate: true)
    let result = formatter.parse(from: "Wednesday", into: &timeComponents)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: "nesday")
  }
  
  func testParseTimeWithEpochSecondsReturnsNil() {
    formatter = TimeFormatComponent.EpochSeconds
    let result = formatter.parse(from: "12345", into: &timeComponents)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(isNil: result)
  }
  
  func testParseTimeWithTimeZoneSetsTimeZone() {
    formatter = TimeFormatComponent.TimeZone
    let result = formatter.parse(from: "EST ", into: &timeComponents)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(timeComponents.timeZone.name, equals: "EST")
    assert(result, equals: " ")
  }
  
  func testParseTimeWithTimeZoneWithUnderThreeCharactersReturnsNil() {
    formatter = TimeFormatComponent.TimeZone
    let result = formatter.parse(from: "ES", into: &timeComponents)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(timeComponents.timeZone.name, equals: "UTC")
    assert(isNil: result)
  }
  
  func testParseTimeWithTimeZoneOffsetDoesNotModifyTime() {
    formatter = TimeFormatComponent.TimeZoneOffset
    let result = formatter.parse(from: "+03:00 Z", into: &timeComponents)
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
    let result = formatter.parse(from: "-04:00 Z", into: &timeComponents)
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
    let result = formatter.parse(from: "+0300", into: &timeComponents)
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
    let result = formatter.parse(from: "badstring", into: &timeComponents)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(isNil: result)
  }
  
  func testParseTimeWithTimeZoneOffsetWithNonNumericHourReturnsNil() {
    formatter = TimeFormatComponent.TimeZoneOffset
    let result = formatter.parse(from: "+AM:PM", into: &timeComponents)
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
    let result = formatter.parse(from: "AM Z", into: &timeComponents)
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
    let result = formatter.parse(from: "PM Z", into: &timeComponents)
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
    let result = formatter.parse(from: "FM Z", into: &timeComponents)
    assert(timeComponents.year, equals: 0)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 11)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(isNil: result)
  }
  
  func testParseTimeWithMeridianWithOneLetterReturnsNil() {
    timeComponents.hour = 11
    formatter = TimeFormatComponent.Meridian
    let result = formatter.parse(from: "F", into: &timeComponents)
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
    let result = formatter.parse(from: "2015-05-12 00:00:00", into: &timeComponents)
    assert(timeComponents.year, equals: 2015)
    assert(timeComponents.month, equals: 5)
    assert(timeComponents.day, equals: 12)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(result, equals: " 00:00:00")
  }
  
  @available(*, deprecated)
  func testParseTimeWithMultipleComponentsWithOldMethodParsesAllComponents() {
    formatter = TimeFormat(.Year, "-", .Month, "-", .Day)
    var timeComponents = (year: 0, month: 0, day: 0, hour: 0, minute: 0, second: 0, nanosecond: 0.0, timeZone: TimeZone(name: "UTC"))
    
    let result = formatter.parseTime(from: "2015-05-12 00:00:00", into: &timeComponents, calendar: GregorianCalendar())
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
    let result = formatter.parse(from: "2015-May-12 00:00:00", into: &timeComponents)
    assert(timeComponents.year, equals: 2015)
    assert(timeComponents.month, equals: 0)
    assert(timeComponents.day, equals: 0)
    assert(timeComponents.hour, equals: 0)
    assert(timeComponents.minute, equals: 0)
    assert(timeComponents.second, equals: 0)
    assert(timeComponents.nanosecond, equals: 0.0)
    assert(isNil: result)
  }
  
  func testParseTimestampBuildsTimestamp() {
    let formatter = TimeFormat(.Year, "-", .Month, "-", .Day, " ", .Hour, ":", .Minute, ":", .Seconds)
    let zone = TimeZone(name: "UTC")
    let result = formatter.parseTimestamp("2015-05-12 15:23:11", timeZone: zone, calendar: GregorianCalendar())
    assert(result?.epochSeconds, equals: 1431444191)
    assert(result?.year, equals: 2015)
    assert(result?.month, equals: 5)
    assert(result?.day, equals: 12)
    assert(result?.hour, equals: 15)
    assert(result?.minute, equals: 23)
    assert(result?.second, equals: 11)
  }
  
  func testParseDateBuildsDate() {
    let formatter = TimeFormat(.Year, "-", .Month, "-", .Day, " ", .Hour, ":", .Minute, ":", .Seconds)
    let zone = TimeZone(name: "UTC")
    let result = formatter.parseDate("2015-05-12 15:23:11", timeZone: zone, calendar: GregorianCalendar())
    assert(result?.year, equals: 2015)
    assert(result?.month, equals: 5)
    assert(result?.day, equals: 12)
  }
  
  func testParseTimeBuildsTime() {
    let formatter = TimeFormat(.Year, "-", .Month, "-", .Day, " ", .Hour, ":", .Minute, ":", .Seconds)
    let zone = TimeZone(name: "UTC")
    let result = formatter.parseTime("2015-05-12 15:23:11", timeZone: zone, calendar: GregorianCalendar()) as Time?
    assert(result?.hour, equals: 15)
    assert(result?.minute, equals: 23)
    assert(result?.second, equals: 11)
  }
  
  @available(*, deprecated)
  func testParseTimeAsTimestampBuildsTimestamp() {
    let formatter = TimeFormat(.Year, "-", .Month, "-", .Day, " ", .Hour, ":", .Minute, ":", .Seconds)
    let zone = TimeZone(name: "UTC")
    let result = formatter.parseTime("2015-05-12 15:23:11", timeZone: zone, calendar: GregorianCalendar()) as Timestamp?
    assert(result?.epochSeconds, equals: 1431444191)
    assert(result?.year, equals: 2015)
    assert(result?.month, equals: 5)
    assert(result?.day, equals: 12)
    assert(result?.hour, equals: 15)
    assert(result?.minute, equals: 23)
    assert(result?.second, equals: 11)
  }
  
  func testParseTimeToTimestampWithTimeZoneInFormatUsesThatTimeZone() {
    let formatter = TimeFormat(.Year, "-", .Month, "-", .Day, " ", .Hour, ":", .Minute, ":", .Seconds, " ", .TimeZone)
    let zone = TimeZone(name: "UTC")
    let result = formatter.parseTimestamp("2015-05-12 15:23:11 EDT", timeZone: zone, calendar: GregorianCalendar())
    assert(result?.epochSeconds, equals: 1431458591)
    assert(result?.year, equals: 2015)
    assert(result?.month, equals: 5)
    assert(result?.day, equals: 12)
    assert(result?.hour, equals: 15)
    assert(result?.minute, equals: 23)
    assert(result?.second, equals: 11)
    assert(result?.timeZone.name, equals: "EDT")
  }
  
  func testParseTimestampWithInvalidStringReturnsNil() {
    let formatter = TimeFormat(.Year, "-", .Month, "-", .Day, " ", .Hour, ":", .Minute, ":", .Seconds)
    let result = formatter.parseTimestamp("2015-May-12 00:00:00")
    assert(isNil: result)
  }
  
  func testParseDateWithInvalidStringReturnsNil() {
    let formatter = TimeFormat(.Year, "-", .Month, "-", .Day, " ", .Hour, ":", .Minute, ":", .Seconds)
    let result = formatter.parseDate("2015-May-12 00:00:00")
    assert(isNil: result)
  }
  
  func testParseTimeWithInvalidStringReturnsNil() {
    let formatter = TimeFormat(.Year, "-", .Month, "-", .Day, " ", .Hour, ":", .Minute, ":", .Seconds)
    let result = formatter.parseTime("2015-May-12 00:00:00") as Time?
    assert(isNil: result)
  }
  
  func testParseTimeWithDatabaseFormatCanParseValidTime() {
    let formatter = TimeFormat.Database
    let result = formatter.parseTimestamp("1996-11-12 05:26:09", timeZone: TimeZone(name: "UTC"))
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
    let result = formatter.parseTimestamp("Fri, 21 Dec 2001 23:11:51 GMT", timeZone:
      TimeZone(name: "UTC"))
    assert(result?.epochSeconds, equals: 1008976311)
    assert(result?.year, equals: 2001)
    assert(result?.month, equals: 12)
    assert(result?.day, equals: 21)
    assert(result?.hour, equals: 23)
    assert(result?.minute, equals: 11)
    assert(result?.second, equals: 51)
  }
  
  func testParseTimeWithRfc822CanParseValidTime() {
    let result = TimeFormat.Rfc822.parseTimestamp("Sun, 06 Nov 1994 08:49:37 GMT")
    assert(result?.year, equals: 1994)
    assert(result?.month, equals: 11)
    assert(result?.day, equals: 6)
    assert(result?.hour, equals: 8)
    assert(result?.minute, equals: 49)
    assert(result?.second, equals: 37)
    assert(result?.timeZone.name, equals: "GMT")
  }
  
  func testParseTimeWithRfc850CanParseValidTime() {
    let result = TimeFormat.Rfc850.parseTimestamp("Sunday, 06-Nov-94 08:49:37 GMT")
    assert(result?.year, equals: 1994)
    assert(result?.month, equals: 11)
    assert(result?.day, equals: 6)
    assert(result?.hour, equals: 8)
    assert(result?.minute, equals: 49)
    assert(result?.second, equals: 37)
    assert(result?.timeZone.name, equals: "GMT")
  }
  
  func testParseTimeWithPosixFormatCanParseValidTime() {
    let result = TimeFormat.Posix.parseTimestamp("Sun Nov  6 08:49:37 1994")
    assert(result?.year, equals: 1994)
    assert(result?.month, equals: 11)
    assert(result?.day, equals: 6)
    assert(result?.hour, equals: 8)
    assert(result?.minute, equals: 49)
    assert(result?.second, equals: 37)
    assert(result?.timeZone.name, equals: TimeZone.systemTimeZone().name)
  }
}