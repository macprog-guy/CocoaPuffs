
#import <SenTestingKit/SenTestingKit.h>
#import "NSObject+NUExtensions.h"

@interface TestObject : NSObject
@property (assign) int number;
@property (retain) TestObject *object;
@end

@implementation TestObject
@synthesize number, object;
@end


@interface NUObject_NUExtensionsTests : SenTestCase {
    NSMutableArray *_willChangeKeys;
    NSMutableArray *_didChangeKeys;
}
@end



@implementation NUObject_NUExtensionsTests

- (void)setUp
{
    _willChangeKeys = [NSMutableArray array];
    _didChangeKeys  = [NSMutableArray array];
}

- (void) willChangeValueForKey:(NSString *)key
{
    [super willChangeValueForKey:key];
    [_willChangeKeys addObject:key];
}

- (void) didChangeValueForKey:(NSString *)key
{
    [super didChangeValueForKey:key];
    [_didChangeKeys addObject:key];
}

- (void)testSetValueForPotentiallyBoundKey
{
    TestObject *a = [[TestObject alloc] init];
    TestObject *b = [[TestObject alloc] init];
    TestObject *c = [[TestObject alloc] init];

    a.object = [[TestObject alloc] init];
    b.object = [[TestObject alloc] init];
    c.object = [[TestObject alloc] init];

    // -------------------------------------------------------------------------
    //
    // Test simple cases where there are no bindings.
    //
    // -------------------------------------------------------------------------

    STAssertEquals(a.number, (int)0, @"number should be 0");
    [a setValue:[NSNumber numberWithInt:9] forPotentiallyBoundKeyPath:@"number"];
    STAssertEquals(a.number, (int)9, @"number should be 9");
    
    [a setValue:[NSNumber numberWithInt:4] forPotentiallyBoundKeyPath:@"object.number"];
    STAssertEquals(a.object.number, (int)4, @"object.number should be 4");
    
    // -------------------------------------------------------------------------
    //
    // Test simple bindings
    //
    // We bind b to a and call the method on b. 
    // Both a and b should see their values change.
    //
    // -------------------------------------------------------------------------
    
    [b bind:@"number" toObject:a withKeyPath:@"number" options:nil];
    [b.object bind:@"number" toObject:a withKeyPath:@"object.number" options:nil];
    
    [b setValue:[NSNumber numberWithInt:3] forPotentiallyBoundKeyPath:@"number"];
    STAssertEquals(b.number, (int)3, @"number should be 3");
    STAssertEquals(a.number, (int)3, @"number should be 3");
    
    [b setValue:[NSNumber numberWithInt:7] forPotentiallyBoundKeyPath:@"object.number"];
    STAssertEquals(b.object.number, (int)7, @"object.number should be 7");
    STAssertEquals(a.object.number, (int)7, @"object.number should be 7");
    
    // -------------------------------------------------------------------------
    //
    // Test complex bindings
    //
    // We bind c to b, which forms a binding chain c->b->a and call the method 
    // on c. The values for a, b and c should all change.
    //
    // -------------------------------------------------------------------------
    
    [c bind:@"number" toObject:b withKeyPath:@"number" options:nil];
    [c.object bind:@"number" toObject:b.object withKeyPath:@"number" options:nil];
    
    [c setValue:[NSNumber numberWithInt:2] forPotentiallyBoundKeyPath:@"number"];
    STAssertEquals(c.number, (int)2, @"number should be 2");
    STAssertEquals(b.number, (int)2, @"number should be 2");
    STAssertEquals(a.number, (int)2, @"number should be 2");
    
    [c setValue:[NSNumber numberWithInt:8] forPotentiallyBoundKeyPath:@"object.number"];
    STAssertEquals(c.object.number, (int)8, @"object.number should be 8");
    STAssertEquals(b.object.number, (int)8, @"object.number should be 8");
    STAssertEquals(a.object.number, (int)8, @"object.number should be 8");
}    


- (void) testBindToArrayAtIndexWithKeyPathOptions
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i=0;  i<10;  i++) {
        TestObject *test = [[TestObject alloc] init];
        test.number = i;
        test.object = [[TestObject alloc] init];
        test.object.number = i;
        [array addObject:test];
    }

    @autoreleasepool {

        TestObject *test3 = [[TestObject alloc] init];
        TestObject *test7 = [[TestObject alloc] init];
        
        test3.object = [[TestObject alloc] init];
        test7.object = [[TestObject alloc] init];
        
        
        [test3 bind:@"number" toArray:array atIndex:3 withKeyPath:@"number" options:nil];
        [test7.object bind:@"number" toArray:array atIndex:7 withKeyPath:@"object.number" options:nil];
        
        STAssertEquals(test3.number, (int)3, @"number should be 3");
        STAssertEquals(test7.object.number, (int)7, @"object.number should be 7");
        
        ((TestObject*)[array objectAtIndex:3]).number = 333;
        ((TestObject*)[array objectAtIndex:7]).object.number = 777;

        STAssertEquals(test3.number, (int)333, @"number should be 3");
        STAssertEquals(test7.object.number, (int)777, @"object.number should be 7");
        
        [test3 unbind:@"number"];
        [test7.object unbind:@"number"];
    }
    
    STAssertNoThrow(((TestObject*)[array objectAtIndex:3]).number = 3, @"Should not have thrown an exception");
    STAssertNoThrow(((TestObject*)[array objectAtIndex:7]).object.number = 7, @"Should not have thrown an exception");
}

- (void) testWillAndDidChangeValueForKeys
{
    [self willChangeValueForKeys:@"A",@"B",@"C",nil];
    [self didChangeValueForKeys:@"A",@"B",@"C",nil];
    
    NSArray *willExpect = @[@"A",@"B",@"C"];
    NSArray *didExpect  = @[@"C",@"B",@"A"];
    
    STAssertEqualObjects(_willChangeKeys, willExpect, @"Arrays should match");
    STAssertEqualObjects(_didChangeKeys, didExpect, @"Arrays should match");
}

- (void) testMethodListDescriptionForCoverageOnly
{
    NSString *description = [self methodListDescrption];
    STAssertNotNil(description, @"Method List should never be nil");
}

- (void) testSetUndoRedoValueForKeyPathWithUndoManagerAndActionNameDisableAnimationSkipAssignment
{
    NSUndoManager *undoManager = [[NSUndoManager alloc] init];
    NSMutableDictionary  *dict = [NSMutableDictionary dictionaryWithObject:@1 forKey:@"A"];
    
    [dict setUndoValue:@99 redoValue:@1 forKeyPath:@"A" withUndoManager:undoManager andActionName:@"Set A" disableAnimations:YES skipAssignment:YES];
    
    STAssertEqualObjects([dict objectForKey:@"A"], @1, @"Values should be equal");
    [undoManager undo];
    STAssertEqualObjects([dict objectForKey:@"A"], @99, @"Values should be equal");
    [undoManager redo];
    STAssertEqualObjects([dict objectForKey:@"A"], @1, @"Values should be equal");
}

- (void) testDeepCopyIfPossible
{
    NSDictionary *dict = @{@"A":@"A", @"B":@"B"};
    NSDictionary *copy = [dict copy];
    NSDictionary *deepCopy = [dict deepCopyIfPossible];
    
    STAssertEquals([dict objectForKey:@"A"], [copy objectForKey:@"A"], @"Values should match");
    STAssertEquals([dict objectForKey:@"B"], [copy objectForKey:@"B"], @"Values should match");

    STAssertFalse([dict objectForKey:@"A"] == [deepCopy objectForKey:@"A"], @"Values should be equal but different objects");
    STAssertFalse([dict objectForKey:@"B"] == [deepCopy objectForKey:@"B"], @"Values should be equal but different objects");
    STAssertEqualObjects([dict objectForKey:@"A"], [deepCopy objectForKey:@"A"], @"Values should match");
    STAssertEqualObjects([dict objectForKey:@"B"], [deepCopy objectForKey:@"B"], @"Values should match");
    
    NSObject *objectA = [[NSObject alloc] init];
    NSObject *objectB = [objectA deepCopyIfPossible];
    
    STAssertEquals(objectA, objectB, @"Should be the same object");
}

@end
