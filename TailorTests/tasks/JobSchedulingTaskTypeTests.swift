@testable import Tailor
import TailorTesting

class JobSchedulingTaskTypeTests: TailorTestCase {
  final class TestTask: JobSchedulingTaskType {
    var entries = [JobSchedulingEntry]()
    var defaultFrequency = 1.day
    var defaultStartTime = 0.minutes
    init() {
      run("command1", every: 1.hour)
      run("command2", every: 2.hours)
    }
  }
  
  override func setUp() {
    super.setUp()
    NSThread.currentThread().threadDictionary.removeAllObjects()
  }
  
  override func tearDown() {
    APPLICATION_ARGUMENTS = ("tailor.exit", [:])
    NSThread.currentThread().threadDictionary.removeAllObjects()
    super.tearDown()
  }
  
  func testRunMethodAddsEntryToList() {
    let task = TestTask()
    task.entries = []
    task.run("ps -ef", every: 2.hours, at: 10.minutes)
    assert(task.entries, equals: [JobSchedulingEntry(frequency: 2.hours, startTime: 10.minutes, command: "ps -ef")])
  }
  
  func testRunMethodWithNoStartTimeUsesDefault() {
    let task = TestTask()
    task.entries = []
    task.run("ps -ef", every: 2.hours)
    assert(task.entries, equals: [JobSchedulingEntry(frequency: 2.hours, startTime: 0.minutes, command: "ps -ef")])
  }
  
  func testRunMethodWithNoFrequencyUsesDefault() {
    let task = TestTask()
    task.entries = []
    task.run("ps -ef", at: 10.minutes)
    assert(task.entries, equals: [JobSchedulingEntry(frequency: 1.day, startTime: 10.minutes, command: "ps -ef")])
  }
  
  func testRunMethodWithTaskTypeCreatesCommandFromTask() {
    let task = TestTask()
    task.entries = []
    task.run(AlterationsTask.self, with: ["foo": "bar", "baz": "bat"], every: 6.hours, at: 20.minutes)
    assert(task.entries, equals: [JobSchedulingEntry(frequency: 6.hours, startTime: 20.minutes, command: "run_alterations baz=bat foo=bar")])
  }
  
  func testEveryMethodChangesDefaultFrequencyAndStartTimes() {
    let task = TestTask()
    task.entries = []
    task.every(1.hour, at: 15.minutes) {
      task.run("ps -ef")
    }
    task.run("touch /tmp/hi.txt")
    assert(task.entries, equals: [
      JobSchedulingEntry(frequency: 1.hour, startTime: 15.minutes, command: "ps -ef"),
      JobSchedulingEntry(frequency: 1.day, startTime: 0.minutes, command: "touch /tmp/hi.txt")
    ])
  }
  
  //MARK: - Generating Crontab
  
  func testCronLineWithMinutesInStartTimePutsStartTimeInCronLine() {
    let entry = JobSchedulingEntry(frequency: 0.day, startTime: 10.minutes, command: "whoami")
    assert(entry.cronLine, equals: "10 * * * * whoami")
  }
  
  func testCronLineWithMinutesInFrequencyPutsFrequencyInCronLine() {
    let entry = JobSchedulingEntry(frequency: 10.minutes, startTime: 0.minutes, command: "whoami")
    assert(entry.cronLine, equals: "*/10 * * * * whoami")
  }
  
  func testCronLineWithMinutesInFrequencyAndStartTimePutsMultipleStartTimesInCronLine() {
    let entry = JobSchedulingEntry(frequency: 10.minutes, startTime: 15.minutes, command: "whoami")
    assert(entry.cronLine, equals: "15,25,35,45,55 * * * * whoami")
  }
  
  func testCronLineWithNoMinutesInEitherFieldPutsZeroInCronLine() {
    let entry = JobSchedulingEntry(frequency: 1.hour, startTime: 0.minutes, command: "whoami")
    assert(entry.cronLine, equals: "0 * * * * whoami")
  }
  
  func testCronLineWithOneMinuteFrequencyPutsAsteriskInCronLine() {
    let entry = JobSchedulingEntry(frequency: 1.minute, startTime: 0.minutes, command: "whoami")
    assert(entry.cronLine, equals: "* * * * * whoami")
  }
  
  func testCronLineWithOneHourFrequencyPutsAsteriskInCronLine() {
    let entry = JobSchedulingEntry(frequency: 1.hour, startTime: 0.minutes, command: "whoami")
    assert(entry.cronLine, equals: "0 * * * * whoami")
  }
  
  func testCronLineWithHoursInFrequencyPutsFrequencyInCronLine() {
    let entry = JobSchedulingEntry(frequency: 2.hours, startTime: 0.minutes, command: "whoami")
    assert(entry.cronLine, equals: "0 */2 * * * whoami")
  }
  
  func testCronLineWithHoursInStartTimePutsStartTimeInCronLine() {
    let entry = JobSchedulingEntry(frequency: 0.minutes, startTime: 4.hours, command: "whoami")
    assert(entry.cronLine, equals: "0 4 * * * whoami")
  }
  
  func testCronLineWithHoursInFrequencyAndStartTimePutsMultipleStartTimesInCronLine() {
    let entry = JobSchedulingEntry(frequency: 3.hours, startTime: 1.hour, command: "whoami")
    assert(entry.cronLine, equals: "0 1,4,7,10,13,16,19,22 * * * whoami")
  }
  
  func testCronLineWithNoHoursHasZeroInCronLine() {
    let entry = JobSchedulingEntry(frequency: 1.day, startTime: 0.minutes, command: "whoami")
    assert(entry.cronLine, equals: "0 0 * * * whoami")
  }
  
  func testCronLineWithNoHoursWithMinutesHasAsteriskInCronLine() {
    let entry = JobSchedulingEntry(frequency: 30.minutes, startTime: 0.minutes, command: "whoami")
    assert(entry.cronLine, equals: "*/30 * * * * whoami")
  }
  
  func testCronLineEntriesFromDocumentationGenerateExpectedValues() {
    var entry = JobSchedulingEntry(frequency: 1.hour, startTime: 10.minutes, command: "whoami")
    assert(entry.cronLine, equals: "10 * * * * whoami")
    entry = JobSchedulingEntry(frequency: 30.minutes, startTime: 0.minutes, command: "whoami")
    assert(entry.cronLine, equals: "*/30 * * * * whoami")
    entry = JobSchedulingEntry(frequency: 2.hours + 10.minutes, startTime: 0.minutes, command: "whoami")
    assert(entry.cronLine, equals: "*/10 */2 * * * whoami")
    entry = JobSchedulingEntry(frequency: 2.days, startTime: 6.hours + 30.minutes, command: "whoami")
    assert(entry.cronLine, equals: "30 6 */2 * * whoami")
    entry = JobSchedulingEntry(frequency: 10.minutes, startTime: 1.hour, command: "whoami")
    assert(entry.cronLine, equals: "*/10 1 * * * whoami")
    entry = JobSchedulingEntry(frequency: 4.months, startTime: 15.days, command: "whoami")
    assert(entry.cronLine, equals: "0 0 15 */4 * whoami")
  }
  
  func testCronHeaderLineGetsHeaderLine() {
    let task = TestTask()
    assert(task.cronHeaderLine, equals: "# Begin crontab for TailorTests")
  }
  
  func testCronFooterLineGetsFooterLine() {
    let task = TestTask()
    assert(task.cronFooterLine, equals: "# End crontab for TailorTests")
  }
  
  func testCrontabGeneratesCrontabForJobs() {
    let task = TestTask()
    task.entries = [
      JobSchedulingEntry(frequency: 1.day, startTime: 6.hours, command: "command1"),
      JobSchedulingEntry(frequency: 6.hours, startTime: 30.minutes, command: "command2")
    ]
    assert(task.crontab, equals: "# Begin crontab for TailorTests\n0 6 * * * command1\n30 */6 * * * command2\n# End crontab for TailorTests")
  }
  
  func testWriteCrontabWritesCrontabForJobs() {
    let task = TestTask()
    task.entries = [
      JobSchedulingEntry(frequency: 1.day, startTime: 6.hours, command: "command1"),
      JobSchedulingEntry(frequency: 6.hours, startTime: 30.minutes, command: "command2")
    ]
    let crontab = "# Begin crontab for TailorTests\n0 6 * * * command1\n30 */6 * * * command2\n# End crontab for TailorTests"
    ExternalProcess.startStubbing()
    ExternalProcess.stubResult = (0, NSData())
    task.writeCrontab()
    ExternalProcess.stopStubbing()
    guard let process = ExternalProcess.stubs.last else {
      assert(false, message: "did not start any processes")
      return
    }
    assert(process.launchPath, equals: "/usr/bin/crontab")
    assert(process.arguments, equals: ["/tmp/tailor_crons.txt"])
    let writtenContents = NSString(data: NSData(contentsOfFile: "/tmp/tailor_crons.txt") ?? NSData(), encoding: NSUTF8StringEncoding)
    assert(writtenContents, equals: crontab + "\n")
  }
  
  func testWriteCrontabWithExistingCrontabPutsNewContentAtEndOfCrontab() {
    let task = TestTask()
    task.entries = [
      JobSchedulingEntry(frequency: 1.day, startTime: 6.hours, command: "command1"),
      JobSchedulingEntry(frequency: 6.hours, startTime: 30.minutes, command: "command2")
    ]
    let crontab = "# Begin crontab for TailorTests\n0 6 * * * command1\n30 */6 * * * command2\n# End crontab for TailorTests"
    let existingCrontab = "* 0 * * * ls"
    ExternalProcess.startStubbing()
    ExternalProcess.stubResult = (0, NSData(bytes: existingCrontab.utf8))
    task.writeCrontab()
    ExternalProcess.stopStubbing()
    guard let process = ExternalProcess.stubs.first else {
      assert(false, message: "did not start any processes")
      return
    }
    guard let process2 = ExternalProcess.stubs.last else {
      assert(false, message: "did not start any processes")
      return
    }
    assert(process.launchPath, equals: "/usr/bin/crontab")
    assert(process.arguments, equals: ["-l"])
    assert(process2.launchPath, equals: "/usr/bin/crontab")
    assert(process2.arguments, equals: ["/tmp/tailor_crons.txt"])
    let writtenContents = NSString(data: NSData(contentsOfFile: "/tmp/tailor_crons.txt") ?? NSData(), encoding: NSUTF8StringEncoding)
    assert(writtenContents, equals: existingCrontab + "\n" + crontab + "\n")
  }
  
  func testWriteCrontabWithExistingCrontabWithTailorSectionReplacesJustTailorSection() {
    let task = TestTask()
    task.entries = [
      JobSchedulingEntry(frequency: 1.day, startTime: 6.hours, command: "command1"),
      JobSchedulingEntry(frequency: 6.hours, startTime: 30.minutes, command: "command2")
    ]
    let existingCrontab = "* 0 * * * ls\n# Begin crontab for TailorTests\n0 6 * * * command3\n# End crontab for TailorTests\n* 1 * * * whoami"
    let resultCrontab = "* 0 * * * ls\n# Begin crontab for TailorTests\n0 6 * * * command1\n30 */6 * * * command2\n# End crontab for TailorTests\n* 1 * * * whoami"
    ExternalProcess.startStubbing()
    ExternalProcess.stubResult = (0, NSData(bytes: existingCrontab.utf8))
    task.writeCrontab()
    ExternalProcess.stopStubbing()
    guard let process = ExternalProcess.stubs.first else {
      assert(false, message: "did not start any processes")
      return
    }
    guard let process2 = ExternalProcess.stubs.last else {
      assert(false, message: "did not start any processes")
      return
    }
    assert(process.launchPath, equals: "/usr/bin/crontab")
    assert(process.arguments, equals: ["-l"])
    assert(process2.launchPath, equals: "/usr/bin/crontab")
    assert(process2.arguments, equals: ["/tmp/tailor_crons.txt"])
    let writtenContents = NSString(data: NSData(contentsOfFile: "/tmp/tailor_crons.txt") ?? NSData(), encoding: NSUTF8StringEncoding)
    assert(writtenContents, equals: resultCrontab + "\n")
  }
  
  func testWriteCrontabWithEmptyExistingCrontabWithTailorSectionWritesJustTailorSection() {
    let task = TestTask()
    task.entries = [
      JobSchedulingEntry(frequency: 1.day, startTime: 6.hours, command: "command1"),
      JobSchedulingEntry(frequency: 6.hours, startTime: 30.minutes, command: "command2")
    ]
    ExternalProcess.startStubbing()
    ExternalProcess.stubResult = (0, NSData(bytes: "crontab: no crontab for tailor".utf8))
    task.writeCrontab()
    ExternalProcess.stopStubbing()
    guard let process = ExternalProcess.stubs.first else {
      assert(false, message: "did not start any processes")
      return
    }
    guard let process2 = ExternalProcess.stubs.last else {
      assert(false, message: "did not start any processes")
      return
    }
    assert(process.launchPath, equals: "/usr/bin/crontab")
    assert(process.arguments, equals: ["-l"])
    assert(process2.launchPath, equals: "/usr/bin/crontab")
    assert(process2.arguments, equals: ["/tmp/tailor_crons.txt"])
    let writtenContents = NSString(data: NSData(contentsOfFile: "/tmp/tailor_crons.txt") ?? NSData(), encoding: NSUTF8StringEncoding)
    assert(writtenContents, equals: task.crontab + "\n")
  }
  
  func testClearCrontabWithExistingCrontabWithTailorSectionRemovesJustTailorSection() {
    let task = TestTask()
    task.entries = [
      JobSchedulingEntry(frequency: 1.day, startTime: 6.hours, command: "command1"),
      JobSchedulingEntry(frequency: 6.hours, startTime: 30.minutes, command: "command2")
    ]
    let existingCrontab = "* 0 * * * ls\n# Begin crontab for TailorTests\n0 6 * * * command3\n# End crontab for TailorTests\n* 1 * * * whoami"
    let resultCrontab = "* 0 * * * ls\n* 1 * * * whoami"
    ExternalProcess.startStubbing()
    ExternalProcess.stubResult = (0, NSData(bytes: existingCrontab.utf8))
    task.clearCrontab()
    ExternalProcess.stopStubbing()
    guard let process = ExternalProcess.stubs.first else {
      assert(false, message: "did not start any processes")
      return
    }
    guard let process2 = ExternalProcess.stubs.last else {
      assert(false, message: "did not start any processes")
      return
    }
    assert(process.launchPath, equals: "/usr/bin/crontab")
    assert(process.arguments, equals: ["-l"])
    assert(process2.launchPath, equals: "/usr/bin/crontab")
    assert(process2.arguments, equals: ["/tmp/tailor_crons.txt"])
    let writtenContents = NSString(data: NSData(contentsOfFile: "/tmp/tailor_crons.txt") ?? NSData(), encoding: NSUTF8StringEncoding)
    assert(writtenContents, equals: resultCrontab + "\n")
  }
  
  //MARK: - Tasks
  
  func testRunTaskWithWriteCommandWritesCrontab() {
    let crontab = "# Begin crontab for TailorTests\n0 * * * * command1\n0 */2 * * * command2\n# End crontab for TailorTests"
    ExternalProcess.startStubbing()
    ExternalProcess.stubResult = (0, NSData())
    APPLICATION_ARGUMENTS = ("scheduled_jobs", ["write": "1"])
    
    TestTask.runTask()
    ExternalProcess.stopStubbing()
    guard let process = ExternalProcess.stubs.last else {
      assert(false, message: "did not start any processes")
      return
    }
    assert(process.launchPath, equals: "/usr/bin/crontab")
    assert(process.arguments, equals: ["/tmp/tailor_crons.txt"])
    let writtenContents = NSString(data: NSData(contentsOfFile: "/tmp/tailor_crons.txt") ?? NSData(), encoding: NSUTF8StringEncoding)
    assert(writtenContents, equals: crontab + "\n")
  }
  
  func testRunTaskWithClearCommandClearsCrontab() {
    let existingCrontab = "* 0 * * * ls\n# Begin crontab for TailorTests\n0 6 * * * command3\n# End crontab for TailorTests\n* 1 * * * whoami"
    let resultCrontab = "* 0 * * * ls\n* 1 * * * whoami"
    ExternalProcess.startStubbing()
    ExternalProcess.stubResult = (0, NSData(bytes: existingCrontab.utf8))
    
    APPLICATION_ARGUMENTS = ("scheduled_jobs", ["clear": "1"])
    TestTask.runTask()
    ExternalProcess.stopStubbing()
    guard let process = ExternalProcess.stubs.first else {
      assert(false, message: "did not start any processes")
      return
    }
    guard let process2 = ExternalProcess.stubs.last else {
      assert(false, message: "did not start any processes")
      return
    }
    assert(process.launchPath, equals: "/usr/bin/crontab")
    assert(process.arguments, equals: ["-l"])
    assert(process2.launchPath, equals: "/usr/bin/crontab")
    assert(process2.arguments, equals: ["/tmp/tailor_crons.txt"])
    let writtenContents = NSString(data: NSData(contentsOfFile: "/tmp/tailor_crons.txt") ?? NSData(), encoding: NSUTF8StringEncoding)
    assert(writtenContents, equals: resultCrontab + "\n")
    
  }
  
  func testRunTaskWithInvalidCommandDoesNotStartProcess() {
    ExternalProcess.startStubbing()
    ExternalProcess.stubResult = (0, NSData(bytes: "Yo".utf8))
    
    APPLICATION_ARGUMENTS = ("scheduled_jobs", ["foo": "1"])
    TestTask.runTask()
    ExternalProcess.stopStubbing()
    assert(ExternalProcess.stubs.isEmpty)
    
  }

  
  //MARK: - Comparisons
  
  func testEntriesWithSameInformationAreEqual() {
    let entry1 = JobSchedulingEntry(frequency: 2.hours, startTime: 10.minutes, command: "ps -ef")
    let entry2 = JobSchedulingEntry(frequency: 2.hours, startTime: 10.minutes, command: "ps -ef")
    assert(entry1, equals: entry2)
  }
  
  func testEntriesWithDifferentFrequenciesAreNotEqual() {
    let entry1 = JobSchedulingEntry(frequency: 2.hours, startTime: 10.minutes, command: "ps -ef")
    let entry2 = JobSchedulingEntry(frequency: 3.hours, startTime: 10.minutes, command: "ps -ef")
    assert(entry1, doesNotEqual: entry2)
  }
  
  func testEntriesWithDifferentStartTimesAreNotEqual() {
    let entry1 = JobSchedulingEntry(frequency: 2.hours, startTime: 10.minutes, command: "ps -ef")
    let entry2 = JobSchedulingEntry(frequency: 2.hours, startTime: 20.minutes, command: "ps -ef")
    assert(entry1, doesNotEqual: entry2)
  }
  
  func testEntriesWithDifferentCommandsAreNotEqual() {
    let entry1 = JobSchedulingEntry(frequency: 2.hours, startTime: 10.minutes, command: "ps -ef")
    let entry2 = JobSchedulingEntry(frequency: 2.hours, startTime: 10.minutes, command: "ps -eo")
    assert(entry1, doesNotEqual: entry2)
  }
}