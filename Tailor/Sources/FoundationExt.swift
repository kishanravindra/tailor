import Foundation

#if os(Linux)
  extension NSBundle {
    class func allBundles() -> [NSBundle] {
      return []
    }
  }

  extension NSPropertyListMutabilityOptions {
      public static let Immutable = NSPropertyListMutabilityOptions(rawValue: 0)
      public static let MutableContainers = NSPropertyListMutabilityOptions(rawValue: 1)
      public static let MutableContainersAndLeaves = NSPropertyListMutabilityOptions(rawValue: 2)
  }

  extension String {
  }

  public func NSLog(string: String, _ arguments: Any...) {
    print(string)
  }

  public extension NSData {
    public func rangeOfData(dataToFind: NSData, options mask: NSDataSearchOptions, range searchRange: NSRange) -> NSRange {
      return NSRange(location: NSNotFound, length: NSNotFound)
    }
  }


extension NSData {
    
    /* Create an NSData from a Base-64 encoded NSString using the given options. By default, returns nil when the input is not recognized as valid Base-64.
    */
    public convenience init?(base64EncodedString base64String: String, options: NSDataBase64DecodingOptions) {
        let encodedBytes = Array(base64String.utf8)
        guard let decodedBytes = NSData.base64DecodeBytes(encodedBytes, options: options) else {
            return nil
        }
        self.init(bytes: decodedBytes, length: decodedBytes.count)
    }
    
    /* Create a Base-64 encoded NSString from the receiver's contents using the given options.
    */
    public func base64EncodedStringWithOptions(options: NSDataBase64EncodingOptions) -> String {
        var decodedBytes = [UInt8](count: self.length, repeatedValue: 0)
        getBytes(&decodedBytes, length: decodedBytes.count)
        let encodedBytes = NSData.base64EncodeBytes(decodedBytes, options: options)
        let characters = encodedBytes.map { Character(UnicodeScalar($0)) }
        return String(characters)
    }
    
    /* Create an NSData from a Base-64, UTF-8 encoded NSData. By default, returns nil when the input is not recognized as valid Base-64.
    */
    public convenience init?(base64EncodedData base64Data: NSData, options: NSDataBase64DecodingOptions) {
        var encodedBytes = [UInt8](count: base64Data.length, repeatedValue: 0)
        base64Data.getBytes(&encodedBytes, length: encodedBytes.count)
        guard let decodedBytes = NSData.base64DecodeBytes(encodedBytes, options: options) else {
            return nil
        }
        self.init(bytes: decodedBytes, length: decodedBytes.count)
    }
    
    /* Create a Base-64, UTF-8 encoded NSData from the receiver's contents using the given options.
    */
    public func base64EncodedDataWithOptions(options: NSDataBase64EncodingOptions) -> NSData {
        var decodedBytes = [UInt8](count: self.length, repeatedValue: 0)
        getBytes(&decodedBytes, length: decodedBytes.count)
        let encodedBytes = NSData.base64EncodeBytes(decodedBytes, options: options)
        return NSData(bytes: encodedBytes, length: encodedBytes.count)
    }
    
    /**
      The ranges of ASCII characters that are used to encode data in Base64.
      */
    private static var base64ByteMappings: [Range<UInt8>] {
        return [
            65 ..< 91,      // A-Z
            97 ..< 123,     // a-z
            48 ..< 58,      // 0-9
            43 ..< 44,      // +
            47 ..< 48,      // /
            61 ..< 62       // =
        ]
    }

    /**
        This method takes a byte with a character from Base64-encoded string
        and gets the binary value that the character corresponds to.
     
        If the byte is not a valid character in Base64, this will return nil.
     
        - parameter byte:       The byte with the Base64 character.
        - returns:              The numeric value that the character corresponds
                                to.
        */
    private static func base64DecodeByte(byte: UInt8) -> UInt8? {
        var decodedStart: UInt8 = 0
        for range in base64ByteMappings {
            if range.contains(byte) {
                let result = decodedStart + (byte - range.startIndex)
                return result == 64 ? 0 : result
            }
            decodedStart += range.endIndex - range.startIndex
        }
        return nil
    }
    
    /**
        This method takes six bits of binary data and encodes it as a character
        in Base64.
 
        The value in the byte must be less than 64, because a Base64 character
        can only represent 6 bits.
 
        - parameter byte:       The byte to encode
        - returns:              The ASCII value for the encoded character.
        */
    private static func base64EncodeByte(byte: UInt8) -> UInt8 {
        assert(byte < 64)
        var decodedStart: UInt8 = 0
        for range in base64ByteMappings {
            let decodedRange = decodedStart ..< decodedStart + (range.endIndex - range.startIndex)
            if decodedRange.contains(byte) {
                return range.startIndex + (byte - decodedStart)
            }
            decodedStart += range.endIndex - range.startIndex
        }
        return 0
    }
    
    /**
        This method takes an array of bytes and either adds or removes padding
        as part of Base64 encoding and decoding.
 
        If the fromSize is larger than the toSize, this will inflate the bytes
        by adding zero between the bits. If the fromSize is smaller than the
        toSize, this will deflate the bytes by removing the most significant
        bits and recompacting the bytes.
 
        For instance, if you were going from 6 bits to 8 bits, and you had
        an array of bytes with `[0b00010000, 0b00010101, 0b00001001 0b00001101]`,
        this would give a result of: `[0b01000001 0b01010010 0b01001101]`.
        This transition is done when decoding Base64 data.
     
        If you were going from 8 bits to 6 bits, and you had an array of bytes
        with `[0b01000011 0b01101111 0b01101110], this would give a result of:
        `[0b00010000 0b00110110 0b00111101 0b00101110]. This transition is done
        when encoding data in Base64.
     
        - parameter bytes:      The original bytes
        - parameter fromSize:   The number of useful bits in each byte of the
                                input.
        - parameter toSize:     The number of useful bits in each byte of the
                                output.
        - returns:              The resized bytes
        */
    private static func base64ResizeBytes(bytes: [UInt8], fromSize: UInt32, toSize: UInt32) -> [UInt8] {
        var bitBuffer: UInt32 = 0
        var bitCount: UInt32 = 0
        
        var result = [UInt8]()
        
        result.reserveCapacity(bytes.count * Int(fromSize) / Int(toSize))
        
        let mask = UInt32(1 << toSize - 1)
        
        for byte in bytes {
            bitBuffer = bitBuffer << fromSize | UInt32(byte)
            bitCount += fromSize
            if bitCount % toSize == 0 {
                while(bitCount > 0) {
                    let byte = UInt8(mask & (bitBuffer >> (bitCount - toSize)))
                    result.append(byte)
                    bitCount -= toSize
                }
            }
        }
        
        let paddingBits = toSize - (bitCount % toSize)
        if paddingBits != toSize {
            bitBuffer = bitBuffer << paddingBits
            bitCount += paddingBits
        }
        
        while(bitCount > 0) {
            let byte = UInt8(mask & (bitBuffer >> (bitCount - toSize)))
            result.append(byte)
            bitCount -= toSize
        }
        
        return result

    }
    
    /**
        This method decodes Base64-encoded data.
     
        If the input contains any bytes that are not valid Base64 characters,
        this will return nil.
 
        - parameter bytes:      The Base64 bytes
        - parameter options:    Options for handling invalid input
        - returns:              The decoded bytes.
        */
    private static func base64DecodeBytes(bytes: [UInt8], options: NSDataBase64DecodingOptions = []) -> [UInt8]? {
        var decodedBytes = [UInt8]()
        decodedBytes.reserveCapacity(bytes.count)
        for byte in bytes {
            guard let decoded = base64DecodeByte(byte) else {
                if options.contains(.IgnoreUnknownCharacters) {
                    continue
                }
                else {
                    return nil
                }
            }
            decodedBytes.append(decoded)
        }
        return base64ResizeBytes(decodedBytes, fromSize: 6, toSize: 8)
    }
    
    
    /**
        This method encodes data in Base64.
     
        - parameter bytes:      The bytes you want to encode
        - parameter options:    Options for formatting the result
        - returns:              The Base64-encoding for those bytes.
        */
    private static func base64EncodeBytes(bytes: [UInt8], options: NSDataBase64EncodingOptions = []) -> [UInt8] {
        var encodedBytes = base64ResizeBytes(bytes, fromSize: 8, toSize: 6)
        encodedBytes = encodedBytes.map(base64EncodeByte)
        
        let paddingBytes = (4 - (encodedBytes.count % 4)) % 4
        for _ in 0..<paddingBytes {
            encodedBytes.append(61)
        }
        let lineLength: Int
        if options.contains(.Encoding64CharacterLineLength) { lineLength = 64 }
        else if options.contains(.Encoding76CharacterLineLength) { lineLength = 76 }
        else { lineLength = 0 }
        if lineLength > 0 {
            var separator = [UInt8]()
            if options.contains(.EncodingEndLineWithCarriageReturn) { separator.append(13) }
            if options.contains(.EncodingEndLineWithLineFeed) { separator.append(10) }
            let lines = encodedBytes.count / lineLength
            for line in 0..<lines {
                for (index,character) in separator.enumerate() {
                    encodedBytes.insert(character, atIndex: (lineLength + separator.count) * line + index + lineLength)
                }
            }
        }
        return encodedBytes
    }
}


public final class NSRegularExpression {
    enum Component: Equatable {
        case Literal(Character)
        indirect case Alternation(Component, Component)
        indirect case Group([Component])
        indirect case Repetition(Component)
        
        func match(string: String, startingAt start: String.Index) -> [Range<String.Index>] {
            if start >= string.endIndex { return [] }
            
            switch(self) {
            case let .Literal(character):
                if character == string[start] {
                    return [start...start]
                }
                else {
                    return []
                }
            case let .Group(components):
                var indices = [start]
                for component in components {
                    indices = indices.flatMap {
                        index in
                        return component.match(string, startingAt: index).map { $0.endIndex }
                    }
                }
                return indices.map { start..<$0 }
            case let .Repetition(component):
                var allEnds = [start.successor()]
                var lastEnds = allEnds
                while !lastEnds.isEmpty {
                    let newEnds = lastEnds.flatMap { component.match(string, startingAt: $0).map { $0.endIndex } }
                    allEnds.appendContentsOf(newEnds)
                    lastEnds = newEnds
                }
                return allEnds.map { start..<$0 }
            case let .Alternation(left,right):
                var ranges = left.match(string, startingAt: start)
                ranges.appendContentsOf(right.match(string, startingAt: start))
                return ranges
            }
        }
    }
    
    let components: [Component]
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        NSUnimplemented()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        NSUnimplemented()
    }
    
    init?(coder aDecoder: NSCoder) {
        NSUnimplemented()
    }
    
    enum ParsingErrors: ErrorType {
        case InvalidInitialCharacter
        case InvalidFinalCharacter
        case UnterminatedGroup
    }
    
    static func parseAllComponents(inout from pattern: [Character], inout into components: [Component], until breaker: Character? = nil) throws {
        while !pattern.isEmpty {
            if pattern.first == breaker {
                pattern.removeFirst()
                return
            }
            try parseOneComponent(from: &pattern, into: &components)
        }
        if breaker != nil {
            throw ParsingErrors.UnterminatedGroup
        }
    }
    
    static func parseOneComponent(inout from pattern: [Character], inout into components: [Component]) throws {
        if pattern.isEmpty { return }
        let start = pattern.removeFirst()
        
        switch(start) {
        case "|":
            if components.isEmpty { throw ParsingErrors.InvalidInitialCharacter }
            let leftSide = components.removeLast()
            var rightSideComponents = [Component]()
            try parseOneComponent(from: &pattern, into: &rightSideComponents)
            if rightSideComponents.isEmpty { throw ParsingErrors.InvalidFinalCharacter }
            components.append(.Alternation(leftSide, rightSideComponents[0]))
        case "(":
            var innerComponents = [Component]()
            try parseAllComponents(from: &pattern, into: &innerComponents, until: ")")
            components.append(.Group(innerComponents))
        case "*":
            if components.isEmpty { throw ParsingErrors.InvalidInitialCharacter }
            let innerComponent = components.removeLast()
            components.append(.Repetition(innerComponent))
        default:
            components.append(.Literal(start))
        }
    }
    
    /* An instance of NSRegularExpression is created from a regular expression pattern and a set of options.  If the pattern is invalid, nil will be returned and an NSError will be returned by reference.  The pattern syntax currently supported is that specified by ICU.
    */
    
    init(pattern: String, options: NSRegularExpressionOptions = []) throws {
        var components = [Component]()
        var characters = Array(pattern.characters)
        try NSRegularExpression.parseAllComponents(from: &characters, into: &components)
        self.components = components
        self.pattern = pattern
        self.options = options
    }
    
    let pattern: String
    let options: NSRegularExpressionOptions
    var numberOfCaptureGroups: Int { NSUnimplemented() }
    
    /* This class method will produce a string by adding backslash escapes as necessary to the given string, to escape any characters that would otherwise be treated as pattern metacharacters.
    */
    class func escapedPatternForString(string: String) -> String { NSUnimplemented() }
}

func ==(lhs: NSRegularExpression.Component, rhs: NSRegularExpression.Component) -> Bool {
    switch(lhs) {
    case let .Literal(s1):
        if case let .Literal(s2) = rhs {
            return s1 == s2
        }
        else {
            return false
        }
    case let .Alternation(c1, c2):
        if case let .Alternation(c3, c4) = rhs {
            return c1 == c3 && c2 == c4
        }
        else {
            return false
        }
    case let .Group(c1):
        if case let .Group(c2) = rhs {
            return c1 == c2
        }
        else {
            return false
        }
    case let .Repetition(c1):
        if case let .Repetition(c2) = rhs {
            return c1 == c2
        }
        else {
            return false
        }
    }
}



extension NSRegularExpression {
    
    /* The fundamental matching method on NSRegularExpression is a block iterator.  There are several additional convenience methods, for returning all matches at once, the number of matches, the first match, or the range of the first match.  Each match is specified by an instance of NSTextCheckingResult (of type NSTextCheckingTypeRegularExpression) in which the overall match range is given by the range property (equivalent to rangeAtIndex:0) and any capture group ranges are given by rangeAtIndex: for indexes from 1 to numberOfCaptureGroups.  {NSNotFound, 0} is used if a particular capture group does not participate in the match.
    */
    
    func enumerateMatchesInString(string: String, options: NSMatchingOptions, range: NSRange, usingBlock block: (NSTextCheckingResult?, NSMatchingFlags, UnsafeMutablePointer<ObjCBool>) -> Void) {
        var index = string.startIndex.advancedBy(range.location)
        let end = index.advancedBy(range.length)
        let group = NSRegularExpression.Component.Group(components)
        var stop = false
        while index < end {
            let ranges = group.match(string, startingAt: index).sort { $0.endIndex > $1.endIndex }
            if let range = ranges.first {
                var ranges = [NSMakeRange(string.startIndex.distanceTo(range.startIndex), range.startIndex.distanceTo(range.endIndex))]
                let result = NSTextCheckingResult.regularExpressionCheckingResultWithRanges(&ranges, count: 1, regularExpression: self)
                block(result, [], &stop)
            }
            if stop {
                break
            }
            index = index.advancedBy(1)
        }
    }
    
    func matchesInString(string: String, options: NSMatchingOptions, range: NSRange) -> [NSTextCheckingResult] {
        var matches = [NSTextCheckingResult]()
        self.enumerateMatchesInString(string, options: options, range: range) {
            _range, _, _ in
            if let range = _range {
                matches.append(range)
            }
        }
        return matches
    }
    func numberOfMatchesInString(string: String, options: NSMatchingOptions, range: NSRange) -> Int { NSUnimplemented() }
    func firstMatchInString(string: String, options: NSMatchingOptions, range: NSRange) -> NSTextCheckingResult? { NSUnimplemented() }
    func rangeOfFirstMatchInString(string: String, options: NSMatchingOptions, range: NSRange) -> NSRange { NSUnimplemented() }
}


extension NSRegularExpression {
    
    /* NSRegularExpression also provides find-and-replace methods for both immutable and mutable strings.  The replacement is treated as a template, with $0 being replaced by the contents of the matched range, $1 by the contents of the first capture group, and so on.  Additional digits beyond the maximum required to represent the number of capture groups will be treated as ordinary characters, as will a $ not followed by digits.  Backslash will escape both $ and itself.
    */
    func stringByReplacingMatchesInString(string: String, options: NSMatchingOptions, range: NSRange, withTemplate templ: String) -> String { NSUnimplemented() }
    public func replaceMatchesInString(string: NSMutableString, options: NSMatchingOptions, range: NSRange, withTemplate templ: String) -> Int { NSUnimplemented() }
    
    /* For clients implementing their own replace functionality, this is a method to perform the template substitution for a single result, given the string from which the result was matched, an offset to be added to the location of the result in the string (for example, in case modifications to the string moved the result since it was matched), and a replacement template.
    */
    func replacementStringForResult(result: NSTextCheckingResult, inString string: String, offset: Int, template templ: String) -> String { NSUnimplemented() }
    
    /* This class method will produce a string by adding backslash escapes as necessary to the given string, to escape any characters that would otherwise be treated as template metacharacters. 
    */
    class func escapedTemplateForString(string: String) -> String { NSUnimplemented() }
}



class NSTextCheckingResult {
    private let ranges: [NSRange]
    let range: NSRange
    let resultType: NSTextCheckingType
    let regularExpression: NSRegularExpression?
    
    private init(ranges: [NSRange], resultType: NSTextCheckingType, regularExpression: NSRegularExpression?) {
        self.ranges = ranges
        self.range = ranges[0]
        self.resultType = resultType
        self.regularExpression = regularExpression
    }
    
    class func regularExpressionCheckingResultWithRanges(ranges: NSRangePointer, count: Int, regularExpression: NSRegularExpression) -> NSTextCheckingResult {
        var list = [NSRange]()
        var pointer = ranges
        for _ in 0..<count {
            list.append(pointer.memory)
            pointer = pointer.successor()
        }
        return NSTextCheckingResult(ranges: list, resultType: .RegularExpression, regularExpression: regularExpression)
    }

    required init?(coder aDecoder: NSCoder) {
        NSUnimplemented()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        NSUnimplemented()
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        NSUnimplemented()
    }
}

extension NSTextCheckingResult {
    /* A result must have at least one range, but may optionally have more (for example, to represent regular expression capture groups).  The range at index 0 always matches the range property.  Additional ranges, if any, will have indexes from 1 to numberOfRanges-1. */
    var numberOfRanges: Int {
        return ranges.count
    }
    func rangeAtIndex(idx: Int) -> NSRange {
        return ranges[idx]
    }
    func resultByAdjustingRangesWithOffset(offset: Int) -> NSTextCheckingResult { NSUnimplemented() }
}


@noreturn internal func NSUnimplemented(fn: String = __FUNCTION__, file: StaticString = __FILE__, line: UInt = __LINE__) {
    fatalError("\(fn) is not yet implemented", file: file, line: line)
}


#else
  public extension NSString {
    public func bridge() -> String {
      return self as String
    }
  }
  public extension String {
    public func bridge() -> NSString {
      return self as NSString
    }
  }
  public extension Array where Element: AnyObject {
    public func bridge() -> NSArray {
      return self as NSArray
    }
  }
  public extension Dictionary where Key: AnyObject, Value: AnyObject {
    public func bridge() -> NSDictionary {
      return self as NSDictionary
    }
  }
#endif