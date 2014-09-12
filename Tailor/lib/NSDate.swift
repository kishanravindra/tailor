import Foundation

/**
  This extension provides a shorthand for initializing dates with components.
  */
extension NSDate {
  /**
    This method initializes a date with components.

    :param: year      The year
    :param: month     The month
    :param: day       The day
    :param: hour      The hour
    :param: minute    The minute
    :param: second    The second
    */
  convenience init(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) {
    let components = NSDateComponents(year: year, month: month, day: day,
      hour: hour, minute: minute, second: second)
    let calendar = NSCalendar.currentCalendar()
    let date = calendar.dateFromComponents(components)!
    self.init(timeInterval: 0, sinceDate: date)
  }
}

/**
  This extension provides a shorthand for initalize date components with their
  constituent parts.
  */
extension NSDateComponents {
  /**
    This method initializes a date component set with its constituent parts.
    
    :param: year      The year
    :param: month     The month
    :param: day       The day
    :param: hour      The hour
    :param: minute    The minute
    :param: second    The second
    */
  convenience init(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) {
    self.init()
    self.year = year
    self.month = month
    self.day = day
    self.hour = hour
    self.minute = minute
    self.second = second
  }
}