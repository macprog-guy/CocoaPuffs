
#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NUFontSelectionHelperTests : SenTestCase {
    NSFont *_font;
    NUFontSelectionHelper *_helper;
}
@property (retain) NSFont *font;
@end

@implementation NUFontSelectionHelperTests

- (void) setUp
{
    _font = [NSFont fontWithName:@"Helvetica" size:16.0];
    _helper = [[NUFontSelectionHelper alloc] init];
    [_helper bind:@"font" toObject:self withKeyPath:@"font" options:nil];
}

- (void) testWithHelvetica
{
    STAssertEqualObjects(_font, _helper.font, @"Values should be equal");
    STAssertEquals(_font.fontSize, _helper.fontSize, @"Values should be equal");
    STAssertEqualObjects(_font.familyName, _helper.fontFamily, @"Values should be equal");
    STAssertFalse(_helper.isBold, @"Value is not as expected");
    STAssertFalse(_helper.isItalic, @"Value is not as expected");
    STAssertTrue(_helper.fontInFamilyExistsInBold, @"Value is not as expected");
    STAssertTrue(_helper.fontInFamilyExistsInItalic, @"Value is not as expected");
    
    // Apply changes to font and check for corresponding changes in helper.
    self.font = _font.fontVariationBold;
    STAssertTrue(_font.isBold, @"Value not as expected");
    STAssertTrue(_helper.isBold, @"Value not as expected");

    self.font = _font.fontVariationItalic;
    STAssertTrue(_font.isBold, @"Value not as expected");
    STAssertTrue(_helper.isBold, @"Value not as expected");
    STAssertTrue(_font.isItalic, @"Value not as expected");
    STAssertTrue(_helper.isItalic, @"Value not as expected");

    self.font = [NSFont fontWithName:@"Courier" size:12.0];
    STAssertEquals(_font.familyName, _helper.fontFamily, @"Value not as expected");
    STAssertEquals(_font.fontSize, _helper.fontSize, @"Value not as expected");
    STAssertFalse(_helper.isBold, @"Value is not as expected");
    STAssertFalse(_helper.isItalic, @"Value is not as expected");
    STAssertTrue(_helper.fontInFamilyExistsInBold, @"Values not as expected");
    STAssertTrue(_helper.fontInFamilyExistsInItalic, @"Values not as expected");
    
    // Apply changes to helper and check for corresponding changes in font.
    _helper.fontSize = 99.0;
    STAssertEquals(_font.fontSize, 99.0f, @"Value not as expected");
    _helper.isBold = YES;
    STAssertTrue(_font.isBold, @"Value not as expected");
    _helper.isBold = NO;
    _helper.isItalic = YES;
    STAssertFalse(_font.isBold, @"Value not as expected");
    STAssertTrue(_font.isItalic, @"Value not as expected");
    _helper.fontFamily = @"Helvetica";
    STAssertEqualObjects(_font.familyName, @"Helvetica", @"Value not as expected");
}

@end
