//
//  TailorC.c
//  Tailor
//
//  Created by John Brownlee on 19/9/14.
//  Copyright (c) 2014 John Brownlee. All rights reserved.
//

#import <stdio.h>
#import "TailorC.h"
#import <string.h>
#import <mysql.h>

MYSQL_BIND emptyMysqlBindParam() {
  MYSQL_BIND result;
  
  memset(&result, 0, sizeof(result));
  
  return result;
}

void tailorInvokeSetter(id object, Method method, id value) {
  typedef void (*setterType)(id, Method, id);
  setterType setter = (setterType)method_invoke;
  setter(object, method, value);
}

id tailorInvokeGetter(id object, Method method) {
  typedef id (*getterType)(id, Method);
  getterType getter = (getterType)method_invoke;
  return getter(object, method);
}

struct sockaddr_in createSocketAddress(int port) {
  struct sockaddr_in address;
  
  memset(&address, 0, sizeof(address));
  
  address.sin_family = AF_INET;
  address.sin_port = htons(port);
  address.sin_addr.s_addr = htonl(INADDR_ANY);
  
  return address;
}
