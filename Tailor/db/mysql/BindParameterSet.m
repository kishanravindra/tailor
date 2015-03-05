#import "BindParameterSet.h"
#import "BindParameter.h"

#ifdef TEST_SUITE
#import "TailorTests-Swift.h"
#else
#import <Tailor/Tailor-Swift.h>
#endif

@implementation BindParameterSet {
  MYSQL_BIND* mysqlParameters;
  NSMutableArray* parameters;
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
  parameters = [NSMutableArray array];
  mysqlParameters = calloc(sizeof(MYSQL_BIND), parameterCount);
  for(NSUInteger indexOfParameter = 0; indexOfParameter < parameterCount; indexOfParameter ++) {
    NSData* dataItem = [data objectAtIndex:indexOfParameter];
    BindParameter* parameter = [[BindParameter alloc] initWithData:dataItem];
    mysqlParameters[indexOfParameter] = [parameter parameter];
    [parameters addObject:parameter];
  }
  return self;
}

- (id) initWithResultSet:(nonnull MysqlResultSet*)resultSet {
  self = [super init];
  NSArray* fields = resultSet.fields;
  parameterCount = fields.count;
  parameters = [NSMutableArray array];
  mysqlParameters = calloc(parameterCount, sizeof(MYSQL_BIND));
  
  for(int indexOfParameter = 0; indexOfParameter < parameterCount; indexOfParameter++) {
    MysqlField* field = [fields objectAtIndex:indexOfParameter];
    BindParameter* parameter = [[BindParameter alloc] initWithField:field];
    mysqlParameters[indexOfParameter] = [parameter parameter];
    [parameters addObject:parameter];
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
  return parameters;
}

@end