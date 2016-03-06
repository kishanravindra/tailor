import Tailor
import Tailor
import TailorSqlite
@testable import TailorTesting
import XCTest
import Foundation

final class TestTailorTestable : XCTestCase {
  final class TestCase: StubbedTestCase, TailorTestable {
    var allTests: [(String, () throws -> Void)] { return [] }
  }
  
  enum TestExceptionType: ErrorType, Equatable {
    case Exception1
    case Exception2
  }
  
  var testCase = TestCase()
  
  var allTests: [(String, () throws -> Void)] { return [
    ("testResetDatabaseTruncatesTables", testResetDatabaseTruncatesTables),
    //("testResetDatabaseRunsAlterations", testResetDatabaseRunsAlterations),
    ("testResetDatabaseWithResetFlagSetTruncatesTables", testResetDatabaseWithResetFlagSetTruncatesTables),
    ("testResetDatabaseWithResetFlagSetDoesNotRunAlterations", testResetDatabaseWithResetFlagSetDoesNotRunAlterations),
    ("testAssertEqualsWithEqualValuesDoesNotTriggerAssertion", testAssertEqualsWithEqualValuesDoesNotTriggerAssertion),
    ("testAssertEqualsWithUnequalValuesTriggersAssertion", testAssertEqualsWithUnequalValuesTriggersAssertion),
    ("testAssertEqualsWithNoMessageTriggersAssertion", testAssertEqualsWithNoMessageTriggersAssertion),
    ("testAssertEqualsWithNilValueTriggersAssertion", testAssertEqualsWithNilValueTriggersAssertion),
    ("testAssertNoExceptionsWithNoExceptionsDoesNotTriggerAssertion", testAssertNoExceptionsWithNoExceptionsDoesNotTriggerAssertion),
    ("testAssertNoExceptionsWithExceptionTriggersAssertion", testAssertNoExceptionsWithExceptionTriggersAssertion),
    ("testAssertNoExceptionsWithExceptionWithNoMessageTriggersAssertion", testAssertNoExceptionsWithExceptionWithNoMessageTriggersAssertion),
    //("testAssertThrowsExceptionWithNoExceptionTriggersAssertion", testAssertThrowsExceptionWithNoExceptionTriggersAssertion),
    //("testAssertThrowsExceptionWithNoExceptionWithNoMessageTriggersAssertion", testAssertThrowsExceptionWithNoExceptionWithNoMessageTriggersAssertion),
    //("testAssertThrowsExceptionWithWrongExceptionTriggersAssertion", testAssertThrowsExceptionWithWrongExceptionTriggersAssertion),
    //("testAssertThrowsExceptionWithWrongExceptionWithNoMessageTriggersAssertion", testAssertThrowsExceptionWithWrongExceptionWithNoMessageTriggersAssertion),
    //("testAssertThrowsExceptionWithWrongExceptionTypeTriggersAssertion", testAssertThrowsExceptionWithWrongExceptionTypeTriggersAssertion),
    //("testAssertThrowsExceptionWithWrongExceptionTypeWithNoMessageTriggersAssertion",
    //testAssertThrowsExceptionWithWrongExceptionTypeWithNoMessageTriggersAssertion),
  ]}


  func setUp() {
    APPLICATION_ARGUMENTS = ("tailor.exit", [:])
    Application.configuration.databaseDriver = { return SqliteConnection(path: "./TestResources/testing.sqlite") }
    AlterationsTask.runTask()
    Application.truncateTables()
    testCase = TestCase()
  }
  
  func tearDown() {
    TAILOR_TESTABLE_DATABASE_RESET = false
  }
  
  //MARK: - Set Up
  
  func testResetDatabaseTruncatesTables() {
    TAILOR_TESTABLE_DATABASE_RESET = false
    Hat().save()
    testCase.resetDatabase()
    XCTAssertEqual(Hat.query.count(), 0)
  }
  
  func testResetDatabaseRunsAlterations() {
    Application.sharedDatabaseConnection().executeQuery("DELETE FROM tailor_alterations")
    testCase.resetDatabase()
    let resultSet = Application.sharedDatabaseConnection().executeQuery("SELECT * FROM tailor_alterations")
    XCTAssertFalse(resultSet.isEmpty)
  }
  
  func testResetDatabaseWithResetFlagSetTruncatesTables() {
    TAILOR_TESTABLE_DATABASE_RESET = true
    Hat().save()
    testCase.resetDatabase()
    XCTAssertEqual(Hat.query.count(), 0)
  }
  
  func testResetDatabaseWithResetFlagSetDoesNotRunAlterations() {
    TAILOR_TESTABLE_DATABASE_RESET = true
    Application.sharedDatabaseConnection().executeQuery("DELETE FROM tailor_alterations")
    testCase.resetDatabase()
    let resultSet = Application.sharedDatabaseConnection().executeQuery("SELECT * FROM tailor_alterations")
    XCTAssertTrue(resultSet.isEmpty)
  }
  
  //MARK: - Equality Comparison
  
  func testAssertEqualsWithEqualValuesDoesNotTriggerAssertion() {
    testCase.assert(1, equals: 1)
    XCTAssertEqual(testCase.failures.count, 0)
  }
  
  func testAssertEqualsWithUnequalValuesTriggersAssertion() {
    testCase.assert(1, equals: 2, message: "Test Message")
    XCTAssertEqual(testCase.failures.count, 1)
    if let failure = testCase.failures.first {
      XCTAssertEqual(failure.message, "1 != 2 - Test Message")
      XCTAssertEqual(failure.file, #file)
      XCTAssertEqual(failure.line, #line - 5)
    }
  }
  
  func testAssertEqualsWithNoMessageTriggersAssertion() {
    testCase.assert(1, equals: 2)
    XCTAssertEqual(testCase.failures.count, 1)
    if let failure = testCase.failures.first {
      XCTAssertEqual(failure.message, "1 != 2")
    }
  }
  
  func testAssertEqualsWithNilValueTriggersAssertion() {
    testCase.assert(nil, equals: 2, message: "Test Message")
    XCTAssertEqual(testCase.failures.count, 1)
    if let failure = testCase.failures.first {
      XCTAssertEqual(failure.message, "Value was nil - Test Message")
    }
  }
  
  //MARK: - Exceptions
  
  func testAssertNoExceptionsWithNoExceptionsDoesNotTriggerAssertion() {
    testCase.assertNoExceptions {
      _ = 1 + 1
    }
    XCTAssertEqual(testCase.failures.count, 0)
  }
  
  func testAssertNoExceptionsWithExceptionTriggersAssertion() {
    testCase.assertNoExceptions("Test Message") {
      throw NSError(domain: "test.tailorframe.work", code: 101, userInfo: nil)
    }
    XCTAssertEqual(testCase.failures.count, 1)
    if let failure = testCase.failures.first {
      XCTAssertEqual(failure.message, "Threw exception - Test Message")
      XCTAssertEqual(failure.file, #file)
      XCTAssertEqual(failure.line, #line - 7)
    }
  }
  
  func testAssertNoExceptionsWithExceptionWithNoMessageTriggersAssertion() {
    testCase.assertNoExceptions {
      throw NSError(domain: "test.tailorframe.work", code: 101, userInfo: nil)
    }
    XCTAssertEqual(testCase.failures.count, 1)
    if let failure = testCase.failures.first {
      XCTAssertEqual(failure.message, "Threw exception")
    }
  }
  
  func testAssertThrowsExceptionWithNoExceptionTriggersAssertion() {
    testCase.assertThrows(TestExceptionType.Exception1, message: "Throws Good") {
      _ = 1 + 1
    }
    XCTAssertEqual(testCase.failures.count, 1)
    if let failure = testCase.failures.first {
      XCTAssertEqual(failure.message, "Did not throw exception - Throws Good")
      XCTAssertEqual(failure.file, #file)
      XCTAssertEqual(failure.line, #line - 7)
    }
  }
  
  func testAssertThrowsExceptionWithNoExceptionWithNoMessageTriggersAssertion() {
    testCase.assertThrows(TestExceptionType.Exception1) {
      _ = 1 + 1
    }
    XCTAssertEqual(testCase.failures.count, 1)
    if let failure = testCase.failures.first {
      XCTAssertEqual(failure.message, "Did not throw exception")
    }
  }
  
  func testAssertThrowsExceptionWithWrongExceptionTriggersAssertion() {
    testCase.assertThrows(TestExceptionType.Exception1, message: "Throws Good") {
      throw TestExceptionType.Exception2
    }
    XCTAssertEqual(testCase.failures.count, 1)
    if let failure = testCase.failures.first {
      XCTAssertEqual(failure.message, "Exception2 != Exception1 - Throws Good")
      XCTAssertEqual(failure.file, #file)
      XCTAssertEqual(failure.line, #line - 7)
    }
  }
  
  func testAssertThrowsExceptionWithWrongExceptionWithNoMessageTriggersAssertion() {
    testCase.assertThrows(TestExceptionType.Exception1) {
      throw TestExceptionType.Exception2
    }
    XCTAssertEqual(testCase.failures.count, 1)
    if let failure = testCase.failures.first {
      XCTAssertEqual(failure.message, "Exception2 != Exception1")
    }
  }
  
  func testAssertThrowsExceptionWithWrongExceptionTypeTriggersAssertion() {
    testCase.assertThrows(TestExceptionType.Exception1, message: "Throws Good") {
      throw NSError(domain: "test.tailorframe.work", code: 101, userInfo: nil)
    }
    XCTAssertEqual(testCase.failures.count, 1)
    if let failure = testCase.failures.first {
      XCTAssertEqual(failure.message, "Threw exception Error Domain=test.tailorframe.work Code=101 \"(null)\" - Throws Good")
      XCTAssertEqual(failure.file, #file)
      XCTAssertEqual(failure.line, #line - 7)
    }
  }
  
  func testAssertThrowsExceptionWithWrongExceptionTypeWithNoMessageTriggersAssertion() {
    testCase.assertThrows(TestExceptionType.Exception1) {
      throw NSError(domain: "test.tailorframe.work", code: 101, userInfo: nil)
    }
    XCTAssertEqual(testCase.failures.count, 1)
    if let failure = testCase.failures.first {
      XCTAssertEqual(failure.message, "Threw exception Error Domain=test.tailorframe.work Code=101 \"(null)\"")
    }
  }
}