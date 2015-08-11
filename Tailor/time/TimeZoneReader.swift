import Foundation
/**
  This structure reads time zone data from a file.
  */
internal struct TimeZoneReader {
  /** The name of the time zone that we are reading. */
  let name: String
  
  /**
    This structure provides an interface for reading data from a byte stream.
    */
  struct DataReader {
    /** The current location in the byte stream. */
    var pointer: UnsafePointer<UInt8>
    
    /** The number of bytes remaining in the byte stream. */
    var remaining: Int
    
    /**
      This initializer creates a data reader from a data object.
      
      - parameter data:    The data that we are reading from.
      */
    init(_ data: NSData) {
      pointer = UnsafePointer<UInt8>(data.bytes)
      remaining = data.length
    }
    
    /** Whether we have read the entire stream. */
    var isEmpty: Bool {
      return remaining == 0
    }
    
    /**
      This method reads a single byte and advances the stream by one byte.
      
      - returns:   The byte.
      */
    mutating func readByte() -> UInt8 {
      if isEmpty {
        print("Reading empty byte")
        return 0
      }
      let value = pointer.memory
      pointer = advance(pointer, 1)
      remaining -= 1
      return value
    }
    
    /**
      This method reads a single integer value from the stream.

      It can be of any size, and will always be read in big-endian order.

      - returns: The value
      */
    mutating func read<T: ByteReadable>() -> T {
      var value : T = 0
      
      let length = sizeof(T)
      for indexOfByte in 0..<length {
        value += T(readByte())
        if indexOfByte < length - 1 {
          value = value << 8
        }
      }
      return value
    }
    
    /**
      This method reads an array of integer values from the stream.

      The values can be of any size, and will be in big-endian order.

      - parameter count:    The number of values to read.
      - returns:            The values.
      */
    mutating func readArray<T: ByteReadable>(count: Int) -> [T] {
      var array = [T](count: count, repeatedValue: 0)
      for index in 0..<count {
        array[index] = read()
      }
      return array
    }
    
    /**
      This method skips a number of bytes in the stream.

      - parameter bytes:   The number of bytes to skip.
      */
    mutating func skip(bytes: Int) {
      pointer = advance(pointer, bytes)
    }
  }
  
  /**
    This method reads time zone policies from the file.
    
    - returns:   The parsed policies.
    */
  func read() -> [TimeZone.Policy] {
    NSLog("Reading %@", name)
    if name == "+VERSION" || name.hasSuffix(".tab") {
      return []
    }
    let fullPath = "\(TimeZoneReader.zoneInfoPath)/\(name)"
    let data = NSData(contentsOfFile: fullPath) ?? NSData()
    var reader = DataReader(data)
    
    if reader.isEmpty {
      return []
    }

    // Skip the file header.
    reader.skip(20)
    
    // Read the counts of the number of elements.
    let utcSourceCount = Int(reader.read() as UInt32)
    let standardSourceCount = Int(reader.read() as UInt32)
    reader.read() as UInt32
    let transitionCount = Int(reader.read() as UInt32)
    let policyCount = Int(reader.read() as UInt32)
    let abbreviationCount = Int(reader.read() as UInt32)
    
    // Read the timestamps when the transitions occur, and the indices of
    // distinct policies for each transition.
    let transitionTimes = reader.readArray(transitionCount) as [Int32]
    let transitionTypes = reader.readArray(transitionCount) as [UInt8]
    
    // Read the policies.
    var policyData = [(Int32, UInt8, UInt8)](count: policyCount, repeatedValue: (0,0,0))
    for indexOfPolicy in 0..<policyCount {
      let gmtOffset = reader.read() as Int32
      let isDst = reader.read() as UInt8
      let abbreviationIndex = reader.read() as UInt8
      policyData[indexOfPolicy] = (gmtOffset, isDst, abbreviationIndex)
    }
    
    // Read the abbreviations for the policies.
    var abbreviations = [Int:String]()
    var characterBuffer = [Int8]()
    var stringStart = 0
    
    for (index,character) in (reader.readArray(abbreviationCount) as [Int8]).enumerate() {
      characterBuffer.append(character)
      if character == 0 {
        abbreviations[stringStart] = String(CString: characterBuffer, encoding: NSASCIIStringEncoding) ?? "???"
        characterBuffer = []
        stringStart = index + 1
      }
    }
    
    if !characterBuffer.isEmpty {
      abbreviations[stringStart] = String(CString: &characterBuffer, encoding: NSASCIIStringEncoding) ?? "???"
    }
    
    // Read information about whether the timestamps come from standard time or
    // wall time, and whether they come from local time or UTC. We currently do
    // not do anything with this information.
    reader.readArray(standardSourceCount) as [UInt8]
    reader.readArray(utcSourceCount) as [UInt8]
    
    let policies = (-1..<transitionCount).map {
      transitionIndex -> TimeZone.Policy in
      
      let policyDataItem: (Int32, UInt8, UInt8)
      let timestamp: Timestamp.EpochInterval
      
      if transitionIndex == -1 {
        policyDataItem = policyData.filter { $0.1 == 0 }.first ?? (0,0,0)
        timestamp = -1 * DBL_MAX
      }
      else {
        timestamp = Timestamp.EpochInterval(transitionTimes[transitionIndex])
        let policyIndex = Int(transitionTypes[transitionIndex])
        if policyIndex < policyData.count {
          policyDataItem = policyData[policyIndex]
        }
        else {
          policyDataItem = (0,0,0)
        }
      }
      
      let abbreviation = abbreviations[Int(policyDataItem.2)] ?? ""
      return TimeZone.Policy(
        beginningTimestamp: timestamp,
        abbreviation: abbreviation,
        offset: Int(policyDataItem.0),
        isDaylightTime: policyDataItem.1 == 1
      )
    }
    
    return policies
  }
  
  /** The path where the system stores zone info files. */
  static let zoneInfoPath = "/usr/share/zoneinfo"
}


/**
  This protocol describes an integer type that can be created one byte at a
  time.
  */
internal protocol ByteReadable: IntegerType,IntegerArithmeticType {
  /**
    This initializer creates a value with a single byte.
  */
  init(_ v: UInt8)
  
  /**
    This initializer shifts a value right by a certain number of bytes.
  */
  func <<(lhs: Self, rhs: Self) -> Self
}

extension UInt64: ByteReadable {}
extension UInt32: ByteReadable {}
extension UInt16: ByteReadable {}
extension UInt8: ByteReadable {}
extension Int32: ByteReadable {}
extension Int8: ByteReadable {}