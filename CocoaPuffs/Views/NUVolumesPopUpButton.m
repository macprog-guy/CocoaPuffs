
#import "NUVolumesPopUpButton.h"

@interface NUVolumesPopUpButton()
- (void) setupInitialMenu;
@end


@implementation NUVolumesPopUpButton

@synthesize selectedURL;

// -----------------------------------------------------------------------------
   #pragma mark - Init & Dealloc
// -----------------------------------------------------------------------------

- (void) commonInit
{
    self.menu = [[NSMenu alloc] initWithTitle:@"Volumes"];
    [self setupInitialMenu];
}

- (id) initWithFrame:(NSRect)frame pullsDown:(BOOL)flag
{
    if ((self = [super initWithFrame:frame pullsDown:flag])) {
        [self commonInit];
    }
    return self;
}

// -----------------------------------------------------------------------------
   #pragma mark - NSCoding
// -----------------------------------------------------------------------------

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
        [self selectItemAtIndex:[aDecoder decodeIntegerForKey:@"NUVolumesPopUpButton_indexOfSelectedItem"]];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:self.indexOfSelectedItem forKey:@"NUVolumesPopUpButton_indexOfSelectedItem"];
}


// -----------------------------------------------------------------------------
   #pragma mark - Properties
// -----------------------------------------------------------------------------

- (NSURL*) selectedURL
{
    return (NSURL*)self.selectedItem.representedObject;
}

- (void) setSelectedURL:(NSURL *)value
{
    if (! [value isEqual:self.selectedURL]) {
        NSMenuItem *item = [self itemWithURL:value];
        if (item)
            [self selectItem:item];
    }
}


// -----------------------------------------------------------------------------
   #pragma mark - Initial Menu
// -----------------------------------------------------------------------------

- (void) setupInitialMenu
{
    /*
     
     Here we add the mounted devices and then add a few other useful places.
     
     */
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    
	NSArray     *mountedVols = [ws mountedLocalVolumePaths]; 
    NSString    *filePath    = nil;
    
    for (NSString *path in mountedVols) {
        
        NSArray *parts = [path componentsSeparatedByString:@"/"];
        NSString *name = parts.lastObject;
        filePath = path;
        
        if ((name == nil) || [name isEqualToString:@""]) {
            name = @"Root";
        }
        
        if ([path isEqualToString:@"/home"]) {
            filePath = NSHomeDirectory();
            name = @"Home";
        }
        
        if ([path isEqualToString:@"/net"])
            continue;
        
        [self addItemWithURL:[NSURL fileURLWithPath:filePath] title:name image:nil andAction:nil forTarget:nil];
    }
    
    [self addSeparator];
    
    filePath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [self addItemWithURL:[NSURL fileURLWithPath:filePath] title:@"Desktop" image:nil andAction:nil forTarget:nil];
    
    filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [self addItemWithURL:[NSURL fileURLWithPath:filePath] title:@"Documents" image:nil andAction:nil forTarget:nil];
    
    filePath = [NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [self addItemWithURL:[NSURL fileURLWithPath:filePath] title:@"Pictures" image:nil andAction:nil forTarget:nil];
}


// -----------------------------------------------------------------------------
   #pragma mark - Managing URLs
// -----------------------------------------------------------------------------

- (void) addSeparator
{
    [self.menu addItem:[NSMenuItem separatorItem]];
}

- (void) addItemWithURL:(NSURL*)aURL title:(NSString*) aTitle image:(NSImage*) anImage andAction:(SEL)aSelector forTarget:(id) aTarget
{
    // Default image is the one for the URL.
    if (anImage == nil) {
        NSWorkspace *ws = [NSWorkspace sharedWorkspace];
        anImage = [ws iconForFile:aURL.path];
    }
    
    // Default title is the last path component of the URL
    if (aTitle == nil)
        aTitle = aURL.lastPathComponent;
        
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:aTitle action:@selector(defaultAction:) keyEquivalent:@""];

    menuItem.image = anImage;
    menuItem.target = self;
    menuItem.representedObject = aURL;
    
    [self.menu addItem:menuItem];
}


- (void) removeURL:(NSURL*)aURL
{
    NSMenuItem *menuItemToRemove = [self itemWithURL:aURL];
    if (menuItemToRemove) {
        [self.menu removeItem:menuItemToRemove];
    }
}

- (NSMenuItem*) itemWithURL:(NSURL*)aURL
{
    NSMenuItem *menuItemToFind = nil;
    
    for (NSMenuItem *menuItem in self.menu.itemArray) {
        if ([menuItem.representedObject isEqual:aURL]) {
            menuItemToFind = menuItem;
            break;
        }
    }
    
    return menuItemToFind;
}


@end
