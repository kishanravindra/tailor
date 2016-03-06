/**
  This type provides a mechanism for registering subtypes of other types.

  You register types with an inventory by calling the `registerSubtypes`
  methods, and you can fetch a list of the registered types by calling
  `registeredSubtypes`, or one of the other `registered` methods.

  */
public struct TypeInventory {
  /** A dictionary mapping the name of a type to its subtypes. */
  public private(set) var typeMapping = [String:[Any.Type]]()

  /**
    This method initializes an empty type inventory.
    */
  public init() {

  }

  /**
    This method gets the subtypes that we have registered of another type.

    - parameter parent:   The parent type
    - returns:            The registered subtypes of the parent type.
    */
  public func registeredSubtypes<ParentType>(parent: ParentType.Type) -> [ParentType.Type] {
    if let types = typeMapping[String(ParentType.self)] {
      return types.flatMap { $0 as? ParentType.Type }
    }
    else {
      return []
    }
  }

  /**
    This method gets the tasks that we have registered.
    */
  public var registeredTasks: [TaskType.Type] {
    if let types = typeMapping[String(TaskType.self)] {
      return types.flatMap { $0 as? TaskType.Type }
    }
    else {
      return []
    }
  }

  /**
    This method gets the alterations that we have registered.
    */
  public var registeredAlterations: [AlterationScript.Type] {
    if let types = typeMapping[String(AlterationScript.self)] {
      return types.flatMap { $0 as? AlterationScript.Type }
    }
    else {
      return []
    }
  }

  /**
    This method adds subtypes to our registry.

    - parameter parent:   The parent type.
    - parameter subtypes: The subtypes to add.
    */
  public mutating func registerSubtypes(parent: Any.Type, subtypes: [Any.Type]) {
    let parentName = String(parent)
    var types = typeMapping[parentName] ?? []
    for type in subtypes {
      let exists = types.contains { $0 == type }
      if !exists { types.append(type) }
    }
    typeMapping[parentName] = types
  }

  /**
    This method gets the shared type inventory.
    */
  public static var shared: TypeInventory {
    get {
      return SHARED_TYPE_INVENTORY
    }
    set {
      SHARED_TYPE_INVENTORY = newValue
    }
  }
}

private var SHARED_TYPE_INVENTORY = TypeInventory()