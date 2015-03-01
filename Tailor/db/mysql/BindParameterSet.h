#import <Foundation/Foundation.h>
@import mysql;

/**
 This class represents a set of bind parameters being passed to a MySQL
 statement.
 */
@interface BindParameterSet: NSObject {
  
}

//MARK: - Creation

/**
 This method initializes a parameter set with empty parameters for a statement.

 @param statement   The statement that these parameters are for.
 @returns           The newly initialized parameter set.
 */
- (nonnull id) initWithStatement:(nonnull MYSQL_STMT*)statement;

/**
 This method initializes a parameter set with data for the buffer.
 
 @param parameterData   The data for the parameters.
 @returns               The newly initialized parameter set.
 */
- (nonnull id) initWithData:(nonnull NSArray*)parameterData;

//MARK: - Binding

/**
 This method sets this parameter set as the input parameters for a statement.
 
 @param statement   The statement.
 */
- (void) bindToInputOfStatement:(nonnull MYSQL_STMT*)statement;

/**
 This method sets this parameter set as the output parameters for a statement.
 
 @param statement   The statement.
 */
- (void) bindToOutputOfStatement:(nonnull MYSQL_STMT*)statement;

//MARK: - Data Accesss

/**
 This method gets an array of parameters.
 
 Each one will be a BindParameter.
 
 @returns   The parameters
 */
- (nonnull NSArray*) parameters;
@end