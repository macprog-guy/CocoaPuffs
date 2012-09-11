
#import <SenTestingKit/SenTestingKit.h>
#import "CocoaPuffs.h"

@interface NUBlockValueTransformerTests : SenTestCase {
    NUBlockValueTransformer *_transformer;
}
@end

@implementation NUBlockValueTransformerTests

- (void) setUp
{
    _transformer = [NUBlockValueTransformer transformerWithBlock:^(id value) {
        NSNumber *number = value;
        return @(number.doubleValue * 2.0);
    }];

    _transformer.reverseBlock = ^(id value) {
        NSNumber *number = value;
        return @(number.doubleValue / 2.0);
    };
}

- (void) testProperties
{
    STAssertTrue([NUBlockValueTransformer allowsReverseTransformation], @"Should allow reverse transforms");
    STAssertEqualObjects([NUBlockValueTransformer transformedValueClass], [NSObject class], @"Should transform to NSObject");
}

- (void) testTransform
{
    NSNumber *value1 = @2.3;
    NSNumber *value2 = @5.0;
    NSNumber *value3 = @0.0;
    
    NSNumber *expect1 = @4.6;
    NSNumber *expect2 = @10.0;
    NSNumber *expect3 = @0.0;
    
    STAssertEqualObjects([_transformer transformedValue:value1], expect1, @"Values should match");
    STAssertEqualObjects([_transformer transformedValue:value2], expect2, @"Values should match");
    STAssertEqualObjects([_transformer transformedValue:value3], expect3, @"Values should match");
}

- (void) testInverseTransform
{
    NSNumber *value1 = @4.6;
    NSNumber *value2 = @10.0;
    NSNumber *value3 = @0.0;
    
    NSNumber *expect1 = @2.3;
    NSNumber *expect2 = @5.0;
    NSNumber *expect3 = @0.0;
    
    STAssertEqualObjects([_transformer reverseTransformedValue:value1], expect1, @"Values should match");
    STAssertEqualObjects([_transformer reverseTransformedValue:value2], expect2, @"Values should match");
    STAssertEqualObjects([_transformer reverseTransformedValue:value3], expect3, @"Values should match");
}

@end
