
#import "NUBlockValueTransformer.h"

@implementation NUBlockValueTransformer // COV_NF_LINE

@synthesize transformBlock, reverseBlock;

- (id) initWithBlock:(NUBlockValueTransformerBlock)block
{
    if ((self = [super init])) {
        self.transformBlock = block;
        self.reverseBlock = block;
    }
    return self;
}

+ (id) transformerWithBlock:(NUBlockValueTransformerBlock)block
{
    return [[self alloc] initWithBlock:block];
}

+ (Class) transformedValueClass 
{ 
    return [NSObject class]; 
}

+ (BOOL)allowsReverseTransformation 
{ 
    return YES; 
}

- (id)transformedValue:(id)value 
{
    return transformBlock? transformBlock(value) : value;
}

- (id)reverseTransformedValue:(id)value
{
    return reverseBlock? reverseBlock(value) : value;
}

@end
