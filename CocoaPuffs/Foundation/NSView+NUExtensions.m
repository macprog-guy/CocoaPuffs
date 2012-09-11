
#import "NSView+NUExtensions.h"
#import "CGAdditions.h"

@implementation NSView (NUExtensions)

- (void) recursivelyDisableAutorisizingMaskConstraints;
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    for (NSView *subview in self.subviews)
        [subview recursivelyDisableAutorisizingMaskConstraints];
}

- (NSImage*) bitmapImageForRect:(NSRect)rect
{
    // NOTE: http://www.stairways.com/blog/2009-04-21-nsimage-from-nsview
    
    NSBitmapImageRep *imageRep = [self bitmapImageRepForCachingDisplayInRect:rect];
    [self cacheDisplayInRect:rect toBitmapImageRep:imageRep];
    
    NSImage* image = [[NSImage alloc] initWithSize:imageRep.size];
    [image addRepresentation:imageRep];
    
    return image;
}

- (NSImage*) bitmapImageForVisibleRect
{
    return [self bitmapImageForRect:self.visibleRect];
}

- (NSImage*) bitmapImage
{
    return [self bitmapImageForRect:self.bounds];
}

// COV_NF_START
- (NSPoint) convertPointToScreen:(NSPoint)point
{
    NSScreen *mainScreen = [NSScreen mainScreen];
    
    NSPoint windowPoint = [self convertPoint:point toView:nil];
    CGRect  screenRect  = [self.window convertRectToScreen:CGRectWithOriginAndSize(windowPoint, CGSizeZero)];
    
    screenRect.origin.y = mainScreen.frame.size.height - screenRect.origin.y;
    
    return screenRect.origin;
}

- (NSPoint) convertPoint:(NSPoint)point fromNestedLayer:(CALayer*)layer
{
    return [self convertPointFromLayer:[self.layer convertPoint:point fromLayer:layer]];
}

- (NSRect) convertRect:(NSRect)rect fromNestedLayer:(CALayer*)layer
{
    return [self convertRectFromLayer:[self.layer convertRect:rect fromLayer:layer]];
}

// COV_NF_END

@end
