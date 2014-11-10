//
//  TailorC.h
//  TailorC
//
//  Created by John Brownlee on 19/9/14.
//  Copyright (c) 2014 John Brownlee. All rights reserved.
//

#include <string.h>
#include <objc/message.h>
#include <netinet/in.h>
#include <sys/socket.h>
@import mysql;


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
  This function invokes a function with no arguments or return values.
 
  :param: object  The object to call the functio on.
  :param: method  The method for the function.
*/
void tailorInvokeFunction(id object, Method method);

/**
 This function creates a socket address for a connection on a port.
 
 :param: port    The port to open.
 :returns:       The socket address.
 */
struct sockaddr_in createSocketAddress(int port);

/**
 This function initializes an empty MySQL bind container.
 
 :returns: The container.
 */

MYSQL_BIND emptyMysqlBindParam();