#import "TailorC.h"

void tailorInvokeFunction(id object, Method method) {
  typedef void (*functionType)(id, Method);
  functionType function = (functionType)method_invoke;
  return function(object, method);
}