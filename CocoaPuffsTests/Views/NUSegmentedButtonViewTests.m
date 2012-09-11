
#import <SenTestingKit/SenTestingKit.h>
#import "CocoaPuffs.h"

@interface NUSegmentedButtonViewTests : SenTestCase

@end

@implementation NUSegmentedButtonViewTests

- (void) testDefaultProperties
{
    // Just for code coverage.
    NUSegmentedButtonView *buttonView = [[NUSegmentedButtonView alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    NUSegmentInfo *button0 = [NUSegmentInfo segment];
    NUSegmentInfo *button1 = [NUSegmentInfo segment];
    NUSegmentInfo *button2 = [NUSegmentInfo segment];
    buttonView.segments = @[button0, button1, button2];
    
    STAssertNotNil(buttonView, @"Should not be nil");
    STAssertEquals(buttonView.supportsMultipleSelection, YES, @"Values should match");
    STAssertEquals(buttonView.supportsEmptySelection, YES, @"Values should match");

    // For code coverage
    STAssertNoThrow([buttonView updateRects], @"Should not raise an exception");
}

@end
