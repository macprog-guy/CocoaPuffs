
#import <SenTestingKit/SenTestingKit.h>
#import "CocoaPuffs.h"


@interface NSLayoutConstraint_NUExtensionsTests : SenTestCase {
    NSView   *_contentView;
    NSView   *_view0;
    NSView   *_view1;
    NSView   *_view2;
}

- (void) addTestConstraints:(NSArray*)constraints;

@end

@implementation NSLayoutConstraint_NUExtensionsTests

- (void) setUp
{
    _contentView = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    _view0 = [[NSView alloc] initWithFrame:CGRectZero];
    _view0.translatesAutoresizingMaskIntoConstraints = NO;
    _view1 = [[NSView alloc] initWithFrame:CGRectZero];
    _view1.translatesAutoresizingMaskIntoConstraints = NO;
    _view2 = [[NSView alloc] initWithFrame:CGRectZero];
    _view2.translatesAutoresizingMaskIntoConstraints = NO;
    _contentView.subviews = @[_view0, _view1, _view2];
}

- (void) addTestConstraints:(NSArray*)constraints
{
    [_contentView addConstraints:constraints];
    [_contentView setNeedsLayout:YES];
    [_contentView layoutSubtreeIfNeeded];
}


- (void) testConstraintsWithItemHavingWidth
{
    NSArray *constraints = [NSLayoutConstraint constraintsWithItem:_view0 havingWidth:20];
    [self addTestConstraints:constraints];

    STAssertNotNil(constraints, @"Result should not be nil");
    STAssertEquals(constraints.count, 1ULL, @"Fixing width requires but one constraint");
    
    NSLayoutConstraint *aConstraint = constraints.firstObject;
    STAssertEquals(aConstraint.constant, 20.0, @"Values should match");
    STAssertEquals(_view0.frame.size.width, 20.0, @"Values should match");
}

- (void) testConstraintsWithItemHavingHeight
{
    NSArray *constraints = [NSLayoutConstraint constraintsWithItem:_view0 havingHeight:20];
    [self addTestConstraints:constraints];
    
    STAssertNotNil(constraints, @"Result should not be nil");
    STAssertEquals(constraints.count, 1ULL, @"Fixing height requires but one constraint");
    
    NSLayoutConstraint *aConstraint = constraints.firstObject;
    STAssertEquals(aConstraint.constant, 20.0, @"Values should match");
    STAssertEquals(_view0.frame.size.height, 20.0, @"Values should match");
}

- (void) testConstraintsWithItemHavingMinimumWidth
{
    NSArray *constraints = [NSLayoutConstraint constraintsWithItem:_view0 havingMinimumWidth:20];
    [self addTestConstraints:constraints];
    
    STAssertNotNil(constraints, @"Result should not be nil");
    STAssertEquals(constraints.count, 1ULL, @"Fixing minimum width requires but one constraint");
    
    NSLayoutConstraint *aConstraint = constraints.firstObject;
    STAssertEquals(aConstraint.constant, 20.0, @"Values should match");
    STAssertEquals((int)aConstraint.relation, (int)NSLayoutRelationGreaterThanOrEqual, @"Values should match");
    STAssertEquals(_view0.frame.size.width, 20.0, @"Values should match");
}

- (void) testConstraintsWithItemHavingMinimumHeight
{
    NSArray *constraints = [NSLayoutConstraint constraintsWithItem:_view0 havingMinimumHeight:20];
    [self addTestConstraints:constraints];
    
    STAssertNotNil(constraints, @"Result should not be nil");
    STAssertEquals(constraints.count, 1ULL, @"Fixing minimum height requires but one constraint");
    
    NSLayoutConstraint *aConstraint = constraints.firstObject;
    STAssertEquals(aConstraint.constant, 20.0, @"Values should match");
    STAssertEquals((int)aConstraint.relation, (int)NSLayoutRelationGreaterThanOrEqual, @"Values should match");
    STAssertEquals(_view0.frame.size.height, 20.0, @"Values should match");
}

- (void) testConstraintsWithItemSpanningWidthOfSuperviewWithPadding
{
    NSArray *constraints = [NSLayoutConstraint constraintsWithItem:_view0 spanningWidthOfSuperviewWithPadding:3];
    [self addTestConstraints:constraints];

    STAssertNotNil(constraints, @"Result should not be nil");
    STAssertEquals(constraints.count, 2ULL, @"Spanning superview width requires two constraints");
    
    CGRect frame = _view0.frame;
    STAssertEquals(CGRectGetMinX(frame), 3.0, @"Values should match");
    STAssertEquals(CGRectGetWidth(frame), 84.0, @"Values should match");
}

- (void) testConstraintsWithItemsHavingEqualWidth
{
    NSArray *constraints = [NSLayoutConstraint constraintsWithItemsHavingEqualWidth:_contentView.subviews];
    [self addTestConstraints:constraints]; // Below ensures that width is not zero.
    [self addTestConstraints:[NSLayoutConstraint constraintsWithItem:_view0 havingMinimumWidth:10]];
    [self addTestConstraints:[NSLayoutConstraint constraintsWithItem:_view1 havingMinimumWidth:40]];
    [self addTestConstraints:[NSLayoutConstraint constraintsWithItem:_view2 havingMinimumWidth:30]];
    
    STAssertEquals(CGRectGetWidth(_view0.frame), 40.0, @"Values should match");
    STAssertEquals(CGRectGetWidth(_view1.frame), 40.0, @"Values should match");
    STAssertEquals(CGRectGetWidth(_view2.frame), 40.0, @"Values should match");
}

- (void) testConstraintsWithItemsHavingEqualLeftEdges
{
    NSArray *constraints = [NSLayoutConstraint constraintsWithItemsHavingEqualLeftEdges:_contentView.subviews];
    [self addTestConstraints:constraints]; // Below ensures that left edge is not zero.
    [self addTestConstraints:[NSLayoutConstraint constraintsWithItem:_view0 havingWidth:10]];
    [self addTestConstraints:[NSLayoutConstraint constraintsWithItem:_view1 spanningWidthOfSuperviewWithPadding:15.0]];
    
    STAssertEquals(CGRectGetMinX(_view0.frame), 15.0, @"Values should match");
    STAssertEquals(CGRectGetMinX(_view1.frame), 15.0, @"Values should match");
    STAssertEquals(CGRectGetMinX(_view2.frame), 15.0, @"Values should match");
}

- (void) testConstraintsWithItemsHavingEqualRightEdges
{
    NSArray *constraints = [NSLayoutConstraint constraintsWithItemsHavingEqualRightEdges:_contentView.subviews];
    [self addTestConstraints:constraints]; // Below ensures that left edge is not zero.
    [self addTestConstraints:[NSLayoutConstraint constraintsWithItem:_view0 havingWidth:23]];
    [self addTestConstraints:[NSLayoutConstraint constraintsWithItem:_view1 havingWidth:10]];
    [self addTestConstraints:[NSLayoutConstraint constraintsWithItem:_view2 spanningWidthOfSuperviewWithPadding:15.0]];
    
    STAssertEquals(CGRectGetMaxX(_view0.frame), 75.0, @"Values should match");
    STAssertEquals(CGRectGetMaxX(_view1.frame), 75.0, @"Values should match");
    STAssertEquals(CGRectGetMaxX(_view2.frame), 75.0, @"Values should match");
}

- (void) testConstraintsWithItemsEachSpanningWidthOfSuperviewWithPadding
{
    NSArray *constraints = [NSLayoutConstraint constraintsWithItems:_contentView.subviews eachSpanningWidthOfSuperviewWithPadding:5];
    [self addTestConstraints:constraints];
    
    STAssertEquals(CGRectGetWidth(_view0.frame), 80.0, @"Values should match");
    STAssertEquals(CGRectGetWidth(_view1.frame), 80.0, @"Values should match");
    STAssertEquals(CGRectGetWidth(_view2.frame), 80.0, @"Values should match");
}

- (void) testConstraintsWithItemsEachAlignedWithBaselineOfSuperview
{
    NSArray *constraints = [NSLayoutConstraint constraintsWithItemsEachAlignedWithBaselineOfSuperview:_contentView.subviews];

    [self addTestConstraints:constraints];
    [self addTestConstraints:[NSLayoutConstraint constraintsWithItem:_view0 havingHeight:20]];
    [self addTestConstraints:[NSLayoutConstraint constraintsWithItem:_view1 havingHeight:20]];
    [self addTestConstraints:[NSLayoutConstraint constraintsWithItem:_view2 havingHeight:20]];
    
    CGRect frame    = _contentView.frame;
    double baseline = CGRectGetMinY(frame) + _contentView.baselineOffsetFromBottom;
    
    double view0Offset = _view0.baselineOffsetFromBottom;
    double view1Offset = _view1.baselineOffsetFromBottom;
    double view2Offset = _view2.baselineOffsetFromBottom;
    
    double expectView0Y = baseline - view0Offset;
    double expectView1Y = baseline - view1Offset;
    double expectView2Y = baseline - view2Offset;
    
    STAssertEquals(CGRectGetMinY(_view0.frame), expectView0Y, @"Values should match");
    STAssertEquals(CGRectGetMinY(_view1.frame), expectView1Y, @"Values should match");
    STAssertEquals(CGRectGetMinY(_view2.frame), expectView2Y, @"Values should match");
}

- (void) testConstraintsWithItemsEachAlignedWithCenterYOfSuperview
{
    NSArray *constraints = [NSLayoutConstraint constraintsWithItemsEachAlignedWithCenterYOfSuperview:_contentView.subviews];
    [self addTestConstraints:constraints];
    [self addTestConstraints:[NSLayoutConstraint constraintsWithItem:_view0 havingHeight:20]];
    [self addTestConstraints:[NSLayoutConstraint constraintsWithItem:_view1 havingHeight:10]];
    [self addTestConstraints:[NSLayoutConstraint constraintsWithItem:_view2 havingHeight:60]];
    
    CGRect frame   = _contentView.frame;
    double centerY = CGRectGetMidY(frame);
    
    double expectView0Y = centerY - 10.0;
    double expectView1Y = centerY -  5.0;
    double expectView2Y = centerY - 30.0;
    
    STAssertEquals(CGRectGetMidY(_view0.frame), 45.0, @"Values should match");
    STAssertEquals(CGRectGetMidY(_view1.frame), 45.0, @"Values should match");
    STAssertEquals(CGRectGetMidY(_view2.frame), 45.0, @"Values should match");

    STAssertEquals(CGRectGetMinY(_view0.frame), expectView0Y, @"Values should match");
    STAssertEquals(CGRectGetMinY(_view1.frame), expectView1Y, @"Values should match");
    STAssertEquals(CGRectGetMinY(_view2.frame), expectView2Y, @"Values should match");
}

- (void) testConstraintsWithVisualFormats
{
    NSArray     *formats = @[@"|[_view0]|",@"|[_view1]|",@"|[_view2]|"];
    NSDictionary  *views = NSDictionaryOfVariableBindings(_view0, _view1, _view2);
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormats:formats options:0 metrics:nil views:views];
    [self addTestConstraints:constraints];
    
    STAssertEquals(CGRectGetWidth(_view0.frame), 90.0, @"Values should match");
    STAssertEquals(CGRectGetWidth(_view1.frame), 90.0, @"Values should match");
    STAssertEquals(CGRectGetWidth(_view2.frame), 90.0, @"Values should match");
}

- (void) testConstraintsForStackedItems
{
    NSArray *constraints = [NSLayoutConstraint constraintsForStackedItems:_contentView.subviews withTopPadding:@"0" itemHeight:@"20" spacing:@"10" bottomPadding:@"0"];
    [self addTestConstraints:constraints];

    STAssertEquals(CGRectGetHeight(_view0.frame), 20.0, @"Values should match");
    STAssertEquals(CGRectGetHeight(_view1.frame), 20.0, @"Values should match");
    STAssertEquals(CGRectGetHeight(_view2.frame), 20.0, @"Values should match");

    STAssertEquals(CGRectGetMinY(_view0.frame), 60.0, @"Values should match");
    STAssertEquals(CGRectGetMinY(_view1.frame), 30.0, @"Values should match");
    STAssertEquals(CGRectGetMinY(_view2.frame),  0.0, @"Values should match");
}

@end
