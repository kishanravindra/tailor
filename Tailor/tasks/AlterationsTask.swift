import Foundation

/**
  This method provides a task for running pending alterations.
  */
public final class AlterationsTask : TaskType {
  /** The command for the task. */
  public static let commandName = "run_alterations"
  
  /**
    This method runs the pending alterations.

    It will pull up the list from the Alteration class, run each one, and put
    its id in the tailor_alterations table.
    */
  public static func runTask() {
    let connection = DatabaseConnection.sharedConnection()
    for alteration in PendingAlterations() {
      if alteration.identifier != "" {
        NSLog("Running alteration %@ %@", alteration.identifier, alteration.name)
        alteration.run()
        connection.executeQuery("INSERT INTO tailor_alterations VALUES (?)", alteration.identifier)
      }
    }
  }
}