import Foundation

/**
  This method provides a task for running pending alterations.
  */
public class AlterationsTask : Task {
  public override class func command() -> String { return "run_alterations" }
  public override func run() {
    NSLog("Running pending alterations")
  }
}