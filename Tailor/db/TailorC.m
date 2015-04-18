#import <stdio.h>
#import "TailorC.h"
#import <string.h>
#import <mysql.h>

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