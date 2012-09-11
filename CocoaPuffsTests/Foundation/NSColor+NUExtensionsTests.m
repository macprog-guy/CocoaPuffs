
#import <SenTestingKit/SenTestingKit.h>
#import <QuartzCore/QuartzCore.h>
#import "NSColor+NUExtensions.h"

@interface NSColor_NUExtensionsTests : SenTestCase

@end



@implementation NSColor_NUExtensionsTests


- (void) testColorWithCGColor
{
    CGColorRef whiteCGColor = CGColorGetConstantColor(kCGColorWhite);
    CGColorRef gray50CGColor = CGColorCreateGenericRGB(0.5, 0.5, 0.5, 1);
    
    NSColor *color = [NSColor colorWithCGColor:whiteCGColor];
    STAssertEqualObjects(color, [NSColor whiteColor], @"Result not as expected");
    
    color = [NSColor colorWithCGColor:gray50CGColor];
    STAssertEqualObjects(color, [NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:1.0], @"Result not as expected");
}

- (void) testCGColor
{
    CGColorRef whiteCGColor = CGColorCreateGenericGray(1.0, 1.0);
    CGColorRef result = [NSColor whiteColor].CGColor;
    STAssertTrue(CGColorEqualToColor(whiteCGColor, result), @"Result not as expected");

    CGColorRef gray50CGColorA = CGColorCreateGenericRGB(0.5, 0.5, 0.5, 1.0);
    NSColor *gray50NSColor = [NSColor colorWithCGColor:gray50CGColorA];
    CGColorRef gray50CGColorB = gray50NSColor.CGColor;
    STAssertTrue(CGColorEqualToColor(gray50CGColorA, gray50CGColorB), @"Result not as expected");
}

- (void) testColorWithBrightnessOffset
{
    NSColor *color1  = [NSColor colorWithCalibratedHue:0.0 saturation:0.5 brightness:0.5 alpha:1.0];
    NSColor *expect1 = [NSColor colorWithCalibratedHue:0.0 saturation:0.5 brightness:0.8 alpha:1.0]; 
    NSColor *expect2 = [NSColor colorWithCalibratedHue:0.0 saturation:0.5 brightness:1.0 alpha:1.0]; 
    NSColor *expect3 = [NSColor colorWithCalibratedHue:0.0 saturation:0.5 brightness:0.0 alpha:1.0]; 
    
    NSColor *result = [color1 colorWithBrightnessOffset:0.3];
    STAssertEqualObjects(result, expect1, @"Result not as expected");

    result = [color1 colorWithBrightnessOffset:0.9];
    STAssertEqualObjects(result, expect2, @"Result not as expected");

    result = [color1 colorWithBrightnessOffset:-0.9];
    STAssertEqualObjects(result, expect3, @"Result not as expected");
}

- (void) testColorWithBrightnessMultiplier
{
    NSColor *color1  = [NSColor colorWithCalibratedHue:0.0 saturation:0.5 brightness:0.5 alpha:1.0];
    NSColor *expect1 = [NSColor colorWithCalibratedHue:0.0 saturation:0.5 brightness:0.75 alpha:1.0]; 
    NSColor *expect2 = [NSColor colorWithCalibratedHue:0.0 saturation:0.5 brightness:1.0 alpha:1.0]; 
    NSColor *expect3 = [NSColor colorWithCalibratedHue:0.0 saturation:0.5 brightness:0.0 alpha:1.0]; 
    
    NSColor *result = [color1 colorWithBrightnessMultiplier:1.5];
    STAssertEqualObjects(result, expect1, @"Result not as expected");
    
    result = [color1 colorWithBrightnessMultiplier:8.6];
    STAssertEqualObjects(result, expect2, @"Result not as expected");
    
    result = [color1 colorWithBrightnessMultiplier:0.0];
    STAssertEqualObjects(result, expect3, @"Result not as expected");
}

@end
