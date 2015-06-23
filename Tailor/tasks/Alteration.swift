import Foundation

import Foundation

/**
  This protocol describes an alteration, which is a one-time script that is run
  to modify the structure or contents of the database.

  Each script should be its own class conforming to this protocol. This protocol
  can only be implemented by classes because of limitations in our ability to
  discover conforming types at runtime.
  */
public protocol AlterationScript: class {
  /**
    This method provides a unique identifier for the alteration.

    Scripts will be run in order based on this identifier. It can be helpful to
    use a timestamp for this, which helps to ensure that the scripts run in the
    correct order.
    */
  static var identifier: String { get }
  
  /**
    This method provides a human-readable description for the alteration.

    The default implementation uses the class name.
    */
  static var name: String { get }
  
  /**
    This method provides the actual logic for the script.
    */
  static func run()
}

/**
  This method gets the alterations that need to be run.

  It will pull up the full list of alterations, and exclude any that have been
  recorded in the tailor_alterations table. If the table doesn't exist, it
  will create it and return the full list of alterations.

  - returns: The pending alterations.
  */
public func PendingAlterations() -> [AlterationScript.Type] {
  var previousAlterations = DatabaseConnection.sharedConnection().executeQuery("SELECT * FROM tailor_alterations")
  if previousAlterations.count == 1 && previousAlterations[0].error != nil {
    DatabaseConnection.sharedConnection().executeQuery("CREATE TABLE tailor_alterations ( id varchar(255) PRIMARY KEY )")
    previousAlterations = []
  }
  var alterations = Application.sharedApplication().registeredAlterations()
  alterations = alterations.filter {
    alteration in
    return previousAlterations.filter {
      previousAlteration in
      let id = previousAlteration.data["id"]!.stringValue!
      return id == alteration.identifier
    }.isEmpty
  }
  alterations = alterations.sort {
    $0.identifier.compare($1.identifier) == NSComparisonResult.OrderedAscending
  }
  return alterations
}

public extension AlterationScript {
  public static var name: String { return reflect(self).summary }
  
  /**
    This method executes a database query.

    This accepts a single list of strings to keep the scripts cleaner. Any
    strings before the first nil entry will be part of the query, and any
    strings after the first nil entry will be bind parameters. The parts of the
    query will be concatenated to from the full query.

    If there is an error running the query, it will log the query and the error
    and exit the program.
    */
  public static func query(components: String?...) {
    var query = ""
    var parameters = [DatabaseValueConvertible]()
    var foundNil = false
    
    for component in components {
      if component == nil {
        foundNil = true
        continue
      }
      else if foundNil {
        parameters.append(component!)
      }
      else {
        query += component! + "\n"
      }
    }
    let results = DatabaseConnection.sharedConnection().executeQuery(query, parameterValues: parameters)
    if !results.isEmpty && results[0].error != nil {
      NSLog("Error running query")
      NSLog("%@ %@", query, parameters.map { $0.databaseValue.description })
      NSLog("Error: %@", results[0].error!)
      exit(1)
    }
  }
}

/**
  This class represents an alteration, which is a one-time script that is run
  to modify the structure or contents of the database.
  
  Each script should be its own subclass of alteration, and override the "alter"
  method with the script's behavior.

  This class has been deprecated. You should implement the AlterationScript
  protocol directly.
  */
@available(*, deprecated, message="Use AlterationScript instead") public class Alteration: AlterationScript {
  /**
    This method provides a unique identifier for the alteration.
  
    This implementation is empty, but subclasses must provide a unique
    identifier.

    Scripts will be run in order based on this identifier. It can be helpful to
    use a timestamp for this, which helps to ensure that the scripts run in the
    correct order.
    */
  public class func id() -> String { return "" }

  public class var identifier: String { return id() }
  
  /**
    This method gets a human-readable description of the alteration.
    */
  public class func description() -> String { return NSStringFromClass(self) }

  public class var name: String { return description() }

  public static func run() {
    self.init().alter()
  }
  
  /**
    This method initializes the alteration.

    It doesn't do anything, but we need an explicit initializer so that we can
    initialize it with the right dynamic type.
    */
  public required init() {
    
  }
  
  /**
    This method gets the alterations that need to be run.

    It will pull up the full list of alterations, and exclude any that have been
    recorded in the tailor_alterations table. If the table doesn't exist, it
    will create it and return the full list of alterations.
    
    - returns: The pending alterations.
    */
  public class func pendingAlterations() -> [Alteration.Type] {
    var previousAlterations = DatabaseConnection.sharedConnection().executeQuery("SELECT * FROM tailor_alterations")
    if previousAlterations.count == 1 && previousAlterations[0].error != nil {
      DatabaseConnection.sharedConnection().executeQuery("CREATE TABLE tailor_alterations ( id varchar(255) PRIMARY KEY )")
      previousAlterations = []
    }
    return Application.sharedApplication().registeredSubclassList(Alteration.self).filter {
      alteration in
      previousAlterations.filter {
        previousAlteration in
        let id = previousAlteration.data["id"]!.stringValue!
        return id == alteration.id()
      }.isEmpty
    }.sort {
      $0.id().compare($1.id()) == NSComparisonResult.OrderedAscending
    }
  }
  
  /**
    This method executes a database query.

    This accepts a single list of strings to keep the scripts cleaner. Any
    strings before the first nil entry will be part of the query, and any
    strings after the first nil entry will be bind parameters. The parts of the
    query will be concatenated to from the full query.

    If there is an error running the query, it will log the query and the error
    and exit the program.
    */
  public func query(components: String?...) {
    var query = ""
    var parameters = [DatabaseValueConvertible]()
    var foundNil = false
    
    for component in components {
      if component == nil {
        foundNil = true
        continue
      }
      else if foundNil {
        parameters.append(component!)
      }
      else {
        query += component! + "\n"
      }
    }
    let results = DatabaseConnection.sharedConnection().executeQuery(query, parameterValues: parameters)
    if !results.isEmpty && results[0].error != nil {
      NSLog("Error running query")
      NSLog("%@ %@", query, parameters.map { $0.databaseValue.description })
      NSLog("Error: %@", results[0].error!)
      exit(1)
    }
  }
  
  /**
    This method runs the body of the script.

    This implementation is empty, so subclasses have to override it.
    */
  public func alter() {
  }
}