
#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NUPluginsManagerTests : SenTestCase {
    NUPluginsManager *_pluginManager;
}
@end

@implementation NUPluginsManagerTests

- (void) setUp
{
    _pluginManager = [[NUPluginsManager alloc] init];
}

- (void) testNothing
{
    // We are not unit-testing the plugins-manager for the moment.
}



@end
