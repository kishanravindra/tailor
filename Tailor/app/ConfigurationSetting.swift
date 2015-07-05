import Foundation

/**
  This class encapsulates a configuration setting or family of configuration
  settings.
  */
public final class ConfigurationSetting: Equatable {
  /** The value at this node. */
  public var value: String?
  
  /** The children in this family of settings. */
  private var children = [String: ConfigurationSetting]()
  
  //MARK: - Initialization
  
  /**
    This method creates a configuration setting with a value.
  
    - parameter value:   The value for the setting.
    */
  public init(value: String? = nil) {
    self.value = value
  }
  
  /**
    This method creates a configuration setting for a family of settings
    in a dictionary.

    The dictionary can have nested dictionaries inside of it. Any value that
    is not a string or dictionary will be ignored.

    - parameter dictionary:    The data for the settings.
    */
  public convenience init(dictionary: NSDictionary) {
    self.init()
    for (key,value) in dictionary {
      if let stringKey = key as? String {
        var child: ConfigurationSetting
        switch(value) {
        case let s as String:
          child = ConfigurationSetting(value: s)
        case let d as NSDictionary:
          child = ConfigurationSetting(dictionary: d)
        default:
          child = ConfigurationSetting()
        }
        self.children[stringKey] = child
      }
    }
  }
  
  /**
    This method creates a configuration setting from a property list file.

    If the file does not exist, or is not a valid property list, this will
    create an empty setting.
  
    - parameter path:  The path to the file.
    */
  public convenience init(contentsOfFile path: String) {
    let data = NSData(contentsOfFile: path) ?? NSData()
    let propertyList: NSDictionary
    do {
      propertyList = try NSPropertyListSerialization.propertyListWithData(data, options: NSPropertyListMutabilityOptions.Immutable, format: nil) as? NSDictionary ?? NSDictionary()
    }
    catch {
      propertyList = NSDictionary()
    }
    self.init(dictionary: propertyList)
  }
  
  //MARK: - Child Access
  
  /**
    This method gets a child node from this setting.
  
    If the setting does not exist, this will create an empty one.

    - parameter keyPath:    The key path for the child.
    - returns:              The configuration setting.
    */
  public func child(keyPath: String) -> ConfigurationSetting {
    let keys = keyPath.componentsSeparatedByString(".")
    if keys.count == 1 {
      let child = self.children[keyPath] ?? {
        let setting = ConfigurationSetting()
        self.children[keyPath] = setting
        return setting
      }()
      return child
    }
    else {
      return self.child(keys: keys)
    }
  }
  
  /**
    This method gets a child node from a key path.

    It will iterate through the keys, getting a child for each key from
    the previous child, starting at this node.

    - parameter keys:     The keys to fetch
    - returns:            The setting at the end of the path.
    */
  public func child(keys  keys: [String]) -> ConfigurationSetting {
    var setting = self
    for key in keys {
      setting = setting.child(key)
    }
    return setting
  }
  
  //MARK: - Data Access
  
  /**
    Whether the setting is empty, which means that it has no value or children.
    */
  public var isEmpty: Bool {
    return self.value == nil && self.children.isEmpty
  }
  
  /**
    This method gets the setting for the node at a key path.

    - parameter keyPath:    The dot-separated key path.
    - returns:              The value for the setting.
    */
  public func fetch(keyPath: String) -> String? {
    return self.fetch(keys: keyPath.componentsSeparatedByString("."))
  }
  
  /**
    This method gets the setting for the node at a key path.
    
    - parameter keys:     The keys in the key path.
    - returns:            The value for the setting.
    */
  public func fetch(keys  keys: [String]) -> String? {
    return self.child(keys: keys).value
  }
  
  /**
    This method sets the value for a setting.

    - parameter keyPath:   The dot-separated key path.
    - parameter value:     The value to set.
    */
  public func set(keyPath: String, value: String?) {
    self.child(keyPath).value = value
  }
  
  /**
    This method sets the value for a setting.

    - parameter keys:    The keys in the key path.
    - parameter value:   The value to set.
    */
  public func set(keys  keys: [String], value: String?) {
    self.child(keys: keys).value = value
  }
  
  /**
    This method sets a default value for a setting.

    If another value has already been set, this will do nothing.
    */
  public func setDefaultValue(keyPath: String, value: String) {
    let setting = self.child(keyPath)
    if setting.value == nil {
      setting.value = value
    }
  }
  
  /**
    This subscript provides access to values by key path.

    - parameter keyPath:    The key path for the setting.
    - returns:              The value for that setting.
    */
  public subscript(keyPath: String) -> String? {
    get {
      return self.fetch(keyPath)
    }
    set(value) {
      return self.set(keyPath, value: value)
    }
  }
  
  /**
    This method converts this setting to a nested dictionary.
    
    - returns:   The dictionary
    */
  public func toDictionary() -> [String:AnyObject] {
    var dictionary = [String:AnyObject]()
    for (key,child) in self.children {
      if child.isEmpty {
        continue
      }
      if let value = child.value {
        dictionary[key] = value
      }
      else {
        dictionary[key] = child.toDictionary()
      }
    }
    return dictionary
  }
  
  /**
    This method adds settings for all the values in a dictionary.

    - parameter dictionary:    The dictionary of values to add.
    */
  public func addDictionary(dictionary: [String:AnyObject]) {
    for (key,value) in dictionary {
      switch(value) {
      case let s as String:
        self.child(key).value = s
      case let d as [String:AnyObject]:
        self.child(key).addDictionary(d)
      default:
        continue
      }
    }
  }
}

/**
  This operator determines if two configuration settings are equal.

  Two settings are equal when they have the same value on their node, have all
  the same keys, and have equal children for every key.

  - returns: Whether the two settings are equal.
  */
public func ==(lhs: ConfigurationSetting, rhs: ConfigurationSetting) -> Bool {
  for (key,value1) in lhs.children {
    guard let value2 = rhs.children[key] else { return false }
    
    if value2 != value1 {
      return false
    }
  }
  for key in rhs.children.keys {
    if lhs.children[key] == nil {
      return false
    }
  }
  if lhs.value != rhs.value {
    return false
  }
  return true
}