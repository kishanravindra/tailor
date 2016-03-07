# General

* Memcache support
* More testing of TailorTestable and company
* Fix localization prefixes for actions with multi-word names
* Make PaginatedList more resilient against bad pages and page sizes
* Support more time formats
* Add error message information to the failures in assertThrows / assertNoExceptions

# Missing Functionality on Linux

* Fix crashes in dynamic Configuration#configure method
* Allow reading commands from the keyboard
* Improve discovery of MIME types for static assets
* Fix reading / writing to external processes

# Support for More Platforms

* Moving test cases to the SwiftPM test runner
* Building on Mac against Swift Foundation
* Building on Mac against Objective-C foundation.

# Disabled tests to re-enable

* TestApplication
    * Requires reading / writing from keyboard
* TestCalendar
    * Requires Islamic Calendar implementation from Foundation
* TestExternalProcess
    * Requires reading / writing data to external processes
* TestJsonError
    * Requires fixes to catching NSError on Linux
* TestRequest
    * Requires fixes to bad percent-encodings
* TestRequestFilterType
    * Requires fixes for catching NSError on Linux
* TestRouteSet
    * Requires fixes to bad percent-encodings
* TestSendmailEmailAgent
* TestSerializationError
    * Requires fixes for catching NSError on Linux
* TestSession
* TestSmtpEmailAgent
* TestTailorTestable
    * Requires fixes for catching NSError in Linux
* TestTimeInterval 
  * Requires fixes for string formatting

# Encryption

* Audit the logic in AesEncryptor
* Evaluate LibreSSL as a replacement for OpenSSL

# Connection Management

* Improve thread management in the Connection type on Linux
* Add an explicit model for IP addresses to Connections

# Subtype Management

* Allow inferring the parent type in TypeInventory#registerSubtypes
* Allow automatically registering subtypes of a type by crawling the type heirarchy
* Make TypeInventory#registeredSubtypes work when passing a protocol type.

# Modeling

* Allowing arrays as query parameters
* Ditching prepared statements
* Clean up implementation of fetching cached results from a query.
* Specifying real data types for bind parameters.

# Workarounds to Revisit

* Initializing calendars in different years
* Hacks in TailorMysql where we moved code out of initializers to work around
  compiler crashes
* Building dictionaries by iterating rather than mapping in JsonPrimitive
* Building arrays by iterating to handle exceptions in JsonPrimitive
* Not being able to declare JsonEncodable conformance on Arrays and Dictionaries
* Using JsonDictionaryConvertable instead of just calling toJson on the
  dictionary
* Having separate throwing and non-throwing implementations of Dictionary.map
* Having a pathFor / redirectTo method with fewer parameters instead of using
  default parameters
* Turning localization sources into structs rather than classes
* Using type parameters in functions dealing with Persistable and UserType
* Use of underscores in renderedTemplates in TemplateRenderingType.
* Using the readEnumIndirect method instead of a dynamicType in persistable enum
  initializer.
* Removing FoundationExt hacks