# General

* Memcache support

# Modeling

* Allowing arrays as query parameters
* Ditching prepared statements
* Clean up implementation of fetching cached results from a query.
* Specifying real data types for bind parameters.

# Workarounds to Revisit

* Initializing calendars in different years
* Specifying explicit names on controller structs
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
* Supporting both application.encryptionKey and sessions.encryptionKey
  when decoding sessions