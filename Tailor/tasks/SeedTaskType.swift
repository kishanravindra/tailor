/**
  This protocol describes a task that is responsible for writing database seeds.

  You can implement this in a task in your app to be able to write your schema
  and seed data to CSV files, and read them back when resetting a database.

  This can be useful for setting up local development environments.
  */
public protocol SeedTaskType: TaskType {
}

extension SeedTaskType {
  /**
    This method gets the path for a seed file.

    - parameter file:   The name of the file, not including the extension.
    - returns:          The path to the file.
    */
  public static func pathForFile(file: String) -> String {
    let info = NSProcessInfo.processInfo().environment
    let directory = info["PWD"] ?? "."
    let path = directory + "/seeds/\(file).csv"
    return path
  }
  
  /**
    This method dumps the database schema to a CSV file.

    The file will be called "tables.csv".
    */
  public static func dumpSchema() {
    let tables = Application.sharedDatabaseConnection().tables()
    let rows = [["table","sql"]] + tables.map {
      (key,value) in
      [key,value]
      }.sort { $0[0] < $1[0] }
    let path = self.pathForFile("tables")
    let data = CsvParser.encode(rows)
    let folderPath = path.stringByDeletingLastPathComponent
    do {
      let manager = NSFileManager.defaultManager()
      try manager.createDirectoryAtPath(folderPath, withIntermediateDirectories: true, attributes: nil)
      try data.writeToFile(path, options: [.DataWritingAtomic])
    }
    catch let error {
      NSLog("Error writing seed data: \(error._domain) \(error._code)")
    }
  }
  
  public static func runTask() {
    
  }
}
