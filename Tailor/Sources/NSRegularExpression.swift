//
//  NSRegularExpression.swift
//  Tailor
//
//  Created by John Brownlee on 12/24/15.
//  Copyright © 2015 John Brownlee. All rights reserved.
//

import Foundation


public final class NSRegularExpression: Equatable{
  public struct Match {
    
  }
  enum Component: Equatable {
    case Literal(Character)
    case Start
    case End
    indirect case Alternation([Component])
    indirect case Group([Component])
    indirect case Repetition(Component, minimum: Int, maximum: Int?)
    indirect case Metaclass(options: [Character], positive: Bool)
    
    func match(string: String, startingAt start: String.Index) -> [Range<String.Index>] {
      switch(self) {
      case let .Literal(character):
        guard start < string.endIndex else { return [] }
        if character == string[start] {
          return [start...start]
        }
        else {
          return []
        }
      case .Start:
        if start == string.startIndex {
          return [start..<start]
        }
        else {
          return []
        }
      case .End:
        if start == string.endIndex {
          return [start..<start]
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
      case let .Repetition(component, minimum, maximum):
        var allEnds = [start]
        var lastEnds = allEnds
        for _ in 0..<minimum {
          let newEnds = lastEnds.flatMap { component.match(string, startingAt: $0).map { $0.endIndex } }
          allEnds = newEnds
          lastEnds = newEnds
        }
        var matchCount = minimum
        while !lastEnds.isEmpty {
          if let _max = maximum {
            if matchCount >= _max { break }
          }
          let newEnds = lastEnds.flatMap { component.match(string, startingAt: $0).map { $0.endIndex } }
          allEnds.appendContentsOf(newEnds)
          lastEnds = newEnds
          matchCount += 1
        }
        return allEnds.map { start..<$0 }
      case let .Alternation(components):
        return components.flatMap { $0.match(string, startingAt: start) }
      case let .Metaclass(options, positive):
        guard start < string.endIndex else { return [] }
        if positive == options.contains(string[start]) {
          return [(start...start)]
        }
        else {
          return []
        }
      }
    }
  }
  
  let components: [Component]
  
  public func copyWithZone(zone: NSZone) -> AnyObject {
    NSUnimplemented()
  }
  
  public func encodeWithCoder(aCoder: NSCoder) {
    NSUnimplemented()
  }
  
  public init?(coder aDecoder: NSCoder) {
    NSUnimplemented()
  }
  
  public enum ParsingErrors: ErrorType {
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
      components.append(.Alternation([leftSide, rightSideComponents[0]]))
    case "(":
      var innerComponents = [Component]()
      try parseAllComponents(from: &pattern, into: &innerComponents, until: ")")
      components.append(.Group(innerComponents))
    case "[":
      var innerComponents = [Component]()
      try parseAllComponents(from: &pattern, into: &innerComponents, until: "]")
      components.append(.Alternation(innerComponents))
    case "*":
      if components.isEmpty { throw ParsingErrors.InvalidInitialCharacter }
      let innerComponent = components.removeLast()
      components.append(.Repetition(innerComponent, minimum: 0, maximum: nil))
    case "+":
      if components.isEmpty { throw ParsingErrors.InvalidInitialCharacter }
      let innerComponent = components.removeLast()
      components.append(.Repetition(innerComponent, minimum: 1, maximum: nil))
    case "?":
      if components.isEmpty { throw ParsingErrors.InvalidInitialCharacter }
      let innerComponent = components.removeLast()
      components.append(.Repetition(innerComponent, minimum: 0, maximum: 1))
    case "\\":
      if pattern.isEmpty {
        throw ParsingErrors.InvalidFinalCharacter
      }
      let symbol = pattern.removeFirst()
      switch(symbol) {
      case "s": components.append(.Metaclass(options: [" ", "\t", "\n"], positive: true))
      case "S": components.append(.Metaclass(options: [" ", "\t", "\n"], positive: false))
      case "d": components.append(.Metaclass(options: ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], positive: true))
      default: components.append(.Metaclass(options: [symbol], positive: true))
      }
    case "^":
      components.append(.Start)
    case "$":
      components.append(.End)
    default:
      components.append(.Literal(start))
    }
  }
  
  /* An instance of NSRegularExpression is created from a regular expression pattern and a set of options.  If the pattern is invalid, nil will be returned and an NSError will be returned by reference.  The pattern syntax currently supported is that specified by ICU.
  */
  
  public init(pattern: String, options: NSRegularExpressionOptions = []) throws {
    var components = [Component]()
    var characters = Array(pattern.characters)
    do {
      try NSRegularExpression.parseAllComponents(from: &characters, into: &components)
    }
    catch let e {
      self.components = []
      self.pattern = pattern
      self.options = options
      throw e
    }
    self.components = components
    self.pattern = pattern
    self.options = options
  }
  
  public let pattern: String
  public let options: NSRegularExpressionOptions
  public var numberOfCaptureGroups: Int { NSUnimplemented() }
  
  /* This class method will produce a string by adding backslash escapes as necessary to the given string, to escape any characters that would otherwise be treated as pattern metacharacters.
  */
  public class func escapedPatternForString(string: String) -> String { NSUnimplemented() }
}


extension NSRegularExpression {
  
  /* The fundamental matching method on NSRegularExpression is a block iterator.  There are several additional convenience methods, for returning all matches at once, the number of matches, the first match, or the range of the first match.  Each match is specified by an instance of NSTextCheckingResult (of type NSTextCheckingTypeRegularExpression) in which the overall match range is given by the range property (equivalent to rangeAtIndex:0) and any capture group ranges are given by rangeAtIndex: for indexes from 1 to numberOfCaptureGroups.  {NSNotFound, 0} is used if a particular capture group does not participate in the match.
  */
  
  public func enumerateMatchesInString(string: String, options: NSMatchingOptions, range: NSRange, usingBlock block: (NSTextCheckingResult?, NSMatchingFlags, UnsafeMutablePointer<ObjCBool>) -> Void) {
    var index = string.startIndex.advancedBy(range.location)
    let end = index.advancedBy(range.length)
    let group = NSRegularExpression.Component.Group(components)
    var stop: ObjCBool = false
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
  
  public func matchesInString(string: String, options: NSMatchingOptions, range: NSRange) -> [NSTextCheckingResult] {
    var matches = [NSTextCheckingResult]()
    self.enumerateMatchesInString(string, options: options, range: range) {
      _range, _, _ in
      if let range = _range {
        matches.append(range)
      }
    }
    return matches
  }
  
  public func numberOfMatchesInString(string: String, options: NSMatchingOptions, range: NSRange) -> Int {
    var count = 0
    self.enumerateMatchesInString(string, options: options, range: range) {
      range,_,_ in
      if range != nil {
        count += 1
      }
    }
    return count
  }
  
  public func firstMatchInString(string: String, options: NSMatchingOptions, range: NSRange) -> NSTextCheckingResult? {
    var match: NSTextCheckingResult? = nil
    self.enumerateMatchesInString(string, options: options, range: range) {
      _match, _, stop in
      match = _match
      stop.memory = true
    }
    return match
  }
  
  public func rangeOfFirstMatchInString(string: String, options: NSMatchingOptions, range: NSRange) -> NSRange {
    if let match = self.firstMatchInString(string, options: options, range: range) {
      return match.range
    }
    else {
      return NSMakeRange(NSNotFound, NSNotFound)
    }
  }
}


extension NSRegularExpression {
  
  /* NSRegularExpression also provides find-and-replace methods for both immutable and mutable strings.  The replacement is treated as a template, with $0 being replaced by the contents of the matched range, $1 by the contents of the first capture group, and so on.  Additional digits beyond the maximum required to represent the number of capture groups will be treated as ordinary characters, as will a $ not followed by digits.  Backslash will escape both $ and itself.
  */
  public func stringByReplacingMatchesInString(string: String, options: NSMatchingOptions, range: NSRange, withTemplate template: String) -> String {
    let result = string.bridge().mutableCopy() as! NSMutableString
    self.replaceMatchesInString(result, options: options, range: range, withTemplate: template)
    return result.bridge()
  }
  
  public func replaceMatchesInString(string: NSMutableString, options: NSMatchingOptions, range: NSRange, withTemplate template: String) -> Int {
    var offset = 0
    var matches = 0
    self.enumerateMatchesInString(string.bridge(), options: options, range: range) {
      _match, _, _ in
      if let match = _match {
        var range = match.range
        range.location += offset
        let replacement = self.replacementStringForResult(match, inString: string.bridge(), offset: offset, template: template)
        string.replaceCharactersInRange(range, withString: replacement)
        offset += replacement.characters.count - range.length
        matches += 1
      }
    }
    return matches
  }
  
  /* For clients implementing their own replace functionality, this is a method to perform the template substitution for a single result, given the string from which the result was matched, an offset to be added to the location of the result in the string (for example, in case modifications to the string moved the result since it was matched), and a replacement template.
  */
  public func replacementStringForResult(result: NSTextCheckingResult, inString string: String, offset: Int, template: String) -> String {
    return template
  }
  
  /* This class method will produce a string by adding backslash escapes as necessary to the given string, to escape any characters that would otherwise be treated as template metacharacters.
  */
  public class func escapedTemplateForString(string: String) -> String { NSUnimplemented() }
}


public class NSTextCheckingResult {
  private let ranges: [NSRange]
  public let range: NSRange
  public let resultType: NSTextCheckingType
  public let regularExpression: NSRegularExpression?
  
  private init(ranges: [NSRange], resultType: NSTextCheckingType, regularExpression: NSRegularExpression?) {
    self.ranges = ranges
    self.range = ranges[0]
    self.resultType = resultType
    self.regularExpression = regularExpression
  }
  
  public class func regularExpressionCheckingResultWithRanges(ranges: NSRangePointer, count: Int, regularExpression: NSRegularExpression) -> NSTextCheckingResult {
    var list = [NSRange]()
    var pointer = ranges
    for _ in 0..<count {
      list.append(pointer.memory)
      pointer = pointer.successor()
    }
    return NSTextCheckingResult(ranges: list, resultType: .RegularExpression, regularExpression: regularExpression)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    NSUnimplemented()
  }
  
  public func encodeWithCoder(aCoder: NSCoder) {
    NSUnimplemented()
  }
  
  public func copyWithZone(zone: NSZone) -> AnyObject {
    NSUnimplemented()
  }
}

extension NSTextCheckingResult {
  /* A result must have at least one range, but may optionally have more (for example, to represent regular expression capture groups).  The range at index 0 always matches the range property.  Additional ranges, if any, will have indexes from 1 to numberOfRanges-1. */
  public var numberOfRanges: Int {
    return ranges.count
  }
  public func rangeAtIndex(idx: Int) -> NSRange {
    return ranges[idx]
  }
  public func resultByAdjustingRangesWithOffset(offset: Int) -> NSTextCheckingResult { NSUnimplemented() }
}

public func ==(lhs: NSRegularExpression, rhs: NSRegularExpression) -> Bool {
  return lhs.pattern == rhs.pattern && lhs.options == rhs.options
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
  case .Start:
    if case .Start = rhs { return true }
    else { return false }
  case .End:
    if case .End = rhs { return true }
    else { return false }
  case let .Alternation(c1):
    if case let .Alternation(c2) = rhs {
      return c1 == c2
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
  case let .Repetition(c1,min1,max1):
    if case let .Repetition(c2,min2,max2) = rhs {
      return c1 == c2 && min1 == min2 && max1 == max2
    }
    else {
      return false
    }
  case let .Metaclass(options1,positive1):
    if case let .Metaclass(options2,positive2) = rhs {
      return options1 == options2 && positive1 == positive2
    }
    else {
      return false
    }
  }
}