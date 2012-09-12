
#import "NUSegmentedSheetView.h"
#import <CocoaPuffs/CocoaPuffs.h>

static NSGradient *gBackgroundGradient;
static NSColor    *gBackgroundColor;
static NSColor    *gBorderColor;

static NSGradient *gSelectedTabGradient;
static NSColor    *gSelectedTabOuterBorderColor;
static NSColor    *gSelectedTabInnerBorderColor;
static NSColor    *gSelectedTabColor;
static NSColor    *gUnselectedTabColor;
static NSColor    *gTabSeparatorColor;

static float gTopMargin = 2.0f;
static float gLeftPadding = 16.0;
static float gRightPadding = 4.0;
static float gTopGradientHeight = 3.0f;
static float gBottomMargin = 2.0f;
static float gImageLabelPadding = 4.0f;

static NSDictionary *gLabelAttributesAlignLeft = nil;
static NSDictionary *gLabelAttributesAlignCenter = nil;
static NSDictionary *gSelectedLabelAttributesAlignLeft = nil;
static NSDictionary *gSelectedLabelAttributesAlignCenter = nil;


@interface NUSegmentedSheetView() {
    CGRect sheetRect;
    CGRect gradientRect;
    CGRect backgroundRect;
}
@end



@implementation NUSegmentedSheetView

// -----------------------------------------------------------------------------
   #pragma mark - Init
// -----------------------------------------------------------------------------

- (id) initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect])) {
        self.alignment = NSLeftTextAlignment;
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
    CGRect  r = self.bounds;
    CGFloat h = r.size.height;
    CGFloat p = ceil(h * 0.32);
    
    NSUInteger i=0;
    for (NUSegmentInfo* segment in self.segments) {
        
        CGFloat  x = r.origin.x;
        CGFloat dx = gLeftPadding;
        CGFloat textWidth = [segment.label sizeWithAttributes:gLabelAttributesAlignLeft].width;

        _imageRects[i]  = CGRectNull;
        _textRects[i]   = CGRectNull;
        _actionRects[i] = CGRectNull;
        _badgeRects[i]  = CGRectNull;
        
        if (segment.image) {
            _imageRects[i] = CGRectInset(CGRectMake(x + dx, 0, h, h), p, p);
            dx += h;
        } 

        if (segment.label) {
            dx += segment.image? gImageLabelPadding : 0;
            _textRects[i] = CGRectMake(x + dx, 0, textWidth, h);
            dx += textWidth;
        }
        
        if (segment.buttonAction) {
            dx += segment.label? gImageLabelPadding : 0;
            _actionRects[i] = CGRectInset(CGRectMake(x + dx, 0, h, h), p, p);
            dx += h;
        }
        
        dx += gRightPadding;
        
        if (dx > 180) {
            CGFloat dw = dx - 180;
            _textRects[i].size.width -= dw;
            _actionRects[i].origin.x -= dw;
            dx = 180;
        }

        _selectRects[i] = CGRectWithOriginAndSize(r.origin, CGSizeMake(dx, h));
        r.origin.x += dx;
        i++;
    }

    CGRect bounds = CGRectMake(0, 0, r.origin.x, h);
    if ([self.superview isKindOfClass:[NSClipView class]]) 
        bounds = CGRectUnion(bounds, self.superview.superview.bounds);

    self.frame = bounds;
    
    CGRectDivide(bounds, &sheetRect, &gradientRect, gTopMargin, NSMaxYEdge);
    CGRectDivide(gradientRect, &gradientRect, &backgroundRect, gTopGradientHeight, NSMaxYEdge);
}


// -----------------------------------------------------------------------------
   #pragma mark - Drawing
// -----------------------------------------------------------------------------

// COV_NF_START

- (void) drawSheetForSegment:(NUSegmentInfo*)segment inRect:(CGRect)frameRect withActionRect:(CGRect)actionRect andFillColor:(NSColor*)fillColor
{
    [NSGraphicsContext saveGraphicsState];
    
    NSBezierPath *contour = [NSBezierPath bezierPath];
    
    CGFloat x = frameRect.origin.x;
    CGFloat y = frameRect.origin.y;
    CGFloat w = frameRect.size.width;
    CGFloat h = frameRect.size.height;
    
    [contour moveToPoint:CGPointMake(x, y + h)];
    
    [contour appendBezierPathWithArcFromPoint:CGPointMake(x + 8, y) 
                                      toPoint:CGPointMake(x + w/2, y) 
                                       radius:8];
    
    [contour appendBezierPathWithArcFromPoint:CGPointMake(x + w - 8, y) 
                                      toPoint:CGPointMake(x + w, y + h) 
                                       radius:8];
    [contour lineToPoint:CGPointMake(x+w, y+h)];
    
    [fillColor set];
    [contour fill];
    
    [gBorderColor set];
    [contour setLineWidth:1];
    [contour stroke];
    
    [NSGraphicsContext restoreGraphicsState];
}

- (void) drawBackground
{
    [NSGraphicsContext saveGraphicsState];
    
    /* 
        The background of the sheets themselves is a plain white (sheet color)
        followed by a small gradient for depth. We need to draw inactive tabs
        here because the gradient must go "above" them for it to look nice.
     
     */
    [[NSColor whiteColor] set];
    NSRectFill(sheetRect);
    
    [gBackgroundColor set];
    NSRectFill(backgroundRect);
    
    NSUInteger i=0;
    for (NUSegmentInfo* segment in self.segments) {
        if (! segment.selected) {
            [self drawSheetForSegment:segment 
                               inRect:CGRectInsetTRBL(_selectRects[i], gTopMargin, 0, gBottomMargin+2, 0)
                       withActionRect:_actionRects[i]
                         andFillColor:gUnselectedTabColor];
        }
        i++;
    }
    
    [gBackgroundGradient drawInRect:gradientRect angle:270.0f];
    
    [NSGraphicsContext restoreGraphicsState];
}

- (void) drawSegment:(NUSegmentInfo*)segment atIndex:(NSUInteger)index
{
    CGRect selectRect = _selectRects[index];
    CGRect imageRect  = _imageRects[index];
    CGRect textRect   = _textRects[index];
    CGRect actionRect = _actionRects[index];

    selectRect = CGRectInsetTRBL(selectRect, gTopMargin, 0, gBottomMargin, 0);
    
    // Draw the sheet if this is the selected sheet.
    if (segment.selected) {
        [self drawSheetForSegment:segment 
                           inRect:selectRect
                   withActionRect:actionRect 
                     andFillColor:[NSColor whiteColor]];
    } 

    // Draw the image or icon usually on the left side.
    if (segment.image && !CGRectIsNull(imageRect)) {
        CGRect sourceRect = CGRectWithOriginAndSize(CGPointZero, segment.image.size);
        [segment.image drawInRect:_imageRects[index] fromRect:sourceRect operation:NSCompositeSourceOver fraction:1.0];
    }

    // Draw the name or label usually next to the icon or centered.
    if (segment.label && !CGRectIsNull(textRect)) {
        
        NSDictionary *labelAttributes = segment.selected? 
        (segment.image? gSelectedLabelAttributesAlignLeft : gSelectedLabelAttributesAlignCenter) :
        (segment.image? gLabelAttributesAlignLeft : gLabelAttributesAlignCenter);
        
        // Center the text vertically
        NSFont *font = [labelAttributes objectForKey:NSFontAttributeName];
        CGRect textArea = _textRects[index];
        textArea.origin.y += (textArea.size.height - font.ascender) / 2.0 + 2.0;
        textArea.size.height = font.ascender - font.descender;
        
        [segment.label drawInRect:textArea withAttributes:labelAttributes];
    }

    // Draw the action button usually on the right side.
    if (segment.buttonAction && segment.active && !CGRectIsNull(actionRect)) {        
        NSImage *actionImage = [NSImage imageNamed:NSImageNameStopProgressTemplate];
        CGRect sourceRect = CGRectWithOriginAndSize(CGPointZero, actionImage.size);
        [actionImage drawInRect:_actionRects[index] fromRect:sourceRect operation:NSCompositeSourceOver fraction:1.0];
    }
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
    if (self == [NUSegmentedSheetView class]) {
        @autoreleasepool {
            
            // We need to allocate an autorelease pool because the default one does
            // not exists yet at this point.
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
            gBorderColor = [NSColor colorWithCalibratedWhite:0.50f alpha:1.0f];
            
            gSelectedTabOuterBorderColor = gBorderColor;
            gSelectedTabInnerBorderColor = [NSColor colorWithCalibratedWhite:0.93 alpha:1.0];
            gSelectedTabColor    = [NSColor colorWithCalibratedWhite:0.74 alpha:1.0];
            gUnselectedTabColor  = [NSColor colorWithCalibratedWhite:0.75f alpha:1.0f];
            gTabSeparatorColor   = [NSColor colorWithCalibratedWhite:0.33 alpha:0.75];
            
            gBackgroundGradient  = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.2f alpha:0.5f] endingColor:gBackgroundColor];    
            gSelectedTabGradient = [[NSGradient alloc] initWithStartingColor:gSelectedTabColor endingColor:[NSColor colorWithCalibratedWhite:0.84 alpha:1.0]];
        }
    }
}

@end
