/**
  This protocol describes a system for delivering email.
  */
public protocol EmailAgent: class {
  /**
    This initializer creates an email deliverer.
  
    - parameter config:   The application configuration for email delivery.
    */
  init(_: [String:String])
  
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
  
    The email agent will be created based on the `email` section of the
    application configuration. This must have a key called "klass", which must
    hold the name of the class that provides the email agent. An instance of the
    class will be instantiated using the rest of the settings in the
    configuration dictionary.
  
    If the email configuration does not exist or does not have a `klass` field,
    this will create a `FileEmailAgent`.

    - returns:    The email agent.
    */
  public static func sharedEmailAgent() -> EmailAgent {
    guard let agent = SHARED_EMAIL_AGENT else {
      let config = self.sharedApplication().configuration.child("email").toDictionary() as? [String:String] ?? [:]
      let klass = NSClassFromString(config["klass"] ?? "") as? EmailAgent.Type ?? FileEmailAgent.self
      let agent = klass.init(config)
      SHARED_EMAIL_AGENT = agent
      return agent
    }
    return agent
  }
}
internal var SHARED_EMAIL_AGENT: EmailAgent? = nil