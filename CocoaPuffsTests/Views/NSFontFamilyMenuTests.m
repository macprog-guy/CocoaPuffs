
#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NSFontFamilyMenuTests : SenTestCase

@end

@implementation NSFontFamilyMenuTests

- (void) testBasicMenu
{
    NUFontFamilyMenu *menu = [NUFontFamilyMenu fontFamilyMenu];

    STAssertNotNil(menu, @"Value should not be nil");
    for (NSString *fontFamily in @[@"Courier",@"Helvetica",@"Arial",@"Times"]) {
        STAssertNotNil([menu itemWithTitle:fontFamily], @"%@ should be a menu item", fontFamily);
    }
}

- (void) testFilteredMenu
{
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"familyName BEGINSWITH[c] 'C'"];
    NUFontFamilyMenu *menu = [NUFontFamilyMenu fontFamilyMenuWithFilterPredicate:filter];

    STAssertNotNil(menu, @"Value should not be nil");
    for (NSString *fontFamily in @[@"Courier"]) {
        STAssertNotNil([menu itemWithTitle:fontFamily], @"%@ should be a menu item", fontFamily);
    }
    
    for (NSString *fontFamily in @[@"Helvetica",@"Arial",@"Times"]) {
        STAssertNil([menu itemWithTitle:fontFamily], @"%@ should be a menu item", fontFamily);
    }
}

@end
