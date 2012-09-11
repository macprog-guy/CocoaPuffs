
#import <SenTestingKit/SenTestingKit.h>
#import "CocoaPuffs.h"

@interface NUBoolToNSColorValueTransformerTests : SenTestCase

@end

@implementation NUBoolToNSColorValueTransformerTests

- (void) testProperties
{
    STAssertFalse([NUBoolToNSColorValueTransformer allowsReverseTransformation], @"Should allow reverse transforms");
    STAssertEqualObjects([NUBoolToNSColorValueTransformer transformedValueClass], [NSColor class], @"Should transform to NSColor");
}

- (void) testTransform
{
    NSNumber *value1 = @YES;
    NSNumber *value2 = @NO;
    NSNumber *value3 = nil;
    
    NSColor *expect1 = [NSColor blackColor];
    NSColor *expect2 = [NSColor redColor];
    NSColor *expect3 = [NSColor redColor];
    
    NUBoolToNSColorValueTransformer *transformer1 = [[NUBoolToNSColorValueTransformer alloc] initWithYesColor:[NSColor blackColor] andNoColor:[NSColor redColor]];
    NUBoolToNSColorValueTransformer *transformer2 = [[NUBoolToNSColorValueTransformer alloc] init];
    
    STAssertEqualObjects([transformer1 transformedValue:value1], expect1, @"Values should match");
    STAssertEqualObjects([transformer1 transformedValue:value2], expect2, @"Values should match");
    STAssertEqualObjects([transformer1 transformedValue:value3], expect3, @"Values should match");

    NSColor *yesColor = [NSColor textColor];
    NSColor *noColor  = [NSColor secondarySelectedControlColor];
    
    STAssertEqualObjects([transformer2 transformedValue:value1], yesColor, @"Values should match");
    STAssertEqualObjects([transformer2 transformedValue:value2], noColor, @"Values should match");
    STAssertEqualObjects([transformer2 transformedValue:value3], noColor, @"Values should match");
}

@end
