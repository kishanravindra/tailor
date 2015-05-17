/**
  This protocol specifies that a type can be used to format a timestamp.
  */
public protocol TimeFormatter {
  /**
    This method formats a timestamp using the rules of this time formatter.
    */
  func formatTime(timestamp: Timestamp) -> String
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
  public static let Database = TimeFormat(.Year, "-", .Month, "-", .Day, " ", .Hour, ":", .Minute, ":", .Seconds, " ", .TimeZoneOffset)
}