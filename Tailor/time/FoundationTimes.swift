import Foundation

extension Timestamp {
  /**
    This method initializes a timestamp to the current time.
    
    - returns:   The new timestamp.
  */
  public static func now() -> Timestamp {
    return self.init(epochSeconds: NSDate().timeIntervalSince1970)
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

/**
  This method gets the system calendar.

  If we cannot find a calendar matching the system calendar, this will fall
  back to the Gregorian calendar.

  This will cache the result, so it will not update if the time zone is changed
  while the app is running.
  */
public func SystemCalendar() -> Calendar {
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