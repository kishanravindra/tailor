import Foundation

/**
  This struct provides a wrapper for running external processes.

  This wraps around NSTask and provides a simpler interface and a mechanism for
  stubbing out the execution in unit tests.
  */
internal struct ExternalProcess: Equatable {
  /** The path to the executable we are launching. */
  internal let launchPath: String
  
  /** The arguments to the executable. */
  internal let arguments: [String]
  
  /** The input that we share with the process. */
  private let input = NSPipe()
  
  /** The output that we share with the process. */
  private let output = NSPipe()
  
  /** The callback that we invoke when the process finishes. */
  private let callback: (Int,NSData)->()
  
  /**
    This initializer creates a new external process.

    It does not launch the process.

    - parameter launchPath:   The path to the executable to launch.
    - parameter arguments:    The arguments to pass to the executable.
    - parameter callback:     A callback to call when the process finishes.
                              This will receive the termination status from the
                              process and the data that it has outputted.
    */
  internal init(launchPath: String, arguments: [String] = [], callback: (Int,NSData)->() = {_,_ in}) {
    self.launchPath = launchPath
    self.arguments = arguments
    self.callback = callback
  }
  
  /**
    This method launches the process.

    In stub mode, this will add this process to the list of stubbed processes
    and call the callback with the global stubResult.

    In non-stub mode, this will call the actual process, and call the callback
    later on with the results of that process.
    */
  internal func launch() {
    if ExternalProcess.stubbing {
      EXTERNAL_PROCESS_STUBS.append(self)
      let result = ExternalProcess.stubResult
      self.callback(result.0, result.1)
    }
    else {
      let task = NSTask()
      task.launchPath = self.launchPath
      task.arguments = self.arguments
      task.standardInput = self.input
      task.standardOutput = self.output
      task.standardError = self.output
      task.terminationHandler = {
        (task: NSTask) -> Void in
        //FIXME
        //self.callback(Int(task.terminationStatus), self.output.fileHandleForReading.availableData)
      }
      task.launch()
    }
  }
  
  /**
    This method gets the data that we have written to the process's input.
    */
  internal var writtenData: NSData {
    //FIXME
    //return input.fileHandleForReading.availableData
    return NSData()
  }
  
  /**
    This method writes data to standard input for thje process.
  
    - parameter data:   The data to write.
    */
  internal func writeData(data: NSData) {
    input.fileHandleForWriting.writeData(data)
  }
  
  /**
    This method reads data from standard output for the process.
  
    This will also include data from the standard error stream.
  
    - returns: The latest unread data.
    */
  internal func readData() -> NSData {
    //FIXME
    //return output.fileHandleForReading.availableData
    return NSData()
  }
  
  /**
    This method closes the standard input for the process.
    */
  internal func closeInput() {
    input.fileHandleForWriting.closeFile()
  }
  
  /**
    This method writes a string to the standard input for the process.

    If the string cannot be encoded, this will do nothing.

    - parameter string:   The string to write.
    - parameter encoding: The encoding to encode the string with.
    */
  internal func writeString(string: String, encoding: UInt = NSASCIIStringEncoding) {
    if let data = string.bridge().dataUsingEncoding(encoding) {
      self.writeData(data)
    }
  }
  
  /**
    This method determines if we are stubbing out the processes.
  
    This is controlled by the `startStubbing` and `stopStubbing` methods.
    */
  internal static var stubbing: Bool { return EXTERNAL_PROCESS_STUB_MODE }
  
  /**
    This method starts stubbing out processes.

    This will prevent any further NSTask instances from being launched, and
    instead collected the ExternalProcess instances in the `stubs` array.

    This will also empty the `stubs` array, so if you are going to use this in
    test cases, you should call this at the start of each test case to ensure
    that the results of previous test cases are cleared out.
    */
  internal static func startStubbing() {
    EXTERNAL_PROCESS_STUB_MODE = true
    EXTERNAL_PROCESS_STUBS = []
  }
  
  /**
    This method stops the stubbing of processes.
    */
  internal static func stopStubbing() {
    EXTERNAL_PROCESS_STUB_MODE = false
  }
  
  /**
    This method gets any processes that have been launched since the last call
    to `startStubbing`.
    */
  internal static var stubs: [ExternalProcess] {
    return EXTERNAL_PROCESS_STUBS
  }
  
  /**
    The result of a stubbed process.
    */
  internal static var stubResult: (Int,NSData) {
    get {
      return EXTERNAL_PROCESS_STUB_RESULT
    }
    set {
      EXTERNAL_PROCESS_STUB_RESULT = newValue
    }
  }
}

/**
  This method determines if two processes are equal.

  For the purposes of this method, they will be considered equal if they have
  the same launch path and arguments.

  - parameter lhs:    The left-hand side of the comparison
  - parameter rhs:    The right-hand side of the comparison
  - returns:          Whether the two processes are equal.
  */
internal func ==(lhs: ExternalProcess, rhs: ExternalProcess) -> Bool {
  return lhs.launchPath == rhs.launchPath && lhs.arguments == rhs.arguments
}

/** Whether we are currently stubbing out the processes. */
private var EXTERNAL_PROCESS_STUB_MODE = false

/** The processes that have been launched since we started stubbing. */
private var EXTERNAL_PROCESS_STUBS = [ExternalProcess]()

/** The values that should provide as the result of the process. */
private var EXTERNAL_PROCESS_STUB_RESULT = (0, NSData())