import Foundation

/**
  This class provides a task for starting the server.
  */
public class ServerTask : Task {
  /** The command for the task. */
  public override class func command() -> String { return "server" }

  /** This method starts the server. */
  public override func run() {
    Application.sharedApplication().startServer()
  }
}