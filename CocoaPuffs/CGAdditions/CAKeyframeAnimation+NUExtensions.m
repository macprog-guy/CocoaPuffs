
#import "CAKeyframeAnimation+NUExtensions.h"
#import "NSArray+NUExtensions.h"
#import <AVFoundation/AVFoundation.h>


@implementation CAKeyframeAnimation (NUExtensions)

- (void) normalizeKeytimesAndValuesWithZeroTime:(double)zeroTime
{
    NSMutableArray *newKeyTimes = [NSMutableArray arrayWithArray:self.keyTimes];
    NSMutableArray *newValues   = [NSMutableArray arrayWithArray:self.values];
    
    if ([newKeyTimes.firstObject doubleValue] > zeroTime) {
        [newKeyTimes insertObject:@0.0 atIndex:0];
        [newValues insertObject:[newValues objectAtIndex:0] atIndex:0];
    }
    
    if ([newKeyTimes.lastObject doubleValue] != 1.0) {
        [newKeyTimes addObject:@1.0];
        [newValues addObject:newValues.lastObject];
    }
    
    self.keyTimes = newKeyTimes;
    self.values = newValues;
}


@end
