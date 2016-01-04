import TailorTesting
import XCTest

XCTMain([
	TestApplication(),
	TestCacheImplementation(),
	TestCookie(),
	TestMemoryCacheStore(),
])