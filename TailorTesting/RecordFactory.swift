import Tailor

/**
  This class provides a reusable pattern for creating records for testing.
  */
public class RecordFactory {
  /** The type of record the factory creates. */
  public let recordType: Record.Type
  
  /**
    The block that generates the default attributes.

    This will be run once for each record, so the block can generate random
    or sequential values and they will be different for different records.
    */
  public let recordInitializer: ()->([String:Any])
  
  /**
    This method creates a record factory.

    :param: recordType          The type of record to create.
    :param: recordInitializer   The initializer for generating the attributes on
                                the record.
    */
  public init(recordType: Record.Type, recordInitializer: ()->[String:Any]) {
    self.recordType = recordType
    self.recordInitializer = recordInitializer
  }
  
  /**
    This method creates a record with this factory.

    :param: attributes    Specific attributes to set on the created record.
                          If a key is mapped to nil in this dictionary, then
                          the field will be nil on the resulting record, even
                          if the factory normally provides a value for it.
    :returns:             The new record.
    */
  public func createRecord(attributes: [String:Any?]) -> Record {
    var mergedAttributes = recordInitializer()
    for (key,value) in attributes {
      if value == nil {
        mergedAttributes.removeValueForKey(key)
      }
      else {
        mergedAttributes[key] = value!
      }
    }
    return recordType.create(mergedAttributes)
  }
  
  /**
    This method registers a new record factory.

    :param: recordType          The type of record the factory is for.
    :param: recordInitializer   The block that generates the attributes for the
                                records.
    */
  public class func register(recordType: Record.Type, recordInitializer: ()->[String:Any]) {
    RECORD_FACTORIES[NSStringFromClass(recordType)] = RecordFactory(recordType: recordType, recordInitializer: recordInitializer)
  }
  
  /**
    This method creates a record from a factory.
  
    As long as you have previously registered a factory for the given record
    type, this will return a non-nil value.

    :param: recordType    The type of record to create.
    :param: attributes    Specific attributes to set on the new record.
    :returns:             The newly created record.
    */
  public class func create<RecordType: Record>(recordType: RecordType.Type, _ attributes: [String:Any?] = [:]) -> RecordType! {
    if let factory = RECORD_FACTORIES[NSStringFromClass(recordType)] {
      return factory.createRecord(attributes) as? RecordType
    }
    return nil
  }
}

public extension Record {
  /**
    This method creates a record of this type using a factory.

    :param: attributes    The specific attributes to set on the record.
    */
  public class func factory(_ attributes: [String:Any?] = [:]) -> Self {
    return RecordFactory.create(self, attributes)
  }
}

/** The record factories that we have registered. */
private var RECORD_FACTORIES = [String: RecordFactory]()