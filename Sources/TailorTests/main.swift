import Tailor
import TailorTesting
import XCTest

typealias NSRegularExpression=Tailor.NSRegularExpression

prepareTestSuite()

XCTMain([
  TestAesEncryptor(),
  TestApplication(),
  TestAuthenticationFilter(),
  TestCacheImplementation(),
  TestConnection(),
  TestControllerType(),
  TestCookieJar(),
  TestCookie(),
  TestCsrfFilter(),
  TestEtagFilter(),
  TestHttpMessageType(),
  TestJobSchedulingTaskType(),
  TestMemoryCacheStore(),
  TestNSData(),
  TestRandomNumber(),
  TestRequest(),
  TestRequestFilterType(),
  TestResponse(),
  TestRouteSet(),
  TestShaPasswordHasher(),
  TestSeedTaskType(),
  TestSession(),
  TestSerializableValue(),
  TestTailorTestable(),
  TestTemplateTestable(),
  TestTimestamp(),
  TestTypeInventory(),
  TestUserType(),
])