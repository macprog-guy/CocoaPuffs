
#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NUWeakReferenceTests : SenTestCase

@end

@implementation NUWeakReferenceTests

- (void) testWeakReferences
{
    NUWeakReference *weakThing = nil;

    @autoreleasepool {
        
        id thing = [[NSObject alloc] init];
        weakThing = [NUWeakReference weakReferenceToObject:thing];
        
        STAssertNotNil(thing, @"Value should not be nil");
        STAssertNotNil(weakThing, @"Value should not be nil");
        STAssertNotNil(weakThing.ref, @"Value should not be nil");

        NSString *descr = weakThing.description;
        STAssertNotNil(descr, @"Should have a description");
        
        // At this point thing is autoreleased and weak-references nilled.
    }
    
    STAssertNotNil(weakThing, @"Value should have been autoreleased");
    STAssertNil(weakThing.ref, @"Value should now be nil");
}


@end
