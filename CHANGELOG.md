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