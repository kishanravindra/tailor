/**
  This protocol describes a system for delivering email.
  */
public protocol EmailAgent {
  /**
    This method delivers an email.
  
    - parameter email:      The email to deliver.
    - parameter callback:   A callback that will be called with the result of
                            trying to deliver the email.
    */
  func deliver(email: Email, callback: Email.ResultHandler)
}

extension Application {
  /**
    This method generates a shared email agent.
  
    The email agent will be created based on the `emailAgent` section of the
    application configuration.

    - returns:    The email agent.
    */
  public static func sharedEmailAgent() -> EmailAgent {
    guard let agent = SHARED_EMAIL_AGENT else {
      let agent = Application.configuration.emailAgent()
      SHARED_EMAIL_AGENT = agent
      return agent
    }
    return agent
  }
}
internal var SHARED_EMAIL_AGENT: EmailAgent? = nil