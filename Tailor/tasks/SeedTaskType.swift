/**
  This protocol describes a task that is responsible for writing database seeds.

  You can implement this in a task in your app to be able to write your schema
  and seed data to CSV files, and read them back when resetting a database.

  This can be useful for setting up local development environments.

  The syntax for this is `seeds load`, to load the database from the seed files,
  or `seeds save`, or saving the database contents to the seed files.
  */
public protocol SeedTaskType: TaskType {
  //MARK: - Customization
  
  /**
    This method gets the seed folder where your seeds will live.

    The default is a path inside project directory, inside a folder with your
    project name, and then inside "config/seeds".
  
    The same project name will be used for your app target and your test target.
    */
  static var seedFolder: String { get }
  
  /**
    This method saves the seed data for all of your models to the seed data.

    You can use the `saveModel` method to save each model one by one.
    */
  static func saveModels()
  
  /**
    This method loads the seed data from all of your models to the seed data.
  
    You can use the `loadModel` method to load each model one by one.
  */
  static func loadModels()
  
  /**
    This method provides the names of the tables that should be excluded from
    the schema when saving the schema.

    The default is an empty list.
    */
  static var excludedTables: [String] { get }
}

extension SeedTaskType {
  /**
    This method gets the seed folder where your seeds will live.
    
    The default is a path inside project directory, inside a folder with your
    project name, and then inside "config/seeds".
    
    The same project name will be used for your app target and your test target.
    */
  public static var seedFolder: String {
    var projectName = Application.projectName
    if projectName.hasSuffix("Tests") {
      projectName = projectName.substringToIndex(projectName.endIndex.advancedBy(-5))
    }
    return Application.projectPath + "/" + projectName + "/config/seeds"
  }
  
  /**
    This method gets the path for a seed file.

    - parameter file:   The name of the file, not including the extension.
    - returns:          The path to the file.
    */
  public static func pathForFile(file: String) -> String {
    return self.seedFolder + "/\(file).csv"
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
    This method saves the database schema to a CSV file.

    The file will be called "tables.csv".
    */
  public static func saveSchema() {
    let tables = Application.sharedDatabaseConnection().tables()
    let rows = [["table","sql"]] + tables.filter { !excludedTables.contains($0.0) }.map { [$0.0, $0.1] }.sort { $0[0] < $1[0] }
    let path = self.pathForFile("tables")
    let data = CsvParser.encode(rows)
    let folderPath = (path as NSString).stringByDeletingLastPathComponent
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
    This method loads the database schema from the tables.csv file.
    */
  public static func loadSchema() {
    let connection = Application.sharedDatabaseConnection()
    for tableName in connection.tableNames() {
      connection.executeQuery("DROP TABLE `\(tableName)`")
    }
    let rows = CsvParser(path: self.pathForFile("tables")).rows
    for row in rows {
      if row.count < 2 || row[1] == "sql" {
        continue
      }
      let query = row[1]
      connection.executeQuery(query)
    }
  }
  
  /**
    This method saves all the data for a model to a CSV file.
  
    The file name will be the table name, with a CSV extension.
  
    - parameter model:    The model that we are saving.
    */
  public static func saveModel<ModelType: Persistable>(model: ModelType.Type) {
    saveTable(model.tableName)
  }
  
  /**
    This method saves all the data for a table to a CSV file.
    
    The file name will be the table name, with a CSV extension.
    
    - parameter table:    The table that we are saving.
    */
  public static func saveTable(table: String) {
    let records = Application.sharedDatabaseConnection().executeQuery("SELECT * FROM `\(table)`")
    let data: NSData
    if !records.isEmpty {
      let keys = Array(records[0].data.keys).sort()
      var rows = [keys]
      for record in records {
        let values = record.data
        let row = keys.map { (key: String) -> String in
          guard let value = values[key] else { return "" }
          if value == SerializableValue.Null {
            return ""
          }
          return value.valueDescription
        }
        rows.append(row)
      }
      data = CsvParser.encode(rows)
    }
    else {
      data = NSData()
    }
    let filename = pathForFile(table)
    data.writeToFile(filename, atomically: true)
  }
  
  /**
    This method loads the seed data for a model from its seed file.

    This will not destroy any existing records. It will insert rows with the
    data from the rows in the seed file.

    - parameter model:    The model to load.
    */
  public static func loadModel<ModelType: Persistable>(model: ModelType.Type) {
    self.loadTable(model.tableName)
  }
  
  
  /**
    This method loads the seed data for a table from its seed file.
  
    This will not destroy any existing records. It will insert rows with the
    data from the rows in the seed file.
  
    - parameter table:    The name of the table to load.
  */
  public static func loadTable(table: String) {
    let rows = CsvParser(path: self.pathForFile(table)).rows
    if rows.count == 0 {
      return
    }
    let keys = rows[0].joinWithSeparator("`,`")
    let connection = Application.sharedDatabaseConnection()
    let placeholders = rows[0].map { _ in return "?" }.joinWithSeparator(",")
    let query = "INSERT INTO `\(table)` (`\(keys)`) VALUES (\(placeholders))"
    for index in 1..<rows.count {
      let row = rows[index].map { $0 == "" ? SerializableValue.Null : $0.serialize }
      connection.executeQuery(query, parameters: row)
    }
  }
  
  /**
    This method runs the task for loading or saving seed data.
    */
  public static func runTask() {
    let application = Application.sharedApplication()
    if application.flags["load"] != nil {
      NSLog("Loading seeds from %@", seedFolder)
      self.loadSchema()
      self.loadTable("tailor_alterations")
      self.loadModels()
    }
    else if application.flags["save"] != nil {
      NSLog("Saving seeds to %@", seedFolder)
      self.saveSchema()
      self.saveTable("tailor_alterations")
      self.saveModels()
    }
    else {
      NSLog("You must provide an operation, either `seeds load` or `seeds save`")
    }
  }
  
  //MARK: - Customization
  
  /**
    This method provides the names of the tables that should be excluded from
    the schema when saving the schema.
    
    The default is an empty list.
    */
  public static var excludedTables: [String] { return [] }
  

  /**
    This method gets the name of the command for loading and saving the seeds.

    The default is "seeds".
    */
  public static var commandName: String { return "seeds" }
}
