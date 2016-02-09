import Tailor

class CreateTestDatabaseAlteration: AlterationScript {
  static var identifier: String {
    return "0"
  }
  static func run() {
    let connection = Application.sharedDatabaseConnection()
    
    for tableName in ["hats", "shelfs", "stores", "users", "hat_types", "tailor_translations"] {
      connection.executeQuery("DROP TABLE IF EXISTS \(tableName)")
    }
    connection.executeQuery("CREATE TABLE `hats` ( `id` integer NOT NULL PRIMARY KEY, `color` varchar(255), `brim_size` integer, shelf_id integer, `created_at` timestamp, `updated_at` timestamp)")
    connection.executeQuery("CREATE TABLE `shelfs` ( `id` integer NOT NULL PRIMARY KEY, `name` varchar(255), `store_id` integer)")
    connection.executeQuery("CREATE TABLE `stores` ( `id` integer NOT NULL PRIMARY KEY, `name` varchar(255))")
    connection.executeQuery("CREATE TABLE `users` ( `id` integer NOT NULL PRIMARY KEY, `email_address` varchar(255), `encrypted_password` varchar(255))")
    connection.executeQuery("CREATE TABLE `tailor_alterations` ( `id` varchar(255) NOT NULL PRIMARY KEY)")
    connection.executeQuery("CREATE TABLE `tailor_translations` ( `id` integer NOT NULL PRIMARY KEY, `translation_key` varchar(255), `locale` varchar(255), `translated_text` varchar(255))")
    connection.executeQuery("CREATE TABLE `hat_types` ( `id` integer NOT NULL PRIMARY KEY, `name` varchar(255))")
    connection.executeQuery("INSERT INTO hat_types VALUES (1,'feathered')")
  }
}
