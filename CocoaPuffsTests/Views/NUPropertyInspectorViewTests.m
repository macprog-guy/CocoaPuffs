
#import <SenTestingKit/SenTestingKit.h>
#import "CocoaPuffs.h"

@interface NUPropertyInspectorViewTests : SenTestCase {
    NSWindow *_window;
    NUPropertyInspectorView *_inspector;
}
@end

@implementation NUPropertyInspectorViewTests

- (void) setUp
{
    _window = [[NSWindow alloc] initWithContentRect:CGRectMake(0, 0, 100, 100)
                                          styleMask:NSBorderlessWindowMask
                                            backing:NSBackingStoreBuffered
                                              defer:YES];
    
    _inspector = [NUPropertyInspectorView propertyInspectorWithName:@"inspector.property"
                                                              label:@"property"
                                                          andControl:[[NSTextField alloc] init]];
    _inspector.frame = CGRectMake(0, 0, 100, 28);
    [_window.contentView addSubview:_inspector];
    [_inspector updateConstraints];
}

- (void) testDefaultProperties
{
    STAssertEqualObjects(_inspector.name, @"inspector.property", @"Values should match");
    STAssertEqualObjects(_inspector.label, @"property", @"Values should match");
    STAssertNotNil(_inspector.labelField, @"Value should not be nil");
    STAssertEqualObjects(_inspector.labelField.stringValue, @"property", @"Values should match");
    STAssertNotNil(_inspector.valueControl, @"Value should not be nil");
    STAssertTrue([_inspector.valueControl isKindOfClass:[NSTextField class]], @"Should be a text field");
    STAssertNil(_inspector.textField, @"Value should be nil");
    STAssertNil(_inspector.units, @"Value should be nil");
    STAssertNil(_inspector.unitsField, @"Value should be nil");
    STAssertTrue(_inspector.resizableControl, @"Control should be resizable by default");
    STAssertFalse(_inspector.translatesAutoresizingMaskIntoConstraints, @"Should not use resizing mask");
    STAssertTrue(_inspector.constraints.isNotEmpty, @"There should be some constraints");
    
    STAssertTrue([_inspector.labelField.cell controlSize] == NSSmallControlSize, @"Inspectors should use small controls");
    STAssertTrue([_inspector.valueControl.cell controlSize] == NSSmallControlSize, @"Inspectors should use small controls");
    STAssertTrue([[_inspector.labelField.cell font] fontSize] == [NSFont systemFontSizeForControlSize:NSSmallControlSize], @"Inspectors should use small font size");
}

- (void) testLabelProperty
{
    _inspector.label = @"Another Label";
    STAssertEqualObjects(_inspector.label, @"Another Label", @"Values should match");
    STAssertEqualObjects(_inspector.labelField.stringValue, @"Another Label", @"Values should match");
}

- (void) testUnitsProperty
{
    STAssertNil(_inspector.unitsField, @"Value should be nil");
    
    _inspector.units = @"GB";
    [_inspector updateConstraints];
    
    NSTextField *field = _inspector.unitsField;
    
    STAssertEqualObjects(_inspector.units, @"GB", @"Values should match");
    STAssertNotNil(field, @"Value should no longer be nil");
    STAssertEqualObjects(field.stringValue, @"GB", @"Values should match");
    STAssertTrue([field.cell controlSize] == NSSmallControlSize, @"Inspectors should use small controls");
    STAssertTrue([[field.cell font] fontSize] == [NSFont systemFontSizeForControlSize:NSSmallControlSize], @"Inspectors should use small font size");
    
    _inspector.units = nil;
    STAssertNil(_inspector.units, @"Value should be nil");
    STAssertNil(_inspector.unitsField, @"Value should no longer be nil");
}

- (void) testTextFieldProperty
{
    _inspector.textField = [[NSTextField alloc] init];
    [_inspector updateConstraints];

    NSTextField *field = _inspector.textField;
    
    STAssertNotNil(field, @"Value should no longer be nil");
    STAssertTrue([field.cell controlSize] == NSSmallControlSize, @"Inspectors should use small controls");
    STAssertTrue([[field.cell font] fontSize] == [NSFont systemFontSizeForControlSize:NSSmallControlSize], @"Inspectors should use small font size");
    
    _inspector.units = @"GB";
    [_inspector updateConstraints];
    
    _inspector.textField = nil;
    STAssertNil(_inspector.textField, @"Value should be nil");
    
}

@end
