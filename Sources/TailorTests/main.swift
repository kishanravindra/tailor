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
  TestMemoryCacheStore(),
  TestNSData(),
  TestRandomNumber(),
  TestShaPasswordHasher(),
  TestTimestamp(),
  TestSerializableValue(),
])