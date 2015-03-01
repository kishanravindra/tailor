#include <string.h>
#include <objc/message.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <Foundation/Foundation.h>

@import mysql;

/**
 This function invokes a property setter dynamically.
 
 :param: object  The receiver of the property
 :param: method  The method container for the setter
 :param: value   The new value to set.
 */
void tailorInvokeSetter(__nonnull id object, __nonnull Method method, __nullable id value);

/**
 This function invokes a property getter dynamically.
 
 :param: object  The owner of the property
 :param: method  The method container for the property.
 :returns:       The current value for the property.
 */
__nullable id tailorInvokeGetter(__nonnull id object, __nonnull Method method);

/**
  This function invokes a function with no arguments or return values.
 
  :param: object  The object to call the functio on.
  :param: method  The method for the function.
*/
void tailorInvokeFunction(__nonnull id object, __nonnull Method method);

/**
 This function creates a socket address for a connection on a port.
 
 :param: port    The port to open.
 :returns:       The socket address.
 */
struct sockaddr_in createSocketAddress(int port);