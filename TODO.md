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

### Routing and Controllers

* Better CSRF prevention
* Easier redirects within controllers
* Supporting more input types in forms
* Better handling of trying to respond twice to one request
* Posting via links

### Modelling

* Transactions
* Resetting local database
* Storing seed data
* Fetching relationships
* More complicated query building and collection proxies
* Reversing alterations
* Passing hashes when creating records
* Using field names instead of database names in conditions

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