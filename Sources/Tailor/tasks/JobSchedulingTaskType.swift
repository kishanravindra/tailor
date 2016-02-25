import Foundation

/**
  This type represents an entry in a job schedule.

  This is a single job that will be run at a given frequency, offset by its
  start time.

  For instance, if a job's frequency is 2 hours, and its start time is 20
  minutes, it will run every two hours at 20 minutes past the hour.

  The default job scheduling task uses cron to schedule the jobs. The mapping
  between time frequencies and cron frequencies may have surprising cases, so
  you should read the documentation on the `cronLine` method for details about
  how this mapping is calculated.
  */
public struct JobSchedulingEntry: Equatable {
  /** How often the job runs. */
  public let frequency: TimeInterval
  
  /** The start time of the job, as an offset from the frequency. */
  public let startTime: TimeInterval
  
  /** The command that this job runs. */
  public let command: String
  
  /**
    This initializer creates a job scheduling entry.

    - parameter frequency:  How often the job runs.
    - parameter startTime:  The start time of the job.
    - parameter command:    The command that this job runs.
    */
  public init(frequency: TimeInterval, startTime: TimeInterval, command: String) {
    self.frequency = frequency
    self.startTime = startTime
    self.command = command
  }
  
  /**
    This method generates a part of a cron timing expression for a job.
  
    This generates just the part of the expression for a single unit of time:
    minutes, hours, etc.
    
    - parameter job:                How frequently the job runs on this unit.
    - parameter start:              When the jobs starts within this unit.
    - parameter max:                The maximum value that is allowed for this
                                    unit.
    - parameter defaultToWildcard:  Whether we should use a wildcard if the
                                    frequency and start are both zero.
    - returns:                      The timing expression.
    */
  private func cronExpression(frequency: Int, start: Int, max: Int, defaultToWildcard: Bool) -> String {
    if start != 0 {
      if frequency != 0 {
        let values = start.stride(through: max, by: frequency)
        return values.map { String($0) }.joinWithSeparator(",")
      }
      else {
        return "\(start)"
      }
    }
    else if frequency > 1 {
      return  "*/\(frequency)"
    }
    else if frequency == 1 {
      return "*"
    }
    else if defaultToWildcard {
      return "*"
    }
    else {
      return "0"
    }
  }
  
  /**
    This method creates a line for a crontab for this entry.

    A cron entry has six parts:

    - minute
    - hour
    - day of month
    - month
    - day of week
    - command
  
    The day of week is not currently supported, so it will always be an
    asterisk. For the other fields, they are mapped to the corresponding field
    in the frequency and start times as follows
  
    - If there is a zero value in the start time, and a zero in the frequency,
      and all of the preceding values in the cron line are zero, the value will
      be zero.
    - If there is a zero value in the start time, and a zero in the frequency,
      and one of the preceding values in the cron line is not zero, the value
      will be a wildcard.
    - If there is a value in the start time, and none in the frequency, the
      value will be the value from the start time.
    - If there is a value in the start time, and a value in the frequency, the
      value will be a comma-separated list of numbers, starting from the start
      time, and increasing by the frequency.
    - If there is a non-zero and non-one value in the frequency, and none in the
      start time, the value will be an asterisk, followed by a slash, followed
      by the value from the frequency.
    - If there is a value of one in the frequency, and none in the start time,
      the value will be an asterisks.
  
    The command will always be the command from the job.
  
    Here are some examples of this. The commands have been removed for
    simplicity, but they will be placed after the timing strings. Any occurences
    of `_/` will actually be an asterisk followed by a slash, but that cannot be
    expressed in this documentation.
  
    <table>
      <tr>
        <th>Frequency</th>
        <th>Start Time</th>
        <th>Cron Entry</th>
        <th>Description</th>
      </tr>
      <tr>
        <td>1.hour</td>
        <td>10.minutes</td>
        <td>10 * * * *</td>
        <td>Every hour, at 10 minutes past the hour</td>
      </tr>
      <tr>
        <td>30.minutes</td>
        <td>0.minutes</td>
        <td>_/30 * * * *</td>
        <td>Every 30 minutes</td>
      </tr>
      <tr>
        <td>2.hours + 10.minutes</td>
        <td>0.minutes</td>
        <td>_/10 _/2 * * *</td>
        <td>Every 10 minutes, but only every other hour</td>
      </tr>
      <tr>
        <td>2.days</td>
        <td>6.hours + 30.minutes</td>
        <td>30 6 _/2 * *</td>
        <td>Every 2 days at 06:30</td>
      </tr>
      <tr>
        <td>10.minutes</td>
        <td>1.hour</td>
        <td>_/10 1 * *</td>
        <td>once every 10 minutes between 1:00 and 1:50</td>
      </tr>
      <tr>
        <td>3.hours</td>
        <td>1.hour</td>
        <td>0 1,4,7,10,13,16,19,22 * *</td>
        <td>Once every three hours every day starting at 1:00, at the top of the hour</td>
      </tr>
      <tr>
        <td>4.months</td>
        <td>15.days</td>
        <td>0 0 15 _/4 *</td>
        <td>Once every hour months, on the 15th day of the month, at midnight</td>
      </tr>
    </table>
    */
  public var cronLine: String {
    var timings = (minute: "*", hour: "*", day: "*", month: "*", dayOfWeek: "*")
    timings.minute = cronExpression(frequency.minutes, start: startTime.minutes, max: 60, defaultToWildcard: false)
    timings.hour = cronExpression(frequency.hours, start: startTime.hours, max: 23, defaultToWildcard: timings.minute != "0")
    timings.day = cronExpression(frequency.days, start: startTime.days, max: 31, defaultToWildcard: timings.hour != "0")
    timings.month = cronExpression(frequency.months, start: startTime.months, max: 12, defaultToWildcard: timings.day != "0")
    return "\(timings.minute) \(timings.hour) \(timings.day) \(timings.month) \(timings.dayOfWeek) \(command)"
  }
}

/**
  This protocol describes a task that writes to a file of scheduled jobs.

  This protocol also provides a DSL for adding entries to the job file, using
  the `run` and `every` methods.

  The task will create an instance of the task type, and use its entries to
  populate the job file. The default implementation writes to a crontab file,
  but you can change this with custom implementations of the `clearJobs` and
  `writeJobs` methods. The crontab will have comments before and after the jobs
  written by this task. These comments will be specific to the application
  hosting the jobs. When updating or clearing the crontab, it will remove the
  existing jobs between these two commented sections. This allows you to add
  extra jobs that are not managed by Tailor, or have jobs for multiple
  applications in the same cron file, without having them be affected by this
  task.

  The best practice is to have an initializer that uses the DSL to add things
  to the list of entries. For instance, this class:
  
      class JobSchedulingTask: JobSchedulingTaskType {
        var entries = [JobSchedulingEntry]()
        var defaultFrequency = 1.day
        var defaultStartTime = 0.minutes

        init() {
          every(2.hours) {
            run "task1"
          }

          every(1.hour, at: 10.minutes) {
            run "task2"
          }
        }
      }

  Would have an entry that runs task1 every 2 hours at the top of the hour,
  and an entry that runs task2 every hour at 10 minutes past the hour.
  */
public protocol JobSchedulingTaskType: TaskType {
  /** The entries in the schedule. */
  var entries: [JobSchedulingEntry] { get set }
  
  /**
    The default frequency for jobs that don't specify a frequency. The `every`
    method changes this default for jobs added in its block.
    */
  var defaultFrequency: TimeInterval { get set }
  
  /**
    The default start time for jobs that don't specify a start time. The `every`
    method changes this default for jobs added in its block.
    */
  var defaultStartTime: TimeInterval { get set }
  
  /**
    This initializer creates the schedule when we're running the task.
    */
  init()
  
  /**
    This method writes our jobs to the job file.

    The default implementation for this produces a crontab file and saves it
    as the user's crontab.
    */
  func writeJobs()
  
  /**
    This method removes our jobs from the job file.

    The default implementation looks for our jobs in the user's crontab and
    removes our entries.
    */
  func clearJobs()
}

extension JobSchedulingTaskType {
  /**
    This method runs the job scheduling task.

    If there is a `write` argument to the task, this will write the jobs. If
    there is a `clear` arguments to the task, this will clear the jobs.
    */
  public static func runTask() {
    let arguments = Application.sharedApplication().flags
    if arguments["write"] != nil {
      self.init().writeJobs()
    }
    else if arguments["clear"] != nil {
      self.init().clearJobs()
    }
    else if arguments["print"] != nil {
      self.init().printJobs()
    }
    else {
      let commandName = self.commandName
      NSLog("You must provide a command, either `\(commandName) write`, `\(commandName) print`, or `\(commandName) clear`")
    }
  }
  
  /**
    This method writes our jobs to the job file.
    
    The default implementation for this produces a crontab file and saves it
    as the user's crontab.
    */
  public func writeJobs() {
    writeCrontab()
  }
  
  /**
   This method writes our jobs to the job file.
   
   The default implementation for this writes the crontab to the console.
   */
  public func printJobs() {
    printCrontab()
  }
  
  /**
    This method removes our jobs from the job file.

    The default implementation looks for our jobs in the user's crontab and
    removes our entries.
    */
  public func clearJobs() {
    clearCrontab()
  }
  
  //MARK: - Adding Jobs
  
  /**
    This method adds a job to our schedule.

    - parameter command:    The command for the job.
    - parameter frequency:  The frequency at which the job runs. If this is not
                            provided, it uses the current `defaultFrequency`.
    - parameter startTime:  The time at which the job starts. If this is not
                            provided, it uses the current `defaultStartTime`.
    */
  public func run(command: String, every frequency: TimeInterval? = nil, at startTime: TimeInterval? = nil) {
    self.entries.append(JobSchedulingEntry(frequency: frequency ?? defaultFrequency, startTime: startTime ?? defaultStartTime, command: command))
  }
  
  /**
    This method adds a job to our schedule that runs another task.
    
    - parameter task:       The task to run.
    - parameter arguments:  The arguments to pass to the job on the command
                            line.
    - parameter frequency:  The frequency at which the job runs. If this is not
                            provided, it uses the current `defaultFrequency`.
    - parameter startTime:  The time at which the job starts. If this is not
                            provided, it uses the current `defaultStartTime`.
    */
  public func run(task: TaskType.Type, with arguments: [String:String], every frequency: TimeInterval? = nil, at startTime: TimeInterval? = nil) {
    var command = Process.arguments.first ?? ""
    command += " " + task.commandName
    if !arguments.isEmpty {
      let argumentStrings = arguments.map {
        key,value in "\(key)=\(value)"
      }.sort()
      command += " " + argumentStrings.joinWithSeparator(" ")
    }
    self.run(command, every: frequency, at: startTime)
  }
  
  /**
    This method changes the default frequency or start time for jobs added in
    a block.

    - parameter frequency:    The new default frequency.
    - parameter startTime:    The new default start time.
    - parameter block:        The block to add the jobs.
    */
  public func every(frequency: TimeInterval, at startTime: TimeInterval? = nil, @noescape block: Void->Void) {
    let oldFrequency = self.defaultFrequency
    let oldStartTime = self.defaultStartTime
    self.defaultFrequency = frequency
    if let time = startTime {
      self.defaultStartTime = time
    }
    block()
    self.defaultFrequency = oldFrequency
    self.defaultStartTime = oldStartTime
  }
  
  //MARK: - Crons
  
  /** This method gets a comments that begins our section of the crontab. */
  public var cronHeaderLine: String {
    return "# Begin crontab for " + Application.configuration.projectName
  }
  
  /** This method gets a comments that ends our section of the crontab. */
  public var cronFooterLine: String {
    return "# End crontab for " + Application.configuration.projectName
  }
  
  /**
    This method gets the full crontab that we write, including the header and
    footer sections.
    */
  public var crontab: String {
    return cronHeaderLine + "\n" + entries.map { $0.cronLine }.joinWithSeparator("\n") + "\n" + cronFooterLine
  }
  
  /**
    This method writes the crontab to the user's crontab file.
    */
  public func writeCrontab() {
    updateCrontab(includeNewCrontab: true)
  }
  
  /**
    This method removes our entries from the user's crontab file.
    */
  public func clearCrontab() {
    updateCrontab(includeNewCrontab: false)
  }
  
  public func printCrontab() {
    print(self.crontab)
  }
  
  /**
    This method updates our section of the user's crontab file.

    This will remove our previous entries. If the includeNewCrontab flag is
    true, this will generate a fresh crontab and add it into our section of the
    crontab. If we do not have a previous entry in the crontab, it will add our
    section at the end.
    */
  private func updateCrontab(includeNewCrontab includeNewCrontab: Bool) {
    let crontabLocation = "/tmp/tailor_crons.txt"
    var finished = false
    ExternalProcess(launchPath: "/usr/bin/crontab", arguments: ["-l"]) {
      listResult, listData in
      guard let listText = NSString(data: listData, encoding: NSUTF8StringEncoding)?.bridge() else {
        NSLog("Error listing crontab: %@", String(listData))
        finished = true
        return
      }
      var fullCrontab = ""
      var inReplacementSection = false
      var exitedReplacementSection = false
      for lineCharacters in listText.characters.split("\n") {
        let line = String(lineCharacters)
        if line == self.cronHeaderLine {
          inReplacementSection = true
        }
        else if line == self.cronFooterLine {
          inReplacementSection = false
          if includeNewCrontab {
            fullCrontab += self.crontab + "\n"
          }
          exitedReplacementSection = true
        }
        else if line.hasPrefix("crontab: no crontab") {
          continue
        }
        else if !inReplacementSection {
          fullCrontab += line + "\n"
        }
      }
      if !exitedReplacementSection && includeNewCrontab {
        fullCrontab += self.crontab + "\n"
      }

      NSData(bytes: fullCrontab.utf8).writeToFile(crontabLocation, atomically: true)
      ExternalProcess(launchPath: "/usr/bin/crontab", arguments: [crontabLocation]) {
        writeResult, writeData in
        if writeResult != 0 {
          let writeString = NSString(data: writeData, encoding: NSUTF8StringEncoding)?.bridge() ?? String(writeData)
          NSLog("Error writing crontab: %@", writeString)
        }
        finished = true
      }.launch()
    }.launch()
    while(!finished) {}
  }
}

/**
  This method determines if two job scheduling entries are equal.

  Two entries are equal if the have the same frequency, start time, and command.

  - parameter lhs:    The left-hand side of the comparison.
  - parameter rhs:    The right-hand side of the comparison.
  - returns:          Whether the two entries are equal.
  */
public func ==(lhs: JobSchedulingEntry, rhs: JobSchedulingEntry) -> Bool {
  return lhs.frequency == rhs.frequency && lhs.startTime == rhs.startTime && lhs.command == rhs.command
}