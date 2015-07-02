# General

* Memcache support
* Update README for new starting procedure

# Modeling

* Allowing arrays as query parameters
* Ditching prepared statements
* Clean up implementation of fetching cached results from a query.
* Specifying real data types for bind parameters.

# Workarounds to Revisit

* Getting rid of connection parameter for MysqlStatement class
* Finding better way of switching on MySQL type enum
* Initializing calendars in different years
* Specifying explicit names on controller structs
* Hacks in TailorMysql where we moved code out of initializers to work around
  compiler crashes