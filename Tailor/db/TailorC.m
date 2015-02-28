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

@implementation BindParameter {
  MYSQL_BIND parameter;
}

- (id) init {
  self = [super init];
  
  memset(&parameter, 0, sizeof(parameter));
  
  return self;
}

- (nonnull id) initWithParameter:(MYSQL_BIND)aParameter {
  self = [super init];
  parameter = aParameter;
  return self;
}

- (id) initWithType:(MYSQL_FIELD)type {
  self = [self init];
  
  enum enum_field_types bufferType = type.type;
  size_t unitSize = sizeof(UInt8);
  size_t count = 1;
  
  NSLog(@"Initializing with buffer type: %i", bufferType);
  
  switch(type.type) {
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
  NSLog(@"Using buffer type string: %i", parameter.buffer_type);
  
  return self;
}

- (BOOL) isNull {
  return *parameter.is_null != 0;
}

- (void*) buffer {
  return parameter.buffer;
}

- (NSInteger) length {
  return *parameter.length;
}

- (MYSQL_BIND) parameter {
  return parameter;
}
@end

@implementation BindParameterSet {
  MYSQL_BIND* mysqlParameters;
  NSUInteger parameterCount;
}

- (id) init {
  self = [super init];
  mysqlParameters = NULL;
  parameterCount = 0;
  return self;
}

- (id) initWithData:(nonnull NSArray*)data {
  self = [super init];
  parameterCount = data.count;
  mysqlParameters = calloc(sizeof(MYSQL_BIND), parameterCount);
  for(NSUInteger indexOfParameter = 0; indexOfParameter < parameterCount; indexOfParameter ++) {
    NSData* dataItem = [data objectAtIndex:indexOfParameter];
    mysqlParameters[indexOfParameter] = [[[BindParameter alloc] initWithData:dataItem] parameter];
  }
  return self;
}

- (id) initWithStatement:(nonnull MYSQL_STMT *)statement {
  self = [super init];
  
  MYSQL_RES* metadataResult = mysql_stmt_result_metadata(statement);
  if(metadataResult == nil) {
    parameterCount = 0;
    mysqlParameters = NULL;
    return self;
  }
  
  parameterCount = mysql_num_fields(metadataResult);
  mysqlParameters = calloc(parameterCount, sizeof(MYSQL_BIND));
  
  for(int indexOfParameter = 0; indexOfParameter < parameterCount; indexOfParameter++) {
    MYSQL_FIELD* fieldType = mysql_fetch_field_direct(metadataResult, (UInt32)indexOfParameter);
    mysqlParameters[indexOfParameter] = [[[BindParameter alloc] initWithType:*fieldType] parameter];
  }
  
  return self;
}

- (void) dealloc {
  if(mysqlParameters != NULL && false) {
    for(NSUInteger indexOfParameter = 0; indexOfParameter < parameterCount; indexOfParameter ++) {
      MYSQL_BIND parameter = mysqlParameters[indexOfParameter];
      
      free(parameter.buffer);
      free(parameter.is_null);
      free(parameter.length);
      free(parameter.error);
    }
    free(mysqlParameters);
  }
}

- (void) bindToInputOfStatement:(nonnull MYSQL_STMT*)statement {
  mysql_stmt_bind_param(statement, mysqlParameters);
}

- (void) bindToOutputOfStatement:(nonnull MYSQL_STMT *)statement {
  mysql_stmt_bind_result(statement, mysqlParameters);
}

- (nonnull NSArray*) parameters {
  NSMutableArray* parameters = [[NSMutableArray alloc] initWithCapacity:parameterCount];
  for(NSUInteger indexOfParameter = 0; indexOfParameter < parameterCount; indexOfParameter++) {
    [parameters addObject:[[BindParameter alloc] initWithParameter: mysqlParameters[indexOfParameter]]];
  }
  return parameters;
}

@end