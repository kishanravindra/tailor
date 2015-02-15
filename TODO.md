### General

* Mailers
* Running cron jobs
* Running persistent background jobs
* Console
* Logging
* Fix parsing of spaces in parameters from Xcode prompt
* More load testing and checks for bugs
* Make template project have a build stage for copying the Framework into the
  application bundle.
* Shorthands for date arithmetic
* Caching
* Clarify language surrounding URLs vs paths in routing
* Reduce use of global variables

### Routing and Controllers

* Better CSRF prevention
* Supporting select tags, checkboxes, etc in forms

### Modelling

* Resetting local database
* Storing seed data
* Reversing alterations
* Getting last item from a query

### Authentication

* Validate uniqueness of user email addresses
* Validate presence of password
* Allowing to set password outside of constructor
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

### Testing

* Helpers for common test patterns
* Assertions for HTML content
* Truncating tables when running tests