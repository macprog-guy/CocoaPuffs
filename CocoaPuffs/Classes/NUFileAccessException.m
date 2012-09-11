#import "NUFileAccessException.h"


NSString *NUFileAccessExceptionName = @"File Access Exception";
NSString *NUFileAccessExceptionErrorKey = @"NUFileAccessException_error";

@implementation NUFileAccessException

- (id) initWithError:(NSError*)anError
{
    return [super initWithName:NUFileAccessExceptionName 
                             reason:anError.localizedDescription 
                           userInfo:@{NUFileAccessExceptionErrorKey: anError}];
}

//
// NOTE: Our unit tests calls raiseWithError: but coverage files does not show this.
//       We remove the noise by marking it as "non-feasable"
//
// COV_NF_START
//
+ (id) raiseWithError:(NSError*)anError
{
    NUFileAccessException *fileAccessException = [[self alloc] initWithError:anError];
    [fileAccessException raise];
    return fileAccessException;
}
// COV_NF_END

- (NSError*) error
{
    return [self.userInfo objectForKey:NUFileAccessExceptionErrorKey];
}

@end
