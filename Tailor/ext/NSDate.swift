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
  
  /**
    This method formats a date using the application's date formatters.

    :param: format    The name of the format to use.
    :returns:         The formatted date, or nil of the format was not found.
    */
  func format(format: String) -> String? {
    if let formatter = Application.sharedApplication().dateFormatters[format] {
      return formatter.stringFromDate(self)
    }
    else {
      return nil
    }
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