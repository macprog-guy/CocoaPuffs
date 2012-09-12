
#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface CGColorToNSColorValueTransformerTests : SenTestCase {
    CGColorToNSColorValueTransformer *_transformer;
}
@end

@implementation CGColorToNSColorValueTransformerTests

- (void) setUp
{
    _transformer = [[CGColorToNSColorValueTransformer alloc] init];
}

- (void) testProperties
{
    STAssertTrue([CGColorToNSColorValueTransformer allowsReverseTransformation], @"Should allow reverse transforms");
    STAssertEqualObjects([CGColorToNSColorValueTransformer transformedValueClass], [NSColor class], @"Should transform to NSColor");
}

- (void) testTransform
{
    CGColorRef cgColor1 = [NSColor yellowColor].CGColor;
    CGColorRef cgColor2 = [NSColor purpleColor].CGColor;
    CGColorRef cgColor3 = [NSColor colorWithCalibratedRed:0.45 green:0.89 blue:0.12 alpha:0.87].CGColor;

    NSColor *nsColor1 = [NSColor yellowColor];
    NSColor *nsColor2 = [NSColor purpleColor];
    NSColor *nsColor3 = [NSColor colorWithCalibratedRed:0.45 green:0.89 blue:0.12 alpha:0.87];
    
    STAssertEqualObjects(nsColor1, [_transformer transformedValue:(__bridge id)cgColor1], @"Colors should match");
    STAssertEqualObjects(nsColor2, [_transformer transformedValue:(__bridge id)cgColor2], @"Colors should match");
    STAssertEqualObjects(nsColor3, [_transformer transformedValue:(__bridge id)cgColor3], @"Colors should match");
}

- (void) testInverseTransform
{
    CGColorRef cgColor1 = [NSColor yellowColor].CGColor;
    CGColorRef cgColor2 = [NSColor purpleColor].CGColor;
    CGColorRef cgColor3 = [NSColor colorWithCalibratedRed:0.45 green:0.89 blue:0.12 alpha:0.87].CGColor;
    
    NSColor *nsColor1 = [NSColor yellowColor];
    NSColor *nsColor2 = [NSColor purpleColor];
    NSColor *nsColor3 = [NSColor colorWithCalibratedRed:0.45 green:0.89 blue:0.12 alpha:0.87];
    
    STAssertTrue(CGColorEqualToColor((__bridge CGColorRef)[_transformer reverseTransformedValue:nsColor1], cgColor1), @"Colors should match");
    STAssertTrue(CGColorEqualToColor((__bridge CGColorRef)[_transformer reverseTransformedValue:nsColor2], cgColor2), @"Colors should match");
    STAssertTrue(CGColorEqualToColor((__bridge CGColorRef)[_transformer reverseTransformedValue:nsColor3], cgColor3), @"Colors should match");
}

@end
