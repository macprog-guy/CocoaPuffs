
#import "NSViewController+NUExtensions.h"

@implementation NSViewController (NUExtensions)

+ (id) controllerWithColocatedNibNamed:(NSString*)nibName
{
    return [[self alloc] initWithNibName:nibName bundle:[NSBundle bundleForClass:self]];
}


@end
