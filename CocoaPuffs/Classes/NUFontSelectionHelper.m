
#import "NUFontSelectionHelper.h"
#import "NSFont+CFTraits.h"
#import "NSObject+NUExtensions.h"


@interface NUFontSelectionHelper() {

    NSFont   *_font;
    NSString *_fontFamily;
    float     _fontSize;
    
    BOOL  _isBold:1;
    BOOL  _isItalic:1;
    BOOL  _fontInFamilyExistsInBold:1;
    BOOL  _fontInFamilyExistsInItalic:1;
}
@end

@implementation NUFontSelectionHelper // COV_NF_LINE

// -----------------------------------------------------------------------------
   #pragma mark Properties
// -----------------------------------------------------------------------------

- (BOOL) isBold
{
    return _isBold;
}

- (NSString*) fontFamily
{
    return _fontFamily;
}

- (void) setFontFamily:(NSString *)value
{
    _fontFamily = value;
    [self updateFont];
}

- (float) fontSize
{
    return _fontSize;
}

- (void) setFontSize:(float)value
{
    _fontSize = value;
    [self updateFont];
}

- (void) setIsBold:(BOOL)value
{
    _isBold = value;
    [self updateFont];
}

- (BOOL) isItalic
{
    return _isItalic;
}

- (void) setIsItalic:(BOOL)value
{
    _isItalic = value;
    [self updateFont];
}




// -----------------------------------------------------------------------------
   #pragma mark Properties
// -----------------------------------------------------------------------------

- (void) setFont:(NSFont *)value
{
    if (! [value isEqual:_font]) {
        _font = value;
        _fontSize = value.fontSize;
        _isBold = _font.isBold;
        _isItalic = _font.isItalic;
        _fontFamily = _font.familyName;
        _fontInFamilyExistsInBold = _font.fontInFamilyExistsInBold;
        _fontInFamilyExistsInItalic = _font.fontInFamilyExistsInItalic;
    }
}


// -----------------------------------------------------------------------------
   #pragma mark Helpers
// -----------------------------------------------------------------------------

- (void) updateFont
{
    NSFontTraitMask fontTraits = (_isBold ? NSBoldFontMask : 0) + (_isItalic ? NSItalicFontMask : 0);
    NSFont *font = [[NSFontManager sharedFontManager] fontWithFamily:_fontFamily traits:fontTraits weight:5 size:_fontSize];
    [self setValue:font forPotentiallyBoundKeyPath:@"font"];
}

@end
