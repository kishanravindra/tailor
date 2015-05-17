/**
  This structure represents a gap between two times.

  This is stored as a series of local time components so that it can accurately
  store semantically meaningful intervals like "3 months", which may have a
  varying length in seconds.

  Any component can be positive or negative, and it is valid to have
  combinations of the two, like an interval of 1 month and -10 days.
  */
public struct TimeInterval: Equatable,Printable {
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

    :param: years         The number of years in the interval.
    :param: months        The number of months in the interval.
    :param: days          The number of days in the interval.
    :param: hours         The number of hours in the interval.
    :param: minutes       The number of seconds in the interval.
    :param: seconds       The number of seconds in the interval.
    :param: nanoseconds   The number of nanoseconds in the interval.
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

    :returns:   The inverted time interval.
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
  
  /**
    This method gets a human readable description for a time interval.
    */
  public var description: String {
    let components = [(years, "years"), (months, "months"), (days, "days"), (minutes, "minutes"), (seconds, "seconds")]
    let textComponents = removeNils(components.map {
      (value, text) -> String? in
      if value == 0 {
        return nil
      }
      else if value == 1 {
        let text = text.substringToIndex(advance(text.endIndex, -1))
        return "\(value) \(text)"
      }
      else {
        return "\(value) \(text)"
      }
    })
    var text = join(", ", textComponents)
    if nanoseconds != 0 {
      text += String(format: ", %.5f nanoseconds", nanoseconds)
    }
    return text
  }
}

/**
  This method determines if two time intervals are equal.

  They are equal if all their components are equal.
  
  :param: lhs   One of the intervals we are checking.
  :param: rhs   The other interval we are checking.
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

  :param: lhs   The left-hand side of the addition.
  :param: rhs   The right-hand side of the addition.
  :returns:     A time interval with the sum.
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

  :param: lhs   The left-hand side of the subtraction.
  :param: rhs   The right-hand side of the subtraction.
  :returns:     A time interval with the difference
  */
public func -(lhs: TimeInterval, rhs: TimeInterval) -> TimeInterval {
  return lhs + rhs.invert()
}

/**
  This method adds a time interval to a timestamp.

  See Timestamp#byAddingInterval for more details.

  :param: lhs   The timestamp that we are adding to.
  :param: rhs   The interval we are adding.
  :returns:     The new timestamp.
  */
public func +(lhs: Timestamp, rhs: TimeInterval) -> Timestamp {
  return lhs.byAddingInterval(rhs)
}

/**
  This method substracts a time interval from a timestamp.

  See Timestamp#byAddingInterval for more details.

  :param: lhs   The timestamp that we are subtracting from.
  :param: rhs   The time interval we are subtracting.
  :returns:     The new timestamp.
  */
public func -(lhs: Timestamp, rhs: TimeInterval) -> Timestamp {
  return lhs.byAddingInterval(rhs.invert())
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