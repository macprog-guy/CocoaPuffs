
#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NUSegmentedTabViewTests : SenTestCase

@end

@implementation NUSegmentedTabViewTests

- (void) testDefaultProperties
{
    // Just for code coverage.
    NUSegmentedTabView *tabView = [[NUSegmentedTabView alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    NUSegmentInfo *tab0 = [NUSegmentInfo segment];
    NUSegmentInfo *tab1 = [NUSegmentInfo segment];
    NUSegmentInfo *tab2 = [NUSegmentInfo segment];

    STAssertNotNil(tabView, @"Should not be nil");
    STAssertEquals(tabView.supportsMultipleSelection, NO, @"Values should match");
    STAssertEquals(tabView.supportsEmptySelection, NO, @"Values should match");
    
    tabView.segments = @[];
    [tabView updateRects];
    
    tabView.segments = @[tab0, tab1, tab2];
    tabView.selectionIndex = 0;
    [tabView updateRects];
}

@end
