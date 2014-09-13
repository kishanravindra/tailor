import Foundation

MysqlConnection.open([
  "host": "127.0.0.1",
  "username": "haberdashery",
  "password": "2wsxcde3",
  "database": "haberdashery"
])

let hats : [Hat] = Hat.query("SELECT * FROM hats", parameters: [])
HaberdasheryApplication.start()