#import <SenTestingKit/SenTestingKit.h>
#import "NUFunctions.h"

@interface NUFunctionsTests : SenTestCase
@end



@implementation NUFunctionsTests

- (void) testFClamp
{
    STAssertEquals(fclamp(0.0, 1.2, 2.0), 1.2, @"Value has not been clamped");
    STAssertEquals(fclamp(0.0,-1.2, 2.0), 0.0, @"Value has not been clamped");
    STAssertEquals(fclamp(0.0, 3.4, 2.0), 2.0, @"Value has not been clamped");
}

@end
