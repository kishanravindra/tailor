#import "BindParameter.h"
#ifdef TEST_SUITE
#import "TailorTests-Swift.h"
#else
#import <Tailor/Tailor-Swift.h>
#endif

@implementation BindParameter {
  MYSQL_BIND parameter;
  NSString* fieldName;
}

//MARK: - Creation

- (id) init {
  self = [super init];
  
  memset(&parameter, 0, sizeof(parameter));
  fieldName = nil;
  
  return self;
}

- (nonnull id) initWithParameter:(MYSQL_BIND)aParameter {
  self = [super init];
  parameter = aParameter;
  return self;
}

- (id) initWithField:(MYSQL_FIELD)field {
  self = [self init];
  
  enum enum_field_types bufferType = field.type;
  size_t unitSize = sizeof(UInt8);
  size_t count = 1;
  
  switch(field.type) {
    case MYSQL_TYPE_TINY:
      unitSize = sizeof(char);
      break;
    case MYSQL_TYPE_SHORT:
      unitSize = sizeof(short);
      break;
    case MYSQL_TYPE_LONG:
    case MYSQL_TYPE_INT24:
      unitSize = sizeof(int);
      break;
    case MYSQL_TYPE_LONGLONG:
      unitSize = sizeof(long long);
      break;
    case MYSQL_TYPE_FLOAT:
      unitSize = sizeof(float);
      break;
    case MYSQL_TYPE_DOUBLE:
      unitSize = sizeof(double);
      break;
    case MYSQL_TYPE_TIME:
    case MYSQL_TYPE_DATE:
    case MYSQL_TYPE_DATETIME:
    case MYSQL_TYPE_TIMESTAMP:
      unitSize = sizeof(MYSQL_TIME);
      break;
    case MYSQL_TYPE_TINY_BLOB:
      count = 1 << 8;
      break;
    case MYSQL_TYPE_BLOB:
      count = 1 << 16;
      break;
    case MYSQL_TYPE_MEDIUM_BLOB:
      count = 1 << 24;
      break;
    case MYSQL_TYPE_LONG_BLOB:
      count = 1 << 31;
      break;
    default:
      bufferType = MYSQL_TYPE_STRING;
      count = 1024;
      break;
  }
  
  void* buffer = calloc(count, unitSize);
  parameter.buffer = buffer;
  parameter.buffer_type = bufferType;
  parameter.buffer_length = (UInt)count;
  
  parameter.length = malloc(sizeof(NSInteger));
  parameter.is_null = malloc(sizeof(my_bool));
  parameter.error = malloc(sizeof(my_bool));
  
  return self;
}

- (id) initWithData:(NSData*)data {
  self = [self init];
  
  parameter.buffer = [[data mutableCopy] mutableBytes];
  parameter.buffer_length = data.length;
  parameter.buffer_type = MYSQL_TYPE_STRING;
  
  return self;
}

//MARK: - Field Information

- (BOOL) isNull {
  return *parameter.is_null != 0;
}

- (void*) buffer {
  return parameter.buffer;
}

- (NSUInteger) length {
  return *parameter.length;
}

- (MYSQL_BIND) parameter {
  return parameter;
}

- (id) data {
  
  if(self.isNull) {
    return nil;
  }
  
  switch(self.parameter.buffer_type) {
    case MYSQL_TYPE_TINY:
      return [NSNumber numberWithInt: *((char*)self.buffer)];
    case MYSQL_TYPE_SHORT:
      return [NSNumber numberWithInt:*((short*)self.buffer)];
    case MYSQL_TYPE_LONG:
    case MYSQL_TYPE_INT24:
      return [NSNumber numberWithInt:*((int*)self.buffer)];
    case MYSQL_TYPE_LONGLONG:
      return [NSNumber numberWithLongLong:*((long long*)self.buffer)];
    case MYSQL_TYPE_FLOAT:
      return [NSNumber numberWithFloat:*((float*)self.buffer)];
    case MYSQL_TYPE_DOUBLE:
      return [NSNumber numberWithDouble:*((double*)self.buffer)];
    case MYSQL_TYPE_TIME:
    case MYSQL_TYPE_DATE:
    case MYSQL_TYPE_DATETIME:
    case MYSQL_TYPE_TIMESTAMP:
      return [BindParameter dateFromTime:  *((MYSQL_TIME*)self.buffer)];
    case MYSQL_TYPE_TINY_BLOB:
    case MYSQL_TYPE_BLOB:
    case MYSQL_TYPE_MEDIUM_BLOB:
    case MYSQL_TYPE_LONG_BLOB:
      return [[NSData alloc] initWithBytes: self.buffer length:self.length];
    default:
      return [[NSString alloc] initWithBytes: self.buffer length:self.length encoding: NSUTF8StringEncoding];
  }
}

+ (NSDate*) dateFromTime:(MYSQL_TIME)time {
  NSDateComponents* components = [[NSDateComponents alloc] init];
  components.year = time.year;
  components.month = time.month;
  components.day = time.day;
  components.hour = time.hour;
  components.minute = time.minute;
  components.second = time.second;
  components.timeZone = [[DatabaseConnection sharedConnection] timeZone];
  
  NSCalendar* calendar = [NSCalendar currentCalendar];
  NSDate* date = [calendar dateFromComponents:components];
  return date;
}
@end
