
#import "NUSplitbarView.h"
#import "NUDelegatingView.h"

@interface NUSplitbarView() {
    CGPoint mouseDownPoint;
    CGRect  originalFrame;
    double  savedBarPosition;
    NUDelegatingView *barView;
}
- (void) resizeViewsWithBarPosition:(CGFloat)position;
@end


@implementation NUSplitbarView  // COV_NF_LINE

@synthesize aboveView, belowView;

// -----------------------------------------------------------------------------
   #pragma mark Init & Dealloc
// -----------------------------------------------------------------------------

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.autoresizesSubviews = YES;
    }
    
    return self;
}



// -----------------------------------------------------------------------------
   #pragma mark Properites
// -----------------------------------------------------------------------------

- (NUDelegatingView*) barView
{
    return barView;
}

- (void) setBarView:(NUDelegatingView *)value
{
    barView.delegate = nil;
    barView = value;
    barView.delegate = self;
}

- (BOOL) belowViewIsCollapsed
{
    return (barView.frame.origin.y == 0.0);
}

- (void) setBelowViewIsCollapsed:(BOOL)value
{
    if (value != self.belowViewIsCollapsed) {
        if (value) {
            savedBarPosition = barView.frame.origin.y;
            [self resizeViewsWithBarPosition:0.0];
        } else {
            [self resizeViewsWithBarPosition:savedBarPosition];
            savedBarPosition = 0.0;
        }
    }
}



// -----------------------------------------------------------------------------
   #pragma mark Resizing
// -----------------------------------------------------------------------------

- (void) resizeViewsWithBarPosition:(CGFloat)position
{
    if (position==0.0 || barView.frame.origin.y==0.0)
        [self willChangeValueForKey:@"belowViewIsCollapsed"];
    
    CGRect bounds = self.bounds;
    CGRect frame  = barView.frame;
    
    frame.origin.y   = position;
    frame.size.width = bounds.size.width;

    aboveView.frame = CGRectMake(0, CGRectGetMaxY(frame), frame.size.width, bounds.size.height - CGRectGetMaxY(frame));
    barView.frame   = frame;
    belowView.frame = CGRectMake(0, 0, frame.size.width, frame.origin.y);

    if (position==0.0 || barView.frame.origin.y==0.0)
        [self didChangeValueForKey:@"belowViewIsCollapsed"];
}

- (void) resizeSubviewsWithOldSize:(NSSize)oldSize
{
    [self resizeViewsWithBarPosition:barView.frame.origin.y];
    [barView setNeedsDisplay:YES];
}

// -----------------------------------------------------------------------------
   #pragma mark Delegated Mouse Events
// -----------------------------------------------------------------------------

// COV_NF_START

- (void) view:(NSView*)aView mouseDown:(NSEvent *)theEvent
{
    mouseDownPoint = [self.superview convertPoint:theEvent.locationInWindow fromView:nil];
    originalFrame  = aView.frame;
}

- (void) view:(NSView*)aView mouseDragged:(NSEvent *)theEvent
{
    /*
     
     Here we assume that we have a horizontal splitbar, which would mean 
     that the view above, the splitbar and below views are stacked 
     vertically. When we change our frame we need to update the frames 
     of all three subviews.
     
     NOTE: using integral rects will ensure that are top and bottom lines
           are always black and not fuzzy gray due to the line being drawn
           between two pixel lines.
     
           The coordinate system of the NSSplitView subview is flipped.
     */
    CGPoint mouseDragPoint = [self.superview convertPoint:theEvent.locationInWindow fromView:nil];
    CGFloat dy = mouseDownPoint.y - mouseDragPoint.y;
    
    CGRect  bounds = aView.superview.bounds; 
    CGRect  frame  = CGRectOffset(originalFrame, 0, dy);
    CGFloat maxY   = bounds.size.height - originalFrame.size.height;
    
    if (frame.origin.y < 0)
        frame.origin.y = 0;
    
    if (frame.origin.y > maxY)
        frame.origin.y = maxY;
    
    frame = CGRectIntegral(frame);
    
    // For some reason after the updateConstraints the frame height becomes 27
    // instead of the normal 26. So we compare origins instead of the whole 
    // frame to avoid flickering and redraw issues.
    //
    // Remove the IF condition and drag the splitbar horizontally to see the
    // redraw issues.
    //
    if (! CGPointEqualToPoint(frame.origin, self.frame.origin)) {
        [self resizeViewsWithBarPosition:frame.origin.y];
    }
}

// -----------------------------------------------------------------------------
   #pragma mark Delegated Cursor Management
// -----------------------------------------------------------------------------

- (void) viewResetCursorRects:(NSView*)aView 
{
    NSCursor *resizeCursor = [NSCursor resizeUpDownCursor];
    NSCursor *normalCursor = [NSCursor arrowCursor];
    
    [aView addCursorRect:aView.bounds cursor:resizeCursor];
    
    for (NSView *subview in aView.subviews) {
        [aView addCursorRect:subview.frame cursor:normalCursor];
    }
}


// -----------------------------------------------------------------------------
   #pragma Drawing
// -----------------------------------------------------------------------------

- (void) view:(NSView*)view drawRect:(NSRect)dirtyRect
{
    if (view == barView) {
        
        CGRect bounds = view.bounds;
        
        NSColor *color1 = [NSColor colorWithCalibratedWhite:0.74 alpha:1.0];
        NSColor *color2 = [NSColor colorWithCalibratedWhite:0.84 alpha:1.0];
        
        NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:color1 endingColor:color2];
        [gradient drawInRect:bounds angle:90];
        
        NSBezierPath *rectPath = [NSBezierPath bezierPath];
        
        [rectPath moveToPoint:CGPointZero];
        [rectPath relativeLineToPoint:CGPointMake(bounds.size.width, 0)];
        [rectPath moveToPoint:CGPointMake(0, bounds.size.height)];
        [rectPath relativeLineToPoint:CGPointMake(bounds.size.width, 0)];
        [rectPath setLineWidth: 1];
        [rectPath setLineJoinStyle: NSBevelLineJoinStyle];
        
        [[NSColor blackColor] set];
        [rectPath stroke];
    }
}

// COV_NF_END

@end
