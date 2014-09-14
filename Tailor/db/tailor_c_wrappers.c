#include "tailor_c_wrappers.h"
#include <string.h>

MYSQL_BIND emptyMysqlBindParam() {
  MYSQL_BIND result;
  
  memset(&result, 0, sizeof(result));
  
  return result;
}

void tailorInvokeSetter(id object, Method method, id value) {
  method_invoke(object, method, value);
}

id tailorInvokeGetter(id object, Method method) {
  return method_invoke(object, method);
}

struct sockaddr_in createSocketAddress(int port) {
  struct sockaddr_in address;
  
  memset(&address, 0, sizeof(address));
  
  address.sin_family = AF_INET;
  address.sin_port = htons(port);
  address.sin_addr.s_addr = htonl(INADDR_ANY);
  
  return address;
}
