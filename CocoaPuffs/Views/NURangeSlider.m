
#import "NURangeSlider.h"
#import <CocoaPuffs/CocoaPuffs.h>

static double kGrooveHeight =  4.0;
static double kRangeHeight  =  8.0;
static double kKnobWidth    = 14.0;
static double kKnobHeight   = 14.0;
static double kKnobZero     = 16.0;

@interface NURangeSlider() {
    
    CGPoint mouseDownPoint;
    double  mouseDragValue;
    double  mouseDownOffsetToKnobEdge;
    
    NSTrackingRectTag trackingTag;
    
    struct {
        BOOL isUpdating:1;
        BOOL isDraggingLeftBound:1;
        BOOL isDraggingRange:1;
        BOOL isDraggingRightBound:1;
        BOOL isDraggingSomething:1;
        BOOL tracksKnobVisibility:1;
        BOOL visibleKnobs:1;
    } flags;
}
@end

static inline double rounded(double value, double rounding) {
    return round(value/rounding) * rounding;
}

@implementation NURangeSlider

// -----------------------------------------------------------------------------
   #pragma mark Synthesized Properties
// -----------------------------------------------------------------------------

@synthesize absoluteMinimum, absoluteMaximum;
@synthesize rangeMinimum, rangeMaximum;
@synthesize rounding;

// -----------------------------------------------------------------------------
   #pragma mark Init & Dealloc
// -----------------------------------------------------------------------------

- (void) commonInit
{
    absoluteMinimum = 0.0;
    absoluteMaximum = 1.0;
    rangeMinimum = 0.0;
    rangeMaximum = 1.0;
    rounding = 0.01;
    self.canDrawConcurrently = YES;
}

- (id) initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect])) {
        [self commonInit];
    }
    return self;
}


// -----------------------------------------------------------------------------
   #pragma mark NSCoding
// -----------------------------------------------------------------------------

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
        self.absoluteMinimum = [aDecoder decodeDoubleForKey:@"NURangeSlider_absoluteMinimum"];
        self.absoluteMaximum = [aDecoder decodeDoubleForKey:@"NURangeSlider_absoluteMaximum"];
        self.rangeMinimum = [aDecoder decodeDoubleForKey:@"NURangeSlider_rangeMinimum"];
        self.rangeMaximum = [aDecoder decodeDoubleForKey:@"NURangeSlider_rangeMaximum"];
        self.rounding = [aDecoder decodeDoubleForKey:@"NURangeSlider_rounding"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeDouble:self.absoluteMinimum forKey:@"NURangeSlider_absoluteMinimum"];
    [aCoder encodeDouble:self.absoluteMaximum forKey:@"NURangeSlider_absoluteMaximum"];
    [aCoder encodeDouble:self.rangeMinimum forKey:@"NURangeSlider_rangeMinimum"];
    [aCoder encodeDouble:self.rangeMaximum forKey:@"NURangeSlider_rangeMaximum"];
    [aCoder encodeDouble:self.rounding forKey:@"NURangeSlider_rounding"];
}


// -----------------------------------------------------------------------------
   #pragma mark Properties
// -----------------------------------------------------------------------------

- (void) setAbsoluteMinimum:(double)value
{
    absoluteMinimum = rounded(value,rounding);
 
    if (! flags.isUpdating) {
        flags.isUpdating = YES;
        
        if (absoluteMinimum > absoluteMaximum)
            [self setValue:@(absoluteMinimum) forPotentiallyBoundKeyPath:@"absoluteMaximum"];
        
        if (rangeMinimum < absoluteMinimum)
            [self setValue:@(absoluteMinimum) forPotentiallyBoundKeyPath:@"rangeMinimum"];
        
        if (rangeMaximum < absoluteMinimum)
            [self setValue:@(absoluteMinimum) forPotentiallyBoundKeyPath:@"rangeMaximum"];
        
        flags.isUpdating = NO;
    }

    [self setNeedsDisplay:YES];
}

- (void) setAbsoluteMaximum:(double)value
{
    absoluteMaximum = value;
    
    if (! flags.isUpdating) {
        flags.isUpdating = YES;

        if (absoluteMaximum < absoluteMinimum)
            [self setValue:@(absoluteMaximum) forPotentiallyBoundKeyPath:@"absoluteMinimum"];
        
        if (rangeMinimum > absoluteMaximum)
            [self setValue:@(absoluteMaximum) forPotentiallyBoundKeyPath:@"rangeMinimum"];
        
        if (rangeMaximum > absoluteMaximum)
            [self setValue:@(absoluteMaximum) forPotentiallyBoundKeyPath:@"rangeMaximum"];

        flags.isUpdating = NO;
    }
    
    [self setNeedsDisplay:YES];
}

- (void) setRangeMinimum:(double)value
{
    value = rounded(value, rounding);
    
    if (! flags.isUpdating) {
        if (value < absoluteMinimum)
            value = absoluteMinimum;
        else if (value >= rangeMaximum)
            value = rangeMaximum;
    }
    
    rangeMinimum = value;
    
    [self setNeedsDisplay:YES];
}

- (void) setRangeMaximum:(double)value
{
    value = rounded(value, rounding);

    if (! flags.isUpdating) {
        if (value > absoluteMaximum)
            value = absoluteMaximum;
        else if (value <= rangeMinimum)
            value = rangeMinimum;
    }
    
    rangeMaximum = value;
    
    [self setNeedsDisplay:YES];
}

- (BOOL) tracksKnobVisibility
{
    return (flags.tracksKnobVisibility != 0);
}

- (void) setTracksKnobVisibility:(BOOL)value
{
    flags.tracksKnobVisibility = value;
    
    if (flags.tracksKnobVisibility) {
        trackingTag = [self addTrackingRect:self.bounds owner:self userData:NULL assumeInside:NO];
    } else {
        [self removeTrackingRect:trackingTag];
    }
}



// -----------------------------------------------------------------------------
   #pragma mark Helpers
// -----------------------------------------------------------------------------

// COV_NF_START

- (double) valueForMousePoint:(CGPoint)point
{
    double range  = absoluteMaximum - absoluteMinimum;
    double width  = self.bounds.size.width - kKnobZero*2;
    double ratio = (point.x - kKnobZero)/width;
    
    if (ratio < 0.0)
        ratio = 0.0;
    else if (ratio > 1.0)
        ratio = 1.0;
    
    return absoluteMinimum + range * ratio;
}

- (CGRect) rectForValue:(double)value
{
    double range  = absoluteMaximum - absoluteMinimum;
    double width  = self.bounds.size.width - kKnobZero*2;
    double ratio = (range > 0.0)? value/range : 0.0;

    if (ratio < 0.0)
        ratio = 0.0;
    else if (ratio > 1.0)
        ratio = 1.0;

    CGRect rect = CGRectMake(0, 0, kKnobWidth, kKnobHeight);
    rect.origin.x = kKnobZero + width * ratio - kKnobWidth/2.0;
    rect.origin.y = (self.bounds.size.height - kKnobHeight)/2.0;
    
    return rect;
}


// -----------------------------------------------------------------------------
   #pragma mark Mouse Events
// -----------------------------------------------------------------------------

- (void) mouseEntered:(NSEvent *)theEvent
{
    flags.visibleKnobs = YES;
    [self setNeedsDisplay:YES];
}

- (void) mouseExited:(NSEvent *)theEvent
{
    flags.visibleKnobs = NO;
    [self setNeedsDisplay:YES];
}

- (void) mouseDown:(NSEvent *)theEvent
{
    mouseDownPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
    mouseDragValue = [self valueForMousePoint:mouseDownPoint];
    
    CGRect minRect = CGRectOffset([self rectForValue:rangeMinimum], -kKnobWidth/2.0, 0.0);
    CGRect maxRect = CGRectOffset([self rectForValue:rangeMaximum],  kKnobWidth/2.0, 0.0);
    CGRect allRect = CGRectUnion(minRect, maxRect);

    flags.isDraggingLeftBound  = CGRectContainsPoint(minRect, mouseDownPoint);
    flags.isDraggingRange      = CGRectContainsPoint(allRect, mouseDownPoint);
    flags.isDraggingRightBound = CGRectContainsPoint(maxRect, mouseDownPoint);
    flags.isDraggingSomething  = flags.isDraggingLeftBound || flags.isDraggingRange || flags.isDraggingRightBound;
    
    if (flags.isDraggingLeftBound || flags.isDraggingRightBound)
        flags.isDraggingRange = NO;
    
    if (flags.isDraggingLeftBound)  // Edge is on the right of the knob.
        mouseDownOffsetToKnobEdge = minRect.size.width - (mouseDownPoint.x - minRect.origin.x);
    else if (flags.isDraggingRightBound) // Edge is on the left of the knob.
        mouseDownOffsetToKnobEdge = maxRect.origin.x - mouseDownPoint.x;
    else if (flags.isDraggingRange)
        mouseDownOffsetToKnobEdge = 0;
}

- (void) mouseDragged:(NSEvent *)theEvent
{
    if (flags.isDraggingSomething) {
        
        CGPoint mouseDragPoint = [self convertPoint:theEvent.locationInWindow fromView:nil];
        mouseDragPoint.x += mouseDownOffsetToKnobEdge;
        double value = [self valueForMousePoint:mouseDragPoint];
        
        if (flags.isDraggingLeftBound && value!=rangeMinimum) {
            [self setValue:@(value) forPotentiallyBoundKeyPath:@"rangeMinimum"];
        } else if (flags.isDraggingRightBound && value!=rangeMaximum) {
            [self setValue:@(value) forPotentiallyBoundKeyPath:@"rangeMaximum"];
        } else if (flags.isDraggingRange && value!=mouseDragValue) {
            double delta = value - mouseDragValue;
            [self setValue:@(rangeMinimum+delta) forPotentiallyBoundKeyPath:@"rangeMinimum"];
            [self setValue:@(rangeMaximum+delta) forPotentiallyBoundKeyPath:@"rangeMaximum"];
            mouseDragValue = value;
        }
    }
}

// -----------------------------------------------------------------------------
   #pragma mark Gestures
// -----------------------------------------------------------------------------

- (void) touchesBeganWithEvent:(NSEvent *)event
{
    // Some day maybe.
}

- (void) touchesMovedWithEvent:(NSEvent *)event
{
    // Some day maybe.
}


// -----------------------------------------------------------------------------
   #pragma mark Drawing
// -----------------------------------------------------------------------------

- (void) drawBackgroundInRect:(NSRect)rect
{
    // Nothing to draw because we want a transparent background.
}

- (void) drawGrooveInRect:(NSRect)rect
{
    NSRect lineRect =  CGRectIntegral(CGRectInset(rect, kKnobWidth/2.0+2, rect.size.height/2.0 - kGrooveHeight/2.0));
    NSBezierPath *linePath = [NSBezierPath bezierPathWithRoundedRect:lineRect xRadius:2.5 yRadius:2.5];
    
    NSGradient *gradient = [[NSGradient alloc] initWithColorsAndLocations:
                               [NSColor colorWithCalibratedWhite:0.5 alpha:1.0], 0.00,
                               [NSColor colorWithCalibratedWhite:0.9 alpha:1.0], 1.00,
                               nil];

    [NSGraphicsContext saveGraphicsState];
    
    [linePath setClip];
    [gradient drawInBezierPath:linePath angle:270];

    [[NSColor blackColor] set];
    [linePath setLineWidth:0.5];
    [linePath stroke];
    [NSGraphicsContext restoreGraphicsState];
}

- (void) drawRangeInRect:(NSRect)rect
{
    CGRect minRect = [self rectForValue:rangeMinimum];
    CGRect maxRect = [self rectForValue:rangeMaximum];
    
    CGRect rangeRect;
    rangeRect.origin.x = CGRectGetMinX(minRect);
    rangeRect.origin.y = (rect.size.height - kRangeHeight) / 2.0;
    rangeRect.size.width = CGRectGetMaxX(maxRect) - rangeRect.origin.x;
    rangeRect.size.height = kRangeHeight;
    
    NSBezierPath *rangePath = [NSBezierPath bezierPathWithRoundedRect:rangeRect xRadius:3 yRadius:3];
    NSColor    *strokeColor = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.6 alpha:1.0];
    NSGradient    *gradient = [[NSGradient alloc] initWithColorsAndLocations:
                                 [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.4 alpha:1.0], 0.00,
                                 [NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.8 alpha:1.0], 1.00,
                                 nil];
    
    [NSGraphicsContext saveGraphicsState];
    
    [rangePath setClip];
    [gradient drawInBezierPath:rangePath angle:90];
    [strokeColor set];
    [rangePath stroke];
    [NSGraphicsContext restoreGraphicsState];
}

- (void) drawKnobInRect:(NSRect)rect atValue:(double)value isMinimum:(BOOL)isMinimum
{
    NSRect knobRect = [self rectForValue:value];
    knobRect.origin.x += isMinimum? -kKnobWidth/2.0 : kKnobWidth/2.0;

    NSBezierPath *outPath = [NSBezierPath bezierPathWithOvalInRect:knobRect];
    NSBezierPath *inPath  = [NSBezierPath bezierPathWithOvalInRect:CGRectInset(knobRect,2,2)];    
    NSGradient  *gradient = [[NSGradient alloc] initWithColorsAndLocations:
                             [NSColor colorWithCalibratedWhite:0.75 alpha:1.0], 0.00,
                             [NSColor colorWithCalibratedWhite:1.00 alpha:1.0], 1.00,
                             nil];
    
    [gradient drawInBezierPath:outPath angle: 90];
    [gradient drawInBezierPath:inPath  angle:-90];
    
    [[NSColor darkGrayColor] set];
    [outPath stroke];
    
    [[NSColor lightGrayColor] set];
    [inPath stroke];
}

- (void) drawRect:(NSRect)dirtyRect
{
    [NSGraphicsContext saveGraphicsState];
    
    NSRect bounds = self.bounds;
    
    [self drawBackgroundInRect:bounds];
    [self drawGrooveInRect:bounds];
    [self drawRangeInRect:bounds];
    
    if (flags.tracksKnobVisibility==NO || flags.visibleKnobs) {
        [self drawKnobInRect:bounds atValue:rangeMinimum isMinimum:YES];
        [self drawKnobInRect:bounds atValue:rangeMaximum isMinimum:NO];
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

// COV_NF_END

@end
