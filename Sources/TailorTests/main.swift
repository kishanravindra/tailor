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
  TestHttpMessageType(),
  TestJobSchedulingTaskType(),
  TestMemoryCacheStore(),
  TestNSData(),
  TestRandomNumber(),
  TestRequest(),
  TestResponse(),
  TestRouteSet(),
  TestShaPasswordHasher(),
  TestSeedTaskType(),
  TestSerializableValue(),
  TestTailorTestable(),
  TestTemplateTestable(),
  TestTimestamp(),
  TestTypeInventory(),
])