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

@interface BindParameter : NSObject {
  
}

- (nonnull id) initWithParameter:(MYSQL_BIND)parameter;
- (nonnull id) initWithData:(nonnull NSData*)data;
- (nonnull id) initWithType:(MYSQL_FIELD)type;
- (BOOL) isNull;
- (nullable void*) buffer;
- (NSInteger) length;

- (MYSQL_BIND) parameter;
@end

@interface BindParameterSet: NSObject {
  
}
- (nonnull id) initWithStatement:(nonnull MYSQL_STMT*)statement;
- (nonnull id) initWithData:(nonnull NSArray*)parameterData;
- (void) bindToInputOfStatement:(nonnull MYSQL_STMT*)statement;
- (void) bindToOutputOfStatement:(nonnull MYSQL_STMT*)statement;
- (nonnull NSArray*) parameters;
@end