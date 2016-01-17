import Foundation

extension Timestamp {
  /**
    This method initializes a timestamp to the current time.
    
    - returns:   The new timestamp.
  */
  public static func now() -> Timestamp {
    if let time = TIMESTAMP_FROZEN_TIME {
      return self.init(epochSeconds: time)
    }
    else {
      return self.init(epochSeconds: NSDate().timeIntervalSince1970)
    }
  }
  
  /**
    This method freezes the current time. After calling this, `Timestamp.now`
    will always return the same value, until you call `unfreeze`.
  
    `freeze` and `unfreeze` are automatically called in the setUp and tearDown
    methods in TailorTestCase, so any test cases that inherit from that will
    have their clock frozen for the duration of the tests.
  
    - parameter timestamp:    The value to return from `Timestamp.now`.
    */
  public static func freeze(at timestamp: Timestamp = Timestamp.now()) {
    TIMESTAMP_FROZEN_TIME = timestamp.epochSeconds
  }
  
  /**
    This method unfreezes the current time. After calling this, `Timestamp.now`
    will return the current clock time.
    */
  public static func unfreeze() {
    TIMESTAMP_FROZEN_TIME = nil
  }
  
  //MARK: - Foundation Bridging
  
  /**
    This method initializes a timestamp to match the timestamp in a foundation
    date.
    
    - parameter foundationDate:    The foundation date whose timestamp we should use.
    */
  public init(foundationDate: NSDate) {
    self.init(epochSeconds: foundationDate.timeIntervalSince1970)
  }
  
  /**
    The foundation date for this timestamp.
    */
  public var foundationDateValue: NSDate {
    return NSDate(timeIntervalSince1970: epochSeconds)
  }
}

private var TIMESTAMP_FROZEN_TIME: Timestamp.EpochInterval? = nil

/**
  This method gets the system calendar.

  If we cannot find a calendar matching the system calendar, this will fall
  back to the Gregorian calendar.

  This will cache the result, so it will not update if the time zone is changed
  while the app is running.
  */
public func SystemCalendar() -> Calendar {
  #if os(Linux)
    return GregorianCalendar()
  #else
    if SYSTEM_CALENDAR != nil {
      return SYSTEM_CALENDAR
    }
    switch(NSCalendar.currentCalendar().calendarIdentifier) {
    case NSCalendarIdentifierGregorian:
      SYSTEM_CALENDAR = GregorianCalendar()
    case NSCalendarIdentifierIslamicTabular:
      SYSTEM_CALENDAR = IslamicCalendar()
    default:
      SYSTEM_CALENDAR = GregorianCalendar()
    }
    return SYSTEM_CALENDAR
  #endif
}

private var SYSTEM_CALENDAR: Calendar!

extension TimeZone {
  /**
    This method gets the system time zone.
  
    This will cache the result, so it will not update if the system time zone
    is changed while the app is running.
  
    */
  public static func systemTimeZone() -> TimeZone {
    let zone = NSTimeZone.systemTimeZone()
    return TimeZone(name: zone.name)
  }
}