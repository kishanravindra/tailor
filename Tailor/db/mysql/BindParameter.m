#import "BindParameter.h"
#ifdef TEST_SUITE
#import "TailorTests-Swift.h"
#else
#import <Tailor/Tailor-Swift.h>
#endif

@implementation BindParameter {
  MYSQL_BIND parameter;
  BOOL binary;
  NSString* fieldName;
}

//MARK: - Creation

- (id) init {
  self = [super init];
  
  memset(&parameter, 0, sizeof(parameter));
  fieldName = nil;
  binary = NO;
  
  return self;
}

- (nonnull id) initWithParameter:(MYSQL_BIND)aParameter {
  self = [super init];
  parameter = aParameter;
  return self;
}

- (id) initWithField:(MysqlField*)field {
  self = [self init];
  
  void* buffer = calloc(field.bufferLength, field.bufferSize);
  parameter.buffer = buffer;
  parameter.buffer_type = field.bufferType;
  parameter.buffer_length = (UInt)field.bufferLength;
  
  parameter.length = malloc(sizeof(NSInteger));
  parameter.is_null = malloc(sizeof(my_bool));
  parameter.error = malloc(sizeof(my_bool));
  
  binary = field.isBinary;
  
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
      if(binary) {
        return [[NSData alloc] initWithBytes: self.buffer length:self.length];
      }
      else {
        return [[NSString alloc] initWithBytes: self.buffer length:self.length encoding: NSUTF8StringEncoding];
      }
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
