#ifndef BIND_PARAMETER_H
#define BIND_PARAMETER_H

#import <Foundation/Foundation.h>
#import <mysql.h>

/**
 This class wraps around a MySQL bind parameter.
 
 This does not do memory management on the pointers within the bind parameter.
 We don't have enough information about the lifecycle of the underlying
 parameters inside the MySQL statement. The bind parameter must be released
 separately, either by the initiator or by being kept inside of a
 BindParameterSet.
 */
@interface BindParameter : NSObject {
}

//MARK: - Creation

/**
 This method initializes a parameter that wraps around a raw parameter.
 
 @param parameter   The MySQL bind parameter to wrap around.
 @returns           The newly initialized parameter.
 */
- (nonnull id) initWithParameter:(MYSQL_BIND)parameter;

/**
 This method initializes a parameter with a byte stream that should go in the
 parameter's buffer.
 
 This will allocate the buffer, which must be freed elsewhere.
 
 @param data    The data for the parameter.
 @returns       The newly initialized parameter.
 */
- (nonnull id) initWithData:(nonnull NSData*)data;

/**
  This method initializes an empty parameter for a field.
 
  This will allocate the buffer, which must be freed elsewhere.
 
  @param field   The field
  @returns      The newly initialized parameter.
  */
- (nonnull id) initWithField:(MYSQL_FIELD)field;

//MARK: - Field Information

/** Whether the field is null. */
@property(readonly) BOOL isNull;

/** The buffer for the parameter data. */
@property(nullable, readonly) void* buffer;

/** The length of the data in the buffer. */
@property(readonly) NSUInteger length;

/** The underlying parameter. */
@property(readonly) MYSQL_BIND parameter;

/**
 This method extracts the data from the parameter.
 
 @returns   The underlying data.
 */
- (nullable id) data;

/**
 This method converts a MySQL time object into a Cocoa date object.
 
  @param time   The time object.
  @returns      The date object.
  */
+ (nonnull NSDate*) dateFromTime:(MYSQL_TIME)time;

@end
#endif