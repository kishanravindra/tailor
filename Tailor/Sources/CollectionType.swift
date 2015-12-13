import Foundation
#if os(Linux)
import Glibc
#endif

extension CollectionType where Generator.Element: Equatable {
  /**
    This method gets an array with the contents of this collection, with
    duplicates removed.
  
    - returns:  A new array with the unique elemnts.
    */
  public var unique: [Generator.Element] {
    var elements: [Generator.Element] = []
    for element in self {
      if !elements.contains(element) {
        elements.append(element)
      }
    }
    return elements
  }
}

extension CollectionType where Index.Distance == Int, Index: Comparable {
  /**
   This method divides this collection into subsequences of a fixed size.
   
   If this is called on an array of 10 items, with a size of three, this will
   return an array containing four subsequences. The first will have items 1
   through 3, the second will have items 4 through 6, the third will have
   items 7 through 9, and the fourth will have item 10.
   
   - parameter size:   The size of the subsequence.
   */
  public func slices(size: Int) -> [Self.SubSequence] {
    let numberOfSlices = Int(ceil(Double(self.count) / Double(size)))
    return (0..<numberOfSlices).map {
      slice in
      let start = startIndex.advancedBy(slice * size)
      let end = min(start.advancedBy(size), endIndex)
      return self[start..<end]
    }
  }
}