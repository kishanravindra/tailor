/**
  This structure represents a gap between two times.

  This is stored as a series of local time components so that it can accurately
  store semantically meaningful intervals like "3 months", which may have a
  varying length in seconds.

  Any component can be positive or negative, and it is valid to have
  combinations of the two, like an interval of 1 month and -10 days.
  */
public struct TimeInterval: Equatable,CustomStringConvertible {
  /** The number of years in the interval. */
  public let years: Int
  
  /** The number of months in the interval. */
  public let months: Int
  
  /** The number of days in the interval. */
  public let days: Int
  
  /** The number of hours in the interval. */
  public let hours: Int
  
  /** The number of minutes in the interval. */
  public let minutes: Int
  
  /** The number of seconds in the interval. */
  public let seconds: Int
  
  /** The number of nanoseconds in the interval. */
  public let nanoseconds: Double
  
  /**
    This initializer creates a time interval from its components.

    - parameter years:         The number of years in the interval.
    - parameter months:        The number of months in the interval.
    - parameter days:          The number of days in the interval.
    - parameter hours:         The number of hours in the interval.
    - parameter minutes:       The number of seconds in the interval.
    - parameter seconds:       The number of seconds in the interval.
    - parameter nanoseconds:   The number of nanoseconds in the interval.
    */
  public init(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0, nanoseconds: Double = 0) {
    self.years = years
    self.months = months
    self.days = days
    self.hours = hours
    self.minutes = minutes
    self.seconds = seconds
    self.nanoseconds = nanoseconds
  }
  
  /**
    This method inverts all the components of the time interval, changing them
    from positive to negative or negative to positive.

    - returns:   The inverted time interval.
    */
  public func invert() -> TimeInterval {
    return TimeInterval(
      years: -1 * years,
      months: -1 * months,
      days: -1 * days,
      hours: -1 * hours,
      minutes: -1 * minutes,
      seconds: -1 * seconds,
      nanoseconds: -1 * nanoseconds
    )
  }
  
  /** This method gets a time that is in the future by this time interval. */
  public var fromNow: Timestamp { return Timestamp.now() + self }
  
  /** This method gets a time that is in the past by this time interval. */
  public var ago: Timestamp { return Timestamp.now() - self }
  
  /**
    This method gets a human readable description for a time interval.
    */
  public var description: String {
    let components = [(years, "years"), (months, "months"), (days, "days"), (hours, "hours"), (minutes, "minutes"), (seconds, "seconds")]
    let textComponents = components.flatMap {
      (value, text) -> String? in
      if value == 0 {
        return nil
      }
      else if value == 1 {
        let text = text.bridge().substringToIndex(text.characters.count - 1)
        return "\(value) \(text)"
      }
      else {
        return "\(value) \(text)"
      }
    }
    var text = textComponents.joinWithSeparator(", ")
    if nanoseconds != 0 {
      text += String(format: ", %.5f nanoseconds", nanoseconds)
    }
    return text
  }
  
  //MARK: - Totals
  
  /**
    This type provides the units of a time interval, for use in normalization.
    */
  public enum Unit {
    case Years
    case Months
    case Days
    case Hours
    case Minutes
    case Seconds
    case Nanoseconds
    
    /** The available units, from largest to smallest. */
    public static let units = [Years,Months,Days,Hours,Minutes,Seconds,Nanoseconds]
  }
  
  /**
    This method gets the total value for this interval expressed in a single
    unit.

    - parameter unit:         The unit that we want the interval expressed in.
    - parameter calendar:     The calendar that we should use when expressing
                              months.
    - returns:                The total value for the interval.
    */
  public func total(unit: Unit, inCalendar calendar: Calendar = SystemCalendar()) -> Int {
    let month = Timestamp.now().month
    let normalized = Timestamp.normalizeTimeInterval(self, withSign: 1, inCalendar: calendar, inMonth: month)
    let years = normalized.years
    var months = normalized.months
    var days = normalized.days
    var hours = normalized.hours
    var minutes = normalized.minutes
    var seconds = normalized.seconds
    var nanoseconds = normalized.nanoseconds
    let index = Unit.units.indexOf(unit) ?? 0
    let includedUnits = Unit.units.prefix(index + 1)
    
    if includedUnits.contains(.Months) {
      months += years * calendar.months
    }
    if includedUnits.contains(.Days) {
      days += months * calendar.daysInMonth(month)
    }
    if includedUnits.contains(.Hours) {
      hours += days * calendar.hoursPerDay
    }
    if includedUnits.contains(.Minutes) {
      minutes += hours * calendar.minutesPerHour
    }
    if includedUnits.contains(.Seconds) {
      seconds += minutes * calendar.secondsPerMinute
    }
    if includedUnits.contains(.Nanoseconds) {
      nanoseconds += Double(seconds) * 1000000000.0
    }
  
    switch(unit) {
    case .Years: return years
    case .Months: return months
    case .Days: return days
    case .Hours: return hours
    case .Minutes: return minutes
    case .Seconds: return seconds
    case .Nanoseconds: return Int(nanoseconds)
    }
  }
}

/**
  This method determines if two time intervals are equal.

  They are equal if all their components are equal.
  
  - parameter lhs:   One of the intervals we are checking.
  - parameter rhs:   The other interval we are checking.
  */
public func ==(lhs: TimeInterval, rhs: TimeInterval) -> Bool {
  let gap = lhs.nanoseconds - rhs.nanoseconds
  return lhs.years == rhs.years &&
    lhs.months == rhs.months &&
    lhs.days == rhs.days &&
    lhs.hours == rhs.hours &&
    lhs.minutes == rhs.minutes &&
    lhs.seconds == rhs.seconds &&
    gap < 0.01 && gap > -0.01
}

/**
  This method adds two time intervals.

  - parameter lhs:    The left-hand side of the addition.
  - parameter rhs:    The right-hand side of the addition.
  - returns:          A time interval with the sum.
  */
public func +(lhs: TimeInterval, rhs: TimeInterval) -> TimeInterval {
  return TimeInterval(
    years: lhs.years + rhs.years,
    months: lhs.months + rhs.months,
    days: lhs.days + rhs.days,
    hours: lhs.hours + rhs.hours,
    minutes: lhs.minutes + rhs.minutes,
    seconds: lhs.seconds + rhs.seconds,
    nanoseconds: lhs.nanoseconds + rhs.nanoseconds
  )
}
/**
  This method subtracts two time intervals.

  - parameter lhs:    The left-hand side of the subtraction.
  - parameter rhs:    The right-hand side of the subtraction.
  - returns:          A time interval with the difference
  */
public func -(lhs: TimeInterval, rhs: TimeInterval) -> TimeInterval {
  return lhs + rhs.invert()
}

/**
  This extension provides shorthand for constructing time intervals out of
  integers.
  */
public extension Int {
  /** A time interval with this number of years. */
  var years: TimeInterval { return TimeInterval(years: self) }
  
  /** A time interval with this number of months. */
  var months: TimeInterval { return TimeInterval(months: self) }
  
  /** A time interval with this number of days. */
  var days: TimeInterval { return TimeInterval(days: self) }
  
  /** A time interval with this number of hours. */
  var hours: TimeInterval { return TimeInterval(hours: self) }
  
  /** A time interval with this number of minutes. */
  var minutes: TimeInterval { return TimeInterval(minutes: self) }
  
  /** A time interval with this number of seconds. */
  var seconds: TimeInterval { return TimeInterval(seconds: self) }
  
  /** A time interval with this number of nanoseconds. */
  var nanoseconds: TimeInterval { return TimeInterval(nanoseconds: Double(self)) }
  
  /** A time interval with this number of years. */
  var year: TimeInterval { return self.years }
  
  /** A time interval with this number of months. */
  var month: TimeInterval { return self.months }
  
  /** A time interval with this number of days. */
  var day: TimeInterval { return self.days }
  
  /** A time interval with this number of hours. */
  var hour: TimeInterval { return self.hours }
  
  /** A time interval with this number of minutes. */
  var minute: TimeInterval { return self.minutes }
  
  /** A time interval with this number of seconds. */
  var second: TimeInterval { return self.seconds }
  
  /** A time interval with this number of nanoseconds. */
  var nanosecond: TimeInterval { return self.nanoseconds }
}

/**
  This extension provides shorthand for constructing time intervals out of
  integers.
  */
public extension Double {
  /** A time interval with this number of nanoseconds. */
  var nanoseconds: TimeInterval { return TimeInterval(nanoseconds: self) }
  
  /** A time interval with this number of nanoseconds. */
  var nanosecond: TimeInterval { return self.nanoseconds }
}