#import <stdio.h>
#import "TailorC.h"
#import <string.h>
#import <mysql.h>

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

void tailorInvokeFunction(id object, Method method) {
  typedef void (*functionType)(id, Method);
  functionType function = (functionType)method_invoke;
  return function(object, method);
}

struct sockaddr_in createSocketAddress(int port) {
  struct sockaddr_in address;
  
  memset(&address, 0, sizeof(address));
  
  address.sin_family = AF_INET;
  address.sin_port = htons(port);
  address.sin_addr.s_addr = htonl(INADDR_ANY);
  
  return address;
}