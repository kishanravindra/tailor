### General

* Helpers for APIs
* Mailers
* Running cron jobs
* Running persistent background jobs
* Console
* Logging
* Fix parsing of parameters from prompt
* More load testing and checks for bugs
* Unit tests
* Make template project have a build stage for copying the Framework into the
  application bundle.
* Make template project have /usr/local/include/mysql in the header path

### Routing and Controllers

* Better CSRF prevention
* Shorthands for restful routes
* Filters for running checks before performing actions
* Easier redirects within controllers
* Rendering other template
* Supporting more input types in forms
* Better handling of trying to respond twice to one request
* Posting via links

### Modelling

* Transactions
* Resetting local database
* Storing seed data
* Fetching relationships
* Setting null values in update
* More complicated query building and collection proxies
* Inferring table names
* Reversing alterations
* Passing hashes when creating records
* Using field names instead of database names in conditions
* Having different connections for different threads

### Authentication

* Validate uniqueness of user email addresses
* Provide limitations on sign-in attempts
* Provide mechanism for resetting passwords
* Provide tracking of IP histories

### Localization

* Storing content / translations in the database
* Localization for countries
* Interpolating values in content
* Fallbacks to default locales
* Inferring locales for templates
* Translating error messages