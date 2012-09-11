
#import <SenTestingKit/SenTestingKit.h>
#import "CocoaPuffs.h"

@interface NUSimpleXPCServiceTests : SenTestCase {
}
@end

@implementation NUSimpleXPCServiceTests

- (void) testBoxingAndUnboxing
{
    uint64_t bytes = 0x1234567809876543;
        
    id thing = @{
        @"a": @[@(NSUIntegerMax), @2LL, @"A"],
        @"b": @(19.2),
        @"c": @[@YES,@NO],
        @"d": [NSData dataWithBytesNoCopy:&bytes length:sizeof(uint64_t) freeWhenDone:NO],
        @"e": [NSNull null],
        @"f": [NSDate dateWithString:@"2012-03-11 18:56:00 +0100"],
        @"g": [NSNumber numberWithInteger:-123],
        @"h": [NSNumber numberWithUnsignedInteger:123],
    };
    
    id otherThing = [NSObject objectFromXPCObject:[thing xpcObject]];
    
    STAssertEqualObjects(thing, otherThing, @"Objects should be equivalent");
    
    otherThing = objectFromXPCObject(xpcObjectFromObject(thing));

    STAssertEqualObjects(thing, otherThing, @"Objects should be equivalent");
}

@end
