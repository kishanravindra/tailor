import Tailor
import TailorTesting
import XCTest

typealias NSRegularExpression=Tailor.NSRegularExpression
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
])