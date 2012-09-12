
#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NUStackedViewTests : SenTestCase {
    NSScrollView  *_scrollView;
    NUStackedView *_stackedView;
    NSView *_view0;
    NSView *_view1;
    NSView *_view2;
}
@end

@implementation NUStackedViewTests

- (void) setUp
{
    _stackedView = [[NUStackedView alloc] initWithFrame:CGRectMake(0, 0, 200, 0)];
    
    // The stacked view will resize its subviews except for their height.
    _view0 = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 0, 100)];
    _view1 = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 0, 100)];
    _view2 = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 0, 100)];
    _stackedView.subviews = @[_view0, _view1, _view2];
    
    _scrollView = [[NSScrollView alloc] initWithFrame:CGRectMake(0, 0, 200, 600)];
    _scrollView.documentView = _stackedView;
}

- (void) testStacking
{
    STAssertFalse([NUStackedView requiresConstraintBasedLayout], @"Should return false");
    
    STAssertEquals(_stackedView.rowSpacing, 0.0, @"Values should match");
    STAssertTrue(CGRectEqualToRect(_view0.frame, CGRectMake(0,   0, 200, 100)), @"Values should match");
    STAssertTrue(CGRectEqualToRect(_view1.frame, CGRectMake(0, 100, 200, 100)), @"Values should match");
    STAssertTrue(CGRectEqualToRect(_view2.frame, CGRectMake(0, 200, 200, 100)), @"Values should match");
    
    _stackedView.rowSpacing = 10;
    
    STAssertEquals(_stackedView.rowSpacing, 10.0, @"Values should match");
    STAssertTrue(CGRectEqualToRect(_view0.frame, CGRectMake(0,   0, 200, 100)), @"Values should match");
    STAssertTrue(CGRectEqualToRect(_view1.frame, CGRectMake(0, 110, 200, 100)), @"Values should match");
    STAssertTrue(CGRectEqualToRect(_view2.frame, CGRectMake(0, 220, 200, 100)), @"Values should match");
    
    _stackedView.subviews = nil;
    STAssertNotNil(_stackedView.subviews, @"Subviews should never be nil");
    STAssertEqualObjects(_stackedView.subviews, [NSArray array], @"Values should match");
}

@end
