#include <objc/message.h>

/**
  This function invokes a function with no arguments or return values.
 
  :param: object  The object to call the functio on.
  :param: method  The method for the function.
*/
void tailorInvokeFunction(__nonnull id object, __nonnull Method method);