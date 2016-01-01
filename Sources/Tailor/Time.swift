/**
  This structure represents a time in a day, independent of the day it occurs
  on.
  */
public struct Time: Comparable, CustomStringConvertible, TimeIntervalArithmeticType {
  /** The hour, in 24 hour time. */
  public let hour: Int
  
  /** The minute */
  public let minute: Int
  
  /** The second */
  public let second: Int
  
  /** The nanosecond */
  public let nanosecond: Double
  
  /** The time zone that this time is expressed in. */
  public let timeZone: TimeZone
  
  /**
    This initializer creates a time.

    - parameter hour:          The hour
    - parameter minute:        The minute
    - parameter second:        The second
    - parameter nanosecond:    The nanosecond
    - parameter timeZone:      The time zone that this time is expressed in.
    */
  public init(hour: Int, minute: Int, second: Int, nanosecond: Double, timeZone: TimeZone = TimeZone.systemTimeZone()) {
    self.hour = hour
    self.minute = minute
    self.second = second
    self.nanosecond = nanosecond
    self.timeZone = timeZone
  }
  
  /**
    This method gets a description of the time for debugging.
    */
  public var description: String {
    return String(format: "%02i:%02i:%02i %@", hour, minute, second, timeZone.name)
  }
  
  /**
    This method gets a timestamp that is on the current date at the time in this
    value.
    */
  public var today: Timestamp {
    return Timestamp.now().change(hour: hour, minute: minute, second: second, nanosecond: nanosecond)
  }
  
  //MARK: - Time Intervals
  
  /**
    This method adds a time interval to this time.

    - parameter interval:     The interval to add.
    - returns:                The new time.
    */
  public func byAddingInterval(interval: TimeInterval) -> Time {
    var day = 0
    var hour = self.hour + interval.hours
    var minute = self.minute + interval.minutes
    var second = self.second + interval.seconds
    var nanosecond = self.nanosecond + interval.nanoseconds
    
    Timestamp.normalizeTime(day: &day, hour: &hour, minute: &minute, second: &second, nanosecond: &nanosecond, inCalendar: GregorianCalendar())
    
    return Time(hour: hour, minute: minute, second: second, nanosecond: nanosecond, timeZone: timeZone)
  }
  
  /**
    This method gets the interval between this time and another time.
   
    - parameter other:    The other time.
    - returns:            The interval.
    */
  public func intervalSince(other: Time) -> TimeInterval {
    let interval = TimeInterval(
      hours: self.hour - other.hour,
      minutes: self.minute - other.minute,
      seconds: self.second - other.second,
      nanoseconds: self.nanosecond - other.nanosecond
    )
    
    let sign = (self < other ? -1 : 1)
    return Timestamp.normalizeTimeInterval(interval, withSign: sign, inCalendar: GregorianCalendar(), inMonth: 1)
  }
}

/**
  This method deterimines if two times are equal.

  Two times are equal when they have the same hour, minute, second, nanosecond,
  and time zone.

  - parameter lhs:    The first time.
  - parameter rhs:    The second time.
  - returns:          Whether the two times are equal.
  */
public func ==(lhs: Time, rhs: Time) -> Bool {
  return lhs.hour == rhs.hour &&
    lhs.minute == rhs.minute &&
    lhs.second == rhs.second &&
    lhs.nanosecond == rhs.nanosecond &&
    lhs.timeZone == rhs.timeZone
}

/**
  This method determines if one time is before another.
  
  - parameter lhs:    The first time.
  - parameter lhs:    The second time.
  - returns:          Whether the first time is before the second time.
  */
public func <(lhs: Time, rhs: Time) -> Bool {
  return lhs.hour < rhs.hour ||
    (lhs.hour == rhs.hour && lhs.minute < rhs.minute) ||
    (lhs.hour == rhs.hour && lhs.minute < rhs.minute) ||
    (lhs.hour == rhs.hour && lhs.minute == rhs.minute && lhs.second < rhs.second) ||
    (lhs.hour == rhs.hour && lhs.minute == rhs.minute && lhs.second == rhs.second && lhs.nanosecond < rhs.nanosecond)
}

extension Int {
  /**
    This method gets a time at this hour.

    - parameter minute:     The minutes past the start of the hour.
    - returns:              The time.
    */
  public func oClock(minute: Int = 0) -> Time {
    return Time(hour: self, minute: minute, second: 0, nanosecond: 0)
  }
  
  /**
    This method gets the time that's thirty minutes past this hour.
    */
  public var thirty: Time {
    return self.oClock(30)
  }
}