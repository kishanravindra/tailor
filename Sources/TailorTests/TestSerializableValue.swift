import Tailor
import TailorTesting
import XCTest
import Foundation

struct TestSerializableValue: XCTestCase, TailorTestable {
  @available(*, deprecated)
  //FIXME: Re-enable commented out tests
  var allTests: [(String, () throws -> Void)] { return [
    ("testFoundationJsonObjectForStringIsString", testFoundationJsonObjectForStringIsString),
    ("testFoundationJsonObjectForArrayOfStringsIsArrayOfStrings", testFoundationJsonObjectForArrayOfStringsIsArrayOfStrings),
    ("testFoundationJsonObjectForDictionaryOfStringsIsDictionaryOfStrings", testFoundationJsonObjectForDictionaryOfStringsIsDictionaryOfStrings),
    ("testFoundationJsonObjectForHeterogeneousArrayMapsInnerArray", testFoundationJsonObjectForHeterogeneousArrayMapsInnerArray),
    ("testFoundationJsonObjectForHeterogeneousDictionaryMapsInnerDictionary", testFoundationJsonObjectForHeterogeneousDictionaryMapsInnerDictionary),
    ("testFoundationJsonObjectForNullIsNsNull", testFoundationJsonObjectForNullIsNsNull),
    ("testFoundationJsonObjectForDoubleIsNsNumber", testFoundationJsonObjectForDoubleIsNsNumber),
    ("testFoundationJsonObjectForIntegerIsNsNumber", testFoundationJsonObjectForIntegerIsNsNumber),
    ("testFoundationJsonObjectForBooleanIsNsNumber", testFoundationJsonObjectForBooleanIsNsNumber),
    ("testFoundationJsonObjectForTimestampIsFormattedString", testFoundationJsonObjectForTimestampIsFormattedString),
    // ("testFoundationJsonObjectForDateIsFormattedString", testFoundationJsonObjectForDateIsFormattedString),
    // ("testFoundationJsonObjectForTimeIsFormattedString", testFoundationJsonObjectForTimeIsFormattedString),
    ("testFoundationJsonObjectForDataIsData", testFoundationJsonObjectForDataIsData),
    ("testJsonDataForStringThrowsException", testJsonDataForStringGetsThrowsException),
    ("testJsonDataForDictionaryOfStringsGetsData", testJsonDataForDictionaryOfStringsGetsData),
    ("testJsonDataForDictionaryWithEscapedStringGetsData", testJsonDataForDictionaryWithEscapedStringGetsData),
    ("testJsonDataForArrayOfStringsGetsData", testJsonDataForArrayOfStringsGetsData),
    ("testJsonDataForHeterogeneousDictionaryGetsData", testJsonDataForHeterogeneousDictionaryGetsData),
    ("testJsonDataForDictionaryWithNullGetsData", testJsonDataForDictionaryWithNullGetsData),
    ("testJsonDataForDictionaryWithNumbersGetsData", testJsonDataForDictionaryWithNumbersGetsData),
    ("testInitWithJsonStringBuildsString", testInitWithJsonStringBuildsString),
    ("testInitWithJsonDictionaryOfStringsBuildsDictionaryOfStrings", testInitWithJsonDictionaryOfStringsBuildsDictionaryOfStrings),
    ("testInitWithJsonArrayOfStringsBuildsArrayOfStrings", testInitWithJsonArrayOfStringsBuildsArrayOfStrings),
    ("testInitWithNsNullGetsNull", testInitWithNsNullGetsNull),
    ("testInitWithIntegerGetsNumber", testInitWithIntegerGetsNumber),
    ("testInitWithDoubleGetsNumber", testInitWithDoubleGetsNumber),
    ("testInitWithJsonObjectWithUnsupportedTypeThrowsException", testInitWithJsonObjectWithUnsupportedTypeThrowsException),
    ("testInitWithJsonDataForDictionaryCreatesDictionary", testInitWithJsonDataForDictionaryCreatesDictionary),
    // ("testInitWithPlistWithValidPathGetsData", testInitWithPlistWithValidPathGetsData),
    ("testInitWithPlistWithInvalidPathThrowsException", testInitWithPlistWithInvalidPathThrowsException),
    ("testInitWithPlistWithInvalidPlistThrowsException", testInitWithPlistWithInvalidPlistThrowsException),
    ("testReadStringWithStringGetsString", testReadStringWithStringGetsString),
    ("testReadStringWithArrayThrowsException", testReadStringWithArrayThrowsException),
    ("testReadArrayWithArrayGetsArray", testReadArrayWithArrayGetsArray),
    ("testReadArrayWithDictionaryThrowsError", testReadArrayWithDictionaryThrowsError),
    ("testReadDictionaryWithDictionaryGetsDictionary", testReadDictionaryWithDictionaryGetsDictionary),
    ("testReadDictionaryWithNullThrowsError", testReadDictionaryWithNullThrowsError),
    ("testReadIntWithIntGetsInt", testReadIntWithIntGetsInt),
    ("testReadIntWithDoubleGetsDouble", testReadIntWithDoubleGetsDouble),
    ("testReadDoubleWithDoubleGetsDouble", testReadDoubleWithDoubleGetsDouble),
    ("testReadDoubleWithIntGetsInt", testReadDoubleWithIntGetsInt),
    ("testReadStringValueWithStringGetsString", testReadStringValueWithStringGetsString),
    ("testReadStringValueWithArrayThrowsException", testReadStringValueWithArrayThrowsException),
    ("testReadArrayValueWithArrayGetsArray", testReadArrayValueWithArrayGetsArray),
    ("testReadArrayValueWithDictionaryThrowsException", testReadArrayValueWithDictionaryThrowsException),
    ("testReadDictionaryValueWithDictionaryReturnsDictionary", testReadDictionaryValueWithDictionaryReturnsDictionary),
    ("testReadIntValueWithIntGetsInt", testReadIntValueWithIntGetsInt),
    ("testReadIntValueWithArrayThrowsException", testReadIntValueWithArrayThrowsException),
    ("testReadDictionaryValueWithStringThrowsException", testReadDictionaryValueWithStringThrowsException),
    ("testReadValueWithNonDictionaryPrimitiveThrowsException", testReadValueWithNonDictionaryPrimitiveThrowsException),
    ("testReadValueWithMissingKeyThrowsException", testReadValueWithMissingKeyThrowsException),
    ("testReadValueWithSerializableValueGetsPrimitive", testReadValueWithSerializableValueGetsPrimitive),
    ("testReadValueWithSerializableValueWithMissingKeyThrowsException", testReadValueWithSerializableValueWithMissingKeyThrowsException),
    ("testReadOptionalIntValueWithIntGetsInt", testReadOptionalIntValueWithIntGetsInt),
    ("testReadOptionalIntValueWithArrayThrowsException", testReadOptionalIntValueWithArrayThrowsException),
    ("testReadOptionalIntValueWithNullValueGetsNil", testReadOptionalIntValueWithNullValueGetsNil),
    ("testReadOptionalIntValueWithEmptyStringValueGetsNil", testReadOptionalIntValueWithEmptyStringValueGetsNil),
    ("testReadOptionalIntValueWithMissingKeyGetsNil", testReadOptionalIntValueWithMissingKeyGetsNil),
    ("testReadOptionalIntValueWithNonDictionaryValueThrowsException", testReadOptionalIntValueWithNonDictionaryValueThrowsException),
    ("testReadIntoConvertiblePopulatesValues", testReadIntoConvertiblePopulatesValues),
    ("testReadIntoConvertibleWithErrorAddsOuterKeyToError", testReadIntoConvertibleWithErrorAddsOuterKeyToError),
    ("testReadRecordWithWithValidIdFetchesRecord", testReadRecordWithWithValidIdFetchesRecord),
    ("testReadRecordWithWithStringIdThrowsException", testReadRecordWithWithStringIdThrowsException),
    ("testReadRecordWithMissingIdThrowsException", testReadRecordWithMissingIdThrowsException),
    ("testReadRecordWithNonDictionaryValueThrowsException", testReadRecordWithNonDictionaryValueThrowsException),
    ("testReadOptionalRecordWithWithValidIdFetchesRecord", testReadOptionalRecordWithWithValidIdFetchesRecord),
    ("testReadOptionalRecordWithWithStringIdThrowsException", testReadOptionalRecordWithWithStringIdThrowsException),
    ("testReadOptionalRecordWithMissingIdReturnsNil", testReadOptionalRecordWithMissingIdReturnsNil),
    ("testReadOptionalRecordWithNonDictionaryValueThrowsException", testReadOptionalRecordWithNonDictionaryValueThrowsException),
    ("testReadEnumWithWithValidIdFetchesRecord", testReadEnumWithWithValidIdFetchesRecord),
    ("testReadEnumWithWithStringIdThrowsException", testReadEnumWithWithStringIdThrowsException),
    ("testReadEnumWithMissingIdThrowsException", testReadEnumWithMissingIdThrowsException),
    ("testReadEnumWithNonDictionaryValueThrowsException", testReadEnumWithNonDictionaryValueThrowsException),
    ("testReadOptionalEnumWithWithValidIdFetchesRecord", testReadOptionalEnumWithWithValidIdFetchesRecord),
    ("testReadOptionalEnumWithWithStringIdThrowsException", testReadOptionalEnumWithWithStringIdThrowsException),
    ("testReadOptionalEnumWithMissingIdReturnsNil", testReadOptionalEnumWithMissingIdReturnsNil),
    ("testReadOptionalEnumWithNonDictionaryValueThrowsException", testReadOptionalEnumWithNonDictionaryValueThrowsException),
    ("testReadEnumWithWithValidNameGetsEnumCase", testReadEnumWithWithValidNameGetsEnumCase),
    ("testReadEnumWithWithIntegerForNameThrowsException", testReadEnumWithWithIntegerForNameThrowsException),
    ("testReadEnumWithMissingNameThrowsException", testReadEnumWithMissingNameThrowsException),
    ("testReadEnumWithNonDictionaryValueForNameThrowsException", testReadEnumWithNonDictionaryValueForNameThrowsException),
    ("testReadOptionalEnumWithWithValidNameFetchesRecord", testReadOptionalEnumWithWithValidNameFetchesRecord),
    ("testReadOptionalEnumWithWithIntegerNameThrowsException", testReadOptionalEnumWithWithIntegerNameThrowsException),
    ("testReadOptionalEnumWithMissingNameReturnsNil", testReadOptionalEnumWithMissingNameReturnsNil),
    ("testReadOptionalEnumWithNonDictionaryValueForNameThrowsException", testReadOptionalEnumWithNonDictionaryValueForNameThrowsException),
    ("testReadEnumWithIdForTableReadsRecord", testReadEnumWithIdForTableReadsRecord),
    ("testReadEnumWithIdForTableWithStringIdReadsRecord", testReadEnumWithIdForTableWithStringIdReadsRecord),
    ("testReadEnumWithIdForTableMissingIdThrowsException", testReadEnumWithIdForTableMissingIdThrowsException),
    ("testReadEnumWithNameWithValidNameGetsEnumCase", testReadEnumWithNameWithValidNameGetsEnumCase),
    ("testReadEnumWithNameWithIntegerForNameThrowsException", testReadEnumWithNameWithIntegerForNameThrowsException),
    ("testReadEnumWithNameWithMissingNameThrowsException", testReadEnumWithNameWithMissingNameThrowsException),
    ("testReadOptionalEnumWithIdForTableReadsRecord", testReadOptionalEnumWithIdForTableReadsRecord),
    ("testReadOptionalEnumWithIdForTableWithStringIdReadsRecord", testReadOptionalEnumWithIdForTableWithStringIdReadsRecord),
    ("testReadOptionalEnumWithIdForTableMissingIdReturnsNil", testReadOptionalEnumWithIdForTableMissingIdReturnsNil),
    ("testReadOptionalEnumWithNameWithValidNameGetsEnumCase", testReadOptionalEnumWithNameWithValidNameGetsEnumCase),
    ("testReadOptionalEnumWithNameWithIntegerForNameReturnsNil", testReadOptionalEnumWithNameWithIntegerForNameReturnsNil),
    ("testReadOptionalEnumWithNameWithMissingNameThrowsException", testReadOptionalEnumWithNameWithMissingNameThrowsException),
    ("testWrappedTypeForStringIsString", testWrappedTypeForStringIsString),
    ("testWrappedTypeForArrayIsArray", testWrappedTypeForArrayIsArray),
    ("testWrappedTypeForDictionaryIsDictionary", testWrappedTypeForDictionaryIsDictionary),
    ("testWrappedTypeForNullIsNull", testWrappedTypeForNullIsNull),
    ("testWrappedTypeForIntegerIsInt", testWrappedTypeForIntegerIsInt),
    ("testWrappedTypeForDoubleIsDouble", testWrappedTypeForDoubleIsDouble),
    ("testWrappedTypeForBooleanIsBoolean", testWrappedTypeForBooleanIsBoolean),
    ("testWrappedTypeForTimestampIsTimestamp", testWrappedTypeForTimestampIsTimestamp),
    ("testWrappedTypeForTimeIsTime", testWrappedTypeForTimeIsTime),
    ("testWrappedTypeForDateIsDate", testWrappedTypeForDateIsDate),
    ("testWrappedTypeForDataIsData", testWrappedTypeForDataIsData),
    ("testStringValueWithStringTypeReturnsString", testStringValueWithStringTypeReturnsString),
    ("testStringValueWithIntegerTypeReturnsNil", testStringValueWithIntegerTypeReturnsNil),
    ("testStringValueWithDescriptionOfStringReturnsString", testStringValueWithDescriptionOfStringReturnsString),
    ("testBoolValueWithBooleanReturnsValue", testBoolValueWithBooleanReturnsValue),
    ("testBoolValueWithZeroReturnsFalse", testBoolValueWithZeroReturnsFalse),
    ("testBoolValueWithOneReturnsTrue", testBoolValueWithOneReturnsTrue),
    ("testBoolValueWithStringReturnsNil", testBoolValueWithStringReturnsNil),
    ("testBoolValueWithDescriptionOfBoolReturnsBool", testBoolValueWithDescriptionOfBoolReturnsBool),
    ("testIntValueWithIntegerReturnsValue", testIntValueWithIntegerReturnsValue),
    ("testIntValueWithStringReturnsNil", testIntValueWithStringReturnsNil),
    ("testIntValueWithDescriptionOfIntReturnsInt", testIntValueWithDescriptionOfIntReturnsInt),
    ("testDataValueWithDataReturnsValue", testDataValueWithDataReturnsValue),
    ("testDataValueWithStringReturnsNil", testDataValueWithStringReturnsNil),
    ("testDoubleValueWithDoubleReturnsValue", testDoubleValueWithDoubleReturnsValue),
    ("testDoubleValueWithDescriptionOfDoubleReturnsDouble", testDoubleValueWithDescriptionOfDoubleReturnsDouble),
    ("testFoundationDateValueWithTimestampReturnsValue", testFoundationDateValueWithTimestampReturnsValue),
    ("testFoundationDateValueWithStringReturnsNil", testFoundationDateValueWithStringReturnsNil),
    ("testTimestampValueWithTimestampReturnsValue", testTimestampValueWithTimestampReturnsValue),
    ("testTimestampValueWithPartialStringReturnsNil", testTimestampValueWithPartialStringReturnsNil),
    ("testTimestampValueWithFullTimestampStringReturnsTimestamp", testTimestampValueWithFullTimestampStringReturnsTimestamp),
    ("testTimestampValueWithDescriptionOfTimestampReturnsTimestamp", testTimestampValueWithDescriptionOfTimestampReturnsTimestamp),
    ("testTimestampValueWithIntegerReturnsNil", testTimestampValueWithIntegerReturnsNil),
    ("testDateValueWithDateReturnsDate", testDateValueWithDateReturnsDate),
    ("testDateValueWithTimestampReturnsDateFromTimestamp", testDateValueWithTimestampReturnsDateFromTimestamp),
    ("testDateValueWithTimeReturnsNil", testDateValueWithTimeReturnsNil),
    ("testDateValueWithValidStringReturnsDate", testDateValueWithValidStringReturnsDate),
    ("testDateValueWithInvalidStringReturnsNil", testDateValueWithInvalidStringReturnsNil),
    // ("testDateValueWithDescriptionOfDateReturnsDate", testDateValueWithDescriptionOfDateReturnsDate),
    ("testDateValueWithIntReturnsNil", testDateValueWithIntReturnsNil),
    ("testTimeValueWithTimeReturnsTime", testTimeValueWithTimeReturnsTime),
    ("testTimeValueWithTimestampReturnsTimeFromTimestamp", testTimeValueWithTimestampReturnsTimeFromTimestamp),
    ("testTimeValueWithDateReturnsNil", testTimeValueWithDateReturnsNil),
    ("testTimeValueWithStringReturnsNil", testTimeValueWithStringReturnsNil),
    // ("testTimeValueWithDescriptionOfTimeGetsTime", testTimeValueWithDescriptionOfTimeGetsTime),
    ("testDescriptionWithStringGetsString", testDescriptionWithStringGetsString),
    ("testDescriptionWithBooleanGetsTrueOrValue", testDescriptionWithBooleanGetsTrueOrValue),
    ("testDescriptionWithDataGetsDataDescription", testDescriptionWithDataGetsDataDescription),
    ("testDescriptionWithIntegerGetsIntegerAsString", testDescriptionWithIntegerGetsIntegerAsString),
    ("testDescriptionWithDoubleGetsDoubleAsString", testDescriptionWithDoubleGetsDoubleAsString),
    ("testDescriptionWithTimestampGetsFormattedDate", testDescriptionWithTimestampGetsFormattedDate),
    // ("testDescriptionWithDateUsesDateDescription", testDescriptionWithDateUsesDateDescription),
    // ("testDescriptionWithTimeUsesTimeDescription", testDescriptionWithTimeUsesTimeDescription),
    ("testDescriptionWithArrayGetsArrayDescription", testDescriptionWithArrayGetsArrayDescription),
    ("testDescriptionWithDictionaryGetsDictionaryDescription", testDescriptionWithDictionaryGetsDictionaryDescription),
    ("testDescriptionWithNullGetsNull", testDescriptionWithNullGetsNull),
    ("testStringsWithSameContentsAreEqual", testStringsWithSameContentsAreEqual),
    ("testStringsWithDifferentContentsAreNotEqual", testStringsWithDifferentContentsAreNotEqual),
    ("testStringDoesNotEqualDictionary", testStringDoesNotEqualDictionary),
    ("testDictionaryWithSameContentsAreEqual", testDictionaryWithSameContentsAreEqual),
    ("testDictionaryWithDifferentKeysAreNotEqual", testDictionaryWithDifferentKeysAreNotEqual),
    ("testDictionaryWithDifferentValuesAreNotEqual", testDictionaryWithDifferentValuesAreNotEqual),
    ("testDictionaryDoesNotEqualArray", testDictionaryDoesNotEqualArray),
    ("testArrayWithSameContentsAreEqual", testArrayWithSameContentsAreEqual),
    ("testArrayWithDifferentContentsAreNotEqual", testArrayWithDifferentContentsAreNotEqual),
    ("testArrayDoesNotEqualString", testArrayDoesNotEqualString),
    ("testComparisonWithEqualStringsIsEqual", testComparisonWithEqualStringsIsEqual),
    ("testComparisonWithUnequalStringsIsNotEqual", testComparisonWithUnequalStringsIsNotEqual),
    ("testComparisonWithStringAndIntIsNotEqual", testComparisonWithStringAndIntIsNotEqual),
    ("testComparisonWithEqualIntsIsEqual", testComparisonWithEqualIntsIsEqual),
    ("testComparisonWithUnequalIntsIsNotEqual", testComparisonWithUnequalIntsIsNotEqual),
    ("testComparisonWithEqualBoolsIsEqual", testComparisonWithEqualBoolsIsEqual),
    ("testComparisonWithEqualDoublesIsEqual", testComparisonWithEqualDoublesIsEqual),
    ("testComparisonWithUnequalDoublesIsNotEqual", testComparisonWithUnequalDoublesIsNotEqual),
    ("testComparisonWithEqualDatasAreEqual", testComparisonWithEqualDatasAreEqual),
    ("testComparisonWithUnequalDatasAreNotEqual", testComparisonWithUnequalDatasAreNotEqual),
    ("testComparisonWithEqualTimestampsAreEqual", testComparisonWithEqualTimestampsAreEqual),
    ("testComparisonWithUnequalTimestampsAreNotEqual", testComparisonWithUnequalTimestampsAreNotEqual),
    ("testComparisonWithEqualTimesAreEqual", testComparisonWithEqualTimesAreEqual),
    ("testComparisonWithUnequalTimesAreNotEqual", testComparisonWithUnequalTimesAreNotEqual),
    ("testComparisonWithEqualDatesAreEqual", testComparisonWithEqualDatesAreEqual),
    ("testComparisonWithUnequalDatesAreNotEqual", testComparisonWithUnequalDatesAreNotEqual),
    ("testComparisonWithNullsIsEqual", testComparisonWithNullsIsEqual),
  ] }

  enum Color: String, StringPersistableEnum {
    case Red
    case DarkBlue
    
    static var cases = [Color.Red, Color.DarkBlue]
  }
  
  enum HatType: String, TablePersistableEnum {
    case Feathered
    case WideBrim
    
    static var cases = [HatType.Feathered, HatType.WideBrim]
  }

  func setUp() {
    setUpTestCase()
  }
  
  //MARK: - Converting to JSON
  
  var complexJsonDictionary: [String:SerializableValue] = [
    "key1": SerializableValue.String("value1"),
    "key2": SerializableValue.Array([
      SerializableValue.String("value2"),
      SerializableValue.String("value3")
      ]),
    "key3": SerializableValue.Dictionary([
      "bKey1": SerializableValue.String("value4"),
      "bKey2": SerializableValue.Integer(891)
      ]),
    "nullKey": SerializableValue.Null,
    "numberKey": SerializableValue.Integer(12),
    "emptyStringKey": SerializableValue.String(""),
  ]
  func testFoundationJsonObjectForStringIsString() {
    let primitive = SerializableValue.String("Hello")
    assert(primitive.toFoundationJsonObject as? String, equals: "Hello")
  }
  
  func testFoundationJsonObjectForArrayOfStringsIsArrayOfStrings() {
    let primitive = SerializableValue.Array([
      SerializableValue.String("A"),
      SerializableValue.String("B")
      ])
    let object = primitive.toFoundationJsonObject
    if let strings = object as? [Any] {
      assert(strings.count, equals: 2)
      assert(strings[0] as? String, equals: "A")
      assert(strings[1] as? String, equals: "B")
    }
    else {
      assert(false, message: "Gets an array of strings")
    }
  }
  
  func testFoundationJsonObjectForDictionaryOfStringsIsDictionaryOfStrings() {
    let primitive = SerializableValue.Dictionary([
      "key1": SerializableValue.String("value1"),
      "key2": SerializableValue.String("value2")
      ])
    
    let object = primitive.toFoundationJsonObject
    if let dictionary = object as? [String:Any] {
      assert(dictionary["key1"] as? String, equals: "value1")
      assert(dictionary["key2"] as? String, equals: "value2")
    }
    else {
      assert(false, message: "Gets a dictionary of strings")
    }
  }
  
  func testFoundationJsonObjectForHeterogeneousArrayMapsInnerArray() {
    let primitive = SerializableValue.Array([
      SerializableValue.String("A"),
      SerializableValue.Array([
        SerializableValue.String("B"),
        SerializableValue.String("C")
        ])
      ])
    let object = primitive.toFoundationJsonObject
    if let array = object as? [Any] {
      assert(array.count, equals: 2)
      assert(array[0] as? String, equals: "A")
      if let innerArray = array[1] as? [Any] {
        assert(innerArray.count, equals: 2)
        assert(innerArray[0] as? String, equals: "B")
        assert(innerArray[1] as? String, equals: "C")
      }
      else {
        assert(false, message: "gets an inner array of strings")
      }
    }
    else {
      assert(false, message: "Gets an array")
    }
  }
  
  func testFoundationJsonObjectForHeterogeneousDictionaryMapsInnerDictionary() {
    let primitive = SerializableValue.Dictionary([
      "aKey1": SerializableValue.String("value1"),
      "aKey2": SerializableValue.Array([
        SerializableValue.String("value2"),
        SerializableValue.String("value3")
        ]),
      "aKey3": SerializableValue.Dictionary([
        "bKey1": SerializableValue.String("value4"),
        "bKey2": SerializableValue.String("value5")
        ])
      ])
    let object = primitive.toFoundationJsonObject
    if let dictionary = object as? [String:Any] {
      assert(dictionary["aKey1"] as? String, equals: "value1")
      if let innerArray = dictionary["aKey2"] as? [Any] {
        assert(innerArray.count, equals: 2)
        assert(innerArray[0] as? String, equals: "value2")
        assert(innerArray[1] as? String, equals: "value3")
      }
      else {
        assert(false, message: "gets an inner array")
      }
      if let innerDictionary = dictionary["aKey3"] as? [String:Any] {
        assert(innerDictionary["bKey1"] as? String, equals: "value4")
        assert(innerDictionary["bKey2"] as? String, equals: "value5")
      }
      else {
        assert(false, message: "gets an inner dictionary")
      }
    }
    else {
      assert(false, message: "Gets a dictionary")
    }
  }
  
  func testFoundationJsonObjectForNullIsNsNull() {
    let primitive = SerializableValue.Null
    let object = primitive.toFoundationJsonObject
    assert(object is NSNull)
  }
  
  func testFoundationJsonObjectForDoubleIsNsNumber() {
    let primitive = SerializableValue.Double(11.5)
    let object = primitive.toFoundationJsonObject
    assert(object as? NSNumber, equals: NSNumber(double: 11.5))
  }
  
  func testFoundationJsonObjectForIntegerIsNsNumber() {
    let primitive = SerializableValue.Integer(15)
    let object = primitive.toFoundationJsonObject
    assert(object as? NSNumber, equals: NSNumber(int: 15))
  }
  
  func testFoundationJsonObjectForBooleanIsNsNumber() {
    let primitive = SerializableValue.Boolean(false)
    let object = primitive.toFoundationJsonObject
    assert(object as? NSNumber, equals: NSNumber(int: 0))
  }
  
  func testFoundationJsonObjectForTimestampIsFormattedString() {
    let timestamp = Timestamp.now()
    let value = SerializableValue.Timestamp(timestamp)
    let object = value.toFoundationJsonObject
    assert(object as? String, equals: timestamp.format(TimeFormat.Database))
  }
  
  func testFoundationJsonObjectForDateIsFormattedString() {
    let timestamp = Timestamp.now()
    let value = SerializableValue.Date(timestamp.date)
    let object = value.toFoundationJsonObject
    assert(object as? String, equals: timestamp.format(TimeFormat.DatabaseDate))
  }
  
  func testFoundationJsonObjectForTimeIsFormattedString() {
    let timestamp = Timestamp.now()
    let value = SerializableValue.Time(timestamp.time)
    let object = value.toFoundationJsonObject
    assert(object as? String, equals: timestamp.time.description)
  }
  
  func testFoundationJsonObjectForDataIsData() {
    let data = NSData(bytes: [1,2,3,4])
    let value = SerializableValue.Data(data)
    let object = value.toFoundationJsonObject
    assert(object as? NSData, equals: data)
  }
  
  func testJsonDataForStringGetsThrowsException() {
    let primitive = SerializableValue.String("Hello")
    do {
      _ = try primitive.jsonData()
      assert(false, message: "should throw error before it gets here")
    }
    catch {
      assert(true, message: "throws an error")
    }
  }
  
  func testJsonDataForDictionaryOfStringsGetsData() {
    let primitive = SerializableValue.Dictionary([
      "key1": SerializableValue.String("value1"),
      "key2": SerializableValue.String("value2")
      ])
    let expectedData = NSData(bytes: "{\"key1\":\"value1\",\"key2\":\"value2\"}".utf8)
    do {
      let data = try primitive.jsonData()
      assert(data, equals: expectedData)
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testJsonDataForDictionaryWithEscapedStringGetsData() {
    let primitive = SerializableValue.Dictionary([
      "key\"1": SerializableValue.String("value1"),
      "key2": SerializableValue.String("value\"2")
      ])
    let expectedData = NSData(bytes: "{\"key2\":\"value\\\"2\",\"key\\\"1\":\"value1\"}".utf8)
    do {
      let data = try primitive.jsonData()
      assert(data, equals: expectedData)
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testJsonDataForArrayOfStringsGetsData() {
    let primitive = SerializableValue.Array([
      SerializableValue.String("value1"),
      SerializableValue.String("value2")
      ])
    let expectedData = NSData(bytes: "[\"value1\",\"value2\"]".utf8)
    do {
      let data = try primitive.jsonData()
      assert(data, equals: expectedData)
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testJsonDataForHeterogeneousDictionaryGetsData() {
    
    let primitive = SerializableValue.Dictionary([
      "aKey1": SerializableValue.String("value1"),
      "aKey2": SerializableValue.Dictionary([
        "bKey1": SerializableValue.String("value2"),
        "bKey2": SerializableValue.String("value3")
        ])
      ])
    
    let expectedData = NSData(bytes: "{\"aKey1\":\"value1\",\"aKey2\":{\"bKey1\":\"value2\",\"bKey2\":\"value3\"}}".utf8)
    do {
      let data = try primitive.jsonData()
      assert(data, equals: expectedData)
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testJsonDataForDictionaryWithNullGetsData() {
    
    let primitive = SerializableValue.Dictionary([
      "aKey1": SerializableValue.String("value1"),
      "aKey2": SerializableValue.Null
      ])
    
    let expectedData = NSData(bytes: "{\"aKey1\":\"value1\",\"aKey2\":null}".utf8)
    do {
      let data = try primitive.jsonData()
      assert(data, equals: expectedData)
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testJsonDataForDictionaryWithNumbersGetsData() {
    
    let primitive = SerializableValue.Dictionary([
      "aKey1": SerializableValue.String("value1"),
      "aKey2": SerializableValue.Integer(42),
      "aKey3": SerializableValue.Double(3.14)
      ])
    
    let expectedData = NSData(bytes: "{\"aKey1\":\"value1\",\"aKey3\":3.14,\"aKey2\":42}".utf8)
    do {
      let data = try primitive.jsonData()
      assert(data, equals: expectedData)
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  //MARK: - Parsing from JSON
  
  func testInitWithJsonStringBuildsString() {
    let object = "Hello"
    do {
      let primitive = try SerializableValue(jsonObject: object)
      assert(primitive, equals: SerializableValue.String("Hello"))
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testInitWithJsonDictionaryOfStringsBuildsDictionaryOfStrings() {
    let object: [String: Any] = [
      "key1": "value1",
      "key2": "value2"
    ]
    do {
      let primitive = try SerializableValue(jsonObject: object)
      assert(primitive, equals: SerializableValue.Dictionary([
        "key1": SerializableValue.String("value1"),
        "key2": SerializableValue.String("value2")
        ]))
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testInitWithJsonArrayOfStringsBuildsArrayOfStrings() {
    let object: [Any] = ["value1", "value2"]
    
    do {
      let primitive = try SerializableValue(jsonObject: object)
      assert(primitive, equals: SerializableValue.Array([
        SerializableValue.String("value1"),
        SerializableValue.String("value2")
        ]))
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testInitWithNsNullGetsNull() {
    let object = NSNull()
    do {
      let primitive = try SerializableValue(jsonObject: object)
      assert(primitive, equals: SerializableValue.Null)
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testInitWithIntegerGetsNumber() {
    let object = NSNumber(integer: 823)
    do {
      let primitive = try SerializableValue(jsonObject: object)
      assert(primitive, equals: SerializableValue.Integer(823))
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testInitWithDoubleGetsNumber() {
    let object = NSNumber(double: 61.4)
    do {
      let primitive = try SerializableValue(jsonObject: object)
      assert(primitive, equals: SerializableValue.Double(61.4))
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testInitWithJsonObjectWithUnsupportedTypeThrowsException() {
    let object = NSObject()
    
    do {
      _ = try SerializableValue(jsonObject: object)
      assert(false, message: "should throw an exception")
    }
    catch SerializationParsingError.UnsupportedType(let type) {
      assert(type == NSObject.self)
    }
    catch {
      assert(false, message: "threw an unexpected error type")
    }
  }
  
  func testInitWithJsonDataForDictionaryCreatesDictionary() {
    
    let data = NSData(bytes: "{\"aKey1\":\"value1\",\"aKey2\":{\"bKey1\":\"value2\",\"bKey2\":\"value3\"}}".utf8)
    do {
      let primitive = try SerializableValue(jsonData: data)
      let expectedPrimitive = SerializableValue.Dictionary([
        "aKey1": SerializableValue.String("value1"),
        "aKey2": SerializableValue.Dictionary([
          "bKey1": SerializableValue.String("value2"),
          "bKey2": SerializableValue.String("value3")
          ])
        ])
      assert(primitive, equals: expectedPrimitive)
    }
    catch let e {
      NSLog("Error: \(e)")
      assert(false, message: "should not throw exception")
    }
  }
  
  func testInitWithPlistWithValidPathGetsData() {
    do {
      let path = "./config/goodPlist.plist"
      let data = try SerializableValue(plist: path)
      assert(data, equals: SerializableValue.Dictionary([
        "en": SerializableValue.Dictionary([
          "key1": SerializableValue.String("value1"),
          "key2": SerializableValue.Dictionary([
            "key3": SerializableValue.String("value3")
            ])
          ])
        ]))
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testInitWithPlistWithInvalidPathThrowsException() {
    do {
      let path = "./config/missingPath.plist"
      _ = try SerializableValue(plist: path)
      assert(false, message: "should throw an exception")
    }
    catch SerializationConversionError.NotValidJsonObject {
      
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testInitWithPlistWithInvalidPlistThrowsException() {
    do {
      let path = "./config/invalidPlist.plist"
      _ = try SerializableValue(plist: path)
      assert(false, message: "should throw an exception")
    }
    catch {
    }
  }
  
  func testReadStringWithStringGetsString() {
    let primitive = SerializableValue.String("Hello")
    do {
      let value: String = try primitive.read()
      assert(value, equals: "Hello")
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testReadStringWithArrayThrowsException() {
    let primitive = SerializableValue.Array([SerializableValue.String("A"), SerializableValue.String("B")])
    do {
      _ = try primitive.read() as String
      assert(false, message: "should throw some kind of exception")
    }
    catch SerializationParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "root")
      assert(type == String.self)
      assert(caseType == [SerializableValue].self)
    }
    catch {
      assert(false, message: "threw unexpected exception type")
    }
  }
  
  func testReadArrayWithArrayGetsArray() {
    let array = [
      SerializableValue.String("A"),
      SerializableValue.Array([SerializableValue.String("B"), SerializableValue.String("C")])
    ]
    let primitive = SerializableValue.Array(array)
    do {
      let value: [SerializableValue] = try primitive.read()
      assert(value, equals: array)
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testReadArrayWithDictionaryThrowsError() {
    let primitive = SerializableValue.Dictionary([
      "key1": SerializableValue.String("value1"),
      "key2": SerializableValue.String("value2")
      ])
    do {
      _  = try primitive.read() as [SerializableValue]
      assert(false, message: "should show some kind of exception")
    }
    catch SerializationParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "root")
      assert(type == [SerializableValue].self)
      assert(caseType == [String:SerializableValue].self)
    }
    catch {
      assert(false, message: "threw unexpected exception type")
    }
  }
  
  func testReadDictionaryWithDictionaryGetsDictionary() {
    let dictionary = [
      "key1": SerializableValue.String("value1"),
      "key2": SerializableValue.Array([SerializableValue.String("B"), SerializableValue.String("C")])
    ]
    let primitive = SerializableValue.Dictionary(dictionary)
    do {
      let value = try primitive.read() as [String:SerializableValue]
      assert(value, equals: dictionary)
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testReadDictionaryWithNullThrowsError() {
    let primitive = SerializableValue.Null
    do {
      _  = try primitive.read() as [String:SerializableValue]
      assert(false, message: "should show some kind of exception")
    }
    catch SerializationParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "root")
      assert(type == Dictionary<String,SerializableValue>.self)
      assert(caseType == NSNull.self)
    }
    catch {
      assert(false, message: "threw unexpected exception type")
    }
  }
  
  func testReadIntWithIntGetsInt() {
    let primitive = SerializableValue.Integer(95)
    do {
      let number = try primitive.read() as Int
      assert(number, equals: 95)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadIntWithDoubleGetsDouble() {
    let primitive = SerializableValue.Integer(95)
    do {
      let number = try primitive.read() as Double
      assert(number, equals: 95.0)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadDoubleWithDoubleGetsDouble() {
    let primitive = SerializableValue.Double(123.3)
    do {
      let number = try primitive.read() as Double
      assert(number, equals: 123.3)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadDoubleWithIntGetsInt() {
    let primitive = SerializableValue.Double(81.45)
    do {
      let number = try primitive.read() as Int
      assert(number, equals: 81)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadStringValueWithStringGetsString() {
    let primitive = SerializableValue.Dictionary(complexJsonDictionary)
    do {
      let value: String = try primitive.read("key1")
      assert(value, equals: try complexJsonDictionary["key1"]!.read())
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testReadStringValueWithArrayThrowsException() {
    let primitive = SerializableValue.Dictionary(complexJsonDictionary)
    do {
      _ = try primitive.read("key2") as String
      assert(false, message: "should throw some kind of exception")
    }
    catch SerializationParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "key2")
      assert(type == String.self)
      assert(caseType == [SerializableValue].self)
    }
    catch {
      assert(false, message: "threw unexpected exception type")
    }
  }
  
  func testReadArrayValueWithArrayGetsArray() {
    let primitive = SerializableValue.Dictionary(complexJsonDictionary)
    do {
      let value: [SerializableValue] = try primitive.read("key2")
      assert(value, equals: try complexJsonDictionary["key2"]!.read())
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testReadArrayValueWithDictionaryThrowsException() {
    let primitive = SerializableValue.Dictionary(complexJsonDictionary)
    do {
      _ = try primitive.read("key3") as [SerializableValue]
      assert(false, message: "should throw some kind of exception")
    }
    catch SerializationParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "key3")
      assert(type == [SerializableValue].self)
      assert(caseType == [String:SerializableValue].self)
    }
    catch {
      assert(false, message: "threw unexpected exception type")
    }
  }
  
  func testReadDictionaryValueWithDictionaryReturnsDictionary() {
    let primitive = SerializableValue.Dictionary(complexJsonDictionary)
    do {
      let value: [String:SerializableValue] = try primitive.read("key3")
      assert(value, equals: try complexJsonDictionary["key3"]!.read())
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testReadIntValueWithIntGetsInt() {
    let primitive = SerializableValue.Dictionary(complexJsonDictionary)
    do {
      let value: Int = try primitive.read("numberKey")
      assert(value, equals: try complexJsonDictionary["numberKey"]!.read())
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testReadIntValueWithArrayThrowsException() {
    let primitive = SerializableValue.Dictionary(complexJsonDictionary)
    do {
      _ = try primitive.read("key2") as Int
      assert(false, message: "should throw some kind of exception")
    }
    catch SerializationParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "key2")
      assert(type == Int.self)
      assert(caseType == [SerializableValue].self)
    }
    catch {
      assert(false, message: "threw unexpected exception type")
    }
  }
  
  func testReadDictionaryValueWithStringThrowsException() {
    let primitive = SerializableValue.Dictionary(complexJsonDictionary)
    do {
      _ = try primitive.read("key1") as [String:SerializableValue]
      assert(false, message: "should throw some kind of exception")
    }
    catch SerializationParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "key1")
      assert(type == [String:SerializableValue].self)
      assert(caseType == String.self)
    }
    catch {
      assert(false, message: "threw unexpected exception type")
    }
  }
  
  func testReadValueWithNonDictionaryPrimitiveThrowsException() {
    let primitive = SerializableValue.String("Hello")
    do {
      _ = try primitive.read("key1") as String
      assert(false, message: "should throw some kind of exception")
    }
    catch SerializationParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "root")
      assert(type == [String:SerializableValue].self)
      assert(caseType == String.self)
    }
    catch {
      assert(false, message: "threw unexpected exception type")
    }
  }
  
  func testReadValueWithMissingKeyThrowsException() {
    let primitive = SerializableValue.Dictionary(complexJsonDictionary)
    
    do {
      _ = try primitive.read("key4") as String
      assert(false, message: "should throw some kind of exception")
    }
    catch SerializationParsingError.MissingField(field: let field) {
      assert(field, equals: "key4")
    }
    catch {
      assert(false, message: "threw unexpected exception type")
    }
  }
  
  func testReadValueWithSerializableValueGetsPrimitive() {
    let primitive = SerializableValue.Dictionary(complexJsonDictionary)
    
    do {
      let innerPrimitive = try primitive.read("key2") as SerializableValue
      assert(innerPrimitive, equals: complexJsonDictionary["key2"]!)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadValueWithSerializableValueWithMissingKeyThrowsException() {
    let primitive = SerializableValue.Dictionary(complexJsonDictionary)
    
    do {
      _ = try primitive.read("key4") as SerializableValue
      assert(false, message: "should throw some kind of exception")
    }
    catch SerializationParsingError.MissingField(field: let field) {
      assert(field, equals: "key4")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadOptionalIntValueWithIntGetsInt() {
    let primitive = SerializableValue.Dictionary(complexJsonDictionary)
    do {
      let value: Int? = try primitive.read("numberKey")
      assert(value, equals: try complexJsonDictionary["numberKey"]!.read())
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testReadOptionalIntValueWithArrayThrowsException() {
    let primitive = SerializableValue.Dictionary(complexJsonDictionary)
    do {
      _ = try primitive.read("key2") as Int?
      assert(false, message: "should throw some kind of exception")
    }
    catch SerializationParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      assert(field, equals: "key2")
      assert(type == Int.self)
      assert(caseType == [SerializableValue].self)
    }
    catch {
      assert(false, message: "threw unexpected exception type")
    }
  }
  
  func testReadOptionalIntValueWithNullValueGetsNil() {
    let primitive = SerializableValue.Dictionary(complexJsonDictionary)
    do {
      let value: Int? = try primitive.read("nullKey")
      assert(isNil: value)
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testReadOptionalIntValueWithEmptyStringValueGetsNil() {
    let primitive = SerializableValue.Dictionary(complexJsonDictionary)
    do {
      let value: Int? = try primitive.read("emptyStringKey")
      assert(isNil: value)
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testReadOptionalIntValueWithMissingKeyGetsNil() {
    let primitive = SerializableValue.Dictionary(complexJsonDictionary)
    do {
      let value: Int? = try primitive.read("missingKey")
      assert(isNil: value)
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }

  
  func testReadOptionalIntValueWithNonDictionaryValueThrowsException() {
    let primitive = SerializableValue.Integer(5)
    do {
      _ = try primitive.read("numberKey")
      assert(false, message: "should throw exception")
    }
    catch let SerializationParsingError.WrongFieldType(field, type, caseType) {
      assert(field, equals: "root")
      assert(type == [String:SerializableValue].self)
      assert(caseType == Int.self)
    }
    catch let e {
      assert(false, message: "threw exception: \(e)")
    }
  }
  
  func testReadIntoConvertiblePopulatesValues() {
    struct MyStruct: SerializationConvertible {
      let value1: String
      let value2: Int
      
      init(deserialize values: SerializableValue) throws {
        self.value1 = try values.read("bKey1")
        self.value2 = try values.read("bKey2")
      }
      
      var serialize: SerializableValue {
        return SerializableValue.Dictionary([
          "bKey1": SerializableValue.String(value1),
          "bKey2": SerializableValue.Integer(value2)
          ])
      }
    }
    
    let primitive = SerializableValue.Dictionary(complexJsonDictionary)
    do {
      let value = try primitive.read("key3", into: MyStruct.self)
      assert(value.value1, equals: "value4")
      assert(value.value2, equals: 891)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadIntoConvertibleWithErrorAddsOuterKeyToError() {
    struct MyStruct: SerializationConvertible {
      let value1: String
      let value2: String
      
      init(deserialize values: SerializableValue) throws {
        self.value1 = try values.read("bKey1")
        self.value2 = try values.read("bKey3")
      }
      
      var serialize: SerializableValue {
        return SerializableValue.Dictionary([
          "bKey1": SerializableValue.String(value1),
          "bKey3": SerializableValue.String(value2)
          ])
      }
    }
    
    let primitive = SerializableValue.Dictionary(complexJsonDictionary)
    do {
      _ = try primitive.read("key3", into: MyStruct.self)
      assert(false, message: "should throw some kind of exception")
    }
    catch SerializationParsingError.MissingField(field: let field) {
      assert(field, equals: "key3.bKey3")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testReadRecordWithWithValidIdFetchesRecord() {
    let hat = Hat().save()!
    let data = ["hat_id": hat.id.serialize].serialize
    do {
      let hat2 = try data.readRecord("hat_id") as Hat
      assert(hat2, equals: hat)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  func testReadRecordWithWithStringIdThrowsException() {
    Hat().save()!
    let data = ["hat_id": "5by5".serialize].serialize
    do {
      _ = try data.readRecord("hat_id") as Hat
      assert(false, message: "should throw exception")
    }
    catch let SerializationParsingError.WrongFieldType(field, type, caseType) {
      assert(field, equals: "hat_id")
      assert(type == Int.self)
      assert(caseType == String.self)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  func testReadRecordWithMissingIdThrowsException() {
    let hat = Hat().save()!
    let data = ["id": hat.id].serialize
    do {
      _ = try data.readRecord("hat_id") as Hat
      assert(false, message: "should throw exception")
    }
    catch SerializationParsingError.MissingField("hat_id") {
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  func testReadRecordWithNonDictionaryValueThrowsException() {
    let hat = Hat().save()!
    let data = hat.id.serialize
    do {
      _ = try data.readRecord("hat_id") as Hat
      assert(false, message: "should throw exception")
    }
    catch let SerializationParsingError.WrongFieldType(field, type, caseType) {
      assert(field, equals: "root")
      assert(type == [String:SerializableValue].self)
      assert(caseType == Int.self)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  func testReadOptionalRecordWithWithValidIdFetchesRecord() {
    let hat = Hat().save()!
    let data = ["hat_id": hat.id.serialize].serialize
    do {
      let hat2 = try data.readRecord("hat_id") as Hat?
      assert(hat2, equals: hat)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  func testReadOptionalRecordWithWithStringIdThrowsException() {
    Hat().save()!
    let data = ["hat_id": "5by5".serialize].serialize
    do {
      _ = try data.readRecord("hat_id") as Hat?
      assert(false, message: "should throw exception")
    }
    catch let SerializationParsingError.WrongFieldType(field, type, caseType) {
      assert(field, equals: "hat_id")
      assert(type == Int.self)
      assert(caseType == String.self)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  func testReadOptionalRecordWithMissingIdReturnsNil() {
    let hat = Hat().save()!
    let data = ["id": hat.id].serialize
    do {
      let record = try data.readRecord("hat_id") as Hat?
      assert(isNil: record)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  func testReadOptionalRecordWithNonDictionaryValueThrowsException() {
    let hat = Hat().save()!
    let data = hat.id.serialize
    do {
      _ = try data.readRecord("hat_id") as Hat?
      assert(false, message: "should throw exception")
    }
    catch let SerializationParsingError.WrongFieldType(field, type, caseType) {
      assert(field, equals: "root")
      assert(type == [String:SerializableValue].self)
      assert(caseType == Int.self)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithWithValidIdFetchesRecord() {
    let type = HatType.Feathered
    let data = ["hat_type_id": type.id].serialize
    do {
      let type2 = try data.readEnum(id: "hat_type_id") as HatType
      assert(type2, equals: type)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithWithStringIdThrowsException() {
    let data = ["hat_type_id": "5by5".serialize].serialize
    do {
      _ = try data.readEnum(id: "hat_type_id") as HatType
      assert(false, message: "should throw exception")
    }
    catch let SerializationParsingError.WrongFieldType(field, type, caseType) {
      assert(field, equals: "hat_type_id")
      assert(type == Int.self)
      assert(caseType == String.self)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithMissingIdThrowsException() {
    let type = HatType.WideBrim
    let data = ["id": type.id].serialize
    do {
      _ = try data.readEnum(id: "hat_type_id") as HatType
      assert(false, message: "should throw exception")
    }
    catch SerializationParsingError.MissingField("hat_type_id") {
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithNonDictionaryValueThrowsException() {
    let type = HatType.WideBrim
    let data = type.id.serialize
    do {
      _ = try data.readEnum(id: "hat_id") as HatType
      assert(false, message: "should throw exception")
    }
    catch let SerializationParsingError.WrongFieldType(field, type, caseType) {
      assert(field, equals: "root")
      assert(type == [String:SerializableValue].self)
      assert(caseType == Int.self)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  @available(*, deprecated)
  func testReadOptionalEnumWithWithValidIdFetchesRecord() {
    let type = HatType.Feathered
    let data = ["hat_type_id": type.id].serialize
    do {
      let type2 = try data.readEnum(id: "hat_type_id") as HatType?
      assert(type2, equals: type)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  @available(*, deprecated)
  func testReadOptionalEnumWithWithStringIdThrowsException() {
    let data = ["hat_type_id": "5by5".serialize].serialize
    do {
      _ = try data.readEnum(id: "hat_type_id") as HatType?
      assert(false, message: "should throw exception")
    }
    catch let SerializationParsingError.WrongFieldType(field, type, caseType) {
      assert(field, equals: "hat_type_id")
      assert(type == Int.self)
      assert(caseType == String.self)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  @available(*, deprecated)
  func testReadOptionalEnumWithMissingIdReturnsNil() {
    let type = HatType.WideBrim
    let data = ["id": type.id].serialize
    do {
      let record = try data.readEnum(id: "hat_type_id") as HatType?
      assert(isNil: record)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  @available(*, deprecated)
  func testReadOptionalEnumWithNonDictionaryValueThrowsException() {
    let type = HatType.WideBrim
    let data = type.id.serialize
    do {
      _ = try data.readEnum(id: "hat_id") as HatType?
      assert(false, message: "should throw exception")
    }
    catch let SerializationParsingError.WrongFieldType(field, type, caseType) {
      assert(field, equals: "root")
      assert(type == [String:SerializableValue].self)
      assert(caseType == Int.self)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithWithValidNameGetsEnumCase() {
    let value = Color.Red
    let data = ["color": value.caseName].serialize
    do {
      let value2 = try data.readEnum(name: "color") as Color
      assert(value2, equals: value)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithWithIntegerForNameThrowsException() {
    let data = ["color": 5].serialize
    do {
      _ = try data.readEnum(name: "color") as Color
      assert(false, message: "should throw exception")
    }
    catch let SerializationParsingError.WrongFieldType(field, type, caseType) {
      assert(field, equals: "color")
      assert(type == String.self)
      assert(caseType == Int.self)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithMissingNameThrowsException() {
    let type = Color.Red
    let data = ["color_name": type.caseName].serialize
    do {
      _ = try data.readEnum(name: "color") as Color
      assert(false, message: "should throw exception")
    }
    catch SerializationParsingError.MissingField("color") {
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  @available(*, deprecated)
  func testReadEnumWithNonDictionaryValueForNameThrowsException() {
    let type = Color.Red
    let data = type.caseName.serialize
    do {
      _ = try data.readEnum(name: "color") as Color
      assert(false, message: "should throw exception")
    }
    catch let SerializationParsingError.WrongFieldType(field, type, caseType) {
      assert(field, equals: "root")
      assert(type == [String:SerializableValue].self)
      assert(caseType == String.self)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  @available(*, deprecated)
  func testReadOptionalEnumWithWithValidNameFetchesRecord() {
    let value = Color.Red
    let data = ["color": value.caseName].serialize
    do {
      let value2 = try data.readEnum(name: "color") as Color?
      assert(value2, equals: value)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  @available(*, deprecated)
  func testReadOptionalEnumWithWithIntegerNameThrowsException() {
    let data = ["color": 5].serialize
    do {
      _ = try data.readEnum(name: "color") as Color?
      assert(false, message: "should throw exception")
    }
    catch let SerializationParsingError.WrongFieldType(field, type, caseType) {
      assert(field, equals: "color")
      assert(type == String.self)
      assert(caseType == Int.self)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  @available(*, deprecated)
  func testReadOptionalEnumWithMissingNameReturnsNil() {
    let value = Color.Red
    let data = ["color_name": value.caseName].serialize
    do {
      let record = try data.readEnum(name: "color") as Color?
      assert(isNil: record)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  @available(*, deprecated)
  func testReadOptionalEnumWithNonDictionaryValueForNameThrowsException() {
    let type = HatType.WideBrim
    let data = type.id.serialize
    do {
      _ = try data.readEnum(id: "hat_id") as HatType?
      assert(false, message: "should throw exception")
    }
    catch let SerializationParsingError.WrongFieldType(field, type, caseType) {
      assert(field, equals: "root")
      assert(type == [String:SerializableValue].self)
      assert(caseType == Int.self)
    }
    catch let e {
      assert(false, message: "threw unexpected error: \(e)")
    }
  }
  
  func testReadEnumWithIdForTableReadsRecord() {
    let type = HatType.Feathered
    let data = ["hat_type_id": type.id].serialize
    assertNoExceptions {
      let type2 = try data.readEnum("hat_type_id") as HatType
      assert(type2, equals: type)
    }
  }
  
  func testReadEnumWithIdForTableWithStringIdReadsRecord() {
    let type = HatType.Feathered
    let data = ["hat_type_id": String(type.id).serialize].serialize
    assertNoExceptions {
      let type2 = try data.readEnum("hat_type_id") as HatType
      assert(type2, equals: type)
    }
  }
  
  func testReadEnumWithIdForTableMissingIdThrowsException() {
    let type = HatType.WideBrim
    let data = ["id": type.id].serialize
    assertThrows(SerializationParsingError.MissingField(field: "hat_type_id")) {
      try data.readEnum("hat_type_id") as HatType
    }
  }
  
  func testReadEnumWithNameWithValidNameGetsEnumCase() {
    let value = Color.Red
    let data = ["color": value.caseName].serialize
    assertNoExceptions {
      let value2 = try data.readEnum("color") as Color
      assert(value2, equals: value)
    }
  }
  
  func testReadEnumWithNameWithIntegerForNameThrowsException() {
    let data = ["color": 5].serialize
    assertThrows(SerializationParsingError.MissingField(field: "color")) {
      _ = try data.readEnum("color") as Color
    }
  }
  
  func testReadEnumWithNameWithMissingNameThrowsException() {
    let type = Color.Red
    let data = ["color_name": type.caseName].serialize
    assertThrows(SerializationParsingError.MissingField(field: "color")) {
      _ = try data.readEnum("color") as Color
    }
  }
  
  func testReadOptionalEnumWithIdForTableReadsRecord() {
    let type = HatType.Feathered
    let data = ["hat_type_id": type.id].serialize
    assertNoExceptions {
      let type2 = try data.readEnum("hat_type_id") as HatType?
      assert(type2, equals: type)
    }
  }
  
  func testReadOptionalEnumWithIdForTableWithStringIdReadsRecord() {
    let type = HatType.Feathered
    let data = ["hat_type_id": String(type.id).serialize].serialize
    assertNoExceptions {
      let type2 = try data.readEnum("hat_type_id") as HatType?
      assert(type2, equals: type)
    }
  }
  
  func testReadOptionalEnumWithIdForTableMissingIdReturnsNil() {
    let type = HatType.WideBrim
    let data = ["id": type.id].serialize
    assertNoExceptions {
      let value = try data.readEnum("hat_type_id") as HatType?
      assert(isNil: value)
    }
  }
  
  func testReadOptionalEnumWithNameWithValidNameGetsEnumCase() {
    let value = Color.Red
    let data = ["color": value.caseName].serialize
    assertNoExceptions {
      let value2 = try data.readEnum("color") as Color?
      assert(value2, equals: value)
    }
  }
  
  func testReadOptionalEnumWithNameWithIntegerForNameReturnsNil() {
    let data = ["color": 5].serialize
    assertNoExceptions {
      let value = try data.readEnum("color") as Color?
      assert(isNil: value)
    }
  }
  
  func testReadOptionalEnumWithNameWithMissingNameThrowsException() {
    let type = Color.Red
    let data = ["color_name": type.caseName].serialize
    assertNoExceptions {
      let value = try data.readEnum("color") as Color?
      assert(isNil: value)
    }
  }
  
  //MARK: - Casting
  
  func testWrappedTypeForStringIsString() {
    let type = SerializableValue.String("hi")
    assert(type.wrappedType == String.self)
  }
  
  func testWrappedTypeForArrayIsArray() {
    let type = SerializableValue.Array([SerializableValue.String("hi")])
    assert(type.wrappedType == Array<SerializableValue>.self)
  }
  
  func testWrappedTypeForDictionaryIsDictionary() {
    let type = SerializableValue.Dictionary(["A": SerializableValue.String("B")])
    assert(type.wrappedType == Dictionary<String,SerializableValue>.self)
  }
  
  func testWrappedTypeForNullIsNull() {
    let type = SerializableValue.Null
    assert(type.wrappedType == NSNull.self)
  }
  
  func testWrappedTypeForIntegerIsInt() {
    let type = SerializableValue.Integer(10)
    assert(type.wrappedType == Int.self)
  }
  
  func testWrappedTypeForDoubleIsDouble() {
    let type = SerializableValue.Double(4.5)
    assert(type.wrappedType == Double.self)
  }
  
  func testWrappedTypeForBooleanIsBoolean() {
    let type = SerializableValue.Boolean(false)
    assert(type.wrappedType == Bool.self)
  }
  
  func testWrappedTypeForTimestampIsTimestamp() {
    let type = SerializableValue.Timestamp(Timestamp.now())
    assert(type.wrappedType == Timestamp.self)
  }
  
  func testWrappedTypeForTimeIsTime() {
    let type = SerializableValue.Time(Timestamp.now().time)
    assert(type.wrappedType == Time.self)
  }
  
  func testWrappedTypeForDateIsDate() {
    let type = SerializableValue.Date(Timestamp.now().date)
    assert(type.wrappedType == Date.self)
  }
  
  func testWrappedTypeForDataIsData() {
    let type = SerializableValue.Data(NSData())
    assert(type.wrappedType == NSData.self)
  }
  
  @available(*, deprecated)
  func testStringValueWithStringTypeReturnsString() {
    let value = SerializableValue.String("Test")
    
    let string = value.stringValue
    assert(string, equals: "Test")
  }
  
  @available(*, deprecated)
  func testStringValueWithIntegerTypeReturnsNil() {
    let value = SerializableValue.Integer(5)
    let string = value.stringValue
    XCTAssertNil(string)
  }
  
  @available(*, deprecated)
  func testStringValueWithDescriptionOfStringReturnsString() {
    let value = SerializableValue.String("Test").valueDescription.serialize
    assert(value.stringValue, equals: "Test")
  }
  
  @available(*, deprecated)
  func testBoolValueWithBooleanReturnsValue() {
    let value = SerializableValue.Boolean(true)
    let boolean = value.boolValue
    assert(boolean, equals: true)
  }
  
  @available(*, deprecated)
  func testBoolValueWithZeroReturnsFalse() {
    let value = SerializableValue.Integer(0)
    let boolean = value.boolValue
    assert(boolean, equals: false)
  }
  
  @available(*, deprecated)
  func testBoolValueWithOneReturnsTrue() {
    let value = SerializableValue.Integer(1)
    let boolean = value.boolValue
    assert(boolean, equals: true)
  }
  
  @available(*, deprecated)
  func testBoolValueWithStringReturnsNil() {
    let value = SerializableValue.String("hi")
    let boolean = value.boolValue
    assert(isNil: boolean)
  }
  
  @available(*, deprecated)
  func testBoolValueWithDescriptionOfBoolReturnsBool() {
    let value = SerializableValue.Boolean(true).valueDescription.serialize
    assert(value.boolValue, equals: true)
  }
  
  @available(*, deprecated)
  func testIntValueWithIntegerReturnsValue() {
    let value = SerializableValue.Integer(42)
    let integer = value.intValue
    assert(integer, equals: 42)
  }
  
  @available(*, deprecated)
  func testIntValueWithStringReturnsNil() {
    let value = SerializableValue.String("yo")
    let integer = value.intValue
    XCTAssertNil(integer)
  }
  
  @available(*, deprecated)
  func testIntValueWithDescriptionOfIntReturnsInt() {
    let value = SerializableValue.Integer(5).valueDescription.serialize
    assert(value.intValue, equals: 5)
  }
  
  @available(*, deprecated)
  func testDataValueWithDataReturnsValue() {
    let data1 = NSData(bytes: [1,2,3,4])
    let value = SerializableValue.Data(data1)
    let data2 = value.dataValue
    assert(data2, equals: data1)
  }
  
  @available(*, deprecated)
  func testDataValueWithStringReturnsNil() {
    let value = SerializableValue.String("Test")
    let data = value.dataValue
    XCTAssertNil(data)
  }
  
  @available(*, deprecated)
  func testDoubleValueWithDoubleReturnsValue() {
    let value = SerializableValue.Double(4.5)
    let double = value.doubleValue
    assert(double, equals: 4.5)
  }
  
  @available(*, deprecated)
  func testDoubleValueWithDescriptionOfDoubleReturnsDouble() {
    let value = SerializableValue.Double(5.4).valueDescription.serialize
    assert(value.doubleValue, equals: 5.4)
  }
  
  @available(*, deprecated)
  func testFoundationDateValueWithTimestampReturnsValue() {
    let timestamp = Timestamp.now()
    let value = SerializableValue.Timestamp(timestamp)
    let date = value.foundationDateValue
    assert(date, equals: timestamp.foundationDateValue)
  }
  
  @available(*, deprecated)
  func testFoundationDateValueWithStringReturnsNil() {
    let value = SerializableValue.String("2015-04-15")
    let date = value.foundationDateValue
    XCTAssertNil(date)
  }
  
  @available(*, deprecated)
  func testTimestampValueWithTimestampReturnsValue() {
    let timestamp = Timestamp.now()
    let value = SerializableValue.Timestamp(timestamp)
    let timestamp2 = value.timestampValue
    assert(timestamp2, equals: timestamp)
  }
  
  @available(*, deprecated)
  func testTimestampValueWithPartialStringReturnsNil() {
    let value = SerializableValue.String("2015-04-15")
    let timestamp = value.timestampValue
    assert(isNil: timestamp)
  }
  
  @available(*, deprecated)
  func testTimestampValueWithFullTimestampStringReturnsTimestamp() {
    let value = SerializableValue.String("2015-04-15 09:30:15")
    let timestamp = value.timestampValue
    assert(isNotNil: timestamp)
    if timestamp != nil {
      assert(timestamp?.year, equals: 2015)
      assert(timestamp?.month, equals: 4)
      assert(timestamp?.day, equals: 15)
      assert(timestamp?.hour, equals: 9)
      assert(timestamp?.minute, equals: 30)
      assert(timestamp?.second, equals: 15)
    }
  }
  
  @available(*, deprecated)
  func testTimestampValueWithDescriptionOfTimestampReturnsTimestamp() {
    let timestamp = Timestamp.now().change(nanosecond: 0)
    let value = SerializableValue.Timestamp(timestamp).valueDescription.serialize
    let timestamp2 = value.timestampValue
    assert(timestamp2, equals: timestamp)
  }
  
  @available(*, deprecated)
  func testTimestampValueWithIntegerReturnsNil() {
    let value = SerializableValue.Integer(12345)
    let timestamp = value.timestampValue
    assert(isNil: timestamp)
  }
  
  @available(*, deprecated)
  func testDateValueWithDateReturnsDate() {
    let date = Date(year: 1995, month: 12, day: 1)
    let value = SerializableValue.Date(date)
    assert(value.dateValue, equals: date)
  }
  
  @available(*, deprecated)
  func testDateValueWithTimestampReturnsDateFromTimestamp() {
    let timestamp = Timestamp(year: 2007, month: 3, day: 25, hour: 12, minute: 7, second: 44, nanosecond: 0)
    let value = SerializableValue.Timestamp(timestamp)
    assert(value.dateValue, equals: timestamp.date)
  }
  
  @available(*, deprecated)
  func testDateValueWithTimeReturnsNil() {
    let value = SerializableValue.Time(Time(hour: 11, minute: 30, second: 0, nanosecond: 0))
    assert(isNil: value.dateValue)
  }
  
  @available(*, deprecated)
  func testDateValueWithValidStringReturnsDate() {
    let value = SerializableValue.String("2015-10-02")
    assert(isNotNil: value.dateValue)
    if value.dateValue != nil {
      assert(value.dateValue?.year, equals: 2015)
      assert(value.dateValue?.month, equals: 10)
      assert(value.dateValue?.day, equals: 2)
    }
  }
  
  @available(*, deprecated)
  func testDateValueWithInvalidStringReturnsNil() {
    let value = SerializableValue.String("2015-10")
    assert(isNil: value.dateValue)
  }
  
  @available(*, deprecated)
  func testDateValueWithDescriptionOfDateReturnsDate() {
    let date = Date(year: 1995, month: 12, day: 1)
    let value = SerializableValue.Date(date).valueDescription.serialize
    assert(isNotNil: value.dateValue)
    if value.dateValue != nil {
      assert(value.dateValue?.year, equals: 1995)
      assert(value.dateValue?.month, equals: 12)
      assert(value.dateValue?.day, equals: 1)
    }
  }
  
  @available(*, deprecated)
  func testDateValueWithIntReturnsNil() {
    let value = SerializableValue.Integer(20151002)
    assert(isNil: value.dateValue)
  }
  
  @available(*, deprecated)
  func testTimeValueWithTimeReturnsTime() {
    let time = Time(hour: 11, minute: 30, second: 0, nanosecond: 0)
    let value = SerializableValue.Time(time)
    assert(value.timeValue, equals: time)
  }
  
  @available(*, deprecated)
  func testTimeValueWithTimestampReturnsTimeFromTimestamp() {
    let timestamp = Timestamp(year: 2007, month: 3, day: 25, hour: 12, minute: 7, second: 44, nanosecond: 0)
    let value = SerializableValue.Timestamp(timestamp)
    assert(value.timeValue, equals: timestamp.time)
  }
  
  @available(*, deprecated)
  func testTimeValueWithDateReturnsNil() {
    let date = Date(year: 1995, month: 12, day: 1)
    let value = SerializableValue.Date(date)
    assert(isNil: value.timeValue)
  }
  
  @available(*, deprecated)
  func testTimeValueWithStringReturnsNil() {
    let value = SerializableValue.String("07:00")
    assert(isNil: value.timeValue)
  }
  
  @available(*, deprecated)
  func testTimeValueWithDescriptionOfTimeGetsTime() {
    let time = Time(hour: 11, minute: 30, second: 0, nanosecond: 0)
    let value = SerializableValue.Time(time).valueDescription.serialize
    assert(value.timeValue, equals: time)
  }
  
  func testDescriptionWithStringGetsString() {
    let value = SerializableValue.String("Hello")
    assert(value.valueDescription, equals: "Hello")
  }
  
  func testDescriptionWithBooleanGetsTrueOrValue() {
    let value1 = SerializableValue.Boolean(true)
    assert(value1.valueDescription, equals: "true")
    let value2 = SerializableValue.Boolean(false)
    assert(value2.valueDescription, equals: "false")
  }
  
  func testDescriptionWithDataGetsDataDescription() {
    let data = NSData(bytes: [1,2,3,4])
    let value = SerializableValue.Data(data)
    assert(value.valueDescription, equals: data.description)
  }
  
  func testDescriptionWithIntegerGetsIntegerAsString() {
    let value = SerializableValue.Integer(42)
    assert(value.valueDescription, equals: "42")
  }
  
  func testDescriptionWithDoubleGetsDoubleAsString() {
    let value = SerializableValue.Double(35.5)
    assert(value.valueDescription, equals: "35.5")
  }
  
  func testDescriptionWithTimestampGetsFormattedDate() {
    let timestamp = Timestamp.now()
    let value = SerializableValue.Timestamp(timestamp)
    assert(value.valueDescription, equals: timestamp.format(TimeFormat.Database))
  }
  
  func testDescriptionWithDateUsesDateDescription() {
    let date = Date(year: 1999, month: 7, day: 12)
    let value = SerializableValue.Date(date)
    assert(value.valueDescription, equals: date.description)
  }
  
  func testDescriptionWithTimeUsesTimeDescription() {
    let time = Time(hour: 15, minute: 7, second: 11, nanosecond: 0, timeZone: TimeZone(name: "US/Pacific"))
    let value = SerializableValue.Time(time)
    assert(value.valueDescription, equals: time.description)
  }
  
  func testDescriptionWithArrayGetsArrayDescription() {
    let array = SerializableValue.Array(["A".serialize, "B".serialize])
    assert(array.valueDescription, equals: "[\"A\", \"B\"]")
  }
  
  func testDescriptionWithDictionaryGetsDictionaryDescription() {
    let array = SerializableValue.Dictionary(["A": "B".serialize, "C": 5.serialize])
    assert(array.valueDescription, equals: "[\"A\": \"B\", \"C\": \"5\"]")
  }
  
  func testDescriptionWithNullGetsNull() {
    let value = SerializableValue.Null
    assert(value.valueDescription, equals: "NULL")
  }
  
  //MARK: - Equality
  
  func testStringsWithSameContentsAreEqual() {
    let value1 = SerializableValue.String("Hello")
    let value2 = SerializableValue.String("Hello")
    assert(value1, equals: value2)
  }
  
  func testStringsWithDifferentContentsAreNotEqual() {
    let value1 = SerializableValue.String("Hello")
    let value2 = SerializableValue.String("Goodbye")
    assert(value1, doesNotEqual: value2)
  }
  
  func testStringDoesNotEqualDictionary() {
    let value1 = SerializableValue.String("Hello")
    let value2 = SerializableValue.Dictionary(["key1": SerializableValue.String("value1"), "key2": SerializableValue.String("value2")])
    assert(value1, doesNotEqual: value2)
  }
  
  func testDictionaryWithSameContentsAreEqual() {
    let value1 = SerializableValue.Dictionary(["key1": SerializableValue.String("value1"), "key2": SerializableValue.String("value2")])
    let value2 = SerializableValue.Dictionary(["key1": SerializableValue.String("value1"), "key2": SerializableValue.String("value2")])
    assert(value1, equals: value2)
  }
  
  func testDictionaryWithDifferentKeysAreNotEqual() {
    let value1 = SerializableValue.Dictionary(["key1": SerializableValue.String("value1"), "key2": SerializableValue.String("value2")])
    let value2 = SerializableValue.Dictionary(["key1": SerializableValue.String("value1"), "key3": SerializableValue.String("value2")])
    assert(value1, doesNotEqual: value2)
  }
  
  func testDictionaryWithDifferentValuesAreNotEqual() {
    let value1 = SerializableValue.Dictionary(["key1": SerializableValue.String("value1"), "key2": SerializableValue.String("value2")])
    let value2 = SerializableValue.Dictionary(["key1": SerializableValue.String("value1"), "key2": SerializableValue.String("value3")])
    assert(value1, doesNotEqual: value2)
  }
  
  func testDictionaryDoesNotEqualArray() {
    let value1 = SerializableValue.Dictionary(["key1": SerializableValue.String("value1"), "key2": SerializableValue.String("value2")])
    let value2 = SerializableValue.Array([SerializableValue.String("value1"), SerializableValue.String("value2")])
    assert(value1, doesNotEqual: value2)
  }
  
  func testArrayWithSameContentsAreEqual() {
    let value1 = SerializableValue.Array([SerializableValue.String("value1"), SerializableValue.String("value2")])
    let value2 = SerializableValue.Array([SerializableValue.String("value1"), SerializableValue.String("value2")])
    assert(value1, equals: value2)
  }
  
  func testArrayWithDifferentContentsAreNotEqual() {
    let value1 = SerializableValue.Array([SerializableValue.String("value1"), SerializableValue.String("value2")])
    let value2 = SerializableValue.Array([SerializableValue.String("value1"), SerializableValue.String("value3")])
    assert(value1, doesNotEqual: value2)
  }
  
  func testArrayDoesNotEqualString() {
    let value1 = SerializableValue.Array([SerializableValue.String("value1"), SerializableValue.String("value2")])
    let value2 = SerializableValue.String("[value1,value2]")
    assert(value1, doesNotEqual: value2)
  }
  
  func testComparisonWithEqualStringsIsEqual() {
    let value1 = SerializableValue.String("hello")
    let value2 = SerializableValue.String("hello")
    assert(value1, equals: value2)
  }
  
  func testComparisonWithUnequalStringsIsNotEqual() {
    let value1 = SerializableValue.String("hello")
    let value2 = SerializableValue.String("goodbye")
    XCTAssertNotEqual(value1, value2)
  }
  
  func testComparisonWithStringAndIntIsNotEqual() {
    let value1 = SerializableValue.String("42")
    let value2 = SerializableValue.Integer(42)
    XCTAssertNotEqual(value1, value2)
  }
  
  func testComparisonWithEqualIntsIsEqual() {
    let value1 = SerializableValue.Integer(25)
    let value2 = SerializableValue.Integer(25)
    assert(value1, equals: value2)
  }
  
  func testComparisonWithUnequalIntsIsNotEqual() {
    let value1 = SerializableValue.Integer(25)
    let value2 = SerializableValue.Integer(26)
    XCTAssertNotEqual(value1, value2)
  }
  
  func testComparisonWithEqualBoolsIsEqual() {
    let value1 = SerializableValue.Boolean(true)
    let value2 = SerializableValue.Boolean(true)
    let value3 = SerializableValue.Boolean(false)
    let value4 = SerializableValue.Boolean(false)
    assert(value1, equals: value2)
    assert(value3, equals: value4)
    XCTAssertNotEqual(value1, value3)
  }
  
  func testComparisonWithEqualDoublesIsEqual() {
    let value1 = SerializableValue.Double(1.5)
    let value2 = SerializableValue.Double(1.5)
    assert(value1, equals: value2)
  }
  
  func testComparisonWithUnequalDoublesIsNotEqual() {
    let value1 = SerializableValue.Double(1.5)
    let value2 = SerializableValue.Double(1.6)
    XCTAssertNotEqual(value1, value2)
  }
  
  func testComparisonWithEqualDatasAreEqual() {
    let value1 = SerializableValue.Data(NSData(bytes: [4,3,2,1]))
    let value2 = SerializableValue.Data(NSData(bytes: [4,3,2,1]))
    assert(value1, equals: value2)
  }
  
  func testComparisonWithUnequalDatasAreNotEqual() {
    let value1 = SerializableValue.Data(NSData(bytes: [4,3,2,1]))
    let value2 = SerializableValue.Data(NSData(bytes: [1,2,3,4]))
    XCTAssertNotEqual(value1, value2)
  }
  
  func testComparisonWithEqualTimestampsAreEqual() {
    let value1 = SerializableValue.Timestamp(Timestamp(epochSeconds: 1234512345))
    let value2 = SerializableValue.Timestamp(Timestamp(epochSeconds: 1234512345))
    assert(value1, equals: value2)
  }
  
  func testComparisonWithUnequalTimestampsAreNotEqual() {
    let value1 = SerializableValue.Timestamp(Timestamp(epochSeconds: 1234512345))
    let value2 = SerializableValue.Timestamp(Timestamp(epochSeconds: 1234512346))
    XCTAssertNotEqual(value1, value2)
  }
  
  func testComparisonWithEqualTimesAreEqual() {
    let value1 = SerializableValue.Time(Timestamp(epochSeconds: 1234512345).time)
    let value2 = SerializableValue.Time(Timestamp(epochSeconds: 1234512345).time)
    assert(value1, equals: value2)
  }
  
  func testComparisonWithUnequalTimesAreNotEqual() {
    let value1 = SerializableValue.Time(Timestamp(epochSeconds: 1234512345).time)
    let value2 = SerializableValue.Time(Timestamp(epochSeconds: 1234512346).time)
    XCTAssertNotEqual(value1, value2)
  }
  
  func testComparisonWithEqualDatesAreEqual() {
    let value1 = SerializableValue.Date(Timestamp(epochSeconds: 1234512345).date)
    let value2 = SerializableValue.Date(Timestamp(epochSeconds: 1234512345).date)
    assert(value1, equals: value2)
  }
  
  func testComparisonWithUnequalDatesAreNotEqual() {
    let value1 = SerializableValue.Date(Timestamp(epochSeconds: 1234512345).date)
    let value2 = SerializableValue.Date(Timestamp(epochSeconds: 2234512345).date)
    XCTAssertNotEqual(value1, value2)
  }
  
  func testComparisonWithNullsIsEqual() {
    assert(SerializableValue.Null, equals: SerializableValue.Null)
  }
}
