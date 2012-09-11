
#import <SenTestingKit/SenTestingKit.h>
#import "CocoaPuffs.h"

@interface NUZeroingDictionaryTests : SenTestCase

@end

@implementation NUZeroingDictionaryTests

- (void) testZeroingDictionary
{
    @autoreleasepool {

        NUZeroingDictionary *dict = [NUZeroingDictionary dictionary];
        dict.timerInterval = 0.1;

        id thing1 = [[NSObject alloc] init];
        [dict setObject:thing1 forKey:@"thing1" weakReference:YES];
        
        STAssertEquals(dict.timerInterval, 0.1f, @"Values should match");
        
        @autoreleasepool {
            
            id thing2 = [[NSObject alloc] init];
            id thing3 = [[NSObject alloc] init];

            [dict setObject:thing2 forKey:@"thing2"];
            [dict setObject:thing3 forKey:@"thing3" weakReference:NO];
            
            STAssertEqualObjects(thing1, [dict objectForKey:@"thing1"], @"Values should match");
            STAssertEqualObjects(thing2, [dict objectForKey:@"thing2"], @"Values should match");
            STAssertEqualObjects(thing3, [dict objectForKey:@"thing3"], @"Values should match");

            NSSet *valueSet = [NSSet setWithArray:dict.allValues];
            STAssertTrue([valueSet containsObject:thing1], @"Values should be contained in set");
            STAssertTrue([valueSet containsObject:thing2], @"Values should be contained in set");
            STAssertTrue([valueSet containsObject:thing3], @"Values should be contained in set");
        }

        usleep(150000); // Sleep 0.15s to ensure timer had time to run.

        STAssertEquals(dict.count, 2ULL, @"Values should match");
        STAssertTrue([dict hasKey:@"thing1"], @"Should still have this key");
        STAssertFalse([dict hasKey:@"thing2"], @"Should not have this key anymore");
        STAssertTrue([dict hasKey:@"thing3"], @"Should still have this key");
        
        dict = nil;
    }
}

- (void) testSharedInstance
{
    STAssertNotNil([NUZeroingDictionary sharedInstance], @"There should always be a shared instance");
}


@end
