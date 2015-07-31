import Foundation

extension NSProcessInfo {
  /**
    This method gets the environment dictionary that we have stubbed in place of
    the real environment dictionary.
    */
  public func stubbedEnvironment() -> [String:String] {
     return NSPROCESS_INFO_STUBBED_ENVIRONMENT
  }
  
  /**
    This method replaces the environment dictionary returned by the class with
    test values.
  
    You **must** balance this with a call to unstubEnvironment before the test
    case ends, to prevent unforseen consequences of messing with environment
    variables used by the test process itself.

    - param values:   The values to stub in.
    */
  public static func stubEnvironment(values: [String:String]) {
    if NSPROCESS_INFO_ORIGINAL_ENVIRONMENT == nil {
      let oldMethod = class_getInstanceMethod(NSProcessInfo.self, Selector("environment"))
      let newMethod = class_getInstanceMethod(NSProcessInfo.self, Selector("stubbedEnvironment"))
      NSPROCESS_INFO_ORIGINAL_ENVIRONMENT = method_getImplementation(oldMethod)
      method_setImplementation(oldMethod, method_getImplementation(newMethod))
    }
    NSPROCESS_INFO_STUBBED_ENVIRONMENT = values
  }
  
  /**
    This method replaces the stubbed environment from `stubEnvironment` with the
    real environment.
    */
  public static func unstubEnvironment() {
    if let implementation = NSPROCESS_INFO_ORIGINAL_ENVIRONMENT {
      let oldMethod = class_getInstanceMethod(NSProcessInfo.self, Selector("environment"))
      method_setImplementation(oldMethod, implementation)
      NSPROCESS_INFO_ORIGINAL_ENVIRONMENT = nil
    }
  }
}

/** The environment info to return from stubs. */
private var NSPROCESS_INFO_STUBBED_ENVIRONMENT = [String:String]()

/** The real implementation of the NSProcessInfo environment method. */
private var NSPROCESS_INFO_ORIGINAL_ENVIRONMENT: IMP? = nil