
#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NURoundingValueTransformerTests : SenTestCase

@end

@implementation NURoundingValueTransformerTests

- (void) testProperties
{
    STAssertTrue([NURoundingValueTransformer allowsReverseTransformation], @"Should allow reverse transforms");
    STAssertEqualObjects([NURoundingValueTransformer transformedValueClass], [NSNumber class], @"Should transform to NSNumber");
}

- (void) testTransform
{
    NSNumber *value1 = @2.3333;
    NSNumber *value2 = @5.1931;
    NSNumber *value3 = @110.987;
    NSNumber *value4 = nil;
    
    NSNumber *expect1 = @2.0;
    NSNumber *expect2 = @11.4;
    NSNumber *expect3 = @120.0;
    NSNumber *expect4 = nil;
    
    NURoundingValueTransformer *transformer = [[NURoundingValueTransformer alloc] initWithRoundingFactor:1 multiplier:1 constant:0];

    STAssertEquals(transformer.rounding  , 1.0, @"Values should match");
    STAssertEquals(transformer.multiplier, 1.0, @"Values should match");
    STAssertEquals(transformer.constant  , 0.0, @"Values should match");
    STAssertEqualObjects([transformer transformedValue:value1], expect1, @"Values should match");
    
    transformer.rounding   = 0.1;
    transformer.multiplier = 2;
    transformer.constant   = 1;
    
    STAssertEqualObjects([transformer transformedValue:value2], expect2, @"Values should match");
    
    transformer.rounding   = 20;
    transformer.multiplier = 1;
    transformer.constant   = 0;
    
    STAssertEqualObjects([transformer transformedValue:value3], expect3, @"Values should match");
    STAssertEqualObjects([transformer transformedValue:value4], expect4, @"Values should match");
}

- (void) testReverseTransform
{
    NSNumber *value1 = @2.0;
    NSNumber *value2 = @11.4;
    NSNumber *value3 = @120.0;
    NSNumber *value4 = nil;
    
    NSNumber *expect1 = @2.0;
    NSNumber *expect2 = @5.2;
    NSNumber *expect3 = @120.0;
    NSNumber *expect4 = nil;

    NURoundingValueTransformer *transformer = [[NURoundingValueTransformer alloc] initWithRoundingFactor:1 multiplier:1 constant:0];
    
    STAssertEqualObjects([transformer reverseTransformedValue:value1], expect1, @"Values should match");
    
    transformer.rounding   = 0.1;
    transformer.multiplier = 2;
    transformer.constant   = 1;

    STAssertEqualObjects([transformer reverseTransformedValue:value2], expect2, @"Values should match");
    
    transformer.rounding   = 20;
    transformer.multiplier = 1;
    transformer.constant   = 0;

    STAssertEqualObjects([transformer reverseTransformedValue:value3], expect3, @"Values should match");
    STAssertEqualObjects([transformer reverseTransformedValue:value4], expect4, @"Values should match");
}

@end
