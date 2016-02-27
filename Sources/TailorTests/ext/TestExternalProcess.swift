@testable import Tailor
import TailorTesting
import XCTest
import Foundation

struct TestExternalProcess: XCTestCase, TailorTestable {
  //FIXME: Re-enable disabled tests
  var allTests: [(String, () throws -> Void)] { return [
    ("testInitializationSetsLaunchPathAndArguments", testInitializationSetsLaunchPathAndArguments),
    ("testInitializationWithoutArgumentsSetsEmptyArguments", testInitializationWithoutArgumentsSetsEmptyArguments),
    ("testLaunchInStubModeAddsProcessToStubs", testLaunchInStubModeAddsProcessToStubs),
    ("testLaunchInStubModeCallsCallbackWithStubResult", testLaunchInStubModeCallsCallbackWithStubResult),
    ("testLaunchInStubModeDoesNotLaunchTask", testLaunchInStubModeDoesNotLaunchTask),
    ("testLaunchInNonStubModeDoesNotAddProcessToStubs", testLaunchInNonStubModeDoesNotAddProcessToStubs),
    ("testLaunchInNonStubModeDoesLaunchesTask", testLaunchInNonStubModeDoesLaunchesTask),
    //("testLaunchInNonStubModeCallsCallbackWithResults", testLaunchInNonStubModeCallsCallbackWithResults),
    //("testWrittenDataCollectsWrittenData", testWrittenDataCollectsWrittenData),
    //("testInputAndOutputAreSharedWithProcess", testInputAndOutputAreSharedWithProcess),
    ("testStartStubbingSetsStubFlagToTrue", testStartStubbingSetsStubFlagToTrue),
    ("testStartStubbingClearsPreviousStubs", testStartStubbingClearsPreviousStubs),
    ("testStopStubbingSetsStubFlagToFalse", testStopStubbingSetsStubFlagToFalse),
  ]}

  func setUp() {
    setUpTestCase()
  }
  
  func testInitializationSetsLaunchPathAndArguments() {
    let process = ExternalProcess(launchPath: "/usr/bin/echo", arguments: ["Hello"])
    
    assert(process.launchPath, equals: "/usr/bin/echo")
    assert(process.arguments, equals: ["Hello"])
  }
  
  func testInitializationWithoutArgumentsSetsEmptyArguments() {
    let process = ExternalProcess(launchPath: "/usr/bin/echo")
    assert(process.arguments, equals: [])
  }
  
  func testLaunchInStubModeAddsProcessToStubs() {
    ExternalProcess.startStubbing()
    let path = "/tmp/stub_test.txt"
    do { try NSFileManager.defaultManager().removeItemAtPath(path) } catch {}
    let process = ExternalProcess(launchPath: "/usr/bin/touch", arguments: [path])
    process.launch()
    assert(ExternalProcess.stubs, equals: [process])
  }
  
  func testLaunchInStubModeCallsCallbackWithStubResult() {
    ExternalProcess.startStubbing()
    let path = "/tmp/stub_test.txt"
    do { try NSFileManager.defaultManager().removeItemAtPath(path) } catch {}
    ExternalProcess.stubResult = (123, NSData(bytes: [1,2,3,4]))
    let expectation = expectationWithDescription("callback called")
    let process = ExternalProcess(launchPath: "/usr/bin/touch", arguments: [path]) {
      code,data in
      expectation.fulfill()
      XCTAssertEqual(code, 123)
      XCTAssertEqual(data, NSData(bytes: [1,2,3,4]))
    }
    process.launch()
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }
  
  func testLaunchInStubModeDoesNotLaunchTask() {
    ExternalProcess.startStubbing()
    let path = "/tmp/stub_test.txt"
    do { try NSFileManager.defaultManager().removeItemAtPath(path) } catch {}
    let process = ExternalProcess(launchPath: "/usr/bin/touch", arguments: [path])
    process.launch()
    NSThread.sleepForTimeInterval(0.1)
    assert(!NSFileManager.defaultManager().fileExistsAtPath(path), message: "does not run the task")
  }
  
  func testLaunchInNonStubModeDoesNotAddProcessToStubs() {
    ExternalProcess.stopStubbing()
    let path = "/tmp/stub_test.txt"
    do { try NSFileManager.defaultManager().removeItemAtPath(path) } catch {}
    let process = ExternalProcess(launchPath: "/usr/bin/touch", arguments: [path])
    process.launch()
    assert(ExternalProcess.stubs, equals: [])
  }
  
  func testLaunchInNonStubModeDoesLaunchesTask() {
    ExternalProcess.stopStubbing()
    let path = "/tmp/stub_test.txt"
    do { try NSFileManager.defaultManager().removeItemAtPath(path) } catch {}
    let expectation = expectationWithDescription("task finished")
    let process = ExternalProcess(launchPath: "/usr/bin/touch", arguments: [path]) {
      _,_ in
      expectation.fulfill()
      XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(path), "runs the task")
    }
    process.launch()
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }
  
  func testLaunchInNonStubModeCallsCallbackWithResults() {
    ExternalProcess.stopStubbing()
    let path = "/tmp/stub_test.txt"
    do { try NSFileManager.defaultManager().removeItemAtPath(path) } catch {}
    let expectation = expectationWithDescription("task finished")
    let process = ExternalProcess(launchPath: "/bin/cat", arguments: [path]) {
      code,data in
      XCTAssertEqual(code, 1, "exits with an error")
      let otherData = "cat: /tmp/stub_test.txt: No such file or directory\n".dataUsingEncoding(NSASCIIStringEncoding)!
      XCTAssert(data.isEqualToData(otherData), "has the expected error message in the output")
      expectation.fulfill()
    }
    process.launch()
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }
  
  func testWrittenDataCollectsWrittenData() {
    ExternalProcess.startStubbing()
    let process = ExternalProcess(launchPath: "/usr/bin/echo")
    process.launch()
    process.writeData(NSData(bytes: [1,2,3,4]))
    process.writeData(NSData(bytes: [1,2,3,4]))
    assert(process.writtenData, equals: NSData(bytes: [1,2,3,4,1,2,3,4]))
  }
  
  func testInputAndOutputAreSharedWithProcess() {
    ExternalProcess.stopStubbing()
    let process = ExternalProcess(launchPath: "/usr/bin/grep", arguments: ["foo"])
    process.launch()
    process.writeString("foo fighters\n")
    process.writeString("bar\n")
    process.writeString("foobar\n")
    process.closeInput()
    assert(process.readData(), equals: "foo fighters\nfoobar\n".dataUsingEncoding(NSASCIIStringEncoding)!)
  }
  
  func testStartStubbingSetsStubFlagToTrue() {
    ExternalProcess.stopStubbing()
    ExternalProcess.startStubbing()
    assert(ExternalProcess.stubbing)
  }
  
  func testStartStubbingClearsPreviousStubs() {
    ExternalProcess.startStubbing()
    let process = ExternalProcess(launchPath: "/usr/bin/echo")
    process.launch()
    ExternalProcess.startStubbing()
    assert(ExternalProcess.stubs, equals: [])
  }
  
  func testStopStubbingSetsStubFlagToFalse() {
    ExternalProcess.startStubbing()
    ExternalProcess.stopStubbing()
    assert(!ExternalProcess.stubbing)
  }
}