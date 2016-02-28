@testable import Tailor
import TailorTesting
import XCTest
import Foundation

struct TestCsvParser: XCTestCase, TailorTestable {

  var allTests: [(String, () throws -> Void)] { return [
    ("testInitializeWithNoParametersGivesEmptyRows", testInitializeWithNoParametersGivesEmptyRows),
    ("testInitializeWithRowsSetsRows", testInitializeWithRowsSetsRows),
    ("testInitializeWithValidDataParsesData", testInitializeWithValidDataParsesData),
    ("testInitializeWithQuotedDataParsesData", testInitializeWithQuotedDataParsesData),
    ("testInitializeWithEscapedQuotesParsesData", testInitializeWithEscapedQuotesParsesData),
    ("testInitializeWithNewlineInQuotesKeepsNewlineInCell", testInitializeWithNewlineInQuotesKeepsNewlineInCell),
    ("testInitializeWithUnterminatedQuoteKeepsEverythingInThatCell", testInitializeWithUnterminatedQuoteKeepsEverythingInThatCell),
    ("testInitializeWithEmptyCellProducesEmptyString", testInitializeWithEmptyCellProducesEmptyString),
    ("testInitializeWithCustomDelimiterParsesWithThatDelimiter", testInitializeWithCustomDelimiterParsesWithThatDelimiter),
    ("testInitializeWithPathParsesFile", testInitializeWithPathParsesFile),
    ("testInitializeWithInvalidPathParsesFile", testInitializeWithInvalidPathParsesFile),
    ("testParseDoesNotSharedDataWithCopies", testParseDoesNotSharedDataWithCopies),
    ("testEncodeDataWithSimpleGridCreatesData", testEncodeDataWithSimpleGridCreatesData),
    ("testEncodeDataPutsQuotesAroundCellWithCommas", testEncodeDataPutsQuotesAroundCellWithCommas),
    ("testEncodeDataPutsQuotesAroundCellWithQuotes", testEncodeDataPutsQuotesAroundCellWithQuotes),
    ("testEncodeDataPutsQuotesAroundCellWithNewline", testEncodeDataPutsQuotesAroundCellWithNewline),
    ("testEncodeDataHandlesRaggedGrid", testEncodeDataHandlesRaggedGrid),
    ("testEncodeDataWithCustomDelimiterUsesThatDelimiter", testEncodeDataWithCustomDelimiterUsesThatDelimiter),
    ("testParseReturnsRowsFromParsedData", testParseReturnsRowsFromParsedData),
    ("testParseWithCustomDelimiterReturnsRowsFromParsedData", testParseWithCustomDelimiterReturnsRowsFromParsedData),
    ("testEncodeReturnsDataForRows", testEncodeReturnsDataForRows),
    ("testEncodeWithCustomDelimiterReturnsDataForRows", testEncodeWithCustomDelimiterReturnsDataForRows),
  ]}

  func setUp() {
    setUpTestCase()
  }
  
  func testInitializeWithNoParametersGivesEmptyRows() {
    let parser = CsvParser()
    assert(parser.rows, equals: [])
  }
  
  func testInitializeWithRowsSetsRows() {
    let rows = [["a","b"], ["c", "d"]]
    let parser = CsvParser(rows: rows)
    assert(parser.rows, equals: rows)
  }
  
  //MARK: - Parsing
  
  func testInitializeWithValidDataParsesData() {
    let data = NSData(bytes: "a,b,c\n1,2,3".utf8)
    let parser = CsvParser(data: data)
    assert(parser.rows, equals: [
      ["a", "b", "c"],
      ["1", "2", "3"]
    ])
  }
  
  func testInitializeWithQuotedDataParsesData() {
    let data = NSData(bytes: "a,b,c\n1,2,\"3, 4\"".utf8)
    let parser = CsvParser(data: data)
    assert(parser.rows, equals: [
      ["a", "b", "c"],
      ["1", "2", "3, 4"]
      ])
  }
  
  func testInitializeWithEscapedQuotesParsesData() {
    let data = NSData(bytes: "a,b,c\n1,2,\"my name is \"\"john\"\"\"".utf8)
    let parser = CsvParser(data: data)
    assert(parser.rows, equals: [
      ["a", "b", "c"],
      ["1", "2", "my name is \"john\""]
      ])
  }
  
  func testInitializeWithNewlineInQuotesKeepsNewlineInCell() {
    let data = NSData(bytes: "a,b,c\n1,2,\"3\n4\"".utf8)
    let parser = CsvParser(data: data)
    assert(parser.rows, equals: [
      ["a", "b", "c"],
      ["1", "2", "3\n4"]
      ])
  }
  
  func testInitializeWithUnterminatedQuoteKeepsEverythingInThatCell() {
    let data = NSData(bytes: "a,b,c\n1,\"2,3,4".utf8)
    let parser = CsvParser(data: data)
    assert(parser.rows, equals: [
      ["a", "b", "c"],
      ["1", "2,3,4"]
      ])
  }
  
  func testInitializeWithEmptyCellProducesEmptyString() {
    let data = NSData(bytes: "a,b,c\n1,\"\",3".utf8)
    let parser = CsvParser(data: data)
    assert(parser.rows, equals: [
      ["a", "b", "c"],
      ["1", "", "3"]
    ])
  }
  
  func testInitializeWithCustomDelimiterParsesWithThatDelimiter() {
    let data = NSData(bytes: "a\tb\tc\n1\t2\t3,4".utf8)
    let parser = CsvParser(data: data, delimiter: "\t")
    assert(parser.rows, equals: [
      ["a", "b", "c"],
      ["1", "2", "3,4"]
      ])
  }
  
  func testInitializeWithPathParsesFile() {
    let data = NSData(bytes: "a,b,c\n1,2,3".utf8)
    data.writeToFile("/tmp/test.csv", atomically: true)
    let parser = CsvParser(path: "/tmp/test.csv")
    assert(parser.rows, equals: [
      ["a", "b", "c"],
      ["1", "2", "3"]
    ])
  }
  
  func testInitializeWithInvalidPathParsesFile() {
    do {
      try NSFileManager.defaultManager().removeItemAtPath("/tmp/bad_test.csv")
    }
    catch {
      
    }
    let parser = CsvParser(path: "/tmp/bad_test.csv")
    assert(parser.rows, equals: [])
  }
  
  func testParseDoesNotSharedDataWithCopies() {
    let data = NSData(bytes: "a\tb\tc\n1\t2\t3,4".utf8)
    var parser1 = CsvParser()
    let parser2 = parser1
    parser1.parse(data)
    assert(!parser1.rows.isEmpty)
    assert(parser2.rows.isEmpty)
  }
  
  //MARK: - Encoding
  
  func testEncodeDataWithSimpleGridCreatesData() {
    let parser = CsvParser(rows: [
      ["a", "b", "c"],
      ["1", "2", "3"]
    ])
    let text = "a,b,c\n1,2,3"
    assert(parser.encodeData(), equals: NSData(bytes: text.utf8))
  }
  
  func testEncodeDataPutsQuotesAroundCellWithCommas() {
    let parser = CsvParser(rows: [
      ["a", "b", "c"],
      ["1", "2", "3,4"]
      ])
    let text = "a,b,c\n1,2,\"3,4\""
    assert(parser.encodeData(), equals: NSData(bytes: text.utf8))
  }
  
  func testEncodeDataPutsQuotesAroundCellWithQuotes() {
    
    let parser = CsvParser(rows: [
      ["a", "b", "c"],
      ["1", "2", "my name is \"john\""]
      ])
    let text = "a,b,c\n1,2,\"my name is \"\"john\"\"\""
    assert(parser.encodeData(), equals: NSData(bytes: text.utf8))
  }
  
  func testEncodeDataPutsQuotesAroundCellWithNewline() {
    
    let parser = CsvParser(rows: [
      ["a", "b", "c"],
      ["1", "2", "3\n4"]
      ])
    let text = "a,b,c\n1,2,\"3\n4\""
    assert(parser.encodeData(), equals: NSData(bytes: text.utf8))
  }
  
  func testEncodeDataHandlesRaggedGrid() {
    
    let parser = CsvParser(rows: [
      ["a", "b", "c"],
      ["1", "2"],
      ["x", "y", "z", "0"]
      ])
    let text = "a,b,c\n1,2\nx,y,z,0"
    assert(parser.encodeData(), equals: NSData(bytes: text.utf8))
  }
  
  func testEncodeDataWithCustomDelimiterUsesThatDelimiter() {
    let parser = CsvParser(rows: [
      ["a", "b", "c"],
      ["1", "2", "3\t4"]
      ], delimiter: "\t")
    let text = "a\tb\tc\n1\t2\t\"3\t4\""
    assert(parser.encodeData(), equals: NSData(bytes: text.utf8))
  }
  
  //MARK: - Shorthands
  
  func testParseReturnsRowsFromParsedData() {
    let data = NSData(bytes: "a,b,c\n1,2,3".utf8)
    let rows = CsvParser.parse(data)
    assert(rows, equals: [
      ["a", "b", "c"],
      ["1", "2", "3"]
    ])
  }
  
  func testParseWithCustomDelimiterReturnsRowsFromParsedData() {
    let data = NSData(bytes: "a\tb,c\n1\t2,3".utf8)
    let rows = CsvParser.parse(data, delimiter: "\t")
    assert(rows, equals: [
      ["a", "b,c"],
      ["1", "2,3"]
      ])
  }
  
  func testEncodeReturnsDataForRows() {
    let expectedData = NSData(bytes: "a,b,c\n1,2,3".utf8)
    let data = CsvParser.encode([
      ["a", "b", "c"],
      ["1", "2", "3"]
    ])
    assert(data, equals: expectedData)
  }
  
  func testEncodeWithCustomDelimiterReturnsDataForRows() {
    let expectedData = NSData(bytes: "a\tb,c\n1\t2,3".utf8)
    let data = CsvParser.encode([
      ["a", "b,c"],
      ["1", "2,3"]
      ], delimiter: "\t")
    assert(data, equals: expectedData)
  }
}
