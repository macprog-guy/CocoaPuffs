
#import "NUPropertySheetView.h"
#import "NUPropertyInspectorView.h"
#import "NUDelegatingView.h"
#import "NSView+NUExtensions.h"
#import "NSLayoutConstraint+NUExtensions.h"
#import "NSArray+NUExtensions.h"

static NSColor    *gBackgroundColor = nil;
static NSGradient *gHeaderGradient  = nil;
static NSColor    *gHeaderLineColor = nil;

static double gDiscloseAnimationDuration = 0.075;

@interface NUPropertySheetView() {

    NSView      *_headerView;
    NSButton    *_headerButton;
    NSTextField *_headerLabel;
    
    NSView      *_inspectorsView;
    NSImageView *_inspectorsImageView;
    CGSize       _inspectorsSize;
    BOOL         _inspectorsVisible;
    double       _inspectorsOffset;
    
    NSLayoutConstraint *_inspectorsHeightConstraint;
    NSMutableArray     *_inspectorsConstraints;
    NSMutableArray     *_sheetConstraints;
}

@end

@implementation NUPropertySheetView // COV_NF_LINE

// -----------------------------------------------------------------------------
   #pragma mark Init & Dealloc
// -----------------------------------------------------------------------------

- (id) initWithName:(NSString*)aName andLabel:(NSString*)aLabel
{
    if ((self = [super initWithFrame:CGRectZero])) {
        
        _name  = [aName copy];
        _label = [aLabel copy];
        _inspectorsVisible = YES;
        _inspectorsOffset = 0.0;
        _inspectorsConstraints = [NSMutableArray array];
        _sheetConstraints = [NSMutableArray array];
        
        _headerView = [[NSView alloc] init];
        _headerView.translatesAutoresizingMaskIntoConstraints = NO;
        
        _inspectorsView = [[NSView alloc] init];
        _inspectorsView.translatesAutoresizingMaskIntoConstraints = NO;
        
        _inspectorsImageView = [[NSImageView alloc] init];
        _inspectorsImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _inspectorsImageView.imageFrameStyle = NSImageFrameNone;
        _inspectorsImageView.imageScaling = NSImageScaleNone;
        _inspectorsImageView.imageAlignment = NSImageAlignTop;
        
        _headerButton = [[NSButton alloc] init];
        _headerButton.translatesAutoresizingMaskIntoConstraints = NO;
        _headerButton.title = @"";
        _headerButton.frame = CGRectMake(4, 4, 16, 16);
        _headerButton.focusRingType = NSFocusRingTypeNone;
        [_headerButton setButtonType:NSOnOffButton];
        [_headerButton setBezelStyle:NSDisclosureBezelStyle];
        [_headerButton sizeToFit];
        [_headerButton bind:@"value" toObject:self withKeyPath:@"inspectorsVisible" options:nil];
        
        _headerLabel = [[NSTextField alloc] init];
        _headerLabel.stringValue = _label;
        _headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_headerLabel.cell setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
        [_headerLabel.cell setAlignment:NSLeftTextAlignment];
        [_headerLabel.cell setControlSize:NSSmallControlSize];
        [_headerLabel setFocusRingType:NSFocusRingTypeNone];
        [_headerLabel setEditable:NO];
        [_headerLabel setDrawsBackground:NO];
        [_headerLabel setBordered:NO];
        [_headerLabel setSelectable:NO];
        
        _headerView.subviews = @[_headerButton, _headerLabel];
        NSDictionary *views = NSDictionaryOfVariableBindings(_headerButton, _headerLabel);

        [_headerView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"|-(4)-[_headerButton]-(8)-[_headerLabel(>=120)]-(4)-|"
                                                 options:NSLayoutFormatAlignAllCenterY|NSLayoutFormatDirectionLeadingToTrailing
                                                 metrics:nil
                                                   views:views]];

        [_headerView addConstraints:
         [NSLayoutConstraint constraintsWithItemsEachAlignedWithCenterYOfSuperview:_headerView.subviews]];
        
        self.subviews = @[_headerView, _inspectorsView];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setNeedsUpdateConstraints:YES];
    }
    
    return self;
}

+ (id) propertySheetWithName:(NSString*)aName andLabel:(NSString*)aLabel
{
    return [[self alloc] initWithName:aName andLabel:aLabel];
}

// -----------------------------------------------------------------------------
   #pragma mark Properties
// -----------------------------------------------------------------------------

- (BOOL) isOpaque
{
    return YES;
}

- (BOOL) inspectorsVisible
{
    return _inspectorsVisible;
}

- (void) setInspectorsVisible:(BOOL)value
{
    _inspectorsVisible = value;
    
    if (_inspectorsVisible) {

        //
        // We animate the opening of the sheet and only then do we
        // substitute inspectorsView for inspectorsImageView.
        //
        // By doing so we need to rebuild our constraints.
        //
        
        CGSize imageSize = _inspectorsImageView.image.size;
        CGSize frameSize = _inspectorsImageView.frame.size;
        double actualDur = (1.0 - frameSize.height / imageSize.height) * gDiscloseAnimationDuration;
        
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:actualDur];
        
        [NSAnimationContext currentContext].completionHandler = ^(void) {
            // COV_NF_START
            if (_inspectorsHeightConstraint.constant == imageSize.height) {
                [self replaceSubview:_inspectorsImageView with:_inspectorsView];
                [self updateConstraints];
            }
            // COV_NF_END
        };
        
        [[_inspectorsHeightConstraint animator] setConstant:imageSize.height];
        [[_inspectorsImageView animator] setAlphaValue:1.0];

        [NSAnimationContext endGrouping];
        
    } else {
        
        //
        // We replace the inspectorsView with the inspectorsImageView
        // whose image content and frame has been updated.
        //
        // We then animate the closing of the sheet by changing the hight
        // constraint on the inspectorsImageView.
        //
        // NOTE: we don't need to create a new image and constraint if we
        //       are currently in the process of animating the property.
        //
        
        double actualDur = gDiscloseAnimationDuration;

        if (_inspectorsImageView.superview == nil) {
            
            _inspectorsImageView.image = [_inspectorsView bitmapImageForVisibleRect];
            _inspectorsImageView.frame = _inspectorsView.frame;
            [self replaceSubview:_inspectorsView with:_inspectorsImageView];
            [self updateConstraints];
            
        } else {
            
            CGSize imageSize = _inspectorsImageView.image.size;
            CGSize frameSize = _inspectorsImageView.frame.size;
            actualDur = (frameSize.height / imageSize.height) * gDiscloseAnimationDuration;
        }
        
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:actualDur];
        
        [[_inspectorsHeightConstraint animator] setConstant:0];
        [[_inspectorsImageView animator] setAlphaValue:0.0];
        
        [NSAnimationContext endGrouping];
    }
}

- (NSArray*) inspectorViews
{
    return _inspectorsView.subviews;
}

- (void) setInspectorViews:(NSArray*)value
{
    _inspectorsView.subviews = value;
    [self setNeedsUpdateConstraints:YES];
    [self setNeedsLayout:YES];
}

+ (BOOL) requiresConstraintBasedLayout
{
    return YES;
}


// -----------------------------------------------------------------------------
   #pragma mark Helpers
// -----------------------------------------------------------------------------

- (void) addInspectorView:(NUPropertyInspectorView*)inspectorView
{
    self.inspectorViews = [self.inspectorViews arrayByAddingObject:inspectorView];
}

- (void) removeInspectorView:(NUPropertyInspectorView*)inspectorView
{
    self.inspectorViews = [self.inspectorViews arrayByRemovingObject:inspectorView];
}


// -----------------------------------------------------------------------------
   #pragma mark Layout
// -----------------------------------------------------------------------------

- (void) updateConstraints
{
    [super updateConstraints];

    [self removeConstraints:_sheetConstraints];
    [_sheetConstraints removeAllObjects];

    [self removeConstraints:_inspectorsConstraints];
    [_inspectorsConstraints removeAllObjects];

    [_sheetConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithItem:_headerView spanningWidthOfSuperviewWithPadding:0]];

    if (_inspectorsView.superview) {
        
        _inspectorsHeightConstraint = nil;
        
        [_inspectorsConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithItems:_inspectorsView.subviews eachSpanningWidthOfSuperviewWithPadding:0]];
        
        [_inspectorsConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithItemsHavingEqualWidth:[_inspectorsView.subviews mapKeyPath:@"labelField"]]];
        
        [_inspectorsConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithItemsHavingEqualRightEdges:[_inspectorsView.subviews mapKeyPath:@"valueControl"]]];
        
        [_inspectorsConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsForStackedItems:_inspectorsView.subviews
                                         withTopPadding:@"3"
                                             itemHeight:@"26"
                                                spacing:nil
                                          bottomPadding:@"3"]];

        [_sheetConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithItem:_inspectorsView spanningWidthOfSuperviewWithPadding:0]];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_headerView, _inspectorsView);
        
        [_sheetConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_headerView(18)][_inspectorsView]|" options:0 metrics:nil views:views]];
        
    } else if (_inspectorsImageView.superview) {
        
        [_inspectorsConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithItem:_inspectorsImageView havingHeight:_inspectorsImageView.image.size.height]];
        
        _inspectorsHeightConstraint = _inspectorsConstraints.lastObject;

        NSDictionary *views = NSDictionaryOfVariableBindings(_headerView, _inspectorsImageView);
        
        [_sheetConstraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_headerView(18)][_inspectorsImageView]|" options:0 metrics:nil views:views]];
    }
    
    [self addConstraints:_sheetConstraints];
    [self addConstraints:_inspectorsConstraints];
}

// -----------------------------------------------------------------------------
   #pragma mark Drawing
// -----------------------------------------------------------------------------

// COV_NF_START

- (void)drawRect:(NSRect)dirtyRect
{
    [NSGraphicsContext saveGraphicsState];
    CGRect frame = CGRectIntegral(_headerView.frame);
    
    // First draw the view background
    [gBackgroundColor set];
    NSRectFill(self.bounds);
    
    // Draw the header gradient
    [gHeaderGradient drawInRect:frame angle:90];
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    NSBezierPath *clip = [NSBezierPath bezierPathWithRect:frame];
    
    // Draw top and bottom lines
    //
    // NOTE: For some reason the bottom line draws thicker when the properties
    //       subview is hidden! Setting a clipping region fixes the symptoms.
    //
    [clip setClip];
    [path moveToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame))];
    [path relativeLineToPoint:CGPointMake(CGRectGetWidth(frame),0)];
    [path moveToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMaxY(frame))];
    [path relativeLineToPoint:CGPointMake(CGRectGetWidth(frame),0)];
    [path setLineWidth:0.5];
    [gHeaderLineColor set];
    [path stroke];
    
    [NSGraphicsContext restoreGraphicsState];
}

// COV_NF_END

+ (void) initialize
{
    if (self == [NUPropertySheetView class]) {
        gBackgroundColor = [NSColor colorWithCalibratedWhite:0.74 alpha:1.0];

        NSColor  *colorA = [NSColor colorWithDeviceWhite:0.94 alpha:1];
        NSColor  *colorB = [NSColor colorWithDeviceWhite:0.84 alpha:1];
        
        gHeaderGradient  = [[NSGradient alloc] initWithColorsAndLocations:colorA, 0.0, colorB, 0.75,nil];
        gHeaderLineColor = [NSColor blackColor];
    }
}

@end
