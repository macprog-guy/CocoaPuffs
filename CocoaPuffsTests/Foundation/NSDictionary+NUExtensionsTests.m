
#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NSDictionary_NUExtensionsTests : SenTestCase

@end

@implementation NSDictionary_NUExtensionsTests

- (void) testHasKey
{
    NSDictionary *dict = @{@"A":@1, @"B":@2};
    STAssertTrue([dict hasKey:@"A"], @"Dictionary should have the key A");
    STAssertTrue([dict hasKey:@"B"], @"Dictionary should have the key B");
    STAssertFalse([dict hasKey:@"C"], @"Dictionary should NOT have the key C");
}

@end
