
#import "NURoundingValueTransformer.h"

@implementation NURoundingValueTransformer

@synthesize rounding, multiplier, constant;

- (id) initWithRoundingFactor:(double)aRounding
                   multiplier:(double)aMultiplier
                     constant:(double)aConstant
{
    if ((self = [super init])) {
        rounding   = aRounding;
        multiplier = aMultiplier;
        constant   = aConstant;
    }
    return self;
}


+ (Class) transformedValueClass 
{ 
    return [NSNumber class]; 
}

+ (BOOL)allowsReverseTransformation 
{ 
    return YES; 
}

- (id)transformedValue:(id)value {
    
    if (value == nil)
        return nil;
    
    long double a = [(NSNumber*)value doubleValue];
    long double b = a * multiplier + constant;
    long double c = roundl(b / rounding) * rounding;

    return @((double)c);
}

- (id)reverseTransformedValue:(id)value
{
    if (value == nil)
        return nil;
    
    long double a = [(NSNumber*)value doubleValue];
    long double b = (a - constant) / multiplier;
    
    // There is no rounding of the reverse transform
    return @((double)b);
}

@end
