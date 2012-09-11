
#import "NUSelectableView.h"
#import <QuartzCore/QuartzCore.h>

@implementation NUSelectableView

@synthesize contentView;

// -----------------------------------------------------------------------------
   #pragma mark Properties
// -----------------------------------------------------------------------------

- (void) setContentView:(NSView *)aView
{
    if (aView != contentView) {
        
        [contentView removeFromSuperview];

        contentView = aView;
        if (!CGRectEqualToRect(contentView.frame, self.bounds))
            contentView.frame = self.bounds;
        
        [self addSubview:contentView];
    }
}

@end
