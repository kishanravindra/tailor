/**
  This protocol describes a type that supports time interval arithmetic.
  */
public protocol TimeIntervalArithmeticType {
  /**
    This method adds a time interval to this time, and returns a new time with
    the result of the addition.
   
    - parameter interval:     The time interval to add.
    - returns:                The new time.
    */
  func byAddingInterval(interval: TimeInterval) -> Self
  
  /**
    This method gets the gap between this time and another time of the same
    type.
  
    - parameter other:    The time that we are getting the interval to
    - returns:            The interval between them.
    */
  func intervalSince(other: Self) -> TimeInterval
}

/**
  This method adds a time interval to a time.

  See TimeIntervalArithmeticType#byAddingInterval for more details.

  - parameter lhs:    The time that we are adding to.
  - parameter rhs:    The interval we are adding.
  - returns:          The new timestamp.
  */
public func +<TimeType: TimeIntervalArithmeticType>(lhs: TimeType, rhs: TimeInterval) -> TimeType {
  return lhs.byAddingInterval(rhs)
}

/**
  This method substracts a time interval from a time.

  See TimeIntervalArithmeticType#byAddingInterval for more details.

  - parameter lhs:    The time that we are subtracting from.
  - parameter rhs:    The time interval we are subtracting.
  - returns:          The new timestamp.
  */
public func -<TimeType: TimeIntervalArithmeticType>(lhs: TimeType, rhs: TimeInterval) -> TimeType {
  return lhs.byAddingInterval(rhs.invert())
}


/**
  This method gets the interval between two timestamps.

  - parameter lhs:    The first timestamp
  - parameter rhs:    The second timestamp
  - returns:          The interval that would have to be added to the second
                      timestamp to produce the first timestamp
  */
public func -<TimeType: TimeIntervalArithmeticType>(lhs: TimeType, rhs: TimeType) -> TimeInterval {
  return lhs.intervalSince(rhs)
}