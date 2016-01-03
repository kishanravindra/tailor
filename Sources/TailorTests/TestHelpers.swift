import TailorTesting
import XCTest
import Foundation
extension TailorTestable {
	public func configure() {

	}
}
extension NSObject {
	class func stubMethod(methodName: String, result: AnyObject?, @noescape body: Void->Void) {
		XCTFail("stubMethod not supported")
	}
	class func stubClassMethod(methodName: String, result: AnyObject?, @noescape body: Void->Void) {
		XCTFail("stubMethod not supported")
	}
}

public func NSStringFromClass(class: Any.Type) -> String {
	return ""
}