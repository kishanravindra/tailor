import Cocoa

internal class DeprecationShims: NSObject {
  class ApplicationWrapper: NSObject {
    let application: Application
    init(_ application: Application) {
      self.application = application
    }
  }
  @available(*, deprecated) dynamic internal func loadLegacyConfigurationSettings(application: ApplicationWrapper) {
    application.application.loadConfigFromFile("sessions.plist")
    application.application.loadConfigFromFile("database.plist")
    application.application.loadConfigFromFile("localization.plist")
  }
}
extension Application {
  /**
    The configuration settings for the application.
  
    **NOTE**: This has been deprecated in favor of the static configuration variable.
    */
  @available(*, deprecated, message="This has been deprecated in favor of the static configuration variable") public var configuration : ConfigurationSetting {
    LEGACY_CONFIGURATION_SETTING = LEGACY_CONFIGURATION_SETTING ?? ConfigurationSetting()
    return LEGACY_CONFIGURATION_SETTING
  }
}

@available(*, deprecated) private var LEGACY_CONFIGURATION_SETTING: ConfigurationSetting! = nil