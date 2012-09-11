
#import "NUSimpleGradient.h"

@implementation NUSimpleGradient // COV_NF_LINE

// ----------------------------------------------------------------------------
   #pragma mark Synthesized Properties
// ----------------------------------------------------------------------------

@synthesize startingColor, endingColor;

// ----------------------------------------------------------------------------
   #pragma mark Init
// ----------------------------------------------------------------------------

- (id) init
{
    if ((self = [super init])) {
        startingColor = [NSColor redColor];
        endingColor = [NSColor blueColor];
    }
    return self;
}

+ (id) simpleGradient
{
    return [[self alloc] init];
}


// ----------------------------------------------------------------------------
   #pragma mark Properties
// ----------------------------------------------------------------------------

- (NSGradient*) gradient
{
    return [[NSGradient alloc] initWithStartingColor:startingColor endingColor:endingColor];
}

// ----------------------------------------------------------------------------
   #pragma mark KVO
// ----------------------------------------------------------------------------

+ (NSSet*) keyPathsForValuesAffectingGradient
{
    return [NSSet setWithObjects:@"startingColor",@"endingColor", nil];
}


@end
