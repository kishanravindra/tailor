import Cocoa
extension NSData {
  /**
    This method searches for a string in this data and uses it to separate out
    subcomponents of the data.

    :param: separator   The separator between the components
    :param: limit       The maximum number of components to create. Once this is
                        reached, the rest of the data will be kept as one piece.
    :returns:           The subcomponents.
    */
  func componentsSeparatedByString(separator: String, limit: Int? = nil) -> [NSData] {
    var components = [NSData]()
    let separatorData = separator.dataUsingEncoding(NSUTF8StringEncoding)!
    var searchRange = NSRange(location: 0, length: self.length)
    while(true) {
      let matchRange = self.rangeOfData(separatorData, options: nil, range: searchRange)
      if matchRange.location == NSNotFound {
        break
      }
      let componentRange = NSRange(location: searchRange.location, length: matchRange.location - searchRange.location)
      if componentRange.length != 0 {
        components.append(self.subdataWithRange(componentRange))
      }
      searchRange.location += componentRange.length + matchRange.length
      searchRange.length -= componentRange.length + matchRange.length
      
      if limit != nil && components.count == limit! - 1 {
        break
      }
    }
    if searchRange.length > 0 {
      components.append(self.subdataWithRange(searchRange))
    }
    return components
  }
}