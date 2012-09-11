
#import "NUBoolToNSColorValueTransformer.h"

@implementation NUBoolToNSColorValueTransformer

@synthesize yesColor, noColor;

- (id) initWithYesColor:(NSColor*)yColor andNoColor:(NSColor*)nColor
{
    if ((self = [super init])) {
        self.yesColor = yColor;
        self.noColor  = nColor;
    }
    return self;
}

- (id) init
{
    return [self initWithYesColor:[NSColor textColor] 
                       andNoColor:[NSColor secondarySelectedControlColor]];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    return [(NSNumber*)value boolValue]? yesColor : noColor;
}

+ (Class) transformedValueClass
{
    return [NSColor class];
}


@end
