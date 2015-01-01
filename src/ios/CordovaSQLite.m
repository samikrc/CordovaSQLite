//
//  CordovaSQLite.m
//
//  Created by Samik R on 12/6/12.
//
//

#import "CordovaSQLite.h"

@implementation CordovaSQLite

/*
* Open a database.
* @param fullDBFilePath
*/
- (void) openDatabase: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* fullDBFilePath = [command.arguments objectAtIndex:0];

    if(_myDb != NULL)
    {
        // Close database
        sqlite3_close(_myDb);
    }
    
    const char* path = [fullDBFilePath UTF8String];
    NSLog(@"Opening database: %s", path);
    
    if(sqlite3_open(path, &_myDb) == SQLITE_OK)
    {
        // Return with success.
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Database opened successfully."];
    }
    else
    {
    	// Get the error string.
        NSString* errMsg = [NSString stringWithUTF8String:(char *) sqlite3_errmsg (_myDb)];
        // Return with error.
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errMsg];
    }
    // Return result.
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Exec query to get a single result value.
 * @param query
 * @param args
 * @return result.
 */
- (void) execQuerySingleResult: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    const char* query = [[command.arguments objectAtIndex:0] UTF8String];
    // Create an array of arguments
    NSMutableArray* args = [NSMutableArray array];
    for(NSObject* obj in [command.arguments objectAtIndex:1])
    {   [args addObject:obj];   }
    // Execute query and get results in an array.
    NSArray* result = [self execQuery :query :args :NO];
    // Check result.
    if([(NSString*)[result objectAtIndex:0]  isEqual: @"SUCCESS"])
    {
    	// In this case, we get back one or more arrays.
    	NSString* resultVal = [result objectAtIndex:1];
        // Return with success.
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:resultVal];    	
	}
	else
	{
        // Return with error.
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[result objectAtIndex:1]];    	
	}

    // Return result.
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Execute a query and return a 2D JSON array. Rows are records and columns are data cols.
 * @param query
 * @param args
 * @return result.
 */
- (void) execQueryArrayResult: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    const char* query = [[command.arguments objectAtIndex:0] UTF8String];
    // Create an array of arguments
    NSMutableArray* args = [NSMutableArray array];
    for(NSObject* obj in [command.arguments objectAtIndex:1])
    {   [args addObject:obj];   }
    // Execute query and get results in an array.
    NSArray* result = [self execQuery :query :args :YES];
    // Check result.
    if([(NSString*)[result objectAtIndex:0]  isEqual: @"SUCCESS"])
    {
        // Log result string
        //NSLog(@"Result string: %@", (NSString*)[result objectAtIndex:1]);
        // Return with success.
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[result objectAtIndex:1]];    	
	}
	else
	{
        // Return with error.
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[result objectAtIndex:1]];    	
	}
    // Return result.
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
    
/**
 * Exec a SQLite query.
 * @param query
 * @param args
 * @return result array.
 */
- (NSArray*) execQuery :(const char*)query :(NSArray*) args :(BOOL) toReturnArray
{
	// Notes: NSArray is an array of object which is read-only, can't be changed.
	// NSMutableArray is a subclass of NSArray, where elements can mutate (i.e., change).
	// http://stackoverflow.com/q/8682555/194742
	// http://iphonebyradix.blogspot.com/2010/09/nsarray-and-nsmutablearray.html
	// http://www.icodeblog.com/2009/08/26/objective-c-tutorial-nsarray/
	NSMutableArray* result = [NSMutableArray array];
    /*
    // Log query and arguments.
    NSLog(@"Executing query: %s with arg: ", query);
    for(int i = 0; i < args.count; i++)
    {	NSLog(@"%@", (NSString*)[args objectAtIndex:i]);	}
    */
    
    // Prepare the query and bind arguments.
    sqlite3_stmt *statement;
	if(sqlite3_prepare_v2(_myDb, query, -1, &statement, NULL) == SQLITE_OK)
	{
		// Now bind. Note that the bind arguments are indexed as 1.., not 0..
		// Also note that we are binding all parameters as string.
		NSObject* bindval;
		for(int i = 0; i < args.count; i++)
		{
			bindval = [args objectAtIndex:i];
			if ([bindval isEqual:[NSNull null]])
			{	sqlite3_bind_null(statement, i + 1);	} 
			else 
			{
          		sqlite3_bind_text(statement, i + 1, [[NSString stringWithFormat:@"%@", bindval] UTF8String], -1, SQLITE_TRANSIENT);
        	}
		}
		
		// Now get results.
		BOOL keepGoing = YES;
		int resultType, columnType, colIndex;
		int colCount = sqlite3_column_count(statement);
		int rowCounter = 0;
		// Set status in result array.
        [result addObject:@"SUCCESS"];
        // Create strings for holding the complete result.
		// String manipulation:
		// https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Strings/Articles/CreatingStrings.html 	
		
    	NSString* resultStr = (toReturnArray) ? @"[" : @"";
		while(keepGoing)
		{
			// Now step a row.
			resultType = sqlite3_step (statement);
			switch(resultType)
			{
				case SQLITE_ROW:
                {
                    // Start with appending a comma
                    if(rowCounter > 0)
                    {	resultStr = [resultStr stringByAppendingString:@", "];	}
                    
					// Loop through the columns and create the row string.
					colIndex = 0;
					NSString* rowStr = (toReturnArray) ? @"[" : @"";
					while(colIndex < colCount)
					{
						// Append a comma.
						if(colIndex > 0)
						{	rowStr = [rowStr stringByAppendingString:@", "];	}
						// Check for null column type.
						columnType = sqlite3_column_type(statement, colIndex);
						if(columnType == SQLITE_NULL)							
						{	rowStr = [rowStr stringByAppendingString:@"null"];	}
						else
						{
							NSString* val = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, colIndex)];
                            if(toReturnArray)
                                rowStr = [rowStr stringByAppendingFormat:@"\"%@\"",val];
                            else
                            {
                                rowStr = val;
                                break;
                            }
						}
						colIndex ++;
					}
					if(toReturnArray)
                        rowStr = [rowStr stringByAppendingString:@"]"];
					// Add the row to the result string.
					resultStr = [resultStr stringByAppendingString:rowStr];
		            // Keep adding rows till we have around 7000 characters. Beyond that, we
		            // get a 'Syntax Error' when the result is passed to javascript.
		            // Can possibly go beyond 7000, haven't tried. Gives error at around 12000.
		            if([resultStr length] > 7000 || !toReturnArray)
                        keepGoing = NO;
                    else
                        rowCounter++;
					break;
				}
                    
				case SQLITE_DONE:
				default:
                {
					keepGoing = NO;
					break;
                }
			}
		}
		resultStr = (toReturnArray) ? [resultStr stringByAppendingString:@"]"] : resultStr;
		// Add the result string.
		[result addObject:resultStr];
		sqlite3_finalize(statement);
	}
	else
	{
		// Set status in result array.
        [result addObject:@"ERROR"];
		[result addObject:[NSString stringWithUTF8String:(char *) sqlite3_errmsg (_myDb)]];
	}
	
	return result;
}

/**
 * Execute set of queries which return no value (like insert, update etc.)
 * @param query
 * @param args
 * @return result.
 */
- (void) execQueryNoResult: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    // Execute an array of queries
	sqlite3_stmt *statement;
	NSString* errMessage = nil;
    for(NSObject* obj in [command.arguments objectAtIndex:0])
    {
    	const char* query = [(NSString*)obj UTF8String];
        if(sqlite3_prepare_v2(_myDb, query, -1, &statement, NULL) == SQLITE_OK)
    	{
    		// Execute the statement.
			int resultType = sqlite3_step (statement);
			if(resultType == SQLITE_ERROR)
			{	
				errMessage = [NSString stringWithUTF8String:(char *) sqlite3_errmsg (_myDb)];
				break;	
			}
			else
			{	sqlite3_finalize(statement);	}
		}
    	else
    	{
    		errMessage = [NSString stringWithUTF8String:(char *) sqlite3_errmsg (_myDb)];
			break;    	
		}
	}
	// Set up plugin result.
	if(errMessage == nil)
	{
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
	}
	else
	{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errMessage];
    }
    // Return result.
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Closes a DB safely.
 * @return
 */
- (void) closeDB: (CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    if(_myDb != NULL)
    {
        // Close database
        sqlite3_close(_myDb);
        _myDb = NULL;
    }
	pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    // Return result.
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/**
 * Deallocate override.
 */
- (void)dealloc
{
    if(_myDb != NULL)
    {
        // Close database
        sqlite3_close(_myDb);
        _myDb = NULL;
    }
}

@end
