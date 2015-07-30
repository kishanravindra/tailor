import Tailor
import TailorTesting

class SeedTaskTypeTests: TailorTestCase {
  final class SeedTask: SeedTaskType {
    static func dumpModels() {
      
    }
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
  
  func testDumpModelsCreatesEmptyFilesForEmptyModel() {
    do {
      try NSFileManager.defaultManager().removeItemAtPath(SeedTask.pathForFile(Hat.self))
    }
    catch {}
    SeedTask.dumpModel(Hat.self)
    let data = NSData(contentsOfFile: SeedTask.pathForFile(Hat.self))
    assert(data, equals: NSData())
  }
}
