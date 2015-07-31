import Tailor
import TailorTesting

class SeedTaskTypeTests: TailorTestCase {
  final class SeedTask: SeedTaskType {
    static var commandName = "seeds"
    
    static func dumpModels() {
      dumpModel(Hat.self)
      dumpModel(Shelf.self)
    }
    static func loadModels() {
      loadModel(Hat.self)
      loadModel(Shelf.self)
    }
  }
  
  override func setUp() {
    super.setUp()
    do {
      for file in ["tables", "hats", "shelfs"] {
        try NSFileManager.defaultManager().removeItemAtPath(SeedTask.pathForFile(file))
      }
    }
    catch {}
  }
  override func tearDown() {
    let connection = Application.sharedDatabaseConnection()
    for table in connection.tableNames() {
      connection.executeQuery("DROP TABLE `\(table)`")
    }
    AlterationsTask.runTask()
    APPLICATION_ARGUMENTS = ("tailor.exit", [:])
    super.tearDown()
  }
  
  func testPathForFileGetsPathInApplicationDirectory() {
    let path = SeedTask.pathForFile("tables")
    assert(path, equals: "/tmp/seeds/tables.csv")
  }
  
  func testDumpSchemaSavesSchemaToFile() {
    SeedTask.dumpSchema()
    guard let data = NSData(contentsOfFile: SeedTask.pathForFile("tables")) else {
      assert(false, message: "Did not save any data to the file")
      return
    }
    
    let rows = CsvParser.parse(data)
    assert(rows, equals: [
      ["table","sql"],
      ["alteration_tests",
        "CREATE TABLE `alteration_tests` (id integer primary key, `material` varchar(255), `colour` varchar(250))"
      ],
      ["hats","CREATE TABLE `hats` ( `id` integer NOT NULL PRIMARY KEY, `color` varchar(255), `brim_size` integer, shelf_id integer, `created_at` timestamp, `updated_at` timestamp)"],
      ["shelfs","CREATE TABLE `shelfs` ( `id` integer NOT NULL PRIMARY KEY, `name` varchar(255), `store_id` integer)"],
      ["stores", "CREATE TABLE `stores` ( `id` integer NOT NULL PRIMARY KEY, `name` varchar(255))"],
      ["tailor_alterations", "CREATE TABLE tailor_alterations ( id varchar(255) PRIMARY KEY )"],
      ["tailor_translations","CREATE TABLE `tailor_translations` ( `id` integer NOT NULL PRIMARY KEY, `translation_key` varchar(255), `locale` varchar(255), `translated_text` varchar(255))"],
      ["users", "CREATE TABLE `users` ( `id` integer NOT NULL PRIMARY KEY, `email_address` varchar(255), `encrypted_password` varchar(255))"]
    ])
  }
  
  func testDumpModelSavesModelToFile() {
    let hat1 = Hat(brimSize: 10, color: "red", shelfId: 1).save()!
    let hat2 = Hat(brimSize: 12, color: "brown").save()!
    
    SeedTask.dumpModel(Hat.self)
    
    let rows = CsvParser(path: "/tmp/seeds/hats.csv").rows
    assert(rows, equals: [
      ["id", "brim_size", "color", "created_at", "shelf_id", "updated_at"],
      ["1", "10", "red", hat1.createdAt!.description, "1", hat1.updatedAt!.description],
      ["2", "12", "brown", hat2.createdAt!.description, "", hat2.updatedAt!.description]
    ])
  }
  
  func testDumpModelCreatesEmptyFilesForEmptyModel() {
    do {
      try NSFileManager.defaultManager().removeItemAtPath(SeedTask.pathForFile(Hat.self))
    }
    catch {}
    SeedTask.dumpModel(Hat.self)
    let data = NSData(contentsOfFile: SeedTask.pathForFile(Hat.self))
    assert(data, equals: NSData())
  }
  
  func testLoadSchemaDropsTablesThatAreNotInFile() {
    let rows = [
      ["table","sql"],
      ["hats","CREATE TABLE `hats` ( `id` integer NOT NULL PRIMARY KEY, `color` varchar(255), `brim_size` integer, shelf_id integer, `created_at` timestamp, `updated_at` timestamp)"],
      ["shelfs","CREATE TABLE `shelfs` ( `id` integer NOT NULL PRIMARY KEY, `name` varchar(255), `store_id` integer)"]
    ]
    CsvParser.encode(rows).writeToFile(SeedTask.pathForFile("tables"), atomically: true)
    SeedTask.loadSchema()
    let tables = Application.sharedDatabaseConnection().tables()
    assert(isNil: tables["stores"], message: "removes tables that are not in the schema file")
  }
  
  func testLoadSchemaAddsTableFromFile() {
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE `hats`")
    let rows = [
      ["table","sql"],
      ["hats","CREATE TABLE `hats` ( `id` integer NOT NULL PRIMARY KEY, `color` varchar(255), `brim_size` integer, shelf_id integer, `created_at` timestamp, `updated_at` timestamp)"],
      ["shelfs","CREATE TABLE `shelfs` ( `id` integer NOT NULL PRIMARY KEY, `name` varchar(255), `store_id` integer)"]
    ]
    CsvParser.encode(rows).writeToFile(SeedTask.pathForFile("tables"), atomically: true)
    SeedTask.loadSchema()
    let tables = Application.sharedDatabaseConnection().tables()
    assert(tables["hats"], equals: rows[1][1], message: "creates the table with the SQL from the file")
  }
  
  func testLoadModelLoadsRecordsFromModel() {
    let rows = [
      ["id", "brim_size", "color", "created_at", "shelf_id", "updated_at"],
      ["1", "10", "red", "2015-07-31 11:02:00", "1", "2015-07-31 11:03:00"],
      ["2", "12", "brown", "2015-07-31 09:15:00", "", "2015-07-31 09:30:00"]
    ]
    CsvParser.encode(rows).writeToFile(SeedTask.pathForFile(Hat.self), atomically: true)
    SeedTask.loadModel(Hat.self)
    let timeZone = Application.sharedDatabaseConnection().timeZone
    let hat1 = Query<Hat>().find(1)
    assert(hat1?.brimSize, equals: 10)
    assert(hat1?.color, equals: "red")
    assert(hat1?.createdAt, equals: Timestamp(year: 2015, month: 7, day: 31, hour: 11, minute: 2, second: 0, nanosecond: 0, timeZone: timeZone))
    assert(hat1?.shelfId, equals: 1)
    assert(hat1?.updatedAt, equals: Timestamp(year: 2015, month: 7, day: 31, hour: 11, minute: 3, second: 0, nanosecond: 0, timeZone: timeZone))
    let hat2 = Query<Hat>().find(2)
    assert(hat2?.brimSize, equals: 12)
    assert(hat2?.color, equals: "brown")
    assert(hat2?.createdAt, equals: Timestamp(year: 2015, month: 7, day: 31, hour: 9, minute: 15, second: 0, nanosecond: 0, timeZone: timeZone))
    assert(isNil: hat2?.shelfId)
    assert(hat2?.updatedAt, equals: Timestamp(year: 2015, month: 7, day: 31, hour: 9, minute: 30, second: 0, nanosecond: 0, timeZone: timeZone))
  }
  
  func testLoadModelWithEmptyFileDoesNotLoadAnyRecords() {
    NSData().writeToFile(SeedTask.pathForFile(Hat.self), atomically: true)
    SeedTask.loadModel(Hat.self)
    assert(Query<Hat>().count(), equals: 0)
  }
  
  func testRunTaskWithNoArgumentsDoesNothing() {
    Hat(brimSize: 10, color: "red", shelfId: 1).save()!
    APPLICATION_ARGUMENTS = ("seeds", [:])
    Application().start()
    assert(Query<Hat>().count(), equals: 1)
  }
  
  func testRunTaskWithLoadCommandLoadsSeeds() {
    let tables = [
      ["table","sql"],
      ["hats","CREATE TABLE `hats` ( `id` integer NOT NULL PRIMARY KEY, `color` varchar(255), `brim_size` integer, shelf_id integer, `created_at` timestamp, `updated_at` timestamp)"],
      ["shelfs","CREATE TABLE `shelfs` ( `id` integer NOT NULL PRIMARY KEY, `name` varchar(255), `store_id` integer)"]
    ]
    CsvParser.encode(tables).writeToFile(SeedTask.pathForFile("tables"), atomically: true)
    
    let hats = [
      ["id", "brim_size", "color", "created_at", "shelf_id", "updated_at"],
      ["1", "10", "red", "2015-07-31 11:02:00", "1", "2015-07-31 11:03:00"],
      ["2", "12", "brown", "2015-07-31 09:15:00", "", "2015-07-31 09:30:00"]
    ]
    CsvParser.encode(hats).writeToFile(SeedTask.pathForFile("hats"), atomically: true)
    
    APPLICATION_ARGUMENTS = ("seeds", ["load": "1"])
    NSThread.currentThread().threadDictionary.removeObjectForKey("SHARED_APPLICATION")
    Application.start()
    assert(Application.sharedDatabaseConnection().tableNames(), equals: ["hats", "shelfs"])
    assert(Query<Hat>().count(), equals: 2)
  }
  
  func testRunTaskWithDumpCommandDumpsSeeds() {
    let hat1 = Hat(brimSize: 10, color: "red", shelfId: 1).save()!
    let hat2 = Hat(brimSize: 12, color: "brown").save()!
    
    
    APPLICATION_ARGUMENTS = ("seeds", ["dump": "1"])
    NSThread.currentThread().threadDictionary.removeObjectForKey("SHARED_APPLICATION")
    Application.start()
    
    guard let tableData = NSData(contentsOfFile: SeedTask.pathForFile("tables")) else {
      assert(false, message: "Did not save any data to the file")
      return
    }
    
    let tables = CsvParser.parse(tableData)
    assert(tables, equals: [
      ["table","sql"],
      ["alteration_tests",
        "CREATE TABLE `alteration_tests` (id integer primary key, `material` varchar(255), `colour` varchar(250))"
      ],
      ["hats","CREATE TABLE `hats` ( `id` integer NOT NULL PRIMARY KEY, `color` varchar(255), `brim_size` integer, shelf_id integer, `created_at` timestamp, `updated_at` timestamp)"],
      ["shelfs","CREATE TABLE `shelfs` ( `id` integer NOT NULL PRIMARY KEY, `name` varchar(255), `store_id` integer)"],
      ["stores", "CREATE TABLE `stores` ( `id` integer NOT NULL PRIMARY KEY, `name` varchar(255))"],
      ["tailor_alterations", "CREATE TABLE tailor_alterations ( id varchar(255) PRIMARY KEY )"],
      ["tailor_translations","CREATE TABLE `tailor_translations` ( `id` integer NOT NULL PRIMARY KEY, `translation_key` varchar(255), `locale` varchar(255), `translated_text` varchar(255))"],
      ["users", "CREATE TABLE `users` ( `id` integer NOT NULL PRIMARY KEY, `email_address` varchar(255), `encrypted_password` varchar(255))"]
      ])
    
    let rows = CsvParser(path: "/tmp/seeds/hats.csv").rows
    assert(rows, equals: [
      ["id", "brim_size", "color", "created_at", "shelf_id", "updated_at"],
      ["1", "10", "red", hat1.createdAt!.description, "1", hat1.updatedAt!.description],
      ["2", "12", "brown", hat2.createdAt!.description, "", hat2.updatedAt!.description]
      ])
  }
}
