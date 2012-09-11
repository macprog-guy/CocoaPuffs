/**
 
 Many thanks to David Dauer, Jesper and Jamie Kirkpatrick
 for their ShortcutRecorder, from which I have libarally
 taken code.
 
 */

#import "NUKeyboardUtils.h"


#define NULocalizedString(key) NSLocalizedStringFromTableInBundle((key), @"NUKeyboardUtils", [NSBundle bundleForClass: [NUKeyboardUtils class]], nil)
#define NUStandardGlyph(key) [NSString stringWithFormat:@"%C",(short)(key)]


@class NUKeyboardUtils;

static NUKeyboardUtils *gSharedKeyboardUtils = nil;


@interface NUKeyboardUtils() {
    NSMutableDictionary *_keyCodeToHumanStringMapping;
    NSMutableDictionary *_stringToKeyCodeMapping;
}
@end


@implementation NUKeyboardUtils

// -----------------------------------------------------------------------------
   #pragma mark Init & Dealloc
// -----------------------------------------------------------------------------

- (id) init
{
    if ((self = [super init])) {
        
        [self adaptToChangedKeyboardLayout:nil];
        
        [[NSDistributedNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(adaptToChangedKeyboardLayout:)
         name:(NSString*)kTISNotifySelectedKeyboardInputSourceChanged
         object:nil];
    }
    return self;
}

+ (id) keyboardUtils
{
    return [[self alloc] init];
}

- (void) dealloc
{
    [[NSDistributedNotificationCenter defaultCenter]
     removeObserver:self
     name:(NSString*)kTISNotifySelectedKeyboardInputSourceChanged
     object:nil];
}


// -----------------------------------------------------------------------------
   #pragma mark Utility Methods
// -----------------------------------------------------------------------------

- (uint16_t) virtualKeyCodesForKey:(unichar)key
{
    @synchronized(self) {
        NSString *keyValue = [NSString stringWithCharacters:&key length:1];
        NSNumber *code = _stringToKeyCodeMapping[keyValue];
        return code? code.unsignedShortValue : -1;
    }
}

- (NSString*) stringForKeyCode:(uint16_t)code
{
    @synchronized(self) {
        return _keyCodeToHumanStringMapping[@(code)];
    }
}

- (NSString*) shortcutStringForKeyCode:(uint16_t)code withModifierFlags:(uint32_t)flags
{
    NSString *strKey = [self stringForKeyCode:code];
    
    return [NSString stringWithFormat:@"%@%@%@%@%@",
            (flags & NSControlKeyMask ? NUStandardGlyph(kGlyphForShift) : @""),
            (flags & NSAlternateKeyMask ? NUStandardGlyph(kGlyphForOption) : @""),
            (flags & NSShiftKeyMask ? NUStandardGlyph(kGlyphForShift) : @""),
            (flags & NSCommandKeyMask ? NUStandardGlyph(kGlyphForCommand) : @""),
            (strKey? strKey : @"")
            ];
}


// -----------------------------------------------------------------------------
   #pragma mark Loading Keyboard Layouts
// -----------------------------------------------------------------------------

- (void) adaptToChangedKeyboardLayout:(NSNotification*)note
{
    @synchronized(self) {
        
        _stringToKeyCodeMapping = [NSMutableDictionary dictionary];
        
        _keyCodeToHumanStringMapping = [NSMutableDictionary dictionaryWithDictionary:@{
                                        @(kKeyCodeForF1):@"F1",
                                        @(kKeyCodeForF2):@"F2",
                                        @(kKeyCodeForF3):@"F3",
                                        @(kKeyCodeForF4):@"F4",
                                        @(kKeyCodeForF5):@"F5",
                                        @(kKeyCodeForF6):@"F6",
                                        @(kKeyCodeForF7):@"F7",
                                        @(kKeyCodeForF8):@"F8",
                                        @(kKeyCodeForF9):@"F9",
                                        @(kKeyCodeForF10):@"F10",
                                        @(kKeyCodeForF11):@"F11",
                                        @(kKeyCodeForF12):@"F12",
                                        @(kKeyCodeForF13):@"F13",
                                        @(kKeyCodeForF14):@"F14",
                                        @(kKeyCodeForF15):@"F15",
                                        @(kKeyCodeForF16):@"F16",
                                        @(kKeyCodeForF17):@"F17",
                                        @(kKeyCodeForF18):@"F18",
                                        @(kKeyCodeForF19):@"F19",
                                        @(kKeyCodeForSpace):NULocalizedString(@"Space"),
                                        @(kKeyCodeForDeleteLeft):NUStandardGlyph(kGlyphForDeleteLeft),
                                        @(kKeyCodeForDeleteRight):NUStandardGlyph(kGlyphForDeleteRight),
                                        @(kKeyCodeForPadClear):NUStandardGlyph(kGlyphForPadClear),
                                        @(kKeyCodeForLeftArrow):NUStandardGlyph(kGlyphForLeftArrow),
                                        @(kKeyCodeForRightArrow):NUStandardGlyph(kGlyphForRightArrow),
                                        @(kKeyCodeForUpArrow):NUStandardGlyph(kGlyphForUpArrow),
                                        @(kKeyCodeForDownArrow):NUStandardGlyph(kGlyphForDownArrow),
                                        @(kKeyCodeForSoutheastArrow):NUStandardGlyph(kGlyphForSoutheastArrow),
                                        @(kKeyCodeForNorthwestArrow):NUStandardGlyph(kGlyphForNorthwestArrow),
                                        @(kKeyCodeForEscape):NUStandardGlyph(kGlyphForEscape),
                                        @(kKeyCodeForPageDown):NUStandardGlyph(kGlyphForPageDown),
                                        @(kKeyCodeForPageUp):NUStandardGlyph(kGlyphForPageUp),
                                        @(kKeyCodeForReturnR2L):NUStandardGlyph(kGlyphForReturnR2L),
                                        @(kKeyCodeForReturn):NUStandardGlyph(kGlyphForReturn),
                                        @(kKeyCodeForTabRight):NUStandardGlyph(kGlyphForTabRight),
                                        @(kKeyCodeForHelp):NUStandardGlyph(kGlyphForHelp)
                                        }];
        
        TISInputSourceRef inputSource = TISCopyCurrentKeyboardInputSource();
        
        if (inputSource == NULL)
            return;
        
        CFDataRef keyboardLayout = (CFDataRef)TISGetInputSourceProperty(inputSource, kTISPropertyUnicodeKeyLayoutData);
        CFRetain(keyboardLayout);
        CFRelease(inputSource);
        
        // For non-unicode layouts such as Chinese, Japanese, and Korean, get the ASCII capable layout
        if(keyboardLayout == NULL) {
            inputSource = TISCopyCurrentASCIICapableKeyboardLayoutInputSource();
            keyboardLayout = (CFDataRef)TISGetInputSourceProperty(inputSource, kTISPropertyUnicodeKeyLayoutData);
            CFRetain(keyboardLayout);
            CFRelease(inputSource);
        }
        
        if (keyboardLayout == NULL)
            return;
        
        const UCKeyboardLayout *rawLayout = (const UCKeyboardLayout *)CFDataGetBytePtr(keyboardLayout);
        
        UniCharCount const maxLength = 4;
        UniCharCount realLength = 0;
        UniChar      chars[maxLength];
        
        uint32_t modFlags = 0;
        uint32_t deadKeys = 0;
        
        for (uint16_t keyCode=0;  keyCode<128;  keyCode++) {
            
            OSStatus err = UCKeyTranslate(rawLayout, keyCode, kUCKeyActionDisplay, modFlags, LMGetKbdType(), kUCKeyTranslateNoDeadKeysBit, &deadKeys, maxLength, &realLength, chars);
            
            if (err == noErr) {
                
                NSNumber *keyValue = @(keyCode);
                NSString *strValue = [NSString stringWithCharacters:chars length:1];
                
                if (_keyCodeToHumanStringMapping[keyValue] == nil) {
                    _keyCodeToHumanStringMapping[keyValue] = strValue;
                    _stringToKeyCodeMapping[strValue] = keyValue;
                    _stringToKeyCodeMapping[strValue.uppercaseString] = keyValue;
                }
            }
        }
        
        CFRelease(keyboardLayout);
    }
}

// -----------------------------------------------------------------------------
   #pragma mark Class Methods
// -----------------------------------------------------------------------------

+ (NUKeyboardUtils*)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gSharedKeyboardUtils = [[NUKeyboardUtils alloc] init];
    });
    
    return gSharedKeyboardUtils;
}

+ (uint16_t) virtualKeyCodesForKey:(unichar)key
{
    return [self.sharedInstance virtualKeyCodesForKey:key];
}

+ (NSString*) stringForKeyCode:(uint16_t)code
{
    return [self.sharedInstance stringForKeyCode:code];
}

+ (NSString*) shortcutStringForKeyCode:(uint16_t)code withModifierFlags:(uint32_t)flags
{
    return [self.sharedInstance shortcutStringForKeyCode:code withModifierFlags:flags];
}

@end


#undef NULocalizedString
#undef NUStandardGlyph

