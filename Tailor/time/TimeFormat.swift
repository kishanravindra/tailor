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
  
    - parameter string:      The string to parse.
    - parameter container:   The container for the time information.
    - parameter calendar:    The calendar that the date is formatted in.
    - returns:           The remaining string.
    */
  func parseTime(from string: String, inout into container: (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, nanosecond: Double, timeZone: TimeZone), calendar: Calendar) -> String?
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
  
    - parameter components:    The components of the format.
    */
  public init(components: [TimeFormatter] = []) {
    self.components = components
  }
  
  /**
    This initializer creates a time format with a series of components.

    - parameter components:    The components of the format.
    */
  public init(_ components: TimeFormatComponent...) {
    self.init(components: components.map { $0 as TimeFormatter })
  }
  
  /**
    This initializer creates a time format from a strftime-style format string.
  
    - parameter formatString:    The format string.
    :todo:                  Support more formats.
    */
  public init(strftime formatString: String) {
    var workingString = ""
    var components = [TimeFormatComponent]()
    var inEscape = false
    for character in formatString.characters {
      if inEscape {
        let newComponents: [TimeFormatComponent]
        switch(character) {
        case "A": newComponents = [.WeekDayName(abbreviate: false)]
        case "a": newComponents = [.WeekDayName(abbreviate: true)]
        case "B": newComponents = [.MonthName(abbreviate: false)]
        case "b": newComponents = [.MonthName(abbreviate: true)]
        case "C": newComponents = [] // Decimal of year / 100
        case "D": newComponents = [.Month, "/", .Day, "/", .YearWith(padding: "0", length: 2, truncate: true)]
        case "d": newComponents = [.Day]
        case "e": newComponents = [.DayWith(padding: " ")]
        case "F": newComponents = [.Year, "-", .Month, "-", .Day]
        case "G": newComponents = [.Year]
        case "g": newComponents = [.YearWith(padding: "0", length: 2, truncate: true)]
        case "H": newComponents = [.Hour]
        case "h": newComponents = [.MonthName(abbreviate: true)]
        case "I": newComponents = [.HourWith(twelveHour: true, padding: "0")]
        case "j": newComponents = [] // Day of year
        case "k": newComponents = [.HourWith(twelveHour: false, padding: " ")]
        case "l": newComponents = [.HourWith(twelveHour: true, padding: " ")]
        case "M": newComponents = [.Minute]
        case "m": newComponents = [.Month]
        case "n": newComponents = ["\n"]
        case "p": newComponents = [.Meridian]
        case "R": newComponents = [.Hour, ":", .Minute]
        case "r": newComponents = [.HourWith(twelveHour: true, padding: "0"), ":", .Minute, ":", .Seconds, " ", .Meridian]
        case "S": newComponents = [.Seconds]
        case "s": newComponents = [.EpochSeconds]
        case "T": newComponents = [.Hour, ":", .Minute, ":", .Seconds]
        case "t": newComponents = ["\t"]
        case "U": newComponents = [] // Week number of the year
        case "u": newComponents = [] // Week day - Monday = 1, Sunday = 7
        case "V": newComponents = [] // Week number of the year, starting from 1
        case "v": newComponents = [.DayWith(padding: " "), "-", .MonthName(abbreviate: true), "-", .Year]
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

    - parameter timestamp:   The timestamp to format.
    - returns:           The formatted string.
    */
  public func formatTime(timestamp: Timestamp) -> String {
    return "".join(self.components.map { $0.formatTime(timestamp) })
  }
  
  /**
    This method parses information from a string into a timestamp.
    
    This should modify the provided container in place to extract the time
    information, and return the remaining string after this formatter has
    consumed its part.
    
    If the string does not match this formatter, the should return nil.
    
    - parameter string:      The string to parse.
    - parameter container:   The container for the time information.
    - parameter calendar:    The calendar that the date is formatted in.
    - returns:           The remaining string.
  */
  public func parseTime(from string: String, inout into container: (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, nanosecond: Double, timeZone: TimeZone), calendar: Calendar = GregorianCalendar()) -> String? {
    var string: String = string
    
    for component in components {
      guard let newString = component.parseTime(from: string, into: &container, calendar: calendar) else {
        return nil
      }
      string = newString
    }
    return string
  }
  
  /**
    This method parses a timestamp from a string.

    - parameter string:    The string to parse.
    - parameter timeZone:  The time zone to interpret the string with.
    - parameter calendar:  The calendar to interpret the string with.
    - returns:         The parsed timestamp. If the string didn't match the
                      expected format, this will return nil.
    */
  public func parseTime(string: String, timeZone: TimeZone = TimeZone.systemTimeZone(), calendar: Calendar = GregorianCalendar()) -> Timestamp? {
    var timeInformation = (year: 0, month: 0, day: 0, hour: 0, minute: 0, second: 0, nanosecond: 0.0, timeZone: timeZone)
    let result = parseTime(from: string, into: &timeInformation)
    if result == nil {
      return nil
    }
    return Timestamp(year: timeInformation.year, month: timeInformation.month, day: timeInformation.day, hour: timeInformation.hour, minute: timeInformation.minute, second: timeInformation.second, nanosecond: timeInformation.nanosecond, timeZone: timeInformation.timeZone, calendar: calendar)
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

    - parameter padding:   A character to use to pad the year to a minimum length.
    - parameter length:    The minimum length of the year.
    - parameter truncate:  Whether it should truncate the year if it is longer than
                      the minimum. This will include the least-significant
                      digits.
    */
  case YearWith(padding: Character?, length: Int, truncate: Bool)
  
  /**
    The month as a number.
  
    - parameter padding:   A character to use to pad the month to two digits.
    */
  case MonthWith(padding: Character?)
  
  /**
    The name as a month.

    - parameter abbreviate:  Whether we should abbreviate the month name.
    */
  case MonthName(abbreviate: Bool)
  
  /**
    The day of the month.
  
    - parameter padding:   A character to use to pad the day to two digits.
    */
  case DayWith(padding: Character?)
  
  /**
    The hour in the day.
  
    - parameter twelveHour:    Whether we should use twelve-hour time instead of
                          twenty-four hour time.
    - parameter padding:       A character to use to pad the hour to two digits.
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
  
    - parameter abbreviate:    Whether we should abbreviate the name.
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

    - parameter string:     The string to pad.
    - parameter with:       The character to pad it with
    - parameter length:     The minimum length of the result.
    - returns:              The padded string.
    */
  private func pad(string: String, with pad: Character, length: Int) -> String {
    let currentLength = string.characters.count
    if currentLength < length {
      return String(count: length - currentLength, repeatedValue: pad) + string
    }
    else {
      return string
    }
  }
  
  /**
    This method formats a timestamp based on the rules of this component.

    - parameter timestamp:    The timestamp to format.
    - returns:                The formatted string.
    */
  public func formatTime(timestamp: Timestamp) -> String {
    switch(self) {
    case let .Literal(s): return s
    case let .YearWith(padding, length, truncate):
      var year = String(timestamp.year)
      if let padding = padding {
        year = pad(year, with: padding, length: length)
      }
      let currentLength = year.characters.count
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
      else if twelveHour && timestamp.hour == 0 {
        hour = "12"
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
    case .Minute: return pad(String(timestamp.minute), with: "0", length: 2)
    case .Seconds: return pad(String(timestamp.second), with: "0", length: 2)
    case .WeekDay: return String(timestamp.weekDay)
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
    case .EpochSeconds: return String(Int(timestamp.epochSeconds))
    case .TimeZone:
      let policy = timestamp.timeZone.policy(timestamp: timestamp.epochSeconds)
      return policy.abbreviation
    case .TimeZoneOffset:
      let policy = timestamp.timeZone.policy(timestamp: timestamp.epochSeconds)
      let seconds = policy.offset
      let hour = (abs(seconds) / 3600) % 24
      let minute = (abs(seconds) / 60) % 60
      let offset = pad(String(hour), with: "0", length: 2) + pad(String(minute), with: "0", length: 2)
      return (seconds < 0 ? "-" : "+") + offset
    case .Meridian: return timestamp.hour > 12 ? "PM": "AM"
    }
  }
  
  /**
    This method parses a number from a string.

    - parameter string:     The string we are reading.
    - parameter length:     The number of digits that we should read.
    - parameter padding:    A character that can appear at the start to pad the
                            string.
    - returns:              A tuple containing the number and the unconsumed
                            part of the string. If we cannot read the number,
                            the number will be zero and the string will be nil.
    */
  private func parseNumber(from string: String, length: Int, padding: Character?) -> (Int,String?) {
    if length > string.characters.count {
      return (0,nil)
    }
    
    var substring = string.substringToIndex(advance(string.startIndex, length))
    var realStartIndex = -1
    for (index,character) in substring.unicodeScalars.enumerate() {
      
      if let padding = padding {
        if padding != "0" && String(character) == String(padding) {
          continue
        }
      }
      if realStartIndex == -1 {
        realStartIndex = index
      }
    }
    substring = substring.substringFromIndex(advance(substring.startIndex, realStartIndex))
    if let value = Int(substring) {
      return (value, string.substringFromIndex(advance(string.startIndex, length)))
    }
    else {
      return (0,nil)
    }
  }
  
  /**
    This method extracts a numeric value from a text component at the beginning
    of a string.

    - parameter string:     The string we are reading.
    - parameter key:        The key that identifies this component in the
                            translations, between the calendar identifier and
                            the index.
    - parameter calendar:   The calendar that the date is formatted in.
    - parameter range:      The range of valid values for the component.
    - returns:              A tuple containing the number and the unconsumed
                            part of the string. If we cannot read the number,
                            the number will be zero and the string will be nil.
    */
  private func parseText(from string: String, key: String, calendar: Calendar, range: Range<Int>) -> (Int,String?) {
    let localization = Application.sharedApplication().localization("en")
    for value in range {
      if let textValue = localization.fetch("dates.\(calendar.identifier).\(key).\(value)") {
        if string.hasPrefix(textValue) {
          return (value,string.substringFromIndex(advance(string.startIndex, textValue.characters.count)))
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
    
    - parameter string:       The string to parse.
    - parameter container:    The container for the time information.
    - parameter calendar:     The calendar that the date is formatted in.
    - returns:                The remaining string.
  
    **TODO:** Parsing more types of components.
    */
  public func parseTime(from string: String, inout into container: (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, nanosecond: Double, timeZone: Tailor.TimeZone), calendar: Calendar = GregorianCalendar()) -> String? {
    switch(self) {
    case let .Literal(literal):
      if string.hasPrefix(literal) {
        return string.substringFromIndex(advance(string.startIndex, literal.characters.count))
      }
      else {
        return nil
      }
    case let .YearWith(padding,length,_):
      var (year,result) = parseNumber(from: string, length: length, padding: padding)
      if result != nil {
        if length == 2 {
          year += 1900
        }
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
    case let .HourWith(_, padding):
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
      let (_, result) = parseNumber(from: string, length: 1, padding: nil)
      return result
    case let .WeekDayName(abbreviate):
      let key = abbreviate ? "week_day_names.abbreviated" : "week_day_names.full"
      let (_, result) = parseText(from: string, key: key, calendar: calendar, range: 1...calendar.daysInWeek)
      return result
    case .EpochSeconds:
      return nil
    case .TimeZone:
      if string.characters.count >= 3 {
        let index = advance(string.startIndex, 3)
        let timeZoneName = string.substringToIndex(index)
        let remainder = string.substringFromIndex(index)
        container.timeZone = Tailor.TimeZone(name: timeZoneName)
        return remainder
      }
      else {
        return nil
      }
    case .TimeZoneOffset:
      if string.characters.count < 6 {
        return nil
      }
      if (string[string.startIndex] != "+" && string[string.startIndex] != "-") || string[advance(string.startIndex, 3)] != ":" {
        return nil
      }
      let hours = Int(string.substringWithRange(advance(string.startIndex, 1)...advance(string.startIndex, 2)))
      let minutes = Int(string.substringWithRange(advance(string.startIndex, 4)...advance(string.startIndex, 5)))
      if hours == nil || minutes == nil {
        return nil
      }
      return string.substringFromIndex(advance(string.startIndex, 6))
    case .Meridian:
      if string.characters.count < 2 {
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
  /**
    This method initializes a time format component with a string literal.
    
    - parameter value:   The string literal.
    */
  public init(stringLiteral value: String) {
    self = .Literal(value)
  }
  
  /**
    This method initializes a time format component with a string literal.
  
    - parameter value:   The string literal.
  */
  public init(unicodeScalarLiteral value: String) {
    self = .Literal(value)
  }
  
  /**
    This method initializes a time format component with a string literal.
  
    - parameter value:   The string literal.
  */
  public init(extendedGraphemeClusterLiteral value: String) {
    self = .Literal(value)
  }
}

/**
  This extension provides some stock time formats.
  */
public extension TimeFormat {
  /** This formats a time as a SQL timestamp. */
  public static let Database = TimeFormat(.Year, "-", .Month, "-", .Day, " ", .Hour, ":", .Minute, ":", .Seconds)
  
  /** This formats a time as a SQL time. */
  public static let DatabaseTime = TimeFormat(.Hour, ":", .Minute, ":", .Seconds)
  
  /** This formats a time as a SQL date. */
  public static let DatabaseDate = TimeFormat(.Year, "-", .Month, "-", .Day)
  
  /** The time format for HTTP dates and times specified by RFC 822. */
  public static let Rfc822 = TimeFormat(.WeekDayName(abbreviate: true), ", ", .Day, " ", .MonthName(abbreviate: true), " ", .Year, " ", .Hour, ":", .Minute, ":", .Seconds, " ", .TimeZone)
  
  public static let Rfc850 = TimeFormat(.WeekDayName(abbreviate: false), ", ", .Day, "-", .MonthName(abbreviate: true), "-", .YearWith(padding: "0", length: 2, truncate: true), " ", .Hour, ":", .Minute, ":", .Seconds, " ", .TimeZone)
  
  public static let Posix = TimeFormat(.WeekDayName(abbreviate: true), " ", .MonthName(abbreviate: true), " ", .DayWith(padding: " "), " ", .Hour, ":", .Minute, ":", .Seconds, " ", .Year)
  
  
  /** This formats a time for a cookie. */
  public static let Cookie = Rfc822
  
  /**
    This gets a full description of a timestamp with all the date and time
    components in a human-readable format.
    */
  public static let Full = TimeFormat(.DayWith(padding: nil), " ", .MonthName(abbreviate: false), ", ", .Year, ", ", .HourWith(twelveHour: false, padding: nil), ":", .Minute, ":", .Seconds, " ", .TimeZone)
  
  /**
    This gets a full description of a timestamp with all the date and time
    components in a human-readable format, based on US date and time formats.
    */
  public static let FullUS = TimeFormat(.MonthName(abbreviate: false), " ", .DayWith(padding: nil), ", ", .Year, ", ", .HourWith(twelveHour: true, padding: nil), ":", .Minute, ":", .Seconds, " ", .Meridian, " ", .TimeZone)
  
  /**
    This gets a full description of a date in a human-readable format.
    */
  public static let FullDate = TimeFormat(.DayWith(padding: nil), " ", .MonthName(abbreviate: false), ", ", .Year)
  
  /**
    This gets a full description of a date in a human-readable format using the
    US date and time formats.
    */
  public static let FullDateUS = TimeFormat(.MonthName(abbreviate: false), " ", .DayWith(padding: nil), ", ", .Year)

  /**
    This gets a full description of a time in a human-readable format.
    */
  public static let FullTime = TimeFormat(.HourWith(twelveHour: false, padding: nil), ":", .Minute, ":", .Seconds, " ", .TimeZone)
  
  /**
    This gets a full description of a time in a human-readable format, based on
    US date and time formats.
    */
  public static let FullTimeUS = TimeFormat(.HourWith(twelveHour: true, padding: nil), ":", .Minute, ":", .Seconds, " ", .Meridian, " ", .TimeZone)
  
  /**
    This gets a date in a format suitable for headers in emails.
    */
  public static let Rfc2822 = TimeFormat(.DayWith(padding: nil), " ", .MonthName(abbreviate: true), " ", .Year, " ", .Hour, ":", .Minute, ":", .Seconds, " ", .TimeZoneOffset)
}