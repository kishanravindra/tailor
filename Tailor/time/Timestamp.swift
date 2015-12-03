/**
  This struct encapsulates a moment in time.
  */
public struct Timestamp: Equatable, Comparable, CustomStringConvertible, TimeIntervalArithmeticType {
  /**
    The type that represents the interval between a timestamp and the Unix
    epoch.
    */
  public typealias EpochInterval = Double
  
  /**
    The number of seconds between this moment and the Unix epoch. The epoch is
    1 January, 1970, 00:00:00 UTC.
  */
  public let epochSeconds: EpochInterval
  
  /**
    The calendar that this timestamp uses to localize its time.
    */
  public let calendar: Calendar
  
  /**
    The time zone that this timestamp is formatted in.
  */
  public let timeZone: TimeZone
  /**
    The year on the Gregorian calendar.
    */
  public let year: Int
  
  /**
    The month on the Gregorian calendar.
    */
  public let month: Int
  
  /**
    The day of the month.
    */
  public let day: Int
  
  /**
    The hour of the day.
    */
  public let hour: Int
  
  /**
    The minute of the hour.
    */
  public let minute: Int
  
  /**
    The second component of the timestamp.
    */
  public let second: Int
  
  /**
    The nanosecond component of the timestamp.
    */
  public let nanosecond: Double
  
  /**
    The day of the week when this timestamp.
    */
  public let weekDay: Int
  
  /** The date components of this timestamp. */
  public var date: Date { return Date(year: year, month: month, day: day, calendar: calendar) }
  
  /** The time components of this timestamp. */
  public var time: Time { return Time(hour: hour, minute: minute, second: second, nanosecond: nanosecond, timeZone: timeZone) }
  
  /**
    This method creates a timestamp around a Unix epoch timestamp.
  
    - parameter epochSeconds:   The number of seconds since the Unix epoch for
                                the new timestamp.
    - parameter timeZone:       The time zone to use when localizing the
                                timestamp.
    - parameter calendar:       An instance of the calendar system to use when
                                localizing the timestamp. The year on the
                                calendar does not matter, it only needs to be
                                of the desired type.

  */
  public init(epochSeconds: EpochInterval, timeZone: TimeZone = TimeZone.systemTimeZone(), calendar: Calendar = GregorianCalendar()) {
    self.epochSeconds = epochSeconds
    self.timeZone = timeZone
    
    let localTime = Timestamp.localTime(epochSeconds, timeZone: timeZone, calendar: calendar)
    self.calendar = calendar.inYear(localTime.year)
    self.year = localTime.year
    self.month = localTime.month
    self.day = localTime.day
    self.hour = localTime.hour
    self.minute = localTime.minute
    self.second = localTime.second
    self.nanosecond = localTime.nanosecond
    self.weekDay = localTime.weekDay
  }
  
  /**
    This initializer creates a timestamp around the calendar components.

    - parameter year:          The year
    - parameter month:         The month
    - parameter day:           The day of the month
    - parameter hour:          The hour
    - parameter minute:        The minute in the hour
    - parameter second:        The second in the minute
    - parameter nanosecond:    The nanoseconds in the second
    - parameter timeZone:      The time zone this is specified in
    */
  public init(year: Int = 1970, month: Int = 1, day: Int = 1, hour: Int = 0, minute: Int = 0, second: Int = 0, nanosecond: Double = 0, timeZone: TimeZone = TimeZone.systemTimeZone(), calendar: Calendar = GregorianCalendar()) {
    self.timeZone = timeZone
    self.year = year
    self.month = month
    self.day = day
    self.hour = hour
    self.minute = minute
    self.second = second
    self.nanosecond = nanosecond
    self.calendar = calendar.inYear(year)
    
    let (epochSeconds,weekDay) = Timestamp.timestampForLocalTime(
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second,
      nanosecond: nanosecond,
      timeZone: timeZone,
      calendar: calendar
    )
    self.epochSeconds = epochSeconds
    self.weekDay = weekDay
  }
  
  //MARK: - Transformations
  
  /**
    This method converts this timestamp into one in a different time zone.

    - parameter zone:     The new time zone
    - returns:            The new timestamp.
    */
  public func inTimeZone(zone: TimeZone) -> Timestamp {
    return Timestamp(epochSeconds: self.epochSeconds, timeZone: zone, calendar: self.calendar)
  }
  
  /**
    This method converts this timestamp into one in a different time zone.
    
    - parameter zone:     The name of the new time zone
    - returns:            The new timestamp.
    */
  public func inTimeZone(zoneName: String) -> Timestamp {
    return self.inTimeZone(TimeZone(name: zoneName))
  }
  
  /**
    This method converts this timestamp into a different calendar system.

    The Unix timestamp will remain the same, but all the local components will
    be adjusted based on the calendar system.

    - parameter calendar:     The new calendar to use.
    - returns:                The new timestamp.
    */
  public func inCalendar(calendar: Calendar) -> Timestamp {
    return Timestamp(epochSeconds: self.epochSeconds, timeZone: self.timeZone, calendar: calendar)
  }
  
  /**
    This method gets a new timestamp with some of the local date and time 
    components changed.

    Any component that is omitted will be filled in with the corresponding 
    value from this timestamp.

    - parameter year:        The new year
    - parameter month:       The new month
    - parameter day:         The new day
    - parameter hour:        The new hour
    - parameter minute:      The new minute
    - parameter second:      The new second
    - parameter nanosecond:  The new nanosecond
    */
  public func change(year year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil, nanosecond: Double? = nil) -> Timestamp {
    return Timestamp(
      year: year ?? self.year,
      month: month ?? self.month,
      day: day ?? self.day,
      hour: hour ?? self.hour,
      minute: minute ?? self.minute,
      second: second ?? self.second,
      nanosecond: nanosecond ?? self.nanosecond,
      timeZone: self.timeZone,
      calendar: self.calendar
    )
  }
  
  /**
    This method limits a number to a range of values by increasing or decreasing
    another value.

    - parameter lhs:      The number to limit
    - parameter range:    The range of values that the number can have. This
                          should always be positive, even if the number is
                          supposed to be negative.
    - parameter sign:     Either 1 or -1, to indicate whether the number should
                          be positive or negative.
    - parameter nextUnit: The number to increase to adjust the original number.
    */
  internal static func limit(inout lhs:  Int, to range: (Int,Int), sign: Int, inout byIncreasing nextUnit: Int) -> Bool {
    var range = range
    if sign < 0 {
      let newRange = (-1 * range.1, -1 * range.0)
      range = newRange
    }
    if lhs < range.0 {
      lhs += (range.1 - range.0) + 1
      nextUnit -= 1
      return true
    }
    if lhs > range.1 {
      lhs -= (range.1 - range.0) + 1
      nextUnit += 1
      return true
    }
    return false
  }
  
  
  /**
    This method limits a number to a range of values by increasing or decreasing
    another value.

    - parameter lhs:      The number to limit
    - parameter range:    The range of values that the number can have. This
                          should always be positive, even if the number is
                          supposed to be negative.
    - parameter sign:     Either 1 or -1, to indicate whether the number should
                          be positive or negative.
    - parameter nextUnit: The number to increase to adjust the original number.
    */
  internal static func limit(inout lhs:  Double, to range: (Double,Double), sign: Int, inout byIncreasing nextUnit: Int) -> Bool {
    var range = range
    if sign < 0 {
      let newRange = (-1 * range.1, -1 * range.0)
      range = newRange
    }
    if lhs < range.0 {
      lhs += (range.1 - range.0) + 1
      nextUnit -= 1
      return true
    }
    if lhs > range.1 {
      lhs -= (range.1 - range.0) + 1
      nextUnit += 1
      return true
    }
    return false
  }
  
  /**
    This method normalizes a date, ensuring that the month and day are both
    valid.

    - parameter year:       The year for the date.
    - parameter month:      The month for the date.
    - parameter day:        The day for the date.
    - parameter calendar:   The calendar that the date is interpreted in.
    */
  internal static func normalizeDate(inout year year: Int, inout month: Int, inout day: Int, inCalendar calendar: Calendar) {
    var calendar = calendar
    calendar = calendar.inYear(year)
    var months = (1,calendar.months)
    
    func handleMonthOverlap() {
      repeat {
        calendar = calendar.inYear(year)
        months = (1,calendar.months)
      } while limit(&month, to: months, sign: 1, byIncreasing: &year)
      calendar = calendar.inYear(year)
    }
    
    var days = (1,calendar.daysInMonth(month))
    repeat {
      handleMonthOverlap()
      calendar = calendar.inYear(year)
      let monthForDayRange = (day < 1 ? (month == 1 ? calendar.months : month - 1) : month)
      days = (1,calendar.daysInMonth(monthForDayRange))
    } while limit(&day, to: days, sign: 1, byIncreasing: &month)
  }
  
  /**
    This method normalizes a time, ensuring that the hour, minute, second, and
    nanosecond are within the valid ranges.

    - parameter day:          The day that we should add to if the hours overrun
    - parameter hour:         The hour for the time
    - parameter minute:       The minute for the time
    - parameter second:       The second for the time
    - parameter nanosecond:   The nanosecond for the time
    - parameter calendar:     The calendar that we use to get the ranges for the
                              values.
    */
  internal static func normalizeTime(inout day day: Int, inout hour: Int,  inout minute: Int, inout second: Int, inout nanosecond: Double, inCalendar calendar: Calendar) {
    while limit(&nanosecond, to: (0,999999999.0), sign: 1, byIncreasing: &second) {}
    while limit(&second, to: (0,calendar.secondsPerMinute - 1), sign: 1, byIncreasing: &minute) {}
    while limit(&minute, to: (0,calendar.minutesPerHour - 1), sign: 1, byIncreasing: &hour) {}
    while limit(&hour, to: (0,calendar.hoursPerDay - 1), sign: 1, byIncreasing: &day) {}
  }
  
  /**
    This method normalizes a time interval, ensuring that all the values are of
    the same sign.

    - parameter interval:     The time interval that we need to normalize.
    - parameter sign:         Either 1 or -1, indicating the sign that the
                              values in the time interval should have.
    - parameter calendar:     The calendar that we use to get the number of days
                              in a month.
    - parameter month:        The month to use when getting the number of days.
    */
  internal static func normalizeTimeInterval(interval: TimeInterval, withSign sign: Int, inCalendar calendar: Calendar, inMonth month: Int) -> TimeInterval {
    var years = interval.years
    var months = interval.months
    var days = interval.days
    var hours = interval.hours
    var minutes = interval.minutes
    var seconds = interval.seconds
    var nanoseconds = interval.nanoseconds
    
    limit(&nanoseconds, to: (0,999999999), sign: sign, byIncreasing: &seconds)
    limit(&seconds, to: (0,calendar.secondsPerMinute - 1), sign: sign, byIncreasing: &minutes)
    limit(&minutes, to: (0,calendar.minutesPerHour - 1), sign: sign, byIncreasing: &hours)
    limit(&hours, to: (0,calendar.hoursPerDay - 1), sign: sign, byIncreasing: &days)
    
    let pastMonth = sign == -1 ? month : (month == 1 ? calendar.months : month - 1)
    
    limit(&days, to: (0,calendar.daysInMonth(pastMonth)-1), sign: sign, byIncreasing: &months)
    limit(&months, to: (0,calendar.months-1), sign: sign, byIncreasing: &years)
    
    return TimeInterval(years: years, months: months, days: days, hours: hours, minutes: minutes, seconds: seconds, nanoseconds: nanoseconds)
  }
  
  /**
    This method adds a time interval to this second.

    This will add the local components of the interval to the local components
    of this time, handle any overflows, and then construct a new timestamp from
    those new localized components.

    - parameter interval:     The time interval to add.
    - returns:                The new timestamp.
    */
  public func byAddingInterval(interval: TimeInterval) -> Timestamp {
    var year = self.year + interval.years
    var month = self.month + interval.months
    var day = self.day + interval.days
    var hour = self.hour + interval.hours
    var minute = self.minute + interval.minutes
    var second = self.second + interval.seconds
    var nanosecond = self.nanosecond + interval.nanoseconds
    
    let excess = Int(nanosecond) / 1000000000
    nanosecond = nanosecond % 1000000000
    second += excess
    
    let calendar = self.calendar.inYear(year)
    Timestamp.normalizeTime(day: &day, hour: &hour, minute: &minute, second: &second, nanosecond: &nanosecond, inCalendar: calendar)
    Timestamp.normalizeDate(year: &year, month: &month, day: &day, inCalendar: calendar)
    return Timestamp(year: year, month: month, day: day, hour: hour, minute: minute, second: second, nanosecond: nanosecond, timeZone: self.timeZone, calendar: self.calendar)
  }
  
  /**
    This method gets the interval between this timestamp and another timestamp.
  
    If the other timestamp is before this one, it will get a postitive 
    interval. If the other timestamp is after this one, it will get a negative
    interval.


    - parameter other:   The timestamp that we are getting the interval to.
    */
  public func intervalSince(other: Timestamp) -> TimeInterval {
    let other = Timestamp(epochSeconds: other.epochSeconds, timeZone: self.timeZone, calendar: self.calendar)
    let sign = self < other ? -1 : 1
    let interval = TimeInterval(
      years: self.year - other.year,
      months: self.month - other.month,
      days: self.day - other.day,
      hours: self.hour - other.hour,
      minutes: self.minute - other.minute,
      seconds: self.second - other.second,
      nanoseconds: self.nanosecond - other.nanosecond
    )
    return Timestamp.normalizeTimeInterval(interval, withSign: sign, inCalendar: self.calendar, inMonth: self.month)
  }
  
  /**
    This method gets a description of a timestamp for debugging.
    */
  public var description: String {
    return self.format(TimeFormat.Database)
  }
  
  /**
    This method gets the local time for a timestamp.

    - parameter epochSeconds:     The number of seconds since the Unix epoch for
                                  the timestamp.
    - parameter timeZone:         The time zone to express the local time in.
    - parameter calendar:         A calendar in the calendar system that the
                                  date should be expressed in.
    - returns:                    The local time information.
    */
  internal static func localTime(epochSeconds: EpochInterval, timeZone: TimeZone, calendar: Calendar) -> (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, nanosecond: Double, weekDay: Int) {
    let (epochYear, epochOffset, epochWeekDay) = calendar.unixEpochTime
    let offsetTimestamp = epochSeconds + epochOffset + Double(timeZone.policy(timestamp: epochSeconds).offset)
    var secondsRemaining = Int(offsetTimestamp)
    let nanosecond = (offsetTimestamp - Double(secondsRemaining)) * 1000000000
    var year = epochYear
    var weekDay = epochWeekDay
    while secondsRemaining < 0 {
      year -= 1
      let currentCalendar = calendar.inYear(year)
      let secondsPerHour = currentCalendar.secondsPerMinute * currentCalendar.minutesPerHour
      let secondsPerDay = secondsPerHour * currentCalendar.hoursPerDay
      let secondsInYear = secondsPerDay * currentCalendar.days
      secondsRemaining += secondsInYear
      weekDay = weekDay - currentCalendar.days
    }
    
    while secondsRemaining > 0 {
      let currentCalendar = calendar.inYear(year)
      
      let secondsPerHour = currentCalendar.secondsPerMinute * currentCalendar.minutesPerHour
      let secondsPerDay = secondsPerHour * currentCalendar.hoursPerDay
      let secondsInYear = secondsPerDay * currentCalendar.days
      
      if secondsInYear <= secondsRemaining {
        secondsRemaining -= secondsInYear
        weekDay += currentCalendar.days
        year += 1
        continue
      }
      
      for month in 1...currentCalendar.months {
        let daysInMonth = currentCalendar.daysInMonth(month)
        let secondsInMonth = secondsPerDay * daysInMonth
        
        if secondsInMonth <= secondsRemaining {
          secondsRemaining -= secondsInMonth
          weekDay += daysInMonth
          continue
        }
        
        let day = (secondsRemaining / secondsPerDay) + 1
        secondsRemaining = secondsRemaining % secondsPerDay
        
        let hour = (secondsRemaining / secondsPerHour)
        secondsRemaining = secondsRemaining % secondsPerHour
        
        let minute = (secondsRemaining / calendar.secondsPerMinute)
        let second = secondsRemaining % calendar.secondsPerMinute
        
        weekDay += day - 1
        weekDay = weekDay % calendar.daysInWeek
        if weekDay < 1 {
          weekDay += calendar.daysInWeek
        }
        
        return (year: year, month: month, day: day, hour: hour, minute: minute, second: second, nanosecond: nanosecond, weekDay: weekDay)
      }
    }
    weekDay = weekDay % calendar.daysInWeek
    if weekDay < 1 {
      weekDay += calendar.daysInWeek
    }
    return (year: year, month: 1, day: 1, hour: 0, minute: 0, second: 0, nanosecond: nanosecond, weekDay: weekDay)
  }
  
  /**
    This method gets a timestamp from a local time.

    - parameter time:         The local time that we are getting the time for.
    - parameter timeZone:     The time zone that the local time is expressed in.
    - parameter calendar:     The calendar that the local time is expressed in.
    - returns:                The number of seconds between the Unix epoch and
                              the specified time. It will also return the day of
                              the week for the date.
    */
  internal static func timestampForLocalTime(year  year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, nanosecond: Double, timeZone: TimeZone, calendar: Calendar) -> (EpochInterval,Int) {
    let (epochYear, epochOffset, epochWeekDay) = calendar.unixEpochTime
    var timestamp = -1 * epochOffset
    var weekDay = epochWeekDay
    
    if year < epochYear {
      for currentYear in year..<epochYear {
        let currentCalendar = calendar.inYear(currentYear)
        timestamp -= Double(currentCalendar.days * currentCalendar.hoursPerDay * currentCalendar.minutesPerHour * currentCalendar.secondsPerMinute)
        weekDay -= currentCalendar.days
      }
    }
    else {
      for currentYear in epochYear..<year {
        let currentCalendar = calendar.inYear(currentYear)
        timestamp += Double(currentCalendar.days * currentCalendar.hoursPerDay * currentCalendar.minutesPerHour * currentCalendar.secondsPerMinute)
        weekDay += currentCalendar.days
      }
    }
    
    let calendar = calendar.inYear(year)
    let secondsPerDay = calendar.hoursPerDay * calendar.minutesPerHour * calendar.secondsPerMinute
    
    if month > 0 {
      for currentMonth in 1..<month {
        let days = calendar.daysInMonth(currentMonth)
        timestamp += Double(days * secondsPerDay)
        weekDay += days
      }
    }
    
    timestamp += Double(secondsPerDay * (day - 1))
    timestamp += Double(calendar.secondsPerMinute * calendar.minutesPerHour * hour)
    timestamp += Double(calendar.secondsPerMinute * minute)
    timestamp += Double(second)
    timestamp += nanosecond / 1000000000.0
    weekDay += (day - 1)
    
    weekDay = weekDay % calendar.daysInWeek
    if weekDay < 1 {
      weekDay = calendar.daysInWeek
    }
    
    let originalOffset = timeZone.policy(timestamp: timestamp).offset
    timestamp -= Double(originalOffset)
    
    let newPolicy = timeZone.policy(timestamp: timestamp)
    let newOffset = Double(newPolicy.offset - originalOffset)
    if newOffset != 0 && newPolicy.beginningTimestamp < timestamp - newOffset {
      timestamp -= newOffset
    }
    
    return (timestamp,weekDay)
  }
  
  //MARK: - Formatting
  
  /**
    This method formats the timestamp.

    - parameter format:     The formatter to use to format the timestamp.
    - returns:              The formatted string.
    */
  public func format(format: TimeFormatter) -> String {
    return format.format(self)
  }
}

/**
  This method determines if two timestamps are equal.

  Two timestamps are equal if they have the same epoch, time zone, and calendar.
  */
public func ==(lhs: Timestamp, rhs: Timestamp) -> Bool {
  return lhs.epochSeconds == rhs.epochSeconds &&
    lhs.timeZone == rhs.timeZone &&
    lhs.calendar == rhs.calendar
}

/**
  This method determines if one timestamp is before another.

  This only considers the time interval since the epoch.

  - parameter lhs:    The first timestamp
  - parameter rhs:    The second timestamp
  - returns:          Whether the first timestamp is before the second.
  */
public func <(lhs: Timestamp, rhs: Timestamp) -> Bool {
  return lhs.epochSeconds < rhs.epochSeconds
}