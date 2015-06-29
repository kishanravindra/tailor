# General

* Memcache support

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

# Changes for Sqlite database

* Better specification of database type
* Portable way of getting list of tables
* Adding support for more column types
* Switching test cases to use SQLite 