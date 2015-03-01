#import "BindParameterSet.h"
#import "BindParameter.h"

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
    MYSQL_FIELD* field = mysql_fetch_field_direct(metadataResult, (UInt32)indexOfParameter);
    mysqlParameters[indexOfParameter] = [[[BindParameter alloc] initWithField:*field] parameter];
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