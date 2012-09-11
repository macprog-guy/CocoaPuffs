
#import "NULayerCoordinateValueTransformer.h"


@interface NULayerCoordinateValueTransformer() {
    CALayer *_aLayer;
    CALayer *_bLayer;
}
@end

@implementation NULayerCoordinateValueTransformer // COV_NF_LINE

- (id) initWithSourceLayer:(CALayer*)aLayer andTargetLayer:(CALayer*)bLayer
{
    if ((self = [super init])) {
        _aLayer = aLayer;
        _bLayer = bLayer;
    }
    return self;
}

+ (id) transformerWithSourceLayer:(CALayer*)aLayer andTargetLayer:(CALayer*)bLayer
{
    return [[self alloc] initWithSourceLayer:aLayer andTargetLayer:bLayer];
}

+ (Class) transformedValueClass
{
    return [NSValue class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    NSPoint p = [value pointValue];
    NSPoint q = [_aLayer convertPoint:p toLayer:_bLayer];
    
    return [NSValue valueWithPoint:q];
}

- (id)reverseTransformedValue:(id)value
{
    NSPoint p = [value pointValue];
    NSPoint q = [_bLayer convertPoint:p toLayer:_aLayer];
    
    return [NSValue valueWithPoint:q];
}


@end
