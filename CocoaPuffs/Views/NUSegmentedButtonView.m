
#import "NUSegmentedButtonView.h"
#import <CocoaPuffs/CocoaPuffs.h>

static NSGradient *gDeselectedGradient;
static NSGradient *gSelectedGradient;
static NSGradient *gSelectedLineGradient;

static NSDictionary *gLabelAttributesAlignCenter;


@interface NUSegmentedButtonView() {
    NSBezierPath *segmentsBorder;
    CGRect segmentsRect;
}
@end

@implementation NUSegmentedButtonView

// -----------------------------------------------------------------------------
   #pragma mark - Init
// -----------------------------------------------------------------------------

- (id) initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect])) {
        self.allowsMultipleSelection = YES;
    }
    return self;
}



// -----------------------------------------------------------------------------
   #pragma mark - Properties
// -----------------------------------------------------------------------------

- (BOOL) supportsEmptySelection
{
    return YES;
}




// -----------------------------------------------------------------------------
   #pragma mark - Helpers
// -----------------------------------------------------------------------------

- (void)updateSegmentRects
{
    [super updateSegmentRects];
    
    // Cache some drawing variables here as they remain constant until bounds change.
    segmentsRect = CGRectNull;
    
    const NSUInteger count = self.segments.count;
    for (NSUInteger i=0;  i<count;  i++)
        segmentsRect = CGRectUnion(segmentsRect, _selectRects[i]);
    
    segmentsBorder = [NSBezierPath bezierPathWithRoundedRect:segmentsRect xRadius:4 yRadius:4];
}



// -----------------------------------------------------------------------------
   #pragma mark - Drawing
// -----------------------------------------------------------------------------

// COV_NF_START
- (void) drawBackground
{
    if (self.segments.isNotEmpty) {
        [segmentsBorder setClip];
        [gDeselectedGradient drawInBezierPath:segmentsBorder angle:90];
    }
}

- (void) drawSegment:(NUSegmentInfo*)segment atIndex:(NSUInteger)index
{
    CGRect selectRect = _selectRects[index];
    CGRect imageRect  = _imageRects[index];
    CGRect textRect   = _textRects[index];
    
    // Drawing the selection gradient
    if (segment.selected | segment.pushed)
        [gSelectedGradient drawInRect:selectRect angle:-90];

    // Draw the image if we have one and want one
    if (segment.image && !CGRectIsNull(imageRect)) {
        
        CGFloat side = ceil(fmin(imageRect.size.width, imageRect.size.height) * 0.618);
        
        CGRect sourceRect = CGRectWithOriginAndSize(CGPointZero, segment.image.size);
        CGRect targetRect = CGRectCenterInRect(imageRect, CGRectMake(0, 0, side, side));
        
        [segment.image drawInRect:targetRect 
                         fromRect:sourceRect 
                        operation:NSCompositeSourceOver 
                         fraction:1.0];
        
    } 
    
    // Draw the text if we have some and want some
    if (segment.label && !CGRectIsNull(textRect)) {
        
        NSFont *font = [gLabelAttributesAlignCenter objectForKey:NSFontAttributeName];
        textRect.origin.y += (textRect.size.height - font.ascender) / 2.0 + 1.0;
        textRect.size.height = font.ascender - font.descender;
        
        [segment.label drawInRect:textRect withAttributes:gLabelAttributesAlignCenter];
    }
    
    /* 
     
       Drawing the line separator
     
       There are four scenarios for each side:
     
       1. not-selected   |-> selected;
       2. selected     <-|   not-selected;
       3. not-selected   |   not-selected;
       4. selected       |   selected;
    
    */

    BOOL prevSegmentSelected = (index > 0)? [[self.segments objectAtIndex:index-1] selected] : NO;
    BOOL nextSegmentSelected = (index < self.segments.count-1)? [[self.segments objectAtIndex:index+1] selected] : NO;

    CGRect rectL, rectM, rectR = selectRect;
    CGRectDivide(selectRect, &rectL, &rectM, 2.5, CGRectMinXEdge);
    CGRectDivide(rectM, &rectR, &rectM, 2.5, CGRectMaxXEdge);
    
    // Draw left separator for scenario 1.
    if (segment.selected && !prevSegmentSelected)
        [gSelectedLineGradient drawInRect:rectL angle:0];
    
    // Draw right separator for scenario 2.
    if (segment.selected && !nextSegmentSelected)
        [gSelectedLineGradient drawInRect:rectR angle:180];
    
    // Draw left separator for scenario 3 and 4
    if (segment.selected == prevSegmentSelected) {

        NSBezierPath *line = [NSBezierPath bezierPath];
        CGRect lineRect = CGRectOffset(CGRectInset(selectRect, 0, 3), -0.25, 0); 
        [line moveToPoint:lineRect.origin];
        [line relativeLineToPoint:CGPointMake(0, lineRect.size.height)];
        
        if (prevSegmentSelected)
            [[NSColor colorWithCalibratedWhite:0.9 alpha:0.75] set];
        else 
            [[NSColor colorWithCalibratedWhite:0.3 alpha:0.75] set];
        
        [line setLineWidth:0.5];
        [line stroke];
    }
}

- (void) drawOverlay
{
    if (self.segments.isNotEmpty) {
        [[NSColor darkGrayColor] set];
        [segmentsBorder setLineWidth:1.0];
        [segmentsBorder stroke]; 
    }
}

// COV_NF_END

// -----------------------------------------------------------------------------
   #pragma mark - Class Initialization
// -----------------------------------------------------------------------------

+ (void) initialize
{
    if (self == [NUSegmentedButtonView class]) {
        @autoreleasepool {
            gDeselectedGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.79 alpha:1.0]
                                                                endingColor:[NSColor colorWithCalibratedWhite:0.89 alpha:1.0]];
            
            gSelectedGradient   = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.34 alpha:1.0] 
                                                                endingColor:[NSColor colorWithCalibratedWhite:0.64 alpha:1.0]];
            
            gSelectedLineGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.00 alpha:0.35] 
                                                                  endingColor:[NSColor colorWithCalibratedWhite:0.30 alpha:0.35]];

            NSMutableParagraphStyle *styleC = [[NSMutableParagraphStyle alloc] init];
            
            styleC.alignment         = NSCenterTextAlignment;
            styleC.lineBreakMode     = NSLineBreakByTruncatingTail;
            styleC.minimumLineHeight = 9;
            
            NSFont *labelFont = [NSFont labelFontOfSize:9];
            
            NSShadow *shadow = [[NSShadow alloc] init];
            shadow.shadowColor  = [NSColor whiteColor];
            shadow.shadowOffset = NSMakeSize(0, -1);
            shadow.shadowBlurRadius = 0.0f;

            gLabelAttributesAlignCenter = @{NSFontAttributeName: labelFont, NSForegroundColorAttributeName: [NSColor blackColor], NSParagraphStyleAttributeName: styleC};
        }
    }
}

@end
