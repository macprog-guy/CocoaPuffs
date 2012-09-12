
#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NULayerCoordinateValueTransformerTests : SenTestCase {
    CALayer *_parentLayer;
    NULayerCoordinateValueTransformer *_transformer;
}
@end

@implementation NULayerCoordinateValueTransformerTests

- (void) setUp
{
    CALayer *layer1 = [CALayer layer];
    layer1.frame = CGRectMake(0,0,50,50);
    
    CALayer *layer2 = [CALayer layer];
    layer2.frame = CGRectMake(50,50,0,0);

    _parentLayer = [CALayer layer];
    _parentLayer.frame = CGRectMake(0,0,100,100);
    _parentLayer.sublayers = @[layer1, layer2];
    
    _transformer = [NULayerCoordinateValueTransformer transformerWithSourceLayer:layer1 andTargetLayer:layer2];
}

- (void) testProperties
{
    STAssertTrue([NULayerCoordinateValueTransformer allowsReverseTransformation], @"Should allow reverse transforms");
    STAssertEqualObjects([NULayerCoordinateValueTransformer transformedValueClass], [NSValue class], @"Should transform to NSValue");
}

- (void) testTransform
{
    NSValue *value1 = [NSValue valueWithPoint:CGPointZero];
    NSValue *value2 = [NSValue valueWithPoint:CGPointMake(50, 50)];
    NSValue *value3 = [NSValue valueWithPoint:CGPointMake(100, 100)];
    
    NSValue *expect1 = [NSValue valueWithPoint:CGPointMake(-50, -50)];
    NSValue *expect2 = [NSValue valueWithPoint:CGPointMake(0, 0)];
    NSValue *expect3 = [NSValue valueWithPoint:CGPointMake(50, 50)];
    
    STAssertEqualObjects([_transformer transformedValue:value1], expect1, @"Values should match");
    STAssertEqualObjects([_transformer transformedValue:value2], expect2, @"Values should match");
    STAssertEqualObjects([_transformer transformedValue:value3], expect3, @"Values should match");
}

- (void) testReverseTransform
{
    NSValue *value1 = [NSValue valueWithPoint:CGPointMake(-50, -50)];
    NSValue *value2 = [NSValue valueWithPoint:CGPointMake(0, 0)];
    NSValue *value3 = [NSValue valueWithPoint:CGPointMake(50, 50)];
    
    NSValue *expect1 = [NSValue valueWithPoint:CGPointZero];
    NSValue *expect2 = [NSValue valueWithPoint:CGPointMake(50, 50)];
    NSValue *expect3 = [NSValue valueWithPoint:CGPointMake(100, 100)];
    
    STAssertEqualObjects([_transformer reverseTransformedValue:value1], expect1, @"Values should match");
    STAssertEqualObjects([_transformer reverseTransformedValue:value2], expect2, @"Values should match");
    STAssertEqualObjects([_transformer reverseTransformedValue:value3], expect3, @"Values should match");
}

@end
