
#ifndef Tailor_c_wrappers_h
#define Tailor_c_wrappers_h
#include <mysql.h>
#include <objc/message.h>

/**
  This function initializes an empty MySQL bind container.
 
  :returns: The container.
  */
MYSQL_BIND empty_mysql_bind_param();

/**
  This function invokes a property setter dynamically.
 
  :param: object  The receiver of the property
  :param: method  The method container for the setter
  :param: value   The new value to set.
  */
void tailor_invoke_setter(id object, Method method, id value);

/**
  This function invokes a property getter dynamically.
  
  :param: object  The owner of the property
  :param: method  The method container for the property.
  :returns:       The current value for the property.
  */
id tailor_invoke_getter(id object, Method method);

#endif
