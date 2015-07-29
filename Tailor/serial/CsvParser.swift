import Foundation

/**
This class provides a parser for reading and writing CSV data.
*/
public class CsvParser {
  /**
  This struct stores information about whether the parser is currently in
  a quoted section.
  */
  private struct QuoteState {
    /** Whether the parser is currently in a quoted section. */
    var inQuote = false
    
    /** Whether the last character the parser read was a quotation mark. */
    var lastWasQuote = false
    
    /**
    This method reads a character from the stream and interprets the changes
    to the quote state.
    
    - parameter isQuote: Whether the character is a quote.
    */
    mutating func consume(isQuote: Bool) {
      if isQuote {
        if inQuote {
          if lastWasQuote {
            inQuote = false
            lastWasQuote = false
          }
          else {
            inQuote = false
            lastWasQuote = true
          }
        }
        else {
          inQuote = true
          lastWasQuote = !lastWasQuote
        }
      }
      else {
        lastWasQuote = false
      }
    }
    
    /**
    This method reads a character from the stream and interprets the changes
    to the quote state.
    
    - parameter character: The byte that we are reading.
    */
    mutating func consume(character: UInt8) {
      self.consume(character == 34)
    }
    
    /**
    This method reads a character from the stream and interprets the changes
    to the quote state.
    
    - parameter character: The character that we are reading.
    */
    mutating func consume(character: Character) {
      self.consume(character == "\"")
    }
  }
  
  /** The rows that we have parsed. */
  public var rows: NSMutableArray
  
  /** The delimiter character that we use to separate cells. */
  public var delimiter = ","
  
  //MARK: - Construction
  /**
  This method initializes an empty parser.
  */
  public init() {
    self.rows = NSMutableArray()
  }
  
  /**
  This method initializes a parser with a grid of elements.
  */
  public convenience init(rows: [[String]]) {
    self.init()
    self.rows = NSMutableArray(array: rows)
  }
  
  /**
  This method initializes a parser for reading from a file.
  
  - parameter path: The path to read from.
  */
  public convenience init(path: String) {
    if let data = NSData(contentsOfFile: path) {
      self.init(data: data)
    }
    else {
      self.init()
    }
  }
  
  /**
  This method initializes a parser for parsing a byte stream.
  
  - parameter data: The data to read.
  */
  public convenience init(data: NSData) {
    self.init()
    self.parse(data)
  }
  
  /**
  This method initializes a parser for parsing a byte stream.
  
  - parameter data:        The data to read.
  - parameter delimiter:   The delimiter between cells.
  */
  public convenience init(data: NSData, delimiter: String) {
    self.init()
    self.delimiter = delimiter
    self.parse(data)
  }
  
  //MARK: - Parsing
  
  /**
  This method parses a byte stream into our storage.
  
  - parameter data: The data to write.
  */
  private func parse(data: NSData) {
    var pointer = UnsafePointer<UInt8>(data.bytes)
    let endPointer = advance(pointer, data.length)
    while pointer != endPointer {
      let (bytes, newPointer) = self.extractNextLine(pointer, end: endPointer)
      pointer = newPointer
      self.parseLine(bytes)
    }
  }
  
  /**
  This method extracts the bytes for the next line from the byte stream.
  
  - parameter startPointer:  The beginning of where we should read from the byte
  stream.
  - parameter endPointer:    The end of where we should read from the byte stream.
  - returns:             A 2-tuple where the first element is the bytes for the
  line and the second element is the pointer to the
  location after the newline that terminated the line.
  */
  private func extractNextLine(startPointer: UnsafePointer<UInt8>, end endPointer: UnsafePointer<UInt8>) -> ([UInt8], UnsafePointer<UInt8>) {
    var byte : UInt8 = 0
    var bytes : [UInt8] = []
    var pointer = startPointer
    let lineFeed : UInt8 = 10
    let carriageReturn : UInt8 =  13
    
    var quoteState = QuoteState()
    
    while pointer != endPointer {
      byte = pointer.memory
      pointer = pointer.successor()
      quoteState.consume(byte)
      if !quoteState.inQuote {
        if byte == lineFeed || byte == carriageReturn {
          return (bytes, pointer)
        }
      }
      bytes.append(byte)
    }
    return (bytes, pointer)
  }
  
  /**
  This method parses a line from a CSV file.
  
  The line will be added into the internal storage.
  
  - parameter bytes: The bytes in the line.
  */
  private func parseLine(bytes: [UInt8]) {
    var byteSections : [[UInt8]] = []
    var quoteState = QuoteState()
    let line = NSString(bytes: bytes, length: bytes.count, encoding: NSUTF8StringEncoding) as! String
    var currentString : [UInt8] = []
    var delimiterBytes : [UInt8] = [0]
    let delimiterByte = self.delimiter.nulTerminatedUTF8[0]
    for byte in bytes {
      quoteState.consume(byte)
      
      if byte == delimiterByte && !quoteState.inQuote {
        byteSections.append(currentString)
        currentString = []
        continue
      }
      
      if !quoteState.lastWasQuote {
        currentString.append(byte)
      }
    }
    if !currentString.isEmpty {
      byteSections.append(currentString)
    }
    let strings = byteSections.map {
      (bytes) -> String in
      return NSString(bytes: bytes, length: bytes.count, encoding: NSUTF8StringEncoding) as! String
    }
    self.rows.addObject(strings)
  }
  
  //MARK: - Econding
  
  /**
  This method encodes the elements in our storage into a byte stream.
  
  - returns: The encoded bytes.
  */
  public func encodeData() -> NSData {
    var contents = ""
    for (index, object) in self.rows.enumerate() {
      if index > 0 {
        contents += "\n"
      }
      let row = object as! [String]
      for (index, column) in row.enumerate() {
        if index > 0 {
          contents += self.delimiter
        }
        
        let range = Range(start: column.startIndex, end: column.endIndex)
        var cleanColumn = column
        let searchRange = cleanColumn.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: self.delimiter + "\"\n"))
        if searchRange?.startIndex != nil {
          cleanColumn = cleanColumn.stringByReplacingOccurrencesOfString("\"", withString: "\"\"")
          cleanColumn = "\"" + cleanColumn + "\""
        }
        contents += cleanColumn
      }
    }
    return contents.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
  }
  
  //MARK: Easy Reading and Writing
  
  /**
  This method parses a byte stream.
  
  - parameter data:  The data to parse.
  - returns:     The parsed elements.
  */
  public class func parse(data: NSData) -> [[String]] {
    return self.parse(data, delimiter: ",")
  }
  
  /**
  This method parses a byte stream.
  
  - parameter data:        The data to parse.
  - parameter delimiter:   The delimiter between cells.
  - returns:           The parsed elements.
  */
  public class func parse(data: NSData, delimiter: String) -> [[String]] {
    let parser = CsvParser(data: data, delimiter: delimiter)
    return parser.rows.map { $0 as! [String] }
  }
  
  /**
  This method encodes data into a byte stream.
  
  - parameter data:  The elements to encode.
  - returns:     The encoded data.
  */
  public class func encode(data: [[String]]) -> NSData {
    return self.encode(data, delimiter: ",")
  }
  
  /**
  This method encodes data into a byte stream.
  
  - parameter data:        The elements to encode.
  - parameter delimiter:   The delimiter between cells.
  - returns:           The encoded data.
  */
  public class func encode(data: [[String]], delimiter: String) -> NSData {
    let parser = CsvParser(rows: data)
    parser.delimiter = delimiter
    return parser.encodeData()
  }
}