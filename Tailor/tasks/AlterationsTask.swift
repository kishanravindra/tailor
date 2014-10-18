import Foundation

/**
  This method provides a task for running pending alterations.
  */
public class AlterationsTask : Task {
  public override class func command() -> String { return "run_alterations" }
  
  /**
    This method runs the pending alterations.

    It will pull up the list from the Alteration class, run each one, and put
    its id in the tailor_alterations table.
    */
  public override func run() {
    let connection = DatabaseConnection.sharedConnection()
    for alteration in Alteration.pendingAlterations() {
      if alteration.id() != "" {
        NSLog("Running alteration %@ %@", alteration.id(), alteration.description())
        alteration().alter()
        connection.executeQuery("INSERT INTO tailor_alterations VALUES (?)", alteration.id())
      }
    }
  }
}