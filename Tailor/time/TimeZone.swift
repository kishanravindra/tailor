/**
  This structure represents a time zone, which is a set of rules for the offset
  from UTC in a geographic or political region.

  A time zone has a name and a list of policies. Each policy specifies the
  offset from UTC for times in that the time zone has, starting on a reference
  timestamp.
  */
public struct TimeZone: Equatable,Printable {
  //MARK: - Reading
  
  //MARK: - Structure
  
  /**
    This structure represents a policy that a time zone observes at a particular
    time.
    */
  public struct Policy: Equatable, Printable {
    /**
      The number of seconds after the Unix epoch when this policy goes into
      effect.
      */
    public let beginningTimestamp: Timestamp.EpochInterval
    
    /**
      The short abbreviation for the policy.
      */
    public let abbreviation: String
    
    /**
      The offset from UTC, in seconds, that the region applies to its time under
      this policy.
      */
    public let offset: Int
    
    /**
      Whether the time zone is obversiving daylight saving time at this time.
      */
    public let isDaylightTime: Bool
    
    /**
      This method initializes a time zone policy.
    
      :param: beginningTimestamp    The number of seconds after the Unix epoch
                                    when this policy goes into effect.
      :param: abbreviation          The short abbreviation for the policy.
      :param: offset                The offset from UTC, in seconds.
      :param: isDaylightTime        Whether the time zone is observing daylight
                                    saving time.
      */
    public init(beginningTimestamp: Timestamp.EpochInterval, abbreviation: String, offset: Int, isDaylightTime: Bool) {
      self.beginningTimestamp = beginningTimestamp
      self.abbreviation = abbreviation
      self.offset = offset
      self.isDaylightTime = isDaylightTime
    }
    
    /**
      A description of the policy for debugging.
      */
    public var description: String {
      return "\(beginningTimestamp): UTC+\(offset) (\(abbreviation))"
    }
  }
  
  /** The canonical identifier for the time zone. */
  public let name: String
  
  /** The policies that this time zone observes at different times. */
  public let policies: [Policy]
  
  /**
    This initializer creates a time zone policy with a name.
  
    You can provide a list of policies, but you generally will not want to do
    this yourself. If you omit this, we will look up the time zone data for that
    zone from the system and create policies based on it. If we cannot find any
    time zone data for that name, this will leave the policies empty, which will
    cause the time zone to behave like UTC.

    :param: name        The canonical identifier for the time zone.
    :param: policies    The policies that the time zone observes at different
                        times.
    */
  public init(name: String, policies: [Policy]? = nil) {
    self.name = name
    let policies = policies ?? TimeZoneReader(name: name).read()
    self.policies = sorted(policies) {
      (left,right) -> Bool in
      return left.beginningTimestamp < right.beginningTimestamp
    }
  }
  
  //MARK: - Policy Information
  
  /**
    This method gets the default time zone.

    This will be UTC rather than the system time zone, for the time being.
    */
  public static var defaultTimeZone: TimeZone { return TimeZone(name: "UTC") }
  
  /**
    This method gets a debugging description for this time zone.
    :returns:   The description.
    */
  public var description: String {
    let policyDescription = join(", ", policies.map { $0.description })
    return "\(name): (\(policyDescription))"
  }
  
  /**
    This method gets the policy that is observed in this time zone at a given
    time.
  
    :param: timestamp   The Unix epoch timestamp. This will always be
                        interpreted as UTC.
    :returns:           The policy observed at that time.
    */
  public func policy(# timestamp: Timestamp.EpochInterval) -> Policy {
    if let policy = policyBeforeTimestamp(timestamp, startIndex: 0, endIndex: count(policies) - 1) {
      return policy
    }
    else if policies.isEmpty {
      return Policy(
        beginningTimestamp: 0,
        abbreviation: "UTC",
        offset: 0,
        isDaylightTime: true
      )
    }
    else {
      return policies[0]
    }
  }
  
  /**
    This method searches for the last policy that starts before a given
    timestamp.

    :param: timestamp   The timestamp that we want the policy for.
    :param: startIndex  The beginning of the range where we are searching.
    :param: endIndex    The end of the range where we are searching. This index
                        is included as a candidate in the search.
    */
  public func policyBeforeTimestamp(timestamp: Timestamp.EpochInterval, startIndex: Int, endIndex: Int) -> Policy? {
    let middleIndex = (startIndex + endIndex) / 2
    let policy = policies[middleIndex]
    if policy.beginningTimestamp <= timestamp {
      if middleIndex == endIndex || policies[middleIndex + 1].beginningTimestamp > timestamp {
        return policy
      }
      else {
        return policyBeforeTimestamp(timestamp, startIndex: middleIndex + 1, endIndex: endIndex)
      }
    }
    else if middleIndex > startIndex {
      return policyBeforeTimestamp(timestamp, startIndex: startIndex, endIndex: middleIndex - 1)
    }
    else {
      return nil
    }
  }
}
/**
  This method determines if two time zone policies are equal.

  :param: lhs   The first policy.
  :param: rhs   The second policy.
  :returns:     Whether the two policies are equal.
  */
public func ==(lhs: TimeZone.Policy, rhs: TimeZone.Policy) -> Bool {
  return lhs.beginningTimestamp == rhs.beginningTimestamp &&
  lhs.abbreviation == rhs.abbreviation &&
  lhs.offset == rhs.offset &&
  lhs.isDaylightTime == rhs.isDaylightTime
}

/**
  This method determines if two time zones are equal.

  Two time zones are equal if they have the same name and policies.

  :param: lhs   The first time zone.
  :param: rhs   The second time zone.
  :returns:     Whether they are equal.
  */
public func ==(lhs: TimeZone, rhs: TimeZone) -> Bool {
  return lhs.name == rhs.name &&
    lhs.policies == rhs.policies
}