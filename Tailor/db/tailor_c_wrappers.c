#include "tailor_c_wrappers.h"
#include <string.h>

MYSQL_BIND empty_mysql_bind_param() {
  MYSQL_BIND result;
  
  memset(&result, 0, sizeof(result));
  return result;
}

void tailor_invoke_setter(id object, Method method, id value) {
  method_invoke(object, method, value);
}

id tailor_invoke_getter(id object, Method method) {
  return method_invoke(object, method);
}