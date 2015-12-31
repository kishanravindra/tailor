import Tailor
import TailorTesting
import XCTest

class TimeZoneTests: XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
  func testPolicyDescriptionGetsInformation() {
    let policy = TimeZone.Policy(beginningTimestamp: 12345, abbreviation: "EST", offset: -18800, isDaylightTime: false)
    assert(policy.description, equals: "12345.0: UTC+-18800 (EST)")
  }
  
  func testInitializeWithListOfPoliciesSetsPolicies() {
    let policies = [
      TimeZone.Policy(beginningTimestamp: 10000000, abbreviation: "TZ1", offset: -3600, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 20000000, abbreviation: "TZ2", offset: 3600, isDaylightTime: true)
    ]
    let timeZone = TimeZone(name: "Custom Zone", policies: policies)
    assert(timeZone.name, equals: "Custom Zone")
    assert(timeZone.policies, equals: policies)
  }
  
  func testInitializeWithPositiveOffsetSetsNameAndSinglePolicy() {
    let timeZone = TimeZone(offset: 18000)
    assert(timeZone.name, equals: "+18000")
    assert(timeZone.policies, equals: [
      TimeZone.Policy(beginningTimestamp: -30000000000, abbreviation: "+18000", offset: 18000, isDaylightTime: false)
    ])
  }
  
  func testInitializeWithNegativeOffsetSetsNameAndSinglePolicy() {
    let timeZone = TimeZone(offset: -18000)
    assert(timeZone.name, equals: "-18000")
    assert(timeZone.policies, equals: [
      TimeZone.Policy(beginningTimestamp: -30000000000, abbreviation: "-18000", offset: -18000, isDaylightTime: false)
      ])
  }
  
  func testInitializeWithoutListOfPoliciesReadsPoliciesFromDisk() {
    let timeZone = TimeZone(name: "Asia/Hong_Kong")
    let expectedPolicies = [
      TimeZone.Policy(beginningTimestamp: -30000000000, abbreviation: "LMT", offset: 27402, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -2056693002, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -907389000, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -891667800, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -884246400, abbreviation: "JST", offset: 32400, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -766746000, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -747981000, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -728544600, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -717049800, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -694503000, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -683785800, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -668064600, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -654755400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -636615000, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -623305800, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -605165400, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -591856200, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -573715800, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -559801800, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -542352600, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -528352200, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -510211800, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -498112200, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -478762200, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -466662600, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -446707800, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -435213000, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -415258200, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -403158600, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -383808600, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -371709000, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -352359000, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -340259400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -320909400, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -308809800, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -288855000, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -277360200, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -257405400, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -245910600, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -225955800, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -213856200, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -194506200, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -182406600, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -163056600, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -148537800, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -132816600, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -117088200, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -101367000, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -85638600, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -69312600, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -53584200, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -37863000, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: -22134600, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: -6413400, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 9315000, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 25036200, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 40764600, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 56485800, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 72214200, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 88540200, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 104268600, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 119989800, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 126041400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 151439400, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 167167800, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 182889000, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 198617400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 214338600, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 295385400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 309292200, abbreviation: "HKT", offset: 28800, isDaylightTime: false)
    ]
    assert(timeZone.name, equals: "Asia/Hong_Kong")
    assert(timeZone.policies, equals: expectedPolicies)
  }
  
  func testPolicyWithTimestampInMiddleGetsLastPolicyBeginningBeforeTimestamp() {
    let zone = TimeZone(name: "Custom Zone", policies: [
      TimeZone.Policy(beginningTimestamp: 167167800, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 182889000, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 198617400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 214338600, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 295385400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 309292200, abbreviation: "HKT", offset: 28800, isDaylightTime: false)
      ])
    assert(zone.policy(timestamp: 254338600), equals: TimeZone.Policy(beginningTimestamp: 214338600, abbreviation: "HKT", offset: 28800, isDaylightTime: false))
  }
  
  func testPolicyWithTimestampBeforeFirstPolicyGetsFirstPolicy() {
    let zone = TimeZone(name: "Custom Zone", policies: [
      TimeZone.Policy(beginningTimestamp: 167167800, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 182889000, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 198617400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 214338600, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 295385400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 309292200, abbreviation: "HKT", offset: 28800, isDaylightTime: false)
      ])
    assert(zone.policy(timestamp: 147167800), equals: TimeZone.Policy(beginningTimestamp: 167167800, abbreviation: "HKST", offset: 32400, isDaylightTime: true))
  }
  
  func testPolicyWithTimestampAfterLastPolicyGetsLastPolicy() {
    let zone = TimeZone(name: "Custom Zone", policies: [
      TimeZone.Policy(beginningTimestamp: 167167800, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 182889000, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 198617400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 214338600, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 295385400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 309292200, abbreviation: "HKT", offset: 28800, isDaylightTime: false)
      ])
    assert(zone.policy(timestamp: 329292200), equals: TimeZone.Policy(beginningTimestamp: 309292200, abbreviation: "HKT", offset: 28800, isDaylightTime: false))
  }
  
  func testPolicyWithTimestampAtBeginningOfPolicyGetsThatPolicy() {
    let zone = TimeZone(name: "Custom Zone", policies: [
      TimeZone.Policy(beginningTimestamp: 167167800, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 182889000, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 198617400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 214338600, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 295385400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 309292200, abbreviation: "HKT", offset: 28800, isDaylightTime: false)
      ])
    assert(zone.policy(timestamp: 295385400), equals: TimeZone.Policy(beginningTimestamp: 295385400, abbreviation: "HKST", offset: 32400, isDaylightTime: true))
  }
  
  func testPolicyWithIndicesAfterPolicyCountReturnsNil() {
    let zone = TimeZone(name: "Custom Zone", policies: [
      TimeZone.Policy(beginningTimestamp: 167167800, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 182889000, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 198617400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 214338600, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 295385400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 309292200, abbreviation: "HKT", offset: 28800, isDaylightTime: false)
      ])

    assert(isNil: zone.policyBeforeTimestamp(310000000, startIndex: 6, endIndex: 6))
  }

  
  func testPolicyWithForEmptyPolicyListGetsUtc() {
    let zone = TimeZone(name: "Custom Zone", policies: [])
    assert(zone.policy(timestamp: 295385400), equals: TimeZone.Policy(beginningTimestamp: 0, abbreviation: "UTC", offset: 0, isDaylightTime: false))
  }
  
  func testDescriptionIncludesNameAndPolicies() {
    let zone = TimeZone(name: "Custom Zone", policies: [
      TimeZone.Policy(beginningTimestamp: 167167800, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 182889000, abbreviation: "HKT", offset: 28800, isDaylightTime: false)
    ])
    assert(zone.description, equals: "Custom Zone: (167167800.0: UTC+32400 (HKST), 182889000.0: UTC+28800 (HKT))")
  }
  
  func testTimeZonesWithSameNameAndPoliciesAreEqual() {
    
    let zone1 = TimeZone(name: "Custom Zone", policies: [
      TimeZone.Policy(beginningTimestamp: 167167800, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 182889000, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 198617400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 214338600, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 295385400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 309292200, abbreviation: "HKT", offset: 28800, isDaylightTime: false)
      ])
    
    let zone2 = TimeZone(name: "Custom Zone", policies: [
      TimeZone.Policy(beginningTimestamp: 167167800, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 182889000, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 198617400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 214338600, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 295385400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 309292200, abbreviation: "HKT", offset: 28800, isDaylightTime: false)
      ])
    assert(zone1 == zone2)
  }
  
  func testTimeZonesWithDifferentPoliciesAreUnequal() {
    
    let zone1 = TimeZone(name: "Custom Zone", policies: [
      TimeZone.Policy(beginningTimestamp: 167167800, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 182889000, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 198617400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 214338600, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 295385400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 309292200, abbreviation: "HKT", offset: 28800, isDaylightTime: false)
      ])
    
    let zone2 = TimeZone(name: "Custom Zone", policies: [
      TimeZone.Policy(beginningTimestamp: 167167800, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 182889000, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 198617400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 214338600, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 295385400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 309292200, abbreviation: "HKST", offset: 28800, isDaylightTime: false)
      ])
    assert(zone1 != zone2)
  }
  
  func testTimeZonesWithDifferentNamesAreUnequal() {
    
    let zone1 = TimeZone(name: "Custom Zone", policies: [
      TimeZone.Policy(beginningTimestamp: 167167800, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 182889000, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 198617400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 214338600, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 295385400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 309292200, abbreviation: "HKT", offset: 28800, isDaylightTime: false)
      ])
    
    let zone2 = TimeZone(name: "Custom Zone 2", policies: [
      TimeZone.Policy(beginningTimestamp: 167167800, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 182889000, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 198617400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 214338600, abbreviation: "HKT", offset: 28800, isDaylightTime: false),
      TimeZone.Policy(beginningTimestamp: 295385400, abbreviation: "HKST", offset: 32400, isDaylightTime: true),
      TimeZone.Policy(beginningTimestamp: 309292200, abbreviation: "HKT", offset: 28800, isDaylightTime: false)
      ])
    assert(zone1 != zone2)
  }
}