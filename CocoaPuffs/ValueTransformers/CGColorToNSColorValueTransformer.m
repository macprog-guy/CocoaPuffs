
#import "CGColorToNSColorValueTransformer.h"

@implementation CGColorToNSColorValueTransformer

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    // Transform CGColorRef into NSColor
    return [NSColor colorWithCGColor:(__bridge CGColorRef)value];
}

- (id)reverseTransformedValue:(id)value
{
    // Transform NSColor to CGColor
    return (__bridge id)[(NSColor*)value CGColor];
}

+ (Class) transformedValueClass
{
    return [NSColor class];
}

+ (void) load
{
    CGColorToNSColorValueTransformer *transformer = [[CGColorToNSColorValueTransformer alloc] init];
    [self setValueTransformer:transformer forName:@"CGColorToNSColor"];
}


@end
