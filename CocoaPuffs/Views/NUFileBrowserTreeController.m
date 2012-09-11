
#import "NUFileBrowserTreeController.h"
#import "NUFileBrowserNodeItem.h"

@implementation NUFileBrowserTreeController

@synthesize rootURL, supportedTypes;

// -----------------------------------------------------------------------------
   #pragma mark - Init & Dealloc
// -----------------------------------------------------------------------------

- (void) commonInit
{
    self.childrenKeyPath = @"childNodes";
    self.leafKeyPath = @"isLeaf";
}

- (id) init
{
    if ((self = [super init])) {
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
        self.rootURL = [aDecoder decodeObjectForKey:@"rootURL"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.rootURL forKey:@"rootURL"];
}



// -----------------------------------------------------------------------------
   #pragma mark - Properties
// -----------------------------------------------------------------------------

- (void) setRootURL:(NSURL *)value
{
    if (! [value isEqual:rootURL]) {
        rootURL = value;
        self.content = [NUFileBrowserNodeItem nodesForURL:rootURL andSupportedTypes:supportedTypes];
    }
}

- (void) setSupportedTypes:(NSArray *)value
{
    if (! [value isEqualToArray:supportedTypes]) {
        
        supportedTypes = value;
        
        // Pass pointer along to all root nodes
        for (NUFileBrowserNodeItem *node in (NSArray*)self.content)
            node.supportedTypes = supportedTypes;
    }
}


@end
