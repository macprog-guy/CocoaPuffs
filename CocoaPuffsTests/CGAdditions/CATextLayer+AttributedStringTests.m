
#import <SenTestingKit/SenTestingKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface CATextLayer_AttributedStringTests : SenTestCase

@end



@implementation CATextLayer_AttributedStringTests

- (void) testFontAttributes
{
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.string = @"Hello";
    textLayer.fontSize = 32.0;
    textLayer.font = (__bridge CFTypeRef)([NSFont fontWithName:@"Courier" size:12.0]);

    // Test with NSFont
    NSDictionary *attributes = textLayer.fontAttributes;
    NSFont *font = [attributes objectForKey:NSFontAttributeName];
    
    STAssertEqualObjects(font.fontName, @"Courier", @"Font name is not as expected");
    STAssertEquals(font.fontSize, 32.0f, @"Font size is not as expected");
    
    // Test with CGFont
    CGFontRef anotherFont = CGFontCreateWithFontName((__bridge CFStringRef)@"LucidaGrande");
    textLayer.font = anotherFont;
    textLayer.fontSize = 16.4;
    
    attributes = textLayer.fontAttributes;
    font = [attributes objectForKey:NSFontAttributeName];

    STAssertEqualObjects(font.fontName, @"LucidaGrande", @"Font name is not as expected");
    STAssertEquals(font.fontSize, 16.4f, @"Font size is not as expected");

    CGFontRelease(anotherFont);
}

- (void) testAttributedString
{
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.string = @"Hello";
    textLayer.fontSize = 32.0;
    textLayer.font = (__bridge CFTypeRef)([NSFont fontWithName:@"Courier" size:12.0]);

    // Test with normal string
    NSAttributedString *attrString = textLayer.attributedString;
    NSRange courierRange = NSMakeRange(0, 0);
    
    [attrString attribute:NSFontAttributeName atIndex:0 longestEffectiveRange:&courierRange inRange:NSMakeRange(0, 5)];
    
    STAssertEqualObjects(attrString.string, @"Hello", @"String content not as expected");
    STAssertEquals(courierRange.location, 0ULL, @"The entire string should have the courier font");
    STAssertEquals(courierRange.length, 5ULL, @"The entire string should have the courier font");
    
    // Test with nil string
    textLayer.string = nil;
    attrString = textLayer.attributedString;
    STAssertEqualObjects(attrString.string, @"", @"String content not as expected");
    
    
    // Test with an attributed string
    NSDictionary *coolAttr = @{NSFontAttributeName: [NSFont fontWithName:@"Courier" size:15.0]};
    
    NSMutableAttributedString *coolString = [[NSMutableAttributedString alloc] initWithString:@"World" attributes:coolAttr];
    textLayer.string = coolString;
    
    attrString = textLayer.attributedString;
    [attrString attribute:NSFontAttributeName atIndex:0 longestEffectiveRange:&courierRange inRange:NSMakeRange(0, 5)];
    
    STAssertEqualObjects(attrString.string, @"World", @"String content not as expected");
    STAssertEquals(courierRange.location, 0ULL, @"The entire string should have the courier font");
    STAssertEquals(courierRange.length, 5ULL, @"The entire string should have the courier font");
}


@end
