/**
  This protocol describes a task that is responsible for writing database seeds.

  You can implement this in a task in your app to be able to write your schema
  and seed data to CSV files, and read them back when resetting a database.

  This can be useful for setting up local development environments.
  */
public protocol SeedTaskType: TaskType {
  static func dumpModels()
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
    This method gets the path for a seed file.
    
    - parameter model:  The model that we are writing to the file.
    - returns:          The path to the file.
    */
  public static func pathForFile<ModelType: Persistable>(model: ModelType.Type) -> String {
    return pathForFile(model.modelName().underscored().pluralized)
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
  
  /**
    This method dumps all the data for a model to a CSV file.
  
    The file name will be the model name, in snake case, with a CSV extension.
  
    - parameter model:    The model that we are saving.
    */
  public static func dumpModel<ModelType: Persistable>(model: ModelType.Type) {
    let records = Query<ModelType>().all()
    let data: NSData
    if !records.isEmpty {
      let keys = records[0].valuesToPersist().keys.array.sort()
      var rows = [["id"] + keys]
      for record in records {
        let values = record.valuesToPersist()
        let id = String(record.id ?? 0)
        let row = [id] + keys.map { (values[$0]??.databaseValue ?? DatabaseValue.String("")).description }
        rows.append(row)
      }
      data = CsvParser.encode(rows)
    }
    else {
      data = NSData()
    }
    let filename = pathForFile(model)
    data.writeToFile(filename, atomically: true)
  }
  
  public static func runTask() {
    
  }
}
