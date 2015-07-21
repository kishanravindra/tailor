import Foundation

/**
  This class provides an email system that stores emails in a global list in
  memory.

  This can be useful in testing, since it allows you to easily confirm that an
  email has been sent.
  */
public final class MemoryEmailAgent: EmailAgent {
  /**
    This initializer creates an email agent.
  
    It does not use any configuration settings.
  
    - parameter config:   The application configuration.
    */
  public init(_ config: [String:String]) {
    
  }
  
  /**
    This method delivers an email.

    - parameter email:  The email to deliver.
    */
  public func deliver(email: Email) {
    MemoryEmailAgent.deliveries.append(email)
  }
  
  /** The emails that have been delivered with this agent. */
  public static var deliveries = [Email]()
}