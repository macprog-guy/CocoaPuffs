
#import <SenTestingKit/SenTestingKit.h>
#import "CocoaPuffs.h"

@interface NSBezierPath_NUExtensionsTests : SenTestCase

@end

@implementation NSBezierPath_NUExtensionsTests

- (void) testBezierPathWithRect
{
    // Just for code coverage
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:CGRectMake(0, 0, 100, 100)
                                                 andSides:NURectLeft|NURectTop|NURectRight|NURectBottom
                                                  flipped:NO];
    
    STAssertNotNil(path, @"Result should not be nil");
}

@end
