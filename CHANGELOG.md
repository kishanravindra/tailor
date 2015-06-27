### Version 1.0.0 | 2016-06-05

* Initial release

---

### Pending Release

* Converts the project to Swift 2
* Changes the key for the Application class to TailorApplicationClass
* Regexes on routes can now be nil, because of changes in the
  NSRegularExpression initializer
* The Application class now uses the active bundle to get the root path, which
  should reduce the need to override the rootPath method.
* Several global functions for working with model objects have been deprecated,
  in favor of new methods in protocol extensions.
* More value types now conform to the Equatable protocol.
* Requests are now put onto a single dispatch queue, with no limit on the number
  of simultaneous connections.
* The current time now uses NSDate to get an accurate nanosecond count.
* Several base classes have been replaced with protocols: Controller,
  Alteration, Task, Localization, CacheStore, DatabaseConnection, and Layout
* Several classes have been replaced with structs: CookieJar, Session,
  PasswordHasher, and Query.