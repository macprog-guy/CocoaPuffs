
#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NUSegmentedSheetViewTests : SenTestCase

@end

@implementation NUSegmentedSheetViewTests

- (void) testDefaultProperties
{
    // Just for code coverage.
    NUSegmentedSheetView *sheetView = [[NUSegmentedSheetView alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    NUSegmentInfo *sheet0 = [NUSegmentInfo segment];
    NUSegmentInfo *sheet1 = [NUSegmentInfo segment];
    NUSegmentInfo *sheet2 = [NUSegmentInfo segment];
    sheet2.name  = @"Sheet2";
    sheet2.label = @"A really really really long name so that the width exceeds 180";
    sheet2.image = [NSImage imageNamed:NSImageNameActionTemplate];
    sheet2.selectAction = ^(NUSegmentInfo *segment) { };
    sheet2.buttonAction = ^(NUSegmentInfo *segment) { };
    sheetView.segments = @[sheet0, sheet1, sheet2];
    
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:CGRectMake(0, 0, 1000, 20)];
    scrollView.documentView  = sheetView;
    
    STAssertNotNil(sheetView, @"Should not be nil");
    STAssertEquals(sheetView.supportsMultipleSelection, NO, @"Values should match");
    STAssertEquals(sheetView.supportsEmptySelection, NO, @"Values should match");
}

@end
