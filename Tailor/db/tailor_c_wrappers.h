#ifndef Tailor_c_wrappers_h
#define Tailor_c_wrappers_h
#include <mysql.h>
#include <objc/message.h>
#include <netinet/in.h>
#include <sys/socket.h>

/**
  This function initializes an empty MySQL bind container.
 
  :returns: The container.
  */
MYSQL_BIND emptyMysqlBindParam();

/**
  This function invokes a property setter dynamically.
 
  :param: object  The receiver of the property
  :param: method  The method container for the setter
  :param: value   The new value to set.
  */
void tailorInvokeSetter(id object, Method method, id value);

/**
  This function invokes a property getter dynamically.
  
  :param: object  The owner of the property
  :param: method  The method container for the property.
  :returns:       The current value for the property.
  */
id tailorInvokeGetter(id object, Method method);

/**
  This function creates a socket address for a connection on a port.
 
  :param: port    The port to open.
  :returns:       The socket address.
  */
struct sockaddr_in createSocketAddress(int port);

#endif
