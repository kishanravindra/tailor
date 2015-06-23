import Foundation

/**
  This class provides a task for starting the server.
  */
public final class ServerTask : TaskType {
  /** The command for the task. */
  public static let commandName = "server"

  /** This method starts the server. */
  public static func runTask() {
    Application.sharedApplication().startServer()
  }
}