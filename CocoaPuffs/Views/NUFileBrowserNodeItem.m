
#import "NUFileBrowserNodeItem.h"
#import "NSURL+NUExtensions.h"

@interface NUFileBrowserNodeItem() {
    
    NSImage  *image;
    NSString *label;
    NSArray  *supportedTypes;

    struct {
        uint16_t hasNoImage:1;
        uint16_t hasNoLabel:1;
        uint16_t isEnabled:1;
    } flags;
    
    NSMutableArray *childNodes;    
}

@end

@implementation NUFileBrowserNodeItem

// -----------------------------------------------------------------------------
   #pragma mark Properties
// -----------------------------------------------------------------------------

@synthesize image, label, supportedTypes;

- (id) initWithRepresentedObject:(NSURL*)aURL andSupportedTypes:(NSArray*)types
{
    if ((self = [super initWithRepresentedObject:aURL])) {
        self.supportedTypes = types;
    }
    return self;
}

- (id) initWithRepresentedObject:(NSURL*)modelObject
{
    return [self initWithRepresentedObject:modelObject andSupportedTypes:nil];
}

- (NSImage*) image
{
    NSURL   *url = (NSURL*)self.representedObject;
    NSImage *value = nil;
    
    if ((image != nil) || flags.hasNoImage)
        return image;
    
    if (value == nil) 
        [url getResourceValue:&value forKey:NSURLCustomIconKey error:nil];
        
    if (value == nil)
        [url getResourceValue:&value forKey:NSURLEffectiveIconKey error:nil];
        
    if (value == nil)
        value = [[NSWorkspace sharedWorkspace] iconForFile:url.path]; // COV_NF_LINE
    
    if (value == nil)
        flags.hasNoImage = YES; // COV_NF_LINE

    image = value;
    
    return image;
}

- (NSString*) label
{
    NSURL    *url = (NSURL*)self.representedObject;
    NSString *value = nil;

    if ((label != nil) || flags.hasNoLabel)
        return label;
    
    if (value == nil)
        [url getResourceValue:&value forKey:NSURLLocalizedNameKey error:nil];
    
    if (value == nil) 
        [url getResourceValue:&value forKey:NSURLNameKey error:nil]; // COV_NF_LINE
    
    if (value == nil)
        flags.hasNoLabel = YES; // COV_NF_LINE
    
    label = value;
    
    return label;
}

- (NSString*) type
{
    NSURL *url = (NSURL*)self.representedObject;
    NSString *stringValue = nil;
    [url getResourceValue:&stringValue forKey:NSURLTypeIdentifierKey error:nil];
    return stringValue;
}

- (NSString*) typeDescription
{
    NSURL *url = (NSURL*)self.representedObject;
    NSString *stringValue = nil;
    [url getResourceValue:&stringValue forKey:NSURLLocalizedTypeDescriptionKey error:nil];
    return stringValue;
}


- (NSDate*) creationDate
{
    NSURL *url = (NSURL*)self.representedObject;
    NSDate *dateValue = nil;
    [url getResourceValue:&dateValue forKey:NSURLCreationDateKey error:nil];
    return dateValue;
}

- (NSDate*) lastAccessDate
{
    NSURL *url = (NSURL*)self.representedObject;
    NSDate *dateValue = nil;
    [url getResourceValue:&dateValue forKey:NSURLContentAccessDateKey error:nil];
    return dateValue;
}

- (NSDate*) lastModificationDate
{
    NSURL *url = (NSURL*)self.representedObject;
    NSDate *dateValue = nil;
    [url getResourceValue:&dateValue forKey:NSURLContentModificationDateKey error:nil];
    return dateValue;
}

- (NSUInteger) fileSize
{
    NSURL *url = (NSURL*)self.representedObject;
    NSNumber *numberValue = nil;
    [url getResourceValue:&numberValue forKey:NSURLFileSizeKey error:nil];
    return numberValue.unsignedIntegerValue;
}

- (double) fileSizeKB
{
    return (double)self.fileSize / 1024;
}

- (double) fileSizeMB
{
    return (double)self.fileSize / (1024 * 1024);
}

- (BOOL) isReadable
{
    NSURL *url = (NSURL*)self.representedObject;
    NSNumber *numberValue = nil;
    [url getResourceValue:&numberValue forKey:NSURLIsReadableKey error:nil];
    return numberValue.boolValue;
}


- (BOOL) isDirectory
{
    NSURL *url = (NSURL*)self.representedObject;
    NSNumber *numberValue = nil;
    [url getResourceValue:&numberValue forKey:NSURLIsDirectoryKey error:nil];
    return numberValue.boolValue;
}

- (BOOL) isLeaf
{
    return !self.isDirectory || !self.isReadable;
}

- (BOOL) enabled
{
    return flags.isEnabled && self.isReadable;
}

- (void) setEnabled:(BOOL)value
{
    flags.isEnabled = value;
}

- (NSArray*) childNodes
{
    // We don't set the parent node.
    if (childNodes == nil)
        childNodes = [NUFileBrowserNodeItem nodesForURL:self.representedObject andSupportedTypes:supportedTypes];
    
    return childNodes;
}

- (NSArray*) supportedTypes
{
    return supportedTypes;
}

- (void) setSupportedTypes:(NSArray *)value
{
    supportedTypes  = value;
    flags.isEnabled = supportedTypes ? [(NSURL*)self.representedObject conformsToAnyTypeInTypes:supportedTypes] : YES;
    
    // Pass the now pointer along to already instantiated child nodes
    for (NUFileBrowserNodeItem *node in childNodes)
        node.supportedTypes = supportedTypes;
}


// -----------------------------------------------------------------------------
   #pragma mark NSPasteboardWriting and NSPasteboardReading
// -----------------------------------------------------------------------------

// COV_NF_START

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pboard
{
    return @[(id)kUTTypeURL, (id)kUTTypeFileURL, (id)kUTTypePlainText];
}

- (NSPasteboardWritingOptions)writingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard
{
    return 0;
}

- (id)pasteboardPropertyListForType:(NSString *)type
{
    return [(NSURL*)self.representedObject pasteboardPropertyListForType:type];
}


+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pboard
{
    return @[(id)kUTTypeURL, (id)kUTTypeFileURL, (id)kUTTypePlainText];
}

+ (NSPasteboardWritingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard
{
    return 0;
}

// COV_NF_END



// -----------------------------------------------------------------------------
   #pragma mark Class Methods
// -----------------------------------------------------------------------------

+ (id) treeNodeWithRepresentedObject:(NSURL*)aURL andSupportedTypes:(NSArray*)types
{
    // Autorelease managed by ARC compiler.
    return [[self alloc] initWithRepresentedObject:aURL andSupportedTypes:types];
}


+ (NSMutableArray*) nodesForURL:(NSURL*)URL andSupportedTypes:(NSArray*)types
{
    static NSArray *propertyKeys = nil;

    if (propertyKeys == nil)
        propertyKeys = @[NSURLNameKey, NSURLLocalizedNameKey, 
                        NSURLCreationDateKey, NSURLContentAccessDateKey, NSURLContentModificationDateKey, 
                        NSURLLocalizedTypeDescriptionKey, NSURLTypeIdentifierKey, 
                        NSURLIsDirectoryKey, NSURLIsReadableKey,
                        NSURLFileSizeKey, 
                        NSURLEffectiveIconKey, NSURLCustomIconKey];        
    
    NSError *error = nil;
    NSArray *URLs  = [[NSFileManager defaultManager] 
                    contentsOfDirectoryAtURL:URL
                  includingPropertiesForKeys:propertyKeys 
                                     options:NSDirectoryEnumerationSkipsHiddenFiles 
                                        error:&error];
    
    if (error != nil)
        return [NSMutableArray array]; // COV_NF_LINE


    NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:URLs.count];
        
    for (NSURL *url in URLs) {
        NUFileBrowserNodeItem *item = [NUFileBrowserNodeItem treeNodeWithRepresentedObject:url andSupportedTypes:types];
        [nodes addObject:item];
    }
    
    return nodes;
}

@end
