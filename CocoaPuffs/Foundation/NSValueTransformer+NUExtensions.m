
#import "NSValueTransformer+NUExtensions.h"

@implementation NSValueTransformer (NUExtensions)

-(id)transformedArrayValue:(NSArray*)array
{
    NSMutableArray *result = [NSMutableArray array];
    for (id value in array)
        [result addObject:[self transformedValue:value]];
    
    return result;
}

@end
