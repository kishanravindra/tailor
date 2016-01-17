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
    #if os(Linux)
      let bytePointer = UnsafeMutablePointer<NumberType>(calloc(sizeof(NumberType.self), 1))
      repeat {
        RAND_bytes(UnsafeMutablePointer<UInt8>(bytePointer), Int32(sizeof(NumberType)))
      } while bytePointer.memory > limit
      return bytePointer.memory
    #endif
  }

  /**
    This method generates an array of random numbers.

    - parameter count:    The number of random numbers to generate.
    - returns:            The random numbers.
    */
  public static func generateBytes(count: Int) -> [UInt8] {
    ensureSeed()
    #if os(Linux)
      let buffer = [UInt8](count: count, repeatedValue: 0)
      RAND_bytes(UnsafeMutablePointer<UInt8>(buffer), Int32(buffer.count))
      return buffer
    #endif
  }
}

private var RANDOM_NUMBER_SEEDED = false