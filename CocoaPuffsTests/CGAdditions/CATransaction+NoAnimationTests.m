
#import <SenTestingKit/SenTestingKit.h>
#import "CocoaPuffs.h"

@interface CATransaction_NoAnimationTests : SenTestCase

@end



@implementation CATransaction_NoAnimationTests

- (void) testWithDisabledAnimation
{
    [CATransaction withDisabledAnimation:^(void) {
        STAssertTrue([CATransaction disableActions], @"Actions should be disabled");
    }];
}

- (void) testWithAnimationDuration
{
    [CATransaction withAnimationDuration:3.14 andBlock:^(void) {
        STAssertEqualsWithAccuracy([CATransaction animationDuration], 3.14, 0.01, @"Animation duration not set correctly");
    }];
}

@end
