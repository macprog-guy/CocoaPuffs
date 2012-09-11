
#import <SenTestingKit/SenTestingKit.h>
#import "CAKeyframeAnimation+NUExtensions.h"


@interface CAKeyframeAnimation_NUExtensionsTests : SenTestCase

@end



@implementation CAKeyframeAnimation_NUExtensionsTests

- (void) testNormalizeKeytimesAndValuesWithZeroTime
{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    anim.keyTimes = [NSArray arrayWithObject:[NSNumber numberWithDouble:0.25]];
    anim.values = [NSArray arrayWithObject:[NSNumber numberWithDouble:100.0]];
    [anim normalizeKeytimesAndValuesWithZeroTime:0.0];
    
    STAssertEquals(anim.keyTimes.count, 3ULL, @"There should be 3 key times");
    STAssertEquals([[anim.keyTimes objectAtIndex:0] doubleValue], 0.0, @"First keytime should be 0.0");
    STAssertEquals([anim.keyTimes.lastObject doubleValue], 1.0, @"Last keytime should be 1.0");
    STAssertEquals([[anim.values objectAtIndex:0] doubleValue], 100.0, @"First value should be 100.0");
    STAssertEquals([anim.values.lastObject doubleValue], 100.0, @"Last value should be 100.0");
}

@end
