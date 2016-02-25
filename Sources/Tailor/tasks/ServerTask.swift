import Foundation

/**
  This class provides a task for starting the server.
  */
public final class ServerTask : TaskType {
  /** The command for the task. */
  public static let commandName = "server"

  /** This method starts the server. */
  public static func runTask() {
    Connection.startServer(
      Application.configuration.ipAddress,
      port: Application.configuration.port,
      handler: { RouteSet.shared().handleRequest($0, callback: $1) }
  )
  }
}