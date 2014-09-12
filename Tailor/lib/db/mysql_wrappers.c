#include "mysql_wrappers.h"
#include <string.h>

MYSQL_BIND empty_mysql_bind_param() {
  MYSQL_BIND result;
  
  memset(&result, 0, sizeof(result));
  return result;
}
