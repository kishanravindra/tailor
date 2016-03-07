import Tailor

class CreateTestDatabaseAlteration: AlterationScript {
  static var identifier: String {
    return "0"
  }
  static func run() {
    let connection = Application.sharedDatabaseConnection()
    
    for table in connection.tableNames() {
      connection.executeQuery("DROP TABLE \(table)")
    }
    connection.executeQuery("CREATE TABLE `hats` ( `id` integer NOT NULL PRIMARY KEY, `color` varchar(255), `brim_size` int(11), shelf_id int(11), `created_at` timestamp, `updated_at` timestamp)")
    connection.executeQuery("CREATE TABLE `shelfs` ( `id` integer NOT NULL PRIMARY KEY, `name` varchar(255), `store_id` int(11))")
    connection.executeQuery("CREATE TABLE `stores` ( `id` integer NOT NULL PRIMARY KEY, `name` varchar(255))")
    connection.executeQuery("CREATE TABLE `users` ( `id` integer NOT NULL PRIMARY KEY, `email_address` varchar(255), `encrypted_password` varchar(255))")
    
    connection.executeQuery("CREATE TABLE tailor_alterations ( id varchar(255) PRIMARY KEY )")
  }
}
