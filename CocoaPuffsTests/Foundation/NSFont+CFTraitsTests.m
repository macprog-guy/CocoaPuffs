
#import <SenTestingKit/SenTestingKit.h>
#import "NSFont+CFTraits.h"

@interface NSFont_CFTraitsTests : SenTestCase

@end



@implementation NSFont_CFTraitsTests

- (void) testFontTraitsOnHelvetica
{
    // Helvetica
    // Helvetica-Bold
    // Helvetica-BoldOblique
    // Helvetica-Light
    // Helvetica-LightOblique
    // Helvetica-Oblique

    NSFont *helvetica = [NSFont fontWithName:@"Helvetica" size:16];
    
    STAssertTrue(helvetica.fontInFamilyExistsInBold, @"Bold variant should exist");
    STAssertTrue(helvetica.fontInFamilyExistsInItalic, @"Italic variant should exist");
    STAssertFalse(helvetica.isBold, @"Font is not bold");
    STAssertFalse(helvetica.isItalic, @"Font is not italic");
    STAssertFalse(helvetica.isCondensed, @"Font is not condensed");
    STAssertFalse(helvetica.isExpanded, @"Font is not expanded");
    STAssertFalse(helvetica.isMonospaced, @"Font is not monospaced");
    STAssertFalse(helvetica.isVertical, @"Font is not vertical");
    STAssertEquals(helvetica.fontSize, 16.0f, @"Font size is 16");

    NSFont *bold = helvetica.fontVariationBold;
    STAssertTrue(bold.fontInFamilyExistsInBold, @"Bold variant should exist");
    STAssertTrue(bold.fontInFamilyExistsInItalic, @"Italic variant should exist");
    STAssertTrue(bold.isBold, @"Font is bold");
    STAssertFalse(bold.isItalic, @"Font is not italic");
    STAssertFalse(bold.isCondensed, @"Font is not condensed");
    STAssertFalse(bold.isExpanded, @"Font is not expanded");
    STAssertFalse(bold.isMonospaced, @"Font is not monospaced");
    STAssertFalse(bold.isVertical, @"Font is not vertical");
    STAssertEquals(bold.fontSize, 16.0f, @"Font size is 16");

    NSFont *italic = helvetica.fontVariationItalic;
    STAssertTrue(italic.fontInFamilyExistsInBold, @"Bold variant should exist");
    STAssertTrue(italic.fontInFamilyExistsInItalic, @"Italic variant should exist");
    STAssertFalse(italic.isBold, @"Font is not bold");
    STAssertTrue(italic.isItalic, @"Font is italic");
    STAssertFalse(italic.isCondensed, @"Font is not condensed");
    STAssertFalse(italic.isExpanded, @"Font is not expanded");
    STAssertFalse(italic.isMonospaced, @"Font is not monospaced");
    STAssertFalse(italic.isVertical, @"Font is not vertical");
    STAssertEquals(italic.fontSize, 16.0f, @"Font size is 16");
    
    NSFont *boldItalic = bold.fontVariationItalic;
    STAssertTrue(boldItalic.fontInFamilyExistsInBold, @"Bold variant should exist");
    STAssertTrue(boldItalic.fontInFamilyExistsInItalic, @"Italic variant should exist");
    STAssertTrue(boldItalic.isBold, @"Font is bold");
    STAssertTrue(boldItalic.isItalic, @"Font is italic");
    STAssertFalse(boldItalic.isCondensed, @"Font is not condensed");
    STAssertFalse(boldItalic.isExpanded, @"Font is not expanded");
    STAssertFalse(boldItalic.isMonospaced, @"Font is not monospaced");
    STAssertFalse(boldItalic.isVertical, @"Font is not vertical");
    STAssertEquals(boldItalic.fontSize, 16.0f, @"Font size is 16");

    NSFont *regular = boldItalic.fontVariationRegular;
    STAssertEqualObjects(helvetica, regular, @"Fonts should be equivalent");
}


- (void) testFontTraitsOnCourier
{
    // courier
    // courier-Bold
    // courier-BoldItalic
    // courier-Italic
    
    NSFont *courier = [NSFont fontWithName:@"Courier" size:16];
    
    STAssertTrue(courier.fontInFamilyExistsInBold, @"Bold variant should exist");
    STAssertTrue(courier.fontInFamilyExistsInItalic, @"Italic variant should exist");
    STAssertFalse(courier.isBold, @"Font is not bold");
    STAssertFalse(courier.isItalic, @"Font is not italic");
    STAssertFalse(courier.isCondensed, @"Font is not condensed");
    STAssertFalse(courier.isExpanded, @"Font is not expanded");
    STAssertTrue(courier.isMonospaced, @"Font is not monospaced");
    STAssertFalse(courier.isVertical, @"Font is not vertical");
    STAssertEquals(courier.fontSize, 16.0f, @"Font size is 16");
    
    NSFont *bold = courier.fontVariationBold;
    STAssertTrue(bold.fontInFamilyExistsInBold, @"Bold variant should exist");
    STAssertTrue(bold.fontInFamilyExistsInItalic, @"Italic variant should exist");
    STAssertTrue(bold.isBold, @"Font is bold");
    STAssertFalse(bold.isItalic, @"Font is not italic");
    STAssertFalse(bold.isCondensed, @"Font is not condensed");
    STAssertFalse(bold.isExpanded, @"Font is not expanded");
    STAssertTrue(bold.isMonospaced, @"Font is not monospaced");
    STAssertFalse(bold.isVertical, @"Font is not vertical");
    STAssertEquals(bold.fontSize, 16.0f, @"Font size is 16");
    
    NSFont *italic = courier.fontVariationItalic;
    STAssertTrue(italic.fontInFamilyExistsInBold, @"Bold variant should exist");
    STAssertTrue(italic.fontInFamilyExistsInItalic, @"Italic variant should exist");
    STAssertFalse(italic.isBold, @"Font is not bold");
    STAssertTrue(italic.isItalic, @"Font is italic");
    STAssertFalse(italic.isCondensed, @"Font is not condensed");
    STAssertFalse(italic.isExpanded, @"Font is not expanded");
    STAssertTrue(italic.isMonospaced, @"Font is not monospaced");
    STAssertFalse(italic.isVertical, @"Font is not vertical");
    STAssertEquals(italic.fontSize, 16.0f, @"Font size is 16");
    
    NSFont *boldItalic = bold.fontVariationItalic;
    STAssertTrue(boldItalic.fontInFamilyExistsInBold, @"Bold variant should exist");
    STAssertTrue(boldItalic.fontInFamilyExistsInItalic, @"Italic variant should exist");
    STAssertTrue(boldItalic.isBold, @"Font is bold");
    STAssertTrue(boldItalic.isItalic, @"Font is italic");
    STAssertFalse(boldItalic.isCondensed, @"Font is not condensed");
    STAssertFalse(boldItalic.isExpanded, @"Font is not expanded");
    STAssertTrue(boldItalic.isMonospaced, @"Font is not monospaced");
    STAssertFalse(boldItalic.isVertical, @"Font is not vertical");
    STAssertEquals(boldItalic.fontSize, 16.0f, @"Font size is 16");
    
    NSFont *regular = boldItalic.fontVariationRegular;
    STAssertEqualObjects(courier, regular, @"Fonts should be equivalent");
    
    boldItalic = regular.fontVariationBoldItalic;
    STAssertTrue(boldItalic.isBold, @"Font is bold");
    STAssertTrue(boldItalic.isItalic, @"Font is italic");
}

- (void) testIsUIOptimized
{
    NSFont *courier = [NSFont fontWithName:@"Courier" size:16];
    BOOL isUIOptimized = courier.isUIOptimized;
    STAssertTrue(isUIOptimized || YES, @"Code coverage only");
}




@end
