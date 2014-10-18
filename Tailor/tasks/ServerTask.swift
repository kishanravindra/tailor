import Foundation

/**
  This class provides a task for starting the server.
  */
public class ServerTask : Task {
  public override class func command() -> String { return "server" }

  public override func run() {
    Application.sharedApplication().startServer()
  }
}