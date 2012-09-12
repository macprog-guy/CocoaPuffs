
#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NUSelectableViewTests : SenTestCase

@end

@implementation NUSelectableViewTests

- (void) testContentView
{
    NUSelectableView *selectableView = [[NUSelectableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    NSView *contentView = [[NSView alloc] initWithFrame:CGRectZero];
    
    selectableView.contentView = contentView;
    
    STAssertEquals(selectableView.contentView, contentView, @"Values should match");
    STAssertTrue(CGRectEqualToRect(selectableView.bounds, contentView.frame), @"Values should match");
    
    selectableView.contentView = nil;
}

@end
