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
* Building arrays by iterating to handle exceptions in JSonPrimitive