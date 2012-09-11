
#import "NUFontFamilyMenu.h"

@implementation NUFontFamilyMenu

- (id) initWithTitle:(NSString *)aTitle andFilterPredicate:(NSPredicate*)filter
{
    if ((self = [super initWithTitle:aTitle])) {

        NSFontManager *fontManager = [NSFontManager sharedFontManager];
        NSArray *families = [fontManager availableFontFamilies];
            
        for (NSString *family in families) {
                
            NSFont *font = [fontManager fontWithFamily:family traits:0 weight:5 size:12];
            
            if (font && ((filter == nil) || [filter evaluateWithObject:font])) {
        
                NSDictionary *attributes = @{NSFontAttributeName: font};
                NSMenuItem   *fontItem   = [[NSMenuItem alloc] init];                
                fontItem.attributedTitle = [[NSAttributedString alloc] initWithString:family attributes:attributes];
                fontItem.representedObject = family;
                
                [self addItem:fontItem];
            }
        }
    }
    return self;
}

- (id) initWithTitle:(NSString *)aTitle
{
    return [self initWithTitle:aTitle andFilterPredicate:nil];
}


+ (id) fontFamilyMenuWithFilterPredicate:(NSPredicate*)filter
{
    // Autorelease managed by the ARC compiler.
    return [[self alloc] initWithTitle:@"Font Families" andFilterPredicate:filter];
}

+ (NSMenu*) fontFamilyMenu
{
    // Autorelease managed by the ARC compiler.
    return [[self alloc] initWithTitle:@"Font Families"];
}

@end
