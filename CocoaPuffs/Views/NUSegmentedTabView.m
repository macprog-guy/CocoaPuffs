
#import "NUSegmentedTabView.h"
#import "CocoaPuffs.h"

static NSGradient *gBackgroundGradient;
static NSColor    *gBackgroundColor;
static NSColor    *gBorderColor;

static NSGradient *gSelectedTabGradient;
static NSColor    *gSelectedTabOuterBorderColor;
static NSColor    *gSelectedTabInnerBorderColor;
static NSColor    *gSelectedTabColor;
static NSColor    *gUnselectedTabColor;
static NSColor    *gTabSeparatorColor;

static float gCornerRadius = 4.0f;
static float gTopMargin    = 2.0f;
static float gBottomMargin = 2.0f;
static float gLeftMargin   = 1.0f;
static float gRightMargin  = 1.0f;

static NSDictionary *gLabelAttributesAlignLeft = nil;
static NSDictionary *gLabelAttributesAlignCenter = nil;
static NSDictionary *gSelectedLabelAttributesAlignLeft = nil;
static NSDictionary *gSelectedLabelAttributesAlignCenter = nil;

@interface NUSegmentedTabView() {
    __strong NSBezierPath *openedBorderPath;
    __strong NSBezierPath *openedTabOuterPath;
    __strong NSBezierPath *openedTabInnerPath;
    
    CGRect backgroundRect;
    CGRect backgroundGradientRect;
    CGRect bottomMarginRect;
}
@end


@implementation NUSegmentedTabView

// -----------------------------------------------------------------------------
   #pragma mark - Init
// -----------------------------------------------------------------------------

- (id) initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect])) {
        self.alignment = NSJustifiedTextAlignment;
    }
    return self;
}

// -----------------------------------------------------------------------------
   #pragma mark - Properties
// -----------------------------------------------------------------------------

- (BOOL) supportsMultipleSelection
{
    return NO;
}

- (BOOL) supportsEmptySelection
{
    return NO;
}


// -----------------------------------------------------------------------------
   #pragma mark - Helpers
// -----------------------------------------------------------------------------

- (void) updateSegmentRects
{
    [super updateSegmentRects];
    
    CGRect segmentsRect = CGRectNull;
    CGRect selectedRect = CGRectNull;
    
    for (NSUInteger i=0;  i<self.segments.count;  i++)
        segmentsRect = CGRectUnion(segmentsRect, _selectRects[i]);
    
    CGRect dummy;
    backgroundRect = CGRectInsetTRBL(segmentsRect, gTopMargin, gRightMargin, gBottomMargin, gLeftMargin);
    CGRectDivide(backgroundRect, &backgroundGradientRect, &dummy, 3, NSMaxYEdge);
    CGRectDivide(segmentsRect, &bottomMarginRect, &dummy, gBottomMargin, NSMinYEdge);
    
    openedBorderPath = [self openPathForSemiRoundedRectInRect:backgroundRect];
    openedTabOuterPath = nil;
    openedTabInnerPath = nil;
    
    if (self.selectionIndex != NSNotFound) {
        selectedRect = _selectRects[self.selectionIndex];
        openedTabOuterPath = [self openPathForTabInRect:selectedRect inBounds:backgroundRect];
        openedTabInnerPath = [self openPathForTabInRect:CGRectInset(selectedRect, 0.2, 0) inBounds:backgroundRect];
    }
}

- (NSBezierPath*) openPathForSemiRoundedRectInRect:(CGRect)rect
{
    int minX = NSMinX(rect);
    int midX = NSMidX(rect);
    int maxX = NSMaxX(rect);
    int minY = NSMinY(rect);
    int maxY = NSMaxY(rect);
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint: NSMakePoint(minX, minY)];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                   toPoint:NSMakePoint(midX, maxY) 
                                    radius:gCornerRadius];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) 
                                   toPoint:NSMakePoint(maxX, minY) 
                                    radius:gCornerRadius];
    
    [path lineToPoint:NSMakePoint(maxX, minY)];
    
    return path;
}


- (NSBezierPath*) openPathForTabInRect:(CGRect)rect inBounds:(CGRect)bounds
{
    float minX = NSMinX(bounds);
    float minY = NSMinY(bounds);
    float maxX = NSMaxX(bounds);
    float maxY = NSMaxY(bounds);
    float midY = NSMidY(bounds);
    
    float x1 = NSMinX(rect);
    float x2 = NSMidX(rect);
    float x3 = NSMaxX(rect);
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSMakePoint(minX, minY)];    
    [path lineToPoint:NSMakePoint(x1, minY)];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(x1, maxY) 
                                   toPoint:NSMakePoint(x2, maxY) 
                                    radius:gCornerRadius];
    [path appendBezierPathWithArcFromPoint:NSMakePoint(x3, maxY) 
                                   toPoint:NSMakePoint(x3, midY) 
                                    radius:gCornerRadius];
    [path lineToPoint:NSMakePoint(x3, minY)];
    [path lineToPoint:NSMakePoint(maxX, minY)];
    
    return path;
}


// -----------------------------------------------------------------------------
   #pragma mark - Drawing
// -----------------------------------------------------------------------------

// COV_NF_START

- (void) drawBackground
{
    [NSGraphicsContext saveGraphicsState];
    
    [gBackgroundColor set];
    NSRectFill(self.bounds);
    
    /* 
        The background of the tabs themselves is a dark gray with a small 
        gradient at the top to give them depth. It fills a semi-rounded 
        rectangle. The background color fills the entire background and 
        the gradient about 3 points at the top of the background.
    */
    
    [gUnselectedTabColor set];
    [openedBorderPath fill];
    [gBorderColor set];
    [openedBorderPath setLineWidth:1];
    [openedBorderPath stroke];
    
    [openedBorderPath setClip];
    [gBackgroundGradient drawInRect:backgroundGradientRect angle:270.0f];
    
    [NSGraphicsContext restoreGraphicsState];
}

- (void) drawLabelAndImageForSegment:(NUSegmentInfo*)segment atIndex:(NSUInteger)index
{
    CGRect imageRect  = _imageRects[index];
    CGRect textRect   = _textRects[index];

    if (segment.image && !CGRectIsNull(imageRect)) {
     
        CGFloat side = ceil(fmin(imageRect.size.width, imageRect.size.height) * 0.618);
        CGRect targetRect = CGRectCenterInRect(imageRect, CGRectMake(0, 0, side, side));
        CGRect sourceRect = CGRectWithOriginAndSize(CGPointZero, segment.image.size);
        
        [segment.image drawInRect:targetRect 
                         fromRect:sourceRect 
                        operation:NSCompositeSourceOver 
                         fraction:1.0];
    }
    
    if (segment.label && !CGRectIsNull(textRect)) {
        
        NSDictionary *labelAttributes = segment.selected? 
            (segment.image? gSelectedLabelAttributesAlignLeft : gSelectedLabelAttributesAlignCenter) :
            (segment.image? gLabelAttributesAlignLeft : gLabelAttributesAlignCenter);
            
        // Center the text vertically
        NSFont *font = [labelAttributes objectForKey:NSFontAttributeName];
        textRect.origin.y += (textRect.size.height - font.ascender) / 2.0;
        textRect.size.height = font.ascender - font.descender;

        [segment.label drawInRect:textRect withAttributes:labelAttributes];
    }
}

- (void) drawSegment:(NUSegmentInfo*)segment atIndex:(NSUInteger)index
{
    [NSGraphicsContext saveGraphicsState];
    
    CGRect selectRect = _selectRects[index];

    if (segment.selected) {
        
        // The selected tab is filled with a gradient and stroked with a dark
        // outer border and a light inner border. 
        
        [gSelectedTabColor set];
        NSRectFill(bottomMarginRect);
        
        [gSelectedTabGradient drawInBezierPath:openedTabOuterPath angle:90];
        [gSelectedTabOuterBorderColor set];
        [openedTabOuterPath setLineWidth:1.5];
        [openedTabOuterPath stroke];
        
        [gSelectedTabInnerBorderColor set];
        [openedTabInnerPath setLineWidth:1];
        [openedTabInnerPath stroke];
        
    } else {

        if (index != self.selectionIndex+1) {
            
            // We remove the bottom margin and the top gradient.
            CGRect lineRect = CGRectIntegral(CGRectInsetTRBL(selectRect, gTopMargin+2, 0, gBottomMargin+2, 0));
            NSBezierPath *path = [NSBezierPath bezierPath];
            
            [gTabSeparatorColor set];
            [path moveToPoint:lineRect.origin];
            [path relativeLineToPoint:NSMakePoint(0, lineRect.size.height)];
            [path setLineWidth:1.0];
            [path stroke];
        }

    }
    
    [self drawLabelAndImageForSegment:segment atIndex:index];
    [NSGraphicsContext restoreGraphicsState];
}

- (void) drawOverlay
{
}

// COV_NF_END


// -----------------------------------------------------------------------------
   #pragma mark - Class Initialization
// -----------------------------------------------------------------------------

+ (void) initialize
{
    if (self == [NUSegmentedTabView class]) {
        @autoreleasepool {
            
            NSMutableParagraphStyle *styleL = [[NSMutableParagraphStyle alloc] init];
            NSMutableParagraphStyle *styleC = [[NSMutableParagraphStyle alloc] init];
            
            styleL.alignment         = NSLeftTextAlignment;
            styleL.lineBreakMode     = NSLineBreakByTruncatingTail;
            styleL.minimumLineHeight = 12;

            styleC.alignment         = NSCenterTextAlignment;
            styleC.lineBreakMode     = NSLineBreakByTruncatingTail;
            styleC.minimumLineHeight = 12;
            
            NSFont *labelFont = [NSFont labelFontOfSize:11];
            NSFont *selectedLabelFont = labelFont.fontVariationBold;
            
            NSShadow *shadow = [[NSShadow alloc] init];
            shadow.shadowColor  = [NSColor whiteColor];
            shadow.shadowOffset = NSMakeSize(0, -1);
            shadow.shadowBlurRadius = 0.0f;
            
            gLabelAttributesAlignLeft   = @{NSFontAttributeName: labelFont, NSForegroundColorAttributeName: [NSColor blackColor], NSParagraphStyleAttributeName: styleL};
            gLabelAttributesAlignCenter = @{NSFontAttributeName: labelFont, NSForegroundColorAttributeName: [NSColor blackColor], NSParagraphStyleAttributeName: styleC};
            
            gSelectedLabelAttributesAlignLeft   = @{NSFontAttributeName: selectedLabelFont, NSForegroundColorAttributeName: [NSColor blackColor], NSParagraphStyleAttributeName: styleL, NSShadowAttributeName: shadow};
            gSelectedLabelAttributesAlignCenter = @{NSFontAttributeName: selectedLabelFont, NSForegroundColorAttributeName: [NSColor blackColor], NSParagraphStyleAttributeName: styleC, NSShadowAttributeName: shadow};
            
            gBackgroundColor = [NSColor colorWithCalibratedWhite:0.65f alpha:1.0f];
            gBorderColor = [NSColor colorWithCalibratedWhite:0.62f alpha:1.0f];
        
            gSelectedTabOuterBorderColor = gBorderColor;
            gSelectedTabInnerBorderColor = [NSColor colorWithCalibratedWhite:0.93 alpha:1.0];
            gSelectedTabColor    = [NSColor colorWithCalibratedWhite:0.74 alpha:1.0];
            gUnselectedTabColor  = [NSColor colorWithCalibratedWhite:0.65f alpha:1.0f];
            gTabSeparatorColor   = [NSColor colorWithCalibratedWhite:0.33 alpha:0.75];
            
            gBackgroundGradient  = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.47f alpha:1.0f] endingColor:gUnselectedTabColor];    
            gSelectedTabGradient = [[NSGradient alloc] initWithStartingColor:gSelectedTabColor endingColor:[NSColor colorWithCalibratedWhite:0.84 alpha:1.0]];
        }
    }
}

@end
