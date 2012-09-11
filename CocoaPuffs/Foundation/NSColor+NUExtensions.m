
#import <objc/runtime.h>
#import "NSColor+NUExtensions.h"
#import "NUFunctions.h"

@implementation NSColor (NSColorConversions)

/**
 
 NOTE: This method is depricated because it is now provided by the framework.
 
+ (NSColor*) colorWithCGColor:(CGColorRef) color
{
    return color ? [NSColor colorWithCIColor:[CIColor colorWithCGColor:color]] : nil;
}

 */


/**
 
 NOTE: This method is depricated because it is now provided by the framework.
 
- (CGColorRef) CGColor
{
    static char *kCGColorKey = "CGColor";
    CGColorRef cgColor = (__bridge CGColorRef)objc_getAssociatedObject(self, kCGColorKey);
    
    if (cgColor == nil) {
    
        const NSInteger componentCount = self.numberOfComponents;
        CGFloat components[componentCount];
        [self getComponents:components];

        cgColor = CGColorCreate(self.colorSpace.CGColorSpace, components);
        
        objc_setAssociatedObject(self, kCGColorKey, CFBridgingRelease(cgColor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return cgColor;
}
 
*/

- (NSColor*) colorWithBrightnessOffset:(CGFloat)offset
{
    NSColor *hsbaColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    CGFloat h,s,b,a;
    [hsbaColor getHue:&h saturation:&s brightness:&b alpha:&a];
    
    return [NSColor colorWithCalibratedHue:h saturation:s brightness:fclamp(0.0, b+offset, 1.0) alpha:a];
}

- (NSColor*) colorWithBrightnessMultiplier:(CGFloat)factor
{
    NSColor *hsbaColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    CGFloat h,s,b,a;
    [hsbaColor getHue:&h saturation:&s brightness:&b alpha:&a];
    
    return [NSColor colorWithCalibratedHue:h saturation:s brightness:fclamp(0.0, b*factor, 1.0) alpha:a];
}

@end
