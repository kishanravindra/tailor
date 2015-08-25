/**
  This structure represents a time zone, which is a set of rules for the offset
  from UTC in a geographic or political region.

  A time zone has a name and a list of policies. Each policy specifies the
  offset from UTC for times in that the time zone has, starting on a reference
  timestamp.
  */
public struct TimeZone: Equatable,CustomStringConvertible {
  //MARK: - Structure
  
  /**
    This structure represents a policy that a time zone observes at a particular
    time.
    */
  public struct Policy: Equatable, CustomStringConvertible {
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
    
      - parameter beginningTimestamp:     The number of seconds after the Unix
                                          epoch when this policy goes into
                                          effect.
      - parameter abbreviation:           The short abbreviation for the policy.
      - parameter offset:                 The offset from UTC, in seconds.
      - parameter isDaylightTime:         Whether the time zone is observing
                                          daylight saving time.
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

    - parameter name:         The canonical identifier for the time zone.
    - parameter policies:     The policies that the time zone observes at
                              different times.
    */
  public init(name: String, policies: [Policy]? = nil) {
    self.name = name
    let policies = policies ?? TIME_ZONE_POLICIES[name] ?? TimeZoneReader(name: name).read()
    self.policies = policies.sort {
      (left,right) -> Bool in
      return left.beginningTimestamp < right.beginningTimestamp
    }
  }
  
  /**
    This initializer creates a timezone policy with just an offset.
    
    The name will be the offset, and the zone will have a single policy that has
    that offset.

    - parameter offset:    The offset for the policy.
    */
  public init(offset: Int) {
    let name = offset > 0 ? "+\(offset)" : "\(offset)"
    self.name = name
    self.policies = [Policy(beginningTimestamp: -1 * DBL_MAX, abbreviation: name, offset: offset, isDaylightTime: false)]
  }
  
  //MARK: - Policy Information
  
  /**
    This method gets a debugging description for this time zone.
    - returns:   The description.
    */
  public var description: String {
    let policyDescription = policies.map { $0.description }.joinWithSeparator(", ")
    return "\(name): (\(policyDescription))"
  }
  
  /**
    This method gets the policy that is observed in this time zone at a given
    time.
  
    - parameter timestamp:    The Unix epoch timestamp. This will always be
                              interpreted as UTC.
    - returns:                The policy observed at that time.
    */
  public func policy(timestamp  timestamp: Timestamp.EpochInterval) -> Policy {
    if let policy = policyBeforeTimestamp(timestamp, startIndex: 0, endIndex: policies.count - 1) {
      return policy
    }
    else if policies.isEmpty {
      return Policy(
        beginningTimestamp: 0,
        abbreviation: "UTC",
        offset: 0,
        isDaylightTime: false
      )
    }
    else {
      return policies[0]
    }
  }
  
  /**
    This method searches for the last policy that starts before a given
    timestamp.

    - parameter timestamp:    The timestamp that we want the policy for.
    - parameter startIndex:   The beginning of the range where we are searching.
    - parameter endIndex:     The end of the range where we are searching. This
                              index is included as a candidate in the search.
    */
  public func policyBeforeTimestamp(timestamp: Timestamp.EpochInterval, startIndex: Int, endIndex: Int) -> Policy? {
    let middleIndex = (startIndex + endIndex) / 2
    if middleIndex >= policies.count {
      return nil
    }
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
  
  static func loadTimeZones() -> [String: [TimeZone.Policy]] {
    guard let enumerator = NSFileManager.defaultManager().enumeratorAtPath(TimeZoneReader.zoneInfoPath) else { return [:] }
    var zones: [String: [TimeZone.Policy]] = [:]
    for element in enumerator {
      guard let path = element as? String else { continue }
      let policies = TimeZoneReader(name: path).read()
      guard !policies.isEmpty else { continue }
      zones[path] = policies
      for policy in policies {
        if zones[policy.abbreviation] == nil {
          zones[policy.abbreviation] = [policy]
        }
      }
    }
    return zones
  }
}

/**
  This method determines if two time zone policies are equal.

  - parameter lhs:    The first policy.
  - parameter rhs:    The second policy.
  - returns:          Whether the two policies are equal.
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

  - parameter lhs:    The first time zone.
  - parameter rhs:    The second time zone.
  - returns:          Whether they are equal.
  */
public func ==(lhs: TimeZone, rhs: TimeZone) -> Bool {
  return lhs.name == rhs.name &&
    lhs.policies == rhs.policies
}

extension TimeZone: StringLiteralConvertible {
  /**
    This method gets the time zone by name.

    - parameter value:    The name of the time zone.
    */
  public init(stringLiteral value: String) {
    self.init(name: value)
  }
  
  /**
    This method gets the time zone by name.
    
    - parameter value:    The name of the time zone.
    */
  public init(extendedGraphemeClusterLiteral value: String) {
    self.init(stringLiteral: value)
  }
  
  /**
    This method gets the time zone by name.
    
    - parameter value:    The name of the time zone.
    */
  public init(unicodeScalarLiteral value: String) {
    self.init(stringLiteral: value)
  }
}
let TIME_ZONE_POLICIES: [String:[TimeZone.Policy]] = TimeZone.loadTimeZones()