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
  TestCollectionType(),
  TestConnection(),
  TestControllerType(),
  TestCookieJar(),
  TestCookie(),
  TestCsrfFilter(),
  TestDatabaseRow(),
  TestDatabaseDriver(),
  TestDatabaseValue(),
  TestDictionary(),
  TestEtagFilter(),
  TestExternalProcess(),
  TestHttpMessageType(),
  TestJobSchedulingTaskType(),
  TestMemoryCacheStore(),
  TestNSData(),
  TestNSRegularExpression(),
  TestPasswordHasherType(),
  TestRandomNumber(),
  TestRequest(),
  TestRequestFilterType(),
  TestResponse(),
  TestRouteSet(),
  TestShaPasswordHasher(),
  TestSeedTaskType(),
  TestSession(),
  TestSerializableValue(),
  TestString(),
  TestTailorTestable(),
  TestTemplateTestable(),
  TestTimestamp(),
  TestTypeInventory(),
  TestUserType(),
])