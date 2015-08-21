## Version 1.0.0 | 2016-06-05

* Initial release

---

## Pending Release

#### General

* Converts the project to Swift 2
* Several base classes have been replaced with protocols: `Controller`,
  `Alteration`, `Task`, `Localization`, `CacheStore`, `DatabaseConnection`,
  `User`, and `Layout`.
* Several classes have been replaced with structs: `CookieJar`, `Session`,
  `PasswordHasher`, and `Query`.
* There should now be no need to subclass any type provided by the framework.
* More value types now conform to the Equatable protocol.
* Conformance with RFC 2616 has been improved.

#### New Features

* There is built-in support for sending emails, through the `Email` type.
* There is built-in support for persisting Enum fields on your models to columns
  in the database, through the `PersistableEnum` protocol.
* There is built-in support for reading and writing CSV files, through the
  `CsvParser` type.
* There is a new type-safe system for converting values to and from JSON,
  through the `JsonPrimitive` type.
* There is build-in support for generating a cron file, through the
  `JobSchedulingTaskType` protocol.
* There is a new task type, `SeedTaskType`, which provides a task for saving
  seed data and a database schema to local files.

#### Controllers

* The `ControllerType` protocol, which has replaced the `Controller` class, has
  a very different system for defining routes for actions. You should read the
  [guides](https://tailorframe.work/docs/controllers) for more details on the
  new protocol.
* `Requests` now have a `session` field, which you can use instead of creating
  a session yourself with the request data.
* There is a new `Request.ContentPreference` type for getting information about
  the preferred response types based on headers like `Accept` and
  `Accept-Encoding`.
* Controllers now set the locale for content based on the `Accept-Language`
  header.
* Response codes are now represented by the `Response.Code` type, which provides
  both a numeric code and a text description.
* Controller filters have been replaced with a new `RequestFilter` protocol,
  which allows both pre-processing and post-processing of requests.
* All requests will be put in a `CsrfFilter` by default, which rejects any POST
  request that does not have a valid `csrfToken` parameter.

#### Models

* There is a new mini-framework, TailorSqlite, which provides a SQLite database
  driver. The MySQL driver is now a separate framework.
* Several global functions for working with model objects have been deprecated,
  in favor of new methods in protocol extensions.
* The initializer for the `Persistable` protocol now takes in a `DatabaseRow`
  and throws an exception on failure. You should read the
  [guides](https://tailorframe.work/docs/modelling) for more details on
  implementing initializers for your records.

#### Views

* The `FormBuilder` type has been replaced with the `TemplateForm` type.

#### Application Configuration

* The `ConfigurationSetting` type has been replaced with the
  `Application.Configuration` type. The new configuration system is configured
  in code, rather than through files, which makes it more typesafe, explicit,
  and well-documented.
* Regexes on routes can now be nil, because of changes in the
  `NSRegularExpression` initializer
* The `Application` class now uses the active bundle to get the root path, which
  should reduce the need to override the rootPath method.
* Many instance methods in the `Application` type have been deprecated in favor
  of global configuration settings.
* The AES Encryptor handles missing encryption keys more gracefully.
* There is a more concise syntax for specifying paths and HTTP methods for
  routes.
* There is a new mechanism for specifying the shared route set without
  overriding the Application class.

#### Server

* Requests are now put onto a single dispatch queue, with no limit on the number
  of simultaneous connections.
* The server now supports persistent connections, chunked requests, and
  Continue responses.
* The current time now uses NSDate to get an accurate nanosecond count.
