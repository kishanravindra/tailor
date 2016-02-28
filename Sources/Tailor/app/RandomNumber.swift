import Foundation
#if os(Linux)
import COpenSSL
import Glibc
#endif

/**
  This type provides random number generation that is consistent across
  platforms.

  On Mac OS, this will use arc4random. On Linux, this will use OpenSSL's random
  number generation.
  */
public struct RandomNumber {
  /**
    This method ensures that our random-number generator is seeded.
    */
  private static func ensureSeed() {
    #if os(Linux)
      if !RANDOM_NUMBER_SEEDED {
        RANDOM_NUMBER_SEEDED = true
        let seed = [UInt8](count: 32, repeatedValue: 0)
        let filename = "/dev/urandom".bridge().cStringUsingEncoding(NSASCIIStringEncoding)
        let file = open(UnsafePointer<CChar>(filename), O_RDONLY)
        read(file, UnsafeMutablePointer<Void>(seed), seed.count)
        close(file)
        RAND_seed(seed, 0)
      }
    #endif
  }

  /**
    This method generates a single random number.

    - parameter limit:    The maximum value to return. The return value will be
                          of the same type as the limit.
    - returns:            The random number.
    */
  public static func generateNumber<NumberType: IntegerType>(limit: NumberType) -> NumberType {
    ensureSeed()
    let bytePointer = UnsafeMutablePointer<NumberType>(calloc(sizeof(NumberType.self), 1))
    repeat {
      #if os(Linux)
        RAND_bytes(UnsafeMutablePointer<UInt8>(bytePointer), Int32(sizeof(NumberType)))
      #else
        arc4random_buf(UnsafeMutablePointer<Void>(bytePointer), sizeof(NumberType))
      #endif
    } while bytePointer.memory > limit
    return bytePointer.memory
  }

  /**
    This method generates an array of random numbers.

    - parameter count:    The number of random numbers to generate.
    - returns:            The random numbers.
    */
  public static func generateBytes(count: Int) -> [UInt8] {
    ensureSeed()
    let buffer = [UInt8](count: count, repeatedValue: 0)
    #if os(Linux)
      RAND_bytes(UnsafeMutablePointer<UInt8>(buffer), Int32(buffer.count))
    #else
      arc4random_buf(UnsafeMutablePointer<Void>(buffer), buffer.count)
    #endif
    return buffer
  }
}

private var RANDOM_NUMBER_SEEDED = false