import Tailor
import TailorTesting
import XCTest

typealias NSRegularExpression=Tailor.NSRegularExpression

prepareTestSuite()

XCTMain([
  TestAesEncryptor(),
  TestApplication(),
  TestCacheImplementation(),
  TestConnection(),
  TestCookie(),
  TestJobSchedulingTaskType(),
  TestMemoryCacheStore(),
  TestNSData(),
  TestRandomNumber(),
  TestRouteSet(),
  TestShaPasswordHasher(),
  TestSeedTaskType(),
  TestSerializableValue(),
  TestTimestamp(),
])