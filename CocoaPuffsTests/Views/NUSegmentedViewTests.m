
#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NUCustomInfo : NSObject
@property (retain) NSString *name;
@property (retain) NSImage  *image;
@property (retain) NSString *label;
@property (retain) NSString *hello;
@end

@implementation NUCustomInfo
@end


@interface NUSegmentedViewTests : SenTestCase {
    
    NUSegmentedView *_segmentedView;
    NUSegmentInfo *_button1;
    NUSegmentInfo *_button2;
    NUSegmentInfo *_button3;
    
    NSArray *_array;
    NSArrayController *_buttons;
    
    BOOL _button1WasSelected;
    BOOL _button2WasSelected;
    BOOL _button3WasSelected;
}
@end

@implementation NUSegmentedViewTests


- (void) setUp
{
    NSDictionary *dict1 = @{@"name":@"1", @"label":@"cool", @"hello":@"world", @"image":[NSImage imageNamed:NSImageNameActionTemplate]};
    _button1 = [NUSegmentInfo segmentWithObject:dict1];

    NUCustomInfo *cust2 = [[NUCustomInfo alloc] init];
    cust2.name = @"2";
    cust2.hello = @"world";
    cust2.label = @"hello";
    
    _button2 = [NUSegmentInfo segmentWithObject:cust2];
    _button2.selectAction = ^(NUSegmentInfo *segment) {
        // Does nothing but gets called.
    };

    _button3 = [NUSegmentInfo segment];
    _button3.name = @"3";
    _button3.label = @"3.1";

    _array   = @[_button1, _button2, _button3];
    _buttons = [[NSArrayController alloc] initWithContent:_array];
    
    _segmentedView = [[NUSegmentedView alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    _segmentedView.segments = @[_button1, _button2, _button3];
}

- (void) tearDown
{
    _segmentedView.segments = @[];
    _array = nil;
    _buttons = nil;
    _button1 = nil;
    _button2 = nil;
    _button3 = nil;
    _buttons = nil;
    _segmentedView = nil;
}

- (void) testDefaultProperties
{
    STAssertEquals(_segmentedView.allowsMultipleSelection, NO, @"Should NOT allow multiple selection by default");
    STAssertEquals(_segmentedView.supportsMultipleSelection, YES, @"Should support multiple selection by default");
    STAssertEquals(_segmentedView.supportsEmptySelection, NO, @"Should NOT allow empty selection by default");
    STAssertEquals(_segmentedView.segments.count, 3ULL, @"We should have three segments");
    STAssertEquals(_segmentedView.alignment, NSCenterTextAlignment, @"Default alignment should be centered");
    STAssertEquals(_segmentedView.selectionIndex, NSNotFound, @"Default should have no segment selected");
    STAssertEquals(_segmentedView.selectionIndexes.count, 0ULL, @"Default selectionIndexes should be empty");
    STAssertNil(_segmentedView.selectedObject, @"Default selection should be nil");
    STAssertEqualObjects(_segmentedView.selectedObjects, @[], @"Default selection should be empty");
    STAssertEquals(_segmentedView.segmentWidth, 0.0, @"Default value of segment width should be zero");
    
    STAssertEquals(_button1.enabled, YES, @"Values should match");
    STAssertEquals(_button1.active, NO, @"Values should match");
    STAssertEquals(_button1.pushed, NO, @"Values should match");
    STAssertEquals(_button1.selectable, YES, @"Values should match");
    STAssertEquals(_button1.selected, NO, @"Values should match");
    STAssertNotNil(_button1.description, @"Description should not be nil");
    STAssertNotNil(_button1.image, @"Values should not be nil");
    STAssertNotNil(_button1.name, @"Value should not be nil");
    STAssertNotNil(_button1.label, @"Value should not be nil");
    STAssertNotNil(_button1.representedObject, @"Value should not be nil");
    STAssertNil(_button1.selectAction, @"Value should be nil by default");
    STAssertNil(_button1.buttonAction, @"Value should be nil by default");
    
    _segmentedView.alignment = NSJustifiedTextAlignment;
    STAssertEquals(_segmentedView.alignment, NSJustifiedTextAlignment, @"Values should match");
    
    STAssertFalse(CGRectIsNull([_segmentedView selectionRectAtIndex:0]),@"Should be false");
    STAssertFalse(CGRectIsNull([_segmentedView actionRectAtIndex:0]),@"Should be false");
    STAssertTrue(CGRectIsNull([_segmentedView selectionRectAtIndex:99]),@"Should be true");
    STAssertTrue(CGRectIsNull([_segmentedView actionRectAtIndex:99]),@"Should be true");
    
    STAssertTrue(_segmentedView.frame.size.width > 30.0, @"Should be true");
}

- (void) testKeyValueContainer
{
    STAssertEqualObjects([_button1 valueForKey:@"hello"], @"world", @"Values should match");
    STAssertEqualObjects([_button2 valueForKey:@"hello"], @"world", @"Values should match");
    STAssertThrows([_button1 valueForKey:@"toto"], @"Key should not exist");
}

- (void) testUnboundSelectionIndex
{
    _segmentedView.selectionIndex = 0;
    STAssertEquals(_segmentedView.selectionIndex, 0ULL, @"Values should match");
    STAssertEquals(_segmentedView.selectedObject, _button1, @"Values should match");
    STAssertEqualObjects(_segmentedView.selectionIndexes, [NSIndexSet indexSetWithIndex:0], @"Values should match");
    STAssertEqualObjects(_segmentedView.selectedObjects, @[_button1], @"Values should match");
    STAssertEquals(_button1.selected, YES, @"Values should match");
    STAssertEquals(_button2.selected, NO, @"Values should match");
    STAssertEquals(_button3.selected, NO, @"Values should match");
    
    _segmentedView.selectionIndex = 2;
    STAssertEquals(_segmentedView.selectionIndex, 2ULL, @"Values should match");
    STAssertEquals(_segmentedView.selectedObject, _button3, @"Values should match");
    STAssertEqualObjects(_segmentedView.selectionIndexes, [NSIndexSet indexSetWithIndex:2], @"Values should match");
    STAssertEqualObjects(_segmentedView.selectedObjects, @[_button3], @"Values should match");
    STAssertEquals(_button1.selected, NO, @"Values should match");
    STAssertEquals(_button2.selected, NO, @"Values should match");
    STAssertEquals(_button3.selected, YES, @"Values should match");
    
    STAssertNoThrow(_segmentedView.selectionIndex = 99, @"Should throw exception");
    STAssertEquals(_segmentedView.selectionIndex, NSNotFound, @"Values should match");
    STAssertEquals(_button1.selected, NO, @"Values should match");
    STAssertEquals(_button2.selected, NO, @"Values should match");
    STAssertEquals(_button3.selected, NO, @"Values should match");
}

- (void) testBoundSelectionIndex
{
    [_segmentedView bind:@"segments" toObject:_buttons withKeyPath:@"arrangedObjects" options:nil];
    [_segmentedView bind:@"selectionIndex" toObject:_buttons withKeyPath:@"selectionIndex" options:nil];
    
    _segmentedView.selectionIndex = 0;
    STAssertEquals(_segmentedView.selectionIndex, 0ULL, @"Values should match");
    STAssertEquals(_segmentedView.selectedObject, _button1, @"Values should match");
    STAssertEqualObjects(_segmentedView.selectionIndexes, [NSIndexSet indexSetWithIndex:0], @"Values should match");
    STAssertEqualObjects(_segmentedView.selectedObjects, @[_button1], @"Values should match");
    STAssertEquals(_button1.selected, YES, @"Values should match");
    STAssertEquals(_button2.selected, NO, @"Values should match");
    STAssertEquals(_button3.selected, NO, @"Values should match");
    
    STAssertEquals(_buttons.selectionIndex, _segmentedView.selectionIndex, @"Values should match");
    STAssertEqualObjects(_buttons.selectionIndexes, _segmentedView.selectionIndexes, @"Values should match");
    
    _buttons.selectionIndex = 2;

    STAssertEquals(_buttons.selectionIndex, 2ULL, @"Values should match");
    STAssertEquals(_buttons.selectionIndex, _segmentedView.selectionIndex, @"Values should match");
    STAssertEqualObjects(_buttons.selectionIndexes, _segmentedView.selectionIndexes, @"Values should match");
    STAssertEquals(_button3.selected, YES, @"Values should match");
}

- (void) testUnboundSelectionIndexes
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
    NSArray *buttons   = @[_button2];
    
    // allowsMultipleSelection is NO so only the first index gets selected.
    
    _segmentedView.selectionIndexes = indexSet;
    STAssertEquals(_segmentedView.selectionIndex, 1ULL, @"Values should match");
    STAssertEquals(_segmentedView.selectedObject, _button2, @"Values should match");
    STAssertEqualObjects(_segmentedView.selectionIndexes, [NSIndexSet indexSetWithIndex:1], @"Values should match");
    STAssertEqualObjects(_segmentedView.selectedObjects, buttons, @"Values should match");
    STAssertEquals(_button1.selected, NO, @"Values should match");
    STAssertEquals(_button2.selected, YES, @"Values should match");
    STAssertEquals(_button3.selected, NO, @"Values should match");
    
    // allowsMultipleSelection is YES so all indexes get selected.

    indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
    buttons  = @[_button1, _button2];

    _segmentedView.allowsMultipleSelection = YES;
    _segmentedView.selectionIndexes = indexSet;
    STAssertEquals(_segmentedView.selectionIndex, 0ULL, @"Values should match");
    STAssertEquals(_segmentedView.selectedObject, _button1, @"Values should match");
    STAssertEqualObjects(_segmentedView.selectionIndexes, indexSet, @"Values should match");
    STAssertEqualObjects(_segmentedView.selectedObjects, buttons, @"Values should match");
    STAssertEquals(_button1.selected, YES, @"Values should match");
    STAssertEquals(_button2.selected, YES, @"Values should match");
    STAssertEquals(_button3.selected, NO, @"Values should match");
    
    indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 5)];
    buttons  = @[_button3];
    
    _segmentedView.selectionIndexes = indexSet;
    STAssertEquals(_segmentedView.selectionIndex, 2ULL, @"Values should match");
    STAssertEquals(_segmentedView.selectedObject, _button3, @"Values should match");
    STAssertEqualObjects(_segmentedView.selectionIndexes, [NSIndexSet indexSetWithIndex:2], @"Values should match");
    STAssertEqualObjects(_segmentedView.selectedObjects, buttons, @"Values should match");
    STAssertEquals(_button1.selected, NO, @"Values should match");
    STAssertEquals(_button2.selected, NO, @"Values should match");
    STAssertEquals(_button3.selected, YES, @"Values should match");
}

- (void) testBoundSelectionIndexes
{
    _segmentedView.allowsMultipleSelection = YES;
    [_segmentedView bind:@"segments" toObject:_buttons withKeyPath:@"arrangedObjects" options:nil];
    [_segmentedView bind:@"selectionIndexes" toObject:_buttons withKeyPath:@"selectionIndexes" options:nil];

    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
    NSArray *buttons   = @[_button2, _button3];
    
    _segmentedView.selectionIndexes = indexSet;
    STAssertEquals(_segmentedView.selectionIndex, 1ULL, @"Values should match");
    STAssertEquals(_segmentedView.selectedObject, _button2, @"Values should match");
    STAssertEqualObjects(_segmentedView.selectionIndexes, indexSet, @"Values should match");
    STAssertEqualObjects(_segmentedView.selectedObjects, buttons, @"Values should match");
    STAssertEquals(_button1.selected, NO, @"Values should match");
    STAssertEquals(_button2.selected, YES, @"Values should match");
    STAssertEquals(_button3.selected, YES, @"Values should match");
    
    STAssertEqualObjects(_segmentedView.selectionIndexes, _buttons.selectionIndexes, @"Values should match");

    _buttons.selectionIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];;
    STAssertEqualObjects(_segmentedView.selectionIndexes, _buttons.selectionIndexes, @"Values should match");
}

- (void) testUnboundSelectedObject
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 1)];
    NSArray *buttons = @[_button2];

    _segmentedView.selectedObject = _button2;
    STAssertEquals(_segmentedView.selectionIndex, 1ULL, @"Values should match");
    STAssertEquals(_segmentedView.selectedObject, _button2, @"Values should match");
    STAssertEqualObjects(_segmentedView.selectionIndexes, indexSet, @"Values should match");
    STAssertEqualObjects(_segmentedView.selectedObjects, buttons, @"Values should match");
    STAssertEquals(_button1.selected, NO, @"Values should match");
    STAssertEquals(_button2.selected, YES, @"Values should match");
    STAssertEquals(_button3.selected, NO, @"Values should match");

    indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
    buttons = @[_button1];
    
    _segmentedView.selectedObject = _button1;
    STAssertEquals(_segmentedView.selectionIndex, 0ULL, @"Values should match");
    STAssertEquals(_segmentedView.selectedObject, _button1, @"Values should match");
    STAssertEqualObjects(_segmentedView.selectionIndexes, indexSet, @"Values should match");
    STAssertEqualObjects(_segmentedView.selectedObjects, buttons, @"Values should match");
    STAssertEquals(_button1.selected, YES, @"Values should match");
    STAssertEquals(_button2.selected, NO, @"Values should match");
    STAssertEquals(_button3.selected, NO, @"Values should match");
    
    indexSet = [NSIndexSet indexSet];
    buttons = @[];

    _segmentedView.selectedObject = nil;
    STAssertEquals(_segmentedView.selectionIndex, NSNotFound, @"Values should match");
    STAssertNil(_segmentedView.selectedObject, @"Values should match");
    STAssertEqualObjects(_segmentedView.selectionIndexes, indexSet, @"Values should match");
    STAssertEqualObjects(_segmentedView.selectedObjects, buttons, @"Values should match");
    STAssertEquals(_button1.selected, NO, @"Values should match");
    STAssertEquals(_button2.selected, NO, @"Values should match");
    STAssertEquals(_button3.selected, NO, @"Values should match");
}

- (void) testBoundSelectedObject
{
    // NSArrayConroller does not have a selectedObject property.
}

- (void) testUnboundSelectedObjects
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
    NSArray *buttons = @[_button1];
    
    // allowsMultipleSelection is NO so only the first index gets selected.

    _segmentedView.selectedObjects = buttons;
    STAssertEquals(_segmentedView.selectionIndex, 0ULL, @"Values should match");
    STAssertEquals(_segmentedView.selectedObject, _button1, @"Values should match");
    STAssertEqualObjects(_segmentedView.selectionIndexes, [NSIndexSet indexSetWithIndex:0], @"Values should match");
    STAssertEqualObjects(_segmentedView.selectedObjects, buttons, @"Values should match");
    STAssertEquals(_button1.selected, YES, @"Values should match");
    STAssertEquals(_button2.selected, NO, @"Values should match");
    STAssertEquals(_button3.selected, NO, @"Values should match");
    
    // allowsMultipleSelection is YES so all indexes get selected.

    indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)];
    buttons = @[_button1, _button2, _button3];
    
    _segmentedView.allowsMultipleSelection = YES;
    _segmentedView.selectedObjects = buttons;
    STAssertEquals(_segmentedView.selectionIndex, 0ULL, @"Values should match");
    STAssertEquals(_segmentedView.selectedObject, _button1, @"Values should match");
    STAssertEqualObjects(_segmentedView.selectionIndexes, indexSet, @"Values should match");
    STAssertEqualObjects(_segmentedView.selectedObjects, buttons, @"Values should match");
    STAssertEquals(_button1.selected, YES, @"Values should match");
    STAssertEquals(_button2.selected, YES, @"Values should match");
    STAssertEquals(_button3.selected, YES, @"Values should match");
    
    indexSet = [NSIndexSet indexSet];
    buttons = @[];
    
    _segmentedView.selectedObjects = nil;
    STAssertEquals(_segmentedView.selectionIndex, NSNotFound, @"Values should match");
    STAssertNil(_segmentedView.selectedObject, @"Values should match");
    STAssertEqualObjects(_segmentedView.selectionIndexes, indexSet, @"Values should match");
    STAssertEqualObjects(_segmentedView.selectedObjects, buttons, @"Values should match");
    STAssertEquals(_button1.selected, NO, @"Values should match");
    STAssertEquals(_button2.selected, NO, @"Values should match");
    STAssertEquals(_button3.selected, NO, @"Values should match");
}

- (void) testBoundSelectedObjects
{
    [_segmentedView bind:@"segments" toObject:_buttons withKeyPath:@"arrangedObjects" options:nil];
    [_segmentedView bind:@"selectedObjects" toObject:_buttons withKeyPath:@"selectedObjects" options:nil];
    
    _segmentedView.selectedObjects = @[_button1, _button2];
    STAssertEqualObjects(_segmentedView.selectedObjects, _buttons.selectedObjects, @"Values should match");
    
    _buttons.selectedObjects = @[_button3];
    STAssertEqualObjects(_segmentedView.selectedObjects, _buttons.selectedObjects, @"Values should match");
}


- (void) testUnboundSegmentSelected
{
    _button1.selected = YES;
    STAssertEqualObjects(_segmentedView.selectionIndexes, [NSIndexSet indexSetWithIndex:0], @"Values should match");
    
    _button2.selected = YES;
    STAssertEqualObjects(_segmentedView.selectionIndexes, [NSIndexSet indexSetWithIndex:1], @"Values should match");

    _segmentedView.allowsMultipleSelection = YES;

    _button1.selected = YES;
    STAssertEqualObjects(_segmentedView.selectionIndexes, [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,2)], @"Values should match");

    _button3.selected = YES;
    STAssertEqualObjects(_segmentedView.selectionIndexes, [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,3)], @"Values should match");
}

- (void) testSetSegmentsWithPreSelection
{
    _segmentedView.segments = nil;
    _button1.selected = YES;
    _button2.selected = YES;
    
    // allowsMultipleSelection is NO so only button1 gets selected.
    _segmentedView.segments = @[_button1, _button2, _button3];
    STAssertEqualObjects(_segmentedView.selectionIndexes, [NSIndexSet indexSetWithIndex:0], @"Values should match");
    STAssertEquals(_button1.selected, YES, @"Values should match");
    STAssertEquals(_button2.selected, NO, @"Values should match");

    _segmentedView.segments = nil;
    _segmentedView.allowsMultipleSelection = YES;
    _button1.selected = YES;
    _button2.selected = YES;
    _segmentedView.segments = @[_button1, _button2, _button3];
    STAssertEqualObjects(_segmentedView.selectionIndexes, [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,2)], @"Values should match");
}

- (void) testAlignmentAndSegmentWidth
{
    _segmentedView.alignment = NSRightTextAlignment;
    STAssertEquals(_segmentedView.alignment, NSRightTextAlignment, @"Values should match");
    
    _segmentedView.segmentWidth = 100;
    STAssertEquals(_segmentedView.frame.size.width, 300.0, @"Values should match");
}

@end
