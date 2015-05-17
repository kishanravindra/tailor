/**
  This protocol specifies that a type can be used to format a timestamp.
  */
public protocol TimeFormatter {
  /**
    This method formats a timestamp using the rules of this time formatter.
    */
  func formatTime(timestamp: Timestamp) -> String
  
  /**
    This method parses information from a string into a timestamp.
  
    This should modify the provided container in place to extract the time
    information, and return the remaining string after this formatter has
    consumed its part.
  
    If the string does not match this formatter, the should return nil.
  
    :param: string      The string to parse.
    :param: container   The container for the time information.
    :param: calendar    The calendar that the date is formatted in.
    :returns:           The remaining string.
    */
  func parseTime(from string: String, inout into container: (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, nanosecond: Double), calendar: Calendar) -> String?
}

/**
  This struct encapsulates a way of formatting a timestamp.

  In implementation, it wraps around other things that can format times,
  typically TimeFormatComponents.
  */
public struct TimeFormat: TimeFormatter {
  /** The components of this time format. */
  public private(set) var components: [TimeFormatter]
  
  /**
    This initializer creates a time format with an array components.
  
    :param: components    The components of the format.
    */
  public init(components: [TimeFormatter] = []) {
    self.components = components
  }
  
  /**
    This initializer creates a time format with a series of components.

    :param: components    The components of the format.
    */
  public init(_ components: TimeFormatComponent...) {
    self.init(components: components.map { $0 as TimeFormatter })
  }
  
  /**
    This initializer creates a time format from a strftime-style format string.
  
    :param: formatString    The format string.
    :todo:                  Support more formats.
    */
  public init(strftime formatString: String) {
    var workingString = ""
    var components = [TimeFormatComponent]()
    var inEscape = false
    for character in formatString {
      if inEscape {
        let newComponents: [TimeFormatComponent]
        switch(character) {
        case "A": newComponents = [] // Full weekday name
        case "a": newComponents = [] // Abbreviated weekday name
        case "B": newComponents = [] // Full month name
        case "b": newComponents = [] // Abbreviated month name
        case "C": newComponents = [] // Decimal of year / 100
        case "D": newComponents = [.Month, "/", .Day, "/", .YearWith(padding: "0", length: 2, truncate: true)]
        case "d": newComponents = [.Day]
        case "e": newComponents = [.DayWith(padding: " ")]
        case "F": newComponents = [.Year, "-", .Month, "-", .Day]
        case "G": newComponents = [] // Decimal number with century
        case "g": newComponents = [] // Decimal number without century
        case "H": newComponents = [.Hour]
        case "h": newComponents = [] // Abbreviated month name
        case "I": newComponents = [.HourWith(twelveHour: true, padding: "0")]
        case "j": newComponents = [] // Day of year
        case "k": newComponents = [.HourWith(twelveHour: false, padding: " ")]
        case "l": newComponents = [.HourWith(twelveHour: true, padding: " ")]
        case "M": newComponents = [.Minute]
        case "m": newComponents = [.Month]
        case "n": newComponents = ["\n"]
        case "p": newComponents = [.Meridian]
        case "R": newComponents = [.Hour, ":", .Minute]
        case "r": newComponents = [] // %I:%M:%S %p
        case "S": newComponents = [.Seconds]
        case "s": newComponents = [.EpochSeconds]
        case "T": newComponents = [.Hour, ":", .Minute, ":", .Seconds]
        case "t": newComponents = ["\t"]
        case "U": newComponents = [] // Week number of the year
        case "u": newComponents = [] // Weekday as number, starting from 1
        case "V": newComponents = [] // Week number of the year, starting from 1
        case "v": newComponents = [] // %e-%b-%Y
        case "W": newComponents = [] // Week number of the year, starting with 0
        case "w": newComponents = [] // Weekday as number, starting with 0
        case "X": newComponents = [] // Local time format
        case "x": newComponents = [] // Local date format
        case "Y": newComponents = [.Year]
        case "y": newComponents = [.YearWith(padding: "0", length: 2, truncate: true)]
        case "Z": newComponents = [.TimeZone]
        case "z": newComponents = [.TimeZoneOffset]
        case "+": newComponents = [] // Local date and time format
        case "%": newComponents = ["%"]
        default: newComponents = []
        }
        if newComponents.isEmpty {
          workingString += "%\(character)"
        }
        else {
          components.append(.Literal(workingString))
          components.extend(newComponents)
          workingString = ""
        }
        inEscape = false
      }
      else if character == "%" {
        inEscape = true
      }
      else {
        workingString.append(character)
      }
    }
    components.append(TimeFormatComponent.Literal(workingString))
    self.init(components: components.map { $0 as TimeFormatter })
  }
  
  /**
    This method formats a timestamp using the rules of this time formatter.

    :param: timestamp   The timestamp to format.
    :returns:           The formatted string.
    */
  public func formatTime(timestamp: Timestamp) -> String {
    return join("", self.components.map { $0.formatTime(timestamp) })
  }
  
  /**
    This method parses information from a string into a timestamp.
    
    This should modify the provided container in place to extract the time
    information, and return the remaining string after this formatter has
    consumed its part.
    
    If the string does not match this formatter, the should return nil.
    
    :param: string      The string to parse.
    :param: container   The container for the time information.
    :param: calendar    The calendar that the date is formatted in.
    :returns:           The remaining string.
  */
  public func parseTime(from string: String, inout into container: (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, nanosecond: Double), calendar: Calendar = GregorianCalendar()) -> String? {
    var string: String! = string
    
    for component in components {
      string = component.parseTime(from: string, into: &container, calendar: calendar)
      if string == nil {
        return nil
      }
    }
    return string
  }
  
  /**
    This method parses a timestamp from a string.

    :param: string    The string to parse.
    :param: timeZone  The time zone to interpret the string with.
    :param: calendar  The calendar to interpret the string with.
    :returns:         The parsed timestamp. If the string didn't match the
                      expected format, this will return nil.
    */
  public func parseTime(string: String, timeZone: TimeZone = TimeZone.defaultTimeZone, calendar: Calendar = GregorianCalendar()) -> Timestamp? {
    var timeInformation = (year: 0, month: 0, day: 0, hour: 0, minute: 0, second: 0, nanosecond: 0.0)
    let result = parseTime(from: string, into: &timeInformation)
    if result == nil {
      return nil
    }
    return Timestamp(year: timeInformation.year, month: timeInformation.month, day: timeInformation.day, hour: timeInformation.hour, minute: timeInformation.minute, second: timeInformation.second, nanosecond: timeInformation.nanosecond, timeZone: timeZone, calendar: calendar)
  }
}

/**
  This is a portion of a time format.

  It can be either a literal string or an aspect of the localized time.
  */
public enum TimeFormatComponent: TimeFormatter {
  /** Text that will be put into the result verbatim. */
  case Literal(String)
  
  /**
    The calendar year.

    :param: padding   A character to use to pad the year to a minimum length.
    :param: length    The minimum length of the year.
    :param: truncate  Whether it should truncate the year if it is longer than
                      the minimum. This will include the least-significant
                      digits.
    */
  case YearWith(padding: Character?, length: Int, truncate: Bool)
  
  /**
    The month as a number.
  
    :param: padding   A character to use to pad the month to two digits.
    */
  case MonthWith(padding: Character?)
  
  /**
    The name as a month.

    :param: abbreviate  Whether we should abbreviate the month name.
    */
  case MonthName(abbreviate: Bool)
  
  /**
    The day of the month.
  
    :param: padding   A character to use to pad the day to two digits.
    */
  case DayWith(padding: Character?)
  
  /**
    The hour in the day.
  
    :param: twelveHour    Whether we should use twelve-hour time instead of
                          twenty-four hour time.
    :param: padding       A character to use to pad the hour to two digits.
    */
  case HourWith(twelveHour: Bool, padding: Character?)
  
  /** The minute in the hour, two-digits and zero-padded. */
  case Minute
  
  /** The seconds in the minute, two-digits and zero-padded. */
  case Seconds
  
  /** The day of the week as a numeric value, starting from 1. */
  case WeekDay
  
  /**
    The name of the day of the week.
  
    :param: abbreviate    Whether we should abbreviate the name.
    */
  case WeekDayName(abbreviate: Bool)
  
  /** The number of seconds since the Unix epoch, as an integer. */
  case EpochSeconds
  
  /** The three-letter abbreviation for the time zone. */
  case TimeZone
  
  /**
    The time zone offset.
  
    For three hours east of UTC, this will be +03:00.
  
    For six hours west of UTC, this will be -06:00.
    */
  case TimeZoneOffset
  
  /** Whether the time is in AM or PM. */
  case Meridian
  
  /** The year, four digits and zero-padded.. */
  public static let Year = YearWith(padding: "0", length: 4, truncate: false)
  
  /** The numeric month, two digits and zero-padded. */
  public static let Month = MonthWith(padding: "0")
  
  /** The day of the month, two digits and zero-padded. */
  public static let Day = DayWith(padding: "0")
  
  /** The hour of the day, two digits and zero-padded, with a 24-hour clock. */
  public static let Hour = HourWith(twelveHour: false, padding: "0")
  
  /**
    This method pads a string to a minimum length.

    :param: string    The string to pad.
    :param: with      The character to pad it with
    :param: length    The minimum length of the result.
    :returns:         The padded string.
    */
  private func pad(string: String, with pad: Character, length: Int) -> String {
    let currentLength = count(string)
    if currentLength < length {
      return String(count: length - currentLength, repeatedValue: pad) + string
    }
    else {
      return string
    }
  }
  
  /**
    This method formats a timestamp based on the rules of this component.

    :param: timestamp   The timestamp to format.
    :returns:           The formatted string.
    */
  public func formatTime(timestamp: Timestamp) -> String {
    switch(self) {
    case let .Literal(s): return s
    case let .YearWith(padding, length, truncate):
      var year = String(timestamp.year)
      if let padding = padding {
        year = pad(year, with: padding, length: length)
      }
      let currentLength = count(year)
      if truncate && currentLength > length {
        year = year.substringFromIndex(advance(year.endIndex, length - currentLength))
      }
      return year
    case let .MonthWith(padding):
      let month = String(timestamp.month)
      if let padding = padding {
        return pad(month, with: padding, length: 2)
      }
      else {
        return month
      }
    case let .MonthName(abbreviate):
      let localization = Application.sharedApplication().localization("en")
      let key: String
      if abbreviate {
        key = "dates.\(timestamp.calendar.identifier).month_names.abbreviated.\(timestamp.month)"
      }
      else {
        key = "dates.\(timestamp.calendar.identifier).month_names.full.\(timestamp.month)"
      }
      return localization.fetch(key) ?? "\(timestamp.month)"
    case let .DayWith(padding):
      let day = String(timestamp.day)
      if let padding = padding {
        return pad(day, with: padding, length: 2)
      }
      else {
        return day
      }
    case let .HourWith(twelveHour, padding):
      let hour: String
      if twelveHour && timestamp.hour > 12 {
        hour = String(timestamp.hour - 12)
      }
      else {
        hour = String(timestamp.hour)
      }
      if let padding = padding {
        return pad(hour, with: padding, length: 2)
      }
      else {
        return hour
      }
    case let .Minute: return pad(String(timestamp.minute), with: "0", length: 2)
    case let .Seconds: return pad(String(timestamp.second), with: "0", length: 2)
    case let .WeekDay: return String(timestamp.weekDay)
    case let .WeekDayName(abbreviate):
      let localization = Application.sharedApplication().localization("en")
      let key: String
      if abbreviate {
        key = "dates.\(timestamp.calendar.identifier).week_day_names.abbreviated.\(timestamp.weekDay)"
      }
      else {
        key = "dates.\(timestamp.calendar.identifier).week_day_names.full.\(timestamp.weekDay)"
      }
      return localization.fetch(key) ?? "\(timestamp.weekDay)"
    case let .EpochSeconds: return String(Int(timestamp.epochSeconds))
    case let .TimeZone:
      let policy = timestamp.timeZone.policy(timestamp: timestamp.epochSeconds)
      return policy.abbreviation
    case let .TimeZoneOffset:
      let policy = timestamp.timeZone.policy(timestamp: timestamp.epochSeconds)
      let seconds = policy.offset
      let hour = (abs(seconds) / 3600) % 24
      let minute = (abs(seconds) / 60) % 60
      var offset = pad(String(hour), with: "0", length: 2) + pad(String(minute), with: "0", length: 2)
      return (seconds < 0 ? "-" : "+") + offset
    case let .Meridian: return timestamp.hour > 12 ? "PM": "AM"
    }
  }
  
  /**
    This method parses a number from a string.

    :param: string    The string we are reading.
    :param: length    The number of digits that we should read.
    :param: padding   A character that can appear at the start to pad the
                      string.
    :returns:         A tuple containing the number and the unconsumed part of
                      the string. If we cannot read the number, the number will
                      be zero and the string will be nil.
    */
  private func parseNumber(from string: String, length: Int, padding: Character?) -> (Int,String?) {
    var substring = string.substringToIndex(advance(string.startIndex, length))
    var realStartIndex = -1
    for (index,character) in enumerate(substring.unicodeScalars) {
      if padding != nil && padding! != "0" && String(character) == String(padding!) {
        continue
      }
      if realStartIndex == -1 {
        realStartIndex = index
      }
    }
    substring = substring.substringFromIndex(advance(substring.startIndex, realStartIndex))
    if let value = substring.toInt() {
      return (value, string.substringFromIndex(advance(string.startIndex, length)))
    }
    else {
      return (0,nil)
    }
  }
  
  /**
    This method extracts a numeric value from a text component at the beginning
    of a string.

    :param: string    The string we are reading.
    :param: key       The key that identifies this component in the
                      translations, between the calendar identifier and the
                      index.
    :param: calendar  The calendar that the date is formatted in.
    :param: range     The range of valid values for the component.
    :returns:         A tuple containing the number and the unconsumed part of
                      the string. If we cannot read the number, the number will
                      be zero and the string will be nil.
    */
  private func parseText(from string: String, key: String, calendar: Calendar, range: Range<Int>) -> (Int,String?) {
    let localization = Application.sharedApplication().localization("en")
    for value in range {
      if let textValue = localization.fetch("dates.\(calendar.identifier).\(key).\(value)") {
        if string.hasPrefix(textValue) {
          return (value,string.substringFromIndex(advance(string.startIndex, count(textValue))))
        }
      }
    }
    return (0,nil)
  }
  
  /**
    This method parses information from a string into a timestamp.
    
    This will modify the provided container in place to extract the time
    information, and return the remaining string after this formatter has
    consumed its part.
    
    If the string does not match this formatter, the should return nil.
    
    :param: string      The string to parse.
    :param: container   The container for the time information.
    :param: calendar    The calendar that the date is formatted in.
    :returns:           The remaining string.
    :todo:              Parsing more types of components.
    */
  public func parseTime(from string: String, inout into container: (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, nanosecond: Double), calendar: Calendar = GregorianCalendar()) -> String? {
    var modifiedContainer = container
    switch(self) {
    case let .Literal(literal):
      if string.hasPrefix(literal) {
        return string.substringFromIndex(advance(string.startIndex, count(literal)))
      }
      else {
        return nil
      }
    case let .YearWith(padding,length,truncate):
      let (year,result) = parseNumber(from: string, length: length, padding: padding)
      if result != nil {
        container.year = year
      }
      return result
    case let .MonthWith(padding):
      let (month,result) = parseNumber(from: string, length: 2, padding: padding)
      if result != nil {
        container.month = month
      }
      return result
    case let .MonthName(abbreviated):
      let key = abbreviated ? "month_names.abbreviated" : "month_names.full"
      let (month,result) = parseText(from: string, key: key, calendar: calendar, range: 1...calendar.months)
      if result != nil {
        container.month = month
      }
      return result
    case let .DayWith(padding):
      let (day,result) = parseNumber(from: string, length: 2, padding: padding)
      if result != nil {
        container.day = day
      }
      return result
    case let .HourWith(twelveHour, padding):
      let (hour,result) = parseNumber(from: string, length: 2, padding: padding)
      if result != nil {
        container.hour = hour
      }
      return result
    case .Minute:
      let (minute,result) = parseNumber(from: string, length: 2, padding:
      "0")
      if result != nil {
        container.minute = minute
      }
      return result
    case .Seconds:
      let (seconds,result) = parseNumber(from: string, length: 2, padding:
        "0")
      if result != nil {
        container.second = seconds
      }
      return result
    case .WeekDay:
      let (weekDay, result) = parseNumber(from: string, length: 1, padding: nil)
      return result
    case let .WeekDayName(abbreviate):
      let key = abbreviate ? "week_day_names.abbreviated" : "week_day_names.full"
      let (weekDay, result) = parseText(from: string, key: key, calendar: calendar, range: 1...calendar.daysInWeek)
      return result
    case .EpochSeconds:
      return nil
    case .TimeZone:
      if count(string) > 3 {
        return string.substringFromIndex(advance(string.startIndex, 3))
      }
      else {
        return ""
      }
    case .TimeZoneOffset:
      if count(string) < 6 {
        return nil
      }
      if (string[string.startIndex] != "+" && string[string.startIndex] != "-") || string[advance(string.startIndex, 3)] != ":" {
        return nil
      }
      let hours = string.substringWithRange(advance(string.startIndex, 1)...advance(string.startIndex, 2)).toInt()
      let minutes = string.substringWithRange(advance(string.startIndex, 4)...advance(string.startIndex, 5)).toInt()
      if hours == nil || minutes == nil {
        return nil
      }
      return string.substringFromIndex(advance(string.startIndex, 6))
    case .Meridian:
      if count(string) < 2 {
        return nil
      }
      let index = advance(string.startIndex, 2)
      let meridian = string.substringToIndex(index)
      switch(meridian) {
      case "AM":
        break
      case "PM":
        container.hour += 12
      default:
        return nil
      }
      return string.substringFromIndex(index)
    }
  }
}

/**
  This extension allows us to initialize a time format component with a string
  literal.
  */
extension TimeFormatComponent: StringLiteralConvertible {
  /** Required for protocol conformance. */
  public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
  
  /**
    This method initializes a time format component with a string literal.
    
    :param: value   The string literal.
    */
  public init(stringLiteral value: StringLiteralType) {
    self = .Literal(value)
  }
  
  /**
    This method initializes a time format component with a string literal.
  
    :param: value   The string literal.
  */
  public init(unicodeScalarLiteral value: StringLiteralType) {
    self = .Literal(value)
  }
  
  /**
    This method initializes a time format component with a string literal.
  
    :param: value   The string literal.
  */
  public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
    self = .Literal(value)
  }
}

/**
  This extension provides some stock time formats.
  */
public extension TimeFormat {
  /** This formats a time as a SQL timestamp. */
  public static let Database = TimeFormat(.Year, "-", .Month, "-", .Day, " ", .Hour, ":", .Minute, ":", .Seconds)
  
  /** This formats a time for a cookie. */
  public static let Cookie = TimeFormat(.WeekDayName(abbreviate: true), ", ", .Day, " ", .MonthName(abbreviate: true), " ", .Year, " ", .Hour, ":", .Minute, ":", .Seconds, " ", .TimeZone)
}