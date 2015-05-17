import Foundation

extension Timestamp {
  /**
    This method initializes a timestamp to the current time.
    
    :returns:   The new timestamp.
  */
  public static func now() -> Timestamp {
    return self.init(epochSeconds: Double(Foundation.time(nil)))
  }
  
  //MARK: - Foundation Bridging
  
  /**
    This method initializes a timestamp to match the timestamp in a foundation
    date.
    
    :param: foundationDate    The foundation date whose timestamp we should use.
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