
#import "NUPluginsManager.h"

NSString *kPluginManagerPluginIDKey = @"PluginID";
NSString *kPluginManagerBundleKey = @"Bundle";



@interface NUPluginsManager() {
@private
    NSMutableDictionary *handlers;
    NSMutableDictionary *infos;
}
@end


@implementation NUPluginsManager // COV_NF_LINE

// -----------------------------------------------------------------------------
   #pragma mark Init & Dealloc
// -----------------------------------------------------------------------------

- (id)init
{
    if ((self = [super init])) {
        handlers = [[NSMutableDictionary alloc] initWithCapacity:37];
        infos    = [[NSMutableDictionary alloc] initWithCapacity:37];
    }
    
    return self;
}



// -----------------------------------------------------------------------------
   #pragma mark Plugin Dictionaries
// -----------------------------------------------------------------------------

// COV_NF_START

- (NSMutableDictionary*) pluginInfoForUTType:(NSString*) uttypeid
{
    return [infos objectForKey:uttypeid];
}


- (void) addHandlerForPluginConformingToTypes:(NSArray*) uttypeids
                                   usingBlock:(NUPluginHandlerBlock) handler
{
    for (NSString *uttypeid in uttypeids)
        [self addHandlerForPluginConformingToType:uttypeid usingBlock:handler];
}

- (void) addHandlerForPluginConformingToType:(NSString*) uttypeid 
                                  usingBlock:(NUPluginHandlerBlock) handler
{
    // Get the list of handlers for this type
    NSMutableArray *callbacks = [handlers objectForKey:uttypeid];
    
    // If no such list exists yet then create one
    if (callbacks == nil) {
        callbacks = [NSMutableArray array];
        [handlers setObject:callbacks forKey:uttypeid];
    }
    
    // Add the handler to the list of callbacks
    [callbacks addObject:[handler copy]];
}


// -----------------------------------------------------------------------------
   #pragma mark Loading Plugins
// -----------------------------------------------------------------------------

- (void) callHandlersForPlugin:(NSMutableDictionary*) pluginInfo
{
    // Take all the UTIs that we can handle
    for (NSString *uttypeid in [handlers.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        
        // For a given UTI get its callbacks
        NSArray *callbacks = [handlers objectForKey:uttypeid];
        
        // Look at the types to which the plugin conforms to
        for (NSString *pluginType in [pluginInfo objectForKey:(NSString*)kUTTypeConformsToKey]) {
            
            // If one of the type conforms to the above UTI then call the callbacks for that UTI.
            if (UTTypeConformsTo((__bridge CFStringRef)pluginType, (__bridge CFStringRef)uttypeid)) {
                for (NUPluginHandlerBlock callback in callbacks)
                    callback(uttypeid,pluginInfo);
            }
        }
    }
}

- (void) loadPlugin:(NSDictionary*) pluginInfo
{
    [self callHandlersForPlugin:[pluginInfo mutableCopy]];
}

- (void) loadPluginsInBundle:(NSBundle*) bundle 
      fromDictionariesForKey:(NSString*) pluginsKey
            conformingToType:(NSString*) uttypeid
{
    NSArray *pluginList = 
        [bundle.infoDictionary objectForKey:(NSString*)pluginsKey];
    
    for (NSDictionary *pluginInfo in pluginList) {
        
        // Make the info mutable
        NSMutableDictionary *info = [pluginInfo mutableCopy];
        
        // Set the plugins bundle 
        [info setObject:bundle forKey:kPluginManagerBundleKey];
        [bundle load];
        
        // What is the UTType does this plugin conform to?
        NSArray *pluginTypes = [info objectForKey:(NSString*)kUTTypeConformsToKey];
        
        // Does it conform to the specified uttypeid? 
        // If it does should we load the plugin but only once!
        for (NSString *pluginType in pluginTypes) {
            if (UTTypeConformsTo((__bridge CFStringRef)pluginType, (__bridge CFStringRef)uttypeid)) {
                [self loadPlugin:info];
                break;
            }
        }
    }
}

- (void) loadPluginBundlesInPaths:(NSArray*) searchURLs 
                    withExtension:(NSString*) extension
           fromDictionariesForKey:(NSString*) pluginsKey
                 conformingToType:(NSString*) uttypeid
{
    for (NSURL *directoryURL in searchURLs) {
        
        // TODO: Handle errors gracefully
        NSArray *directoryFiles = [[NSFileManager defaultManager]
                                   contentsOfDirectoryAtURL:directoryURL 
                                   includingPropertiesForKeys:nil 
                                   options:NSDirectoryEnumerationSkipsHiddenFiles 
                                   error:nil];
        
        for (NSURL *fileURL in directoryFiles) {
            NSString *fileExt = [fileURL pathExtension];
            if (extension==nil || [fileExt isEqualToString:extension]) {
                NSBundle *bundle = [NSBundle bundleWithURL:fileURL];
                if (bundle) 
                    [self loadPluginsInBundle:bundle fromDictionariesForKey:pluginsKey conformingToType:uttypeid];
            }
        }
    }
}

// COV_NF_END

@end

