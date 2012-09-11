
#import "CATextLayer+AttributedString.h"
#import <CoreFoundation/CoreFoundation.h>

@implementation CATextLayer (AttributedString)


- (NSDictionary*) fontAttributes
{
    NSFont *font = nil;
    
    /*
     
       If the font property is a CGFontRef we will need to convert
       it to a NSFont. We use CTFontCreateWithGraphicsFont for this
       as CTFontRef is toll-free bridged with NSFont.
     
     */
    if (CFGetTypeID(self.font) == CGFontGetTypeID()) {
        font = (__bridge_transfer NSFont*)CTFontCreateWithGraphicsFont((__bridge CGFontRef)font, self.fontSize, NULL, NULL);
    } else {
        font = [NSFont fontWithName:[(NSFont*)self.font fontName] size:self.fontSize];
    }
    
    return @{NSFontAttributeName: font};
}

- (NSAttributedString*) attributedString
{
    if ([self.string isKindOfClass:[NSAttributedString class]])
        return self.string;
    
    return [[NSAttributedString alloc] initWithString:self.string? self.string : @""
                                           attributes:self.fontAttributes];
}

@end
