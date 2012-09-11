
#import "NUStackedView.h"

@interface NUStackedView() {
    double _rowSpacing;
}
@end


@implementation NUStackedView

// -----------------------------------------------------------------------------
   #pragma mark Properties
// -----------------------------------------------------------------------------

- (BOOL) isFlipped
{
    return YES;
}

- (void) setSubviews:(NSArray *)value
{
    if (value == nil)
        value = @[];
    
    [super setSubviews:value];
    [self resizeSubviewsWithOldSize:self.bounds.size];
}

- (double) rowSpacing
{
    return _rowSpacing;
}

- (void) setRowSpacing:(double)value
{
    _rowSpacing = value;
    [self resizeSubviewsWithOldSize:self.bounds.size];
}



// -----------------------------------------------------------------------------
   #pragma mark Helpers
// -----------------------------------------------------------------------------

- (void) resizeSubviews
{
    [self resizeSubviewsWithOldSize:self.bounds.size];
}



// -----------------------------------------------------------------------------
   #pragma mark NSView
// -----------------------------------------------------------------------------

- (void) didAddSubview:(NSView *)subview
{
    [super didAddSubview:subview];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resizeSubviewsAfterSubviewNotification:)
                                                 name:NSViewFrameDidChangeNotification
                                               object:subview];
    
    [self resizeSubviewsWithOldSize:self.bounds.size];
}

- (void) willRemoveSubview:(NSView *)subview
{
    [super willRemoveSubview:subview];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSViewFrameDidChangeNotification
                                                  object:subview];
}

- (void) viewDidMoveToSuperview
{
    [super viewDidMoveToSuperview];
    [self resizeSubviews];
}

 - (void) resizeSubviewsAfterSubviewNotification:(NSNotification*)note
{
    [self resizeSubviews];
}

- (void) resizeSubviewsWithOldSize:(NSSize)oldSize  
{
    CGFloat width = self.bounds.size.width;
    CGFloat y = 0;
    
    if ([self.superview isKindOfClass:[NSClipView class]])
        width = [(NSScrollView*)self.superview.superview contentSize].width;
        
    for (NSView *subview in self.subviews) {
        
        CGRect frame;
        
        frame.origin.x = 0;
        frame.origin.y = y;
        frame.size.width  = width;
        frame.size.height = subview.frame.size.height;
        
        if (!CGRectEqualToRect(subview.frame, frame))
            subview.frame = frame;
        
        y += frame.size.height + _rowSpacing;
    }
}


// -----------------------------------------------------------------------------
   #pragma mark Class Methods
// -----------------------------------------------------------------------------

+ (BOOL) requiresConstraintBasedLayout
{
    return NO;
}

@end
