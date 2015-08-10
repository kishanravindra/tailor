import TailorTesting
import TailorSqlite
import Tailor

extension TailorTestCase {
  public func configure() {
    APPLICATION_ARGUMENTS = ("tailor.exit", [:])
    Application.configuration.databaseDriver = { SqliteConnection(path: "sqlite_testing.sqlite") }
    Application.configuration.sessionEncryptionKey = "0FC7ECA7AADAD635DCC13A494F9A2EA8D8DAE366382CDB3620190F6F20817124"
  }
}