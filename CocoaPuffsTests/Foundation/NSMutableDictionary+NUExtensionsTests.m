
#import <SenTestingKit/SenTestingKit.h>
#import "NSMutableDictionary+NUExtensions.h"

@interface NSMutableDictionary_NUExtensionsTests : SenTestCase

@end



@implementation NSMutableDictionary_NUExtensionsTests

- (void)testObjectForKeyComputeIfNil
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    id value = [dict objectForKey:@"a" computeIfNil:^() { return @"A"; }];
    STAssertEqualObjects(value, @"A", @"Values should be equal");
    STAssertEquals(dict.count, 1ULL, @"Dictionary should have 1 object");
}

@end
