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