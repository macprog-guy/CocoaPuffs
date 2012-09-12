
#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NUPropertySheetViewTests : SenTestCase {
    
    NSWindow *_window;
    
    NUPropertySheetView     *_sheet;
    NUPropertyInspectorView *_inspector0;
    NUPropertyInspectorView *_inspector1;
    NUPropertyInspectorView *_inspector2;
}
@end

@implementation NUPropertySheetViewTests

- (void) setUp
{
    _window = [[NSWindow alloc] initWithContentRect:CGRectMake(0, 0, 100, 100)
                                          styleMask:NSBorderlessWindowMask
                                            backing:NSBackingStoreBuffered
                                              defer:YES];
    
    _inspector0 = [NUPropertyInspectorView propertyInspectorWithName:@"colors.r" label:@"Red" andControl:[[NSSlider alloc] init]];
    _inspector1 = [NUPropertyInspectorView propertyInspectorWithName:@"colors.g" label:@"Green" andControl:[[NSSlider alloc] init]];
    _inspector2 = [NUPropertyInspectorView propertyInspectorWithName:@"colors.b" label:@"Blue" andControl:[[NSSlider alloc] init]];

    _sheet = [NUPropertySheetView propertySheetWithName:@"sheet.colors" andLabel:@"Properties"];
    _sheet.frame = CGRectMake(0, 0, 100, 100);
    _sheet.inspectorViews = @[_inspector0, _inspector1, _inspector2];
    _sheet.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_window.contentView addSubview:_sheet];
    [_sheet updateConstraints];
    [_window.contentView layoutSubtreeIfNeeded];
}

- (void) testDefaultProperties
{
    STAssertTrue(_sheet.isOpaque, @"Sheets should be opaque");
    STAssertTrue(_sheet.inspectorsVisible, @"Inspectors should be visible by default");
    STAssertEqualObjects(_sheet.name, @"sheet.colors", @"Values should match");
    STAssertEqualObjects(_sheet.label, @"Properties", @"Values should match");
    STAssertTrue(_inspector2.frame.origin.y < _inspector1.frame.origin.y, @"Should be true");
    STAssertTrue(_inspector1.frame.origin.y < _inspector0.frame.origin.y, @"Should be true");
    STAssertEquals(_inspector0.frame.size.width, _sheet.frame.size.width, @"Values should match");
    STAssertEquals(_inspector1.frame.size.width, _sheet.frame.size.width, @"Values should match");
    STAssertEquals(_inspector2.frame.size.width, _sheet.frame.size.width, @"Values should match");
}

- (void) testAddRemoveInspectorView
{
    [_sheet removeInspectorView:_inspector1];
    STAssertNil(_inspector1.superview, @"Inspector should no longer be in the view hierarchy");
    STAssertEquals(_sheet.inspectorViews.count, 2ULL, @"Values should match");
    STAssertTrue(_inspector2.frame.origin.y < _inspector0.frame.origin.y, @"Should be true");
    
    [_sheet addInspectorView:_inspector1];
    [_window.contentView layoutSubtreeIfNeeded];
    
    // Inspector 1 will now be at the bottom.
    STAssertNotNil(_inspector1.superview, @"Inspector should no longer be in the view hierarchy");
    STAssertEquals(_sheet.inspectorViews.count, 3ULL, @"Values should match");
    STAssertTrue(_inspector1.frame.origin.y < _inspector2.frame.origin.y, @"Should be true");
    STAssertTrue(_inspector2.frame.origin.y < _inspector0.frame.origin.y, @"Should be true");
}

- (void) testInspectorsVisibleProperty
{
    NSButton *disclose = [_sheet valueForKey:@"headerButton"];

    _sheet.inspectorsVisible = NO;
    STAssertFalse(_sheet.inspectorsVisible, @"Value should be false");
    STAssertNotNil(disclose, @"There should be a disclose button");
    STAssertEqualObjects(disclose.objectValue, @NO, @"Should not be disclosed");
    
    _sheet.inspectorsVisible = YES;
    STAssertTrue(_sheet.inspectorsVisible, @"Value should be false");
    STAssertEqualObjects(disclose.objectValue, @YES, @"Should be disclosed");
    
    _sheet.inspectorsVisible = NO;
    STAssertFalse(_sheet.inspectorsVisible, @"Value should be false");
    STAssertEqualObjects(disclose.objectValue, @NO, @"Should not be disclosed");
}

@end
