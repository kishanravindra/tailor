import Foundation

/**
  This extension provides a shorthand for initializing dates with components.
  */
public extension NSDate {
  /**
    This method initializes a date with components.

    :param: year      The year
    :param: month     The month
    :param: day       The day
    :param: hour      The hour
    :param: minute    The minute
    :param: second    The second
    */
  public convenience init(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, timeZone: NSTimeZone? = nil) {
    let components = NSDateComponents(year: year, month: month, day: day,
      hour: hour, minute: minute, second: second, timeZone: timeZone)
    let calendar = NSCalendar.currentCalendar()
    let date = calendar.dateFromComponents(components)!
    self.init(timeInterval: 0, sinceDate: date)
  }
  
  /**
    This method formats a date using the application's date formatters.

    :param: format    The name of the format to use.
    :param: timeZone  The time zone to use for formatting the date. If this is
                      not provided, we will use the formatter's current time
                      zone.
    :returns:         The formatted date, or nil if the format was not found.
    */
  public func format(format: String, timeZone: NSTimeZone? = nil) -> String? {
    if let formatter = Application.sharedApplication().dateFormatters[format] {
      var oldTimeZone: NSTimeZone! = formatter.timeZone
      if timeZone != nil {
        formatter.timeZone = timeZone
      }
      let result = formatter.stringFromDate(self)
      formatter.timeZone = oldTimeZone
      return result
    }
    else {
      return nil
    }
  }
  
  /**
    This method format's a date using the application's date formatters.

    :param: format    The name of the format to use.
    :param: timeZone  The name of the time zone to use for formatting the date.
    :returns:         The formatted date, or nil if the format was not found.
    */
  public func format(format: String, timeZoneNamed zoneName: String) -> String? {
    return self.format(format, timeZone: NSTimeZone(name: zoneName))
  }
}

/**
  This extension provides a shorthand for initalize date components with their
  constituent parts.
  */
public extension NSDateComponents {
  /**
    This method initializes a date component set with its constituent parts.
    
    :param: year      The year
    :param: month     The month
    :param: day       The day
    :param: hour      The hour
    :param: minute    The minute
    :param: second    The second
    */
  public convenience init(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, timeZone: NSTimeZone? = nil) {
    self.init()
    self.year = year
    self.month = month
    self.day = day
    self.hour = hour
    self.minute = minute
    self.second = second
    self.timeZone = timeZone ?? NSTimeZone.systemTimeZone()
  }
}