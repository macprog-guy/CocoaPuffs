
#import <SenTestingKit/SenTestingKit.h>
#import "NUSimpleGradient.h"

@interface NUSimpleGradientTests : SenTestCase {
    NUSimpleGradient *simpleGradient;
    NSGradient       *boundGradient;
}
@end



@implementation NUSimpleGradientTests

- (void) testGradient
{
    simpleGradient = [NUSimpleGradient simpleGradient];    
    [self bind:@"boundGradient" toObject:simpleGradient withKeyPath:@"gradient" options:nil];
    
    STAssertNotNil(simpleGradient.startingColor, @"Starting color should not be nil");
    STAssertNotNil(simpleGradient.endingColor, @"Ending color should not be nil");
    STAssertNotNil(simpleGradient.gradient, @"Gradient should not be nil");
    STAssertNotNil(boundGradient, @"Bound gradient should not be nil");
    
    NSGradient *yellowToGreen = [[NSGradient alloc] initWithStartingColor:[NSColor yellowColor] endingColor:[NSColor greenColor]];
    
    simpleGradient.startingColor = [NSColor yellowColor];
    simpleGradient.endingColor = [NSColor greenColor];
    
    STAssertEqualObjects(boundGradient, yellowToGreen, @"Gradients should be equivalent");
}



@end
