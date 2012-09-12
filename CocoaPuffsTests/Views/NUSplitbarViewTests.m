
#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NUSplitbarViewTests : SenTestCase {
    NUSplitbarView   *_splitbarView;
    NSView           *_topView;
    NUDelegatingView *_barView;
    NSView           *_bottomView;
}
@end

@implementation NUSplitbarViewTests

- (void) setUp
{
    _splitbarView = [[NUSplitbarView alloc] initWithFrame:CGRectMake(0, 0, 200, 600)];
    _bottomView = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    _barView = [[NUDelegatingView alloc] initWithFrame:CGRectMake(0, 200, 200, 20)];
    _topView = [[NSView alloc] initWithFrame:CGRectMake(0, 220, 200, 380)];
    
    _splitbarView.aboveView = _topView;
    _splitbarView.barView   = _barView;
    _splitbarView.belowView = _bottomView;
}

- (void) testProperties
{
    STAssertNotNil(_splitbarView.aboveView, @"Value should not be nil");
    STAssertNotNil(_splitbarView.barView, @"Value should not be nil");
    STAssertNotNil(_splitbarView.belowView, @"Value should not be nil");
    STAssertFalse(_splitbarView.belowViewIsCollapsed, @"Value should be false");
}

- (void) testResizeViewsWithBarPosition
{
    [_splitbarView resizeViewsWithBarPosition:400];
    STAssertTrue(CGRectEqualToRect(_bottomView.frame, CGRectMake(0, 0, 200, 400)), @"Values should match");
    STAssertTrue(CGRectEqualToRect(_barView.frame, CGRectMake(0, 400, 200, 20)), @"Values should match");
    STAssertTrue(CGRectEqualToRect(_topView.frame, CGRectMake(0, 420, 200, 180)), @"Values should match");
}

- (void) testResizeView
{
    CGSize oldSize = _splitbarView.frame.size;
    _splitbarView.frame = CGRectMake(0, 0, 300, 400);
    [_splitbarView resizeSubviewsWithOldSize:oldSize];
    
    STAssertTrue(CGRectEqualToRect(_bottomView.frame, CGRectMake(0, 0, 300, 200)), @"Values should match");
    STAssertTrue(CGRectEqualToRect(_barView.frame, CGRectMake(0, 200, 300, 20)), @"Values should match");
    STAssertTrue(CGRectEqualToRect(_topView.frame, CGRectMake(0, 220, 300, 180)), @"Values should match");
}

- (void) testBelowIsCollapsed
{
    _splitbarView.belowViewIsCollapsed = YES;
    STAssertTrue(_splitbarView.belowViewIsCollapsed, @"Value should be true");
    STAssertTrue(CGRectEqualToRect(_bottomView.frame, CGRectMake(0, 0, 200, 0)), @"Values should match");
    STAssertTrue(CGRectEqualToRect(_barView.frame, CGRectMake(0, 0, 200, 20)), @"Values should match");
    STAssertTrue(CGRectEqualToRect(_topView.frame, CGRectMake(0, 20, 200, 580)), @"Values should match");
    
    _splitbarView.belowViewIsCollapsed = NO;
    STAssertFalse(_splitbarView.belowViewIsCollapsed, @"Value should be true");
    STAssertTrue(CGRectEqualToRect(_bottomView.frame, CGRectMake(0, 0, 200, 200)), @"Values should match");
    STAssertTrue(CGRectEqualToRect(_barView.frame, CGRectMake(0, 200, 200, 20)), @"Values should match");
    STAssertTrue(CGRectEqualToRect(_topView.frame, CGRectMake(0, 220, 200, 380)), @"Values should match");
    
    [_splitbarView resizeViewsWithBarPosition:0];
    STAssertTrue(_splitbarView.belowViewIsCollapsed, @"Value should be true");
    STAssertTrue(CGRectEqualToRect(_bottomView.frame, CGRectMake(0, 0, 200, 0)), @"Values should match");
    STAssertTrue(CGRectEqualToRect(_barView.frame, CGRectMake(0, 0, 200, 20)), @"Values should match");
    STAssertTrue(CGRectEqualToRect(_topView.frame, CGRectMake(0, 20, 200, 580)), @"Values should match");

    [_splitbarView resizeViewsWithBarPosition:200];
    STAssertFalse(_splitbarView.belowViewIsCollapsed, @"Value should be true");
    STAssertTrue(CGRectEqualToRect(_bottomView.frame, CGRectMake(0, 0, 200, 200)), @"Values should match");
    STAssertTrue(CGRectEqualToRect(_barView.frame, CGRectMake(0, 200, 200, 20)), @"Values should match");
    STAssertTrue(CGRectEqualToRect(_topView.frame, CGRectMake(0, 220, 200, 380)), @"Values should match");
}

@end
