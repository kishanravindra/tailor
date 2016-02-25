import Foundation
extension NSCharacterSet {
  /**
    This method gets the characters that are allowed in a parameter in a URL.

    These characters are allowed in a segment of the path, between forward
    slashes, or in the query string, in segments separated by ampersands and
    equal signs.

    This includes all ASCII letters and digits, as well as hyphens, underscoes,
    periods, and tildes.
    */
  public static func URLParameterAllowedCharacterSet() -> NSCharacterSet {
    return NSCharacterSet(charactersInString: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_-.~")
  }
}