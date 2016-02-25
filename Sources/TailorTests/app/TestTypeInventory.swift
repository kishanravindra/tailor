@testable import Tailor
import Foundation
import XCTest
import TailorTesting
import TailorSqlite

final class TestTypeInventory : TailorTestable {
  var allTests: [(String, () throws -> Void)] { return [
    ("testCanRegisterTasks", testCanRegisterTasks),
    ("testSubtypeFetchingExcludesInvalidTypes", testSubtypeFetchingExcludesInvalidTypes),
  ]}

  var typeInventory = TypeInventory()

  func setUp() {
    setUpTestCase()
    typeInventory = TypeInventory()
  }

  func testCanRegisterTasks() {
    typeInventory.registerSubtypes(TaskType.self, subtypes: [ExitTask.self, AlterationsTask.self])
    let subtypes = typeInventory.registeredTasks
    let commands = subtypes.map { $0.commandName }
    assert(commands, equals: ["tailor.exit", "run_alterations"])
  }

  func testSubtypeFetchingExcludesInvalidTypes() {
    typeInventory.registerSubtypes(TaskType.self, subtypes: [ExitTask.self, String.self, AlterationsTask.self])
    let subtypes = typeInventory.registeredTasks
    let commands = subtypes.map { $0.commandName }
    assert(commands, equals: ["tailor.exit", "run_alterations"])
  }
}