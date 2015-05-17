/**
  This struct encapsulates a date, without any time information.
  */
public struct Date: Comparable,Printable {
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

    :param: year      The year
    :param: month     The month
    :param: day       The day
    :param: calendar  The calendar system the date is expressed in.
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
  
    :param: timeZone    The time zone that the resulting time should be in.
    :returns:           A timestamp for the beginning of the day.
    */
  public func beginningOfDay(_ timeZone: TimeZone = TimeZone.defaultTimeZone) -> Timestamp {
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
  
    :param: timeZone    The time zone that the resulting time should be in.
    :returns:           A timestamp for the beginning of the day.
    */
  public func endOfDay(_ timeZone: TimeZone = TimeZone.defaultTimeZone) -> Timestamp {
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
}

/**
  This method determines if two dates are equal.

  Two dates are equal when they have the same components and the same calendar
  system.

  :param: lhs   The first date
  :param: rhs   The second date
  :returns:     Whether the two dates are equal.
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

  :param: lhs   The first date
  :param: rhs   The second date
  :returns:     Whether the first date is before the second.
  */
public func <(lhs: Date, rhs: Date) -> Bool {
  return lhs.year < rhs.year ||
    (lhs.year == rhs.year && lhs.month < rhs.month) ||
    (lhs.year == rhs.year && lhs.month == rhs.month && lhs.day < rhs.day)
}