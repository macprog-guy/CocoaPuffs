
#import "CATransaction+NoAnimation.h"

@implementation CATransaction (NoAnimationTransaction)

+ (void) withDisabledAnimation:(void(^)(void)) block
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    block();
    
    [CATransaction commit];
}

+ (void) withAnimationDuration:(float)time andBlock:(void(^)(void))block
{
    [CATransaction begin];
    [CATransaction setValue:@(time) 
                     forKey:kCATransactionAnimationDuration];
    
    block();
    
    [CATransaction commit];
}


@end
