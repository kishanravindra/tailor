/**
  This structure represents a time in a day, independent of the day it occurs
  on.
  */
public struct Time: Comparable, CustomStringConvertible {
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
}

/**
  This method deterimines if two times are equal.

  Two times are equal when they have the same hour, minute, second, nanosecond,
  and time zone.

  - parameter lhs:   The first time.
  - parameter rhs:   The second time.
  - returns:     Whether the two times are equal.
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
  
  - parameter lhs:   The first time.
  - parameter lhs:   The second time.
  - returns:     Whether the first time is before the second time.
  */
public func <(lhs: Time, rhs: Time) -> Bool {
  return lhs.hour < rhs.hour ||
    (lhs.hour == rhs.hour && lhs.minute < rhs.minute) ||
    (lhs.hour == rhs.hour && lhs.minute < rhs.minute) ||
    (lhs.hour == rhs.hour && lhs.minute == rhs.minute && lhs.second < rhs.second) ||
    (lhs.hour == rhs.hour && lhs.minute == rhs.minute && lhs.second == rhs.second && lhs.nanosecond < rhs.nanosecond)
}