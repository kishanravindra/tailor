/**
  This protocol describes a calendar system.

  A calendar can be instantiated with a year, and describes how the days in the
  year are laid out.
  */
public protocol Calendar {
  /**
    This method creates a calendar of this type in a different year.
  
    It would be an initializer, but there are bugs in creating protocol types
    dynamically.

    - parameter year:   The numeric indentifier for the year, in the calendar's
                        own numbering system.
    - returns:          The new calendar
    */
  func inYear(year: Int) -> Calendar
  
  /** An identifier for the calendar for use in localizing parts of a date. */
  var identifier: String { get }
  
  /** The year on the calendar. */
  var year: Int { get }
  
  /** The number of days in the year. */
  var days: Int { get }
  
  /** The number of months in the year. */
  var months: Int { get }
  
  /**
    The number of days in a particular month.

    - parameter month:   The month, where 1 is the first month in the year.
    */
  func daysInMonth(month: Int) -> Int
  
  /**
    The number of days in a week.
    */
  var daysInWeek: Int { get }
  
  /**
    This method describes how the Unix epoch is represented in this calendar.

    The Unix epoch is midnight UTC on 1 January, 1970, on the Gregorian
    calendar.

    This method must return a tuple containg:

    1. The year on this calendar when the Unix epoch occurs.
    2. The number of seconds between the start of that year and the Unix epoch.
    3. The day of the week of the first day in that year.
  
    The return value of this method must be the same in every year.
    */
  var unixEpochTime: (Int, Timestamp.EpochInterval, Int) { get }
  
  /** The number of hours in a day in this calendar. */
  var hoursPerDay: Int { get }
  
  /** The number of minutes in an hour in this calendar. */
  var minutesPerHour: Int { get }
  
  /** The number of seconds in a minute in this calendar. */
  var secondsPerMinute: Int { get }
}

/**
  This structure represents a year on the Gregorian calendar.
  */
public struct GregorianCalendar: Calendar {
  /** The year we are modeling. */
  public let year: Int
  
  /** The number of days in this year. */
  public let days: Int
  
  /** The number of months in this year. */
  public let months: Int = 12
  
  /** The number of days in a week. */
  public let daysInWeek = 7
  
  /** The identifier for the calendar in translations. */
  public let identifier = "gregorian"
  
  /**
    This initializer creates a calendar for year 0.

    This is mostly useful as an input to methods that will supply their own
    year.
    */
  public init() {
    self.init(0)
  }
  
  /**
    This initializer creates a calendar instance for a year.

    - parameter year:    The year on the calendar.
    */
  public init(_ year: Int) {
    self.year = year
    self.days = GregorianCalendar.isLeapYear(year) ? 366: 365
  }
  
  /**
    This method creates a calendar instance for a year.

    - parameter year:    The year on the calendar.
    */
  public func inYear(year: Int) -> Calendar {
    return GregorianCalendar(year)
  }

  /**
    This method determines if a given year is a leap year.
  
    A year is a leap year if the following conditions hold:
  
    1. The year is divisible by 4
    2. The year is *not* divisible by 100, or *is* divisible by 400.

    - parameter year:     The year to check.
    - returns:            Whether the year is a leap year.
    */
  public static func isLeapYear(year: Int) -> Bool {
    return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
  }
  
  /**
    This method describes how the Unix epoch is represented on this calendar.

    The Unix epoch is in the year 1970, and is 0 seconds into the year. That
    year begins on a Thursday.
    */
  public let unixEpochTime = (1970,0.0,5)
  
  /**
    This method gets the number of days in a month on this calendar.

    Months 1,3,5,7,8,10, and 12 have 31 days. Months 4,6,9, and 11 have 30 days.
    Month 2 has 28 days in most years, and 29 days in leap years, as described
    in the isLeapYear function.

    - parameter month:    The month that we are counting days for.
    - returns:            The number of days in that month.
    */
  public func daysInMonth(month: Int) -> Int {
    switch(month) {
    case 1,3,5,7,8,10,12:
      return 31
    case 4,6,9,11:
      return 30
    case 2:
      return GregorianCalendar.isLeapYear(year) ? 29 : 28
    default:
      return 0
    }
  }
  
  /** This calendar has 24 hours in a day. */
  public let hoursPerDay = 24
  
  /** This calendar has 60 minutes in an hour. */
  public let minutesPerHour = 60
  
  /** This calendar has 60 seconds in a minute. */
  public let secondsPerMinute = 60
}

/**
  This structure represents a year on the Islamic calendar.

  We use a tabular Islamic calendar to provide simple conversion.
  */
public struct IslamicCalendar: Calendar {
  /** The year we are modeling. */
  public let year: Int
  
  /** The number of days in this year. */
  public let days: Int
  
  /** The number of months in this year. */
  public let months: Int = 12
  
  /** The number of days in a week. */
  public let daysInWeek = 7
  
  /** The identifier for the calendar in translations. */
  public let identifier = "islamic"
  
  /**
    This initializer creates a calendar for year 0.
  
    This is mostly useful as an input to methods that will supply their own
    year.
    */
  public init() {
    self.init(0)
  }
  
  /**
    This initializer creates a calendar instance for a year.
  
    - parameter year:    The year on the calendar.
    */
  public init(_ year: Int) {
    self.year = year
    self.days = IslamicCalendar.isLeapYear(year) ? 355: 354
  }
  
  /**
  This method creates a calendar instance for a year.
  
  - parameter year:    The year on the calendar.
  */
  public func inYear(year: Int) -> Calendar {
    return IslamicCalendar(year)
  }
  
  /**
    This method determines if a year is a leap year in the Islamic calendar.
  
    We consider any year ending in 2, 5, 7, 10, 13, 16, 18, 21, 24, 26, or 29
    to be a leap year.

    - parameter year:     The year we are checking.
    - returns:            Whether the year is a leap year.
    */
  public static func isLeapYear(year: Int) -> Bool {
    switch(year % 30) {
    case 2,5,7,10,13,16,18,21,24,26,29:
      return true
    default:
      return false
    }
  }
  
  /**
    This method describes how the Unix epoch is represented on this calendar.
    
    The Unix epoch is in the year 1389, and is 24883200 seconds into the year.
    */
  public let unixEpochTime = (1389,24883200.0,4)
  
  /**
    This method gets the number of days in a month on this calendar.
  
    Even numbered months have 29 days and odd numbered months have 30 days. In
    leap years, month 12 has 30 days.
  
    - parameter month:    The month that we are counting days for.
    - returns:            The number of days in that month.
    */
  public func daysInMonth(month: Int) -> Int {
    if month % 2 == 1 {
      return 30
    }
    else if month == 12 && IslamicCalendar.isLeapYear(year) {
      return 30
    }
    else {
      return 29
    }
  }
  
  /** This calendar has 24 hours in a day. */
  public let hoursPerDay = 24
  
  /** This calendar has 60 minutes in an hour. */
  public let minutesPerHour = 60
  
  /** This calendar has 60 seconds in a minute. */
  public let secondsPerMinute = 60
}

/**
  This structure represents a year on the Hebrew calendar.
  */
public struct HebrewCalendar: Calendar {
  /** The year we are modeling. */
  public let year: Int
  
  /** The number of days in this year. */
  public let days: Int
  
  /** The number of days in a week. */
  public let daysInWeek = 7
  
  /**
    The identifier for the calendar in translations.
    
    Unlike most calendars, this identifier changes from year to year. In leap
    years, this will be `hebrew_leap`. In common years, this will be `hebrew`.
    */
  public let identifier: String
  
  /** The number of months in this year. */
  public var months: Int { return HebrewCalendar.isLeapYear(year) ? 13 : 12 }
  
  /**
    The number of days added to this year to correct for the days of the week
    of holidays.
    */
  public let numberOfLeapDays: Int
  
  /** Whether this year has a leap month. */
  public let leapYear: Bool
  
  /**
    This initializer creates a calendar for year 0.
    
    This is mostly useful as an input to methods that will supply their own
    year.
    */
  public init() {
    self.init(0)
  }
  
  /**
    This initializer creates a calendar instance for a year.
    
    - parameter year:    The year on the calendar.
    */
  public init(_ year: Int) {
    self.year = year
    let numberOfLeapDays = HebrewCalendar.numberOfLeapDays(year)
    self.numberOfLeapDays = numberOfLeapDays
    
    let leapYear = HebrewCalendar.isLeapYear(year)
    self.leapYear = leapYear
    
    var days = 354
    if leapYear { days += 30 }
    
    days += numberOfLeapDays
    self.days = days
    
    identifier = (leapYear ? "hebrew_leap" : "hebrew")
  }
  
  /**
    This method creates a calendar instance for a year.
    
    - parameter year:    The year on the calendar.
    */
  public func inYear(year: Int) -> Calendar {
    return HebrewCalendar(year)
  }
  
  /**
    This method gets the number of leap days that are added or removed from a
    year to correct the days of the week of holidays.

    - parameter year:   The year we are checking.
    - returns:          Either 1, -1, or 0.
    */
  public static func numberOfLeapDays(year: Int) -> Int {
    // Reference Molad is 2d 5h 204p on year 1
    var molad = 31524
    
    // Add the number of chalakim added in each 19-year cycle, ignoring full
    // weeks
    molad += 69715 * Int((year - 1) / 19)
    
    let cycleYears = (year - 1) % 19
    let leapYears: Int
    switch(cycleYears) {
    case 0..<3: leapYears = 0
    case 3..<6: leapYears = 1
    case 6..<8: leapYears = 2
    case 8..<11: leapYears = 3
    case 11..<14: leapYears = 4
    case 14..<17: leapYears = 5
    default: leapYears = 6
    }
    let commonYears = cycleYears - leapYears
    
    // Add the number of chalakim added in each common year and leap year since
    // the start of the last 19-year cycle, ignoring full weeks
    molad += commonYears * 113196
    molad += leapYears * 152869
    
    // Take a modulus by the number of chalakim per week
    molad = molad % 181440
    
    let leapYearType: Int
    switch(year % 19) {
    case 1,4,9,12,15: leapYearType = 1    // Common year between leap and common
    case 7,18: leapYearType = 2           // Common year between leap and leap
    case 2,5,10,13,16: leapYearType = 3   // Common year between common and leap
    default: leapYearType = 4             // Leap year
    }
    
    let regular = 0
    let complete = 1
    let deficient = -1
    
    // I'll admit I don't fully understand the reasoning between these rules,
    // but they were provided by an online guide and they seem to square with
    // how Foundation is calculating it.
    if molad < 9924 { return deficient }
    else if molad < 22091 { return leapYearType < 4 ? complete : deficient }
    else if molad < 42709 { return complete }
    else if molad < 45360 { return leapYearType < 3 ? regular : complete }
    else if molad < 61764 { return regular }
    else if molad < 71280 { return regular }
    else if molad < 90335 { return leapYearType < 4 ? regular : deficient }
    else if molad < 113604 { return leapYearType < 4 ? regular : complete }
    else if molad < 123120 { return complete }
    else if molad < 130008 { return deficient }
    else if molad < 139524 { return leapYearType == 1 ? complete : deficient }
    else if molad < 151691 { return leapYearType < 4 ? complete : deficient }
    else if molad < 174960 { return complete }
    else { return -1 }
  }
  
  /**
    This method determines if a year is a leap year in the Hebrew calendar.
    
    - parameter year:     The year we are checking.
    - returns:            Whether the year is a leap year.
    */
  public static func isLeapYear(year: Int) -> Bool {
    switch(year % 19) {
    case 3, 6, 8, 11, 14, 17, 0:
      return true
    default:
      return false
    }
  }
  
  /**
    This method describes how the Unix epoch is represented on this calendar.
  
    The Unix epoch is in the year 5730, and is 9504000 seconds into the year.
    */
  public let unixEpochTime = (5730,9504000.0,7)
  
  /**
    This method gets the number of days in a month on this calendar.
  
    Generally, even-numbered months have 29 days and odd-numbered months have
    30 days. In some years, we add a day to month 2, and in some years we remove
    a day from month 3. This is to fix the dates of certain holidays to occur
    only on certain days of the week.
  
    In leap years, we add an entire month of 30 days. In those years, months
    1 through 5 follow the rules above, and months 6 through 13 follow the
    inverse rules, so the even months have 30 days and the odd months have 29
    days.
  
    - parameter month:    The month that we are counting days for.
    - returns:            The number of days in that month.
    */
  public func daysInMonth(month: Int) -> Int {
    if month == 2 && numberOfLeapDays == 1 {
      return 30
    }
    else if month == 3 && numberOfLeapDays == -1 {
      return 29
    }
    else if month < 6 || !leapYear {
      return 29 + month % 2
    }
    else {
      return 30 - month % 2
    }
  }
  
  /** This calendar has 24 hours in a day. */
  public let hoursPerDay = 24
  
  /** This calendar has 60 minutes in an hour. */
  public let minutesPerHour = 60
  
  /** This calendar has 60 seconds in a minute. */
  public let secondsPerMinute = 60
}


/**
  This method determines if two calendars are equal.

  Calendars are equal when they have the same year and identifier.

  - parameter lhs:    The first calendar.
  - parameter rhs:    The second calendar.
  - returns:          Whether the two calendars are equal.
  */
public func ==(lhs: Calendar, rhs: Calendar) -> Bool {
  return lhs.year == rhs.year &&
    lhs.identifier == rhs.identifier
}

/**
  This method determines if two calendars are unequal.

  Calendars are equal when they have the same year and identifier.

  - parameter lhs:    The first calendar.
  - parameter rhs:    The second calendar.
  - returns:          Whether the two calendars are unequal.
  */
public func !=(lhs: Calendar, rhs: Calendar) -> Bool {
  return !(lhs == rhs)
}

public func ==<T: Calendar>(rhs: T, lhs: T) -> Bool {
  return lhs.year == rhs.year
}

extension GregorianCalendar: Equatable {}
extension IslamicCalendar: Equatable {}
extension HebrewCalendar: Equatable {}