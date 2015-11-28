/**
  This struct encapsulates a date, without any time information.
  */
public struct Date: Comparable, CustomStringConvertible, TimeIntervalArithmeticType {
  /** The calendar system the date is expressed in. */
  public let calendar: Calendar
  
  /** The year on the calendar. */
  public let year: Int
  
  /** The month on the calendar. */
  public let month: Int
  
  /** The day on the calendar. */
  public let day: Int
  
  /**
    This initializer creates a date.

    - parameter year:      The year
    - parameter month:     The month
    - parameter day:       The day
    - parameter calendar:  The calendar system the date is expressed in.
    */
  public init(year: Int, month: Int, day: Int, calendar: Calendar = GregorianCalendar()) {
    self.year = year
    self.month = month
    self.day = day
    self.calendar = calendar
  }
  
  /**
    This method gets a description of the date for debugging.
    */
  public var description: String {
    return String(format: "%04i-%02i-%02i", year, month, day)
  }
  
  /**
    This method gets a timestamp at the beginning of the day.
  
    - parameter timeZone:     The time zone that the resulting time should be
                              in.
    - returns:                A timestamp for the beginning of the day.
    */
  public func beginningOfDay(timeZone: TimeZone = TimeZone.systemTimeZone()) -> Timestamp {
    return Timestamp(
      year: year,
      month: month,
      day: day,
      hour: 0,
      minute: 0,
      second: 0,
      nanosecond: 0,
      timeZone: timeZone,
      calendar: calendar)
  }
  
  /**
    This method gets a timestamp at the end of the day.
  
    This will be on this day, at the last hour, minute, and second. The
    nanosecond will be set to 0.
  
    - parameter timeZone:     The time zone that the resulting time should be
                              in.
    - returns:                A timestamp for the beginning of the day.
    */
  public func endOfDay(timeZone: TimeZone = TimeZone.systemTimeZone()) -> Timestamp {
    return Timestamp(
      year: year,
      month: month,
      day: day,
      hour: calendar.hoursPerDay - 1,
      minute: calendar.minutesPerHour - 1,
      second: calendar.secondsPerMinute - 1,
      nanosecond: 0,
      timeZone: timeZone,
      calendar: calendar)
  }
  
  /**
    This method gets the current day.
    */
  public static func today() -> Date {
    return Timestamp.now().date
  }
  
  /**
    This method adds a time interval to this date.

    - parameter interval:   The interval to add.
    - returns:              The new date.
    */
  public func byAddingInterval(interval: TimeInterval) -> Date {
    var year = self.year + interval.years
    var month = self.month + interval.months
    var day = self.day + interval.days
    
    Timestamp.normalizeDate(year: &year, month: &month, day: &day, inCalendar: calendar)
    return Date(year: year, month: month, day: day, calendar: calendar)
  }
  
  /**
    This method gets the time interval between this date and another date.
   
    - parameter other:    The other date.
    - returns:            The time interval.
    */
  public func intervalSince(other: Date) -> TimeInterval {
    let interval = TimeInterval(
      years: self.year - other.year,
      months: self.month - other.month,
      days: self.day - other.day
    )
    let sign = (self < other) ? -1 : 1
    return Timestamp.normalizeTimeInterval(interval, withSign: sign, inCalendar: calendar, inMonth: month)
  }
}

/**
  This method determines if two dates are equal.

  Two dates are equal when they have the same components and the same calendar
  system.

  - parameter lhs:    The first date
  - parameter rhs:    The second date
  - returns:          Whether the two dates are equal.
  */
public func ==(lhs: Date, rhs: Date) -> Bool {
  return lhs.year == rhs.year &&
    lhs.month == rhs.month &&
    lhs.day == rhs.day &&
    lhs.calendar.identifier == rhs.calendar.identifier
}

/**
  This method determines if one date is before another.

  A date is before another if it is an earlier year, an earlier month in the
  same year, or an earlier day in the same month and year.

  - parameter lhs:    The first date
  - parameter rhs:    The second date
  - returns:          Whether the first date is before the second.
  */
public func <(lhs: Date, rhs: Date) -> Bool {
  return lhs.year < rhs.year ||
    (lhs.year == rhs.year && lhs.month < rhs.month) ||
    (lhs.year == rhs.year && lhs.month == rhs.month && lhs.day < rhs.day)
}