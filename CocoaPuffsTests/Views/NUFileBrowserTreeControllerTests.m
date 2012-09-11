
#import <SenTestingKit/SenTestingKit.h>
#import "CocoaPuffs.h"

@interface NUFileBrowserTreeControllerTests : SenTestCase

@end

@implementation NUFileBrowserTreeControllerTests

- (void) testTreeController
{
    NUFileBrowserTreeController *controller = [[NUFileBrowserTreeController alloc] init];
    controller.rootURL = [[NSURL fileURLWithPath:[NSString stringWithFormat:@"%s/../../Test Files/",__FILE__]] URLByStandardizingPath];
    
    NSArray *files = [controller.arrangedObjects childNodes];
    
    STAssertEquals(files.count, 9ULL, @"Values should match");
    
    NUFileBrowserTreeController *copy = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:controller]];
    NUFileBrowserNodeItem *file = [[files objectAtIndex:5] representedObject];
    
    STAssertEqualObjects(controller.rootURL, copy.rootURL, @"Values should match");
    STAssertEquals([controller.arrangedObjects count], 9ULL, @"Values should match");
    STAssertTrue(file.enabled, @"File should be disabled");
    
    controller.supportedTypes = @[(__bridge id)kUTTypePNG];
    
    STAssertNotNil(controller.supportedTypes, @"Should not be nil");
    STAssertFalse(file.enabled, @"File should be disabled");
}

@end
