
#import "NSBezierPath+NUExtensions.h"
#import "CGAdditions.h"

@implementation NSBezierPath (NUExtensions)


+ (NSBezierPath*) bezierPathWithRect:(CGRect)rect andSides:(int)sides flipped:(BOOL)isFlipped;
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    if (sides & NURectTop) {
        [path moveToPoint:CGRectCornerTL(rect, isFlipped)];
        [path lineToPoint:CGRectCornerTR(rect, isFlipped)];
    }
    
    if (sides & NURectRight) {
        [path moveToPoint:CGRectCornerTR(rect, isFlipped)];
        [path lineToPoint:CGRectCornerBR(rect, isFlipped)];
    }
        
    if (sides & NURectBottom) {
        [path moveToPoint:CGRectCornerBR(rect, isFlipped)];
        [path lineToPoint:CGRectCornerBL(rect, isFlipped)];
    }
    
    if (sides & NURectLeft) {
        [path moveToPoint:CGRectCornerBL(rect, isFlipped)];
        [path lineToPoint:CGRectCornerTL(rect, isFlipped)];
    }
    
    return path;
}


@end
