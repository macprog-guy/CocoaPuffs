#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NUFileAccessExceptionTests : SenTestCase

@end

@implementation NUFileAccessExceptionTests

- (void) testRaiseWithError
{
    NSError *error = nil;
    NSString *text = [NSString stringWithContentsOfFile:@"/" encoding:NSUTF8StringEncoding error:&error];
    
    STAssertNil(text, @"No text should have been returned");
    STAssertNotNil(error, @"Opening the root directory should return an error");
    STAssertThrows([NUFileAccessException raiseWithError:error],@"Should throw an exception");
    
    NUFileAccessException *exception = [[NUFileAccessException alloc] initWithError:error];
    STAssertNotNil(exception, @"Result should not be nil");
    STAssertEqualObjects(exception.name, NUFileAccessExceptionName, @"All such exceptions should have the same name");
    STAssertEqualObjects([exception.userInfo objectForKey:NUFileAccessExceptionErrorKey], error, @"Objects should be identical");
    STAssertEqualObjects(exception.error, error, @"Objects should be identical");
}

@end
