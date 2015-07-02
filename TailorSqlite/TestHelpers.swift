import Tailor
import TailorSqlite

class TestApplication: Tailor.Application {
  required init() {
    super.init()
    let path = self.rootPath() + "/testing.sqlite"
    self.configuration.addDictionary([
      "database": [
        "class": "TailorSqlite.SqliteConnection",
        "path": path
      ],
      "sessions": [
        "encryptionKey": "0FC7ECA7AADAD635DCC13A494F9A2EA8D8DAE366382CDB3620190F6F20817124"
      ]])
  }
  
  override func start() {
    super.start()
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE IF EXISTS `hats`")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE `hats` ( `id` integer NOT NULL PRIMARY KEY, `color` varchar(255), `brim_size` int(11), shelf_id int(11), `created_at` timestamp, `updated_at` timestamp)")
    
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE IF EXISTS `shelfs`")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE `shelfs` ( `id` integer NOT NULL PRIMARY KEY, `name` varchar(255), `store_id` int(11))")
    
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE IF EXISTS `stores`")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE `stores` ( `id` integer NOT NULL PRIMARY KEY, `name` varchar(255))")
    
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE IF EXISTS `users`")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE `users` ( `id` integer NOT NULL PRIMARY KEY, `email_address` varchar(255), `encrypted_password` varchar(255))")
  }
}
