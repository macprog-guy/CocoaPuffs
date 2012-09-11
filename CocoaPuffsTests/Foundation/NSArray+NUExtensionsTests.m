
#import <SenTestingKit/SenTestingKit.h>
#import "NSArray+NUExtensions.h"

@interface NSArray_NUExtensionsTests : SenTestCase

@end



@implementation NSArray_NUExtensionsTests


// ----------------------------------------------------------------------------
   #pragma mark Properties
// ----------------------------------------------------------------------------

- (void) testFirstObject
{
    NSArray *array1 = [NSArray arrayWithObjects:@"a",@"b", nil];
    NSArray *array2 = [NSArray array];
    NSArray *array3 = nil;
    
    STAssertEqualObjects(array1.firstObject, @"a", @"Values should match");
    STAssertNil(array2.firstObject, @"Value should be nil");
    STAssertNil(array3.firstObject, @"Value should be nil");
}

- (void) testIsEmpty
{
    NSArray *array1 = [NSArray arrayWithObjects:@"a",@"b", nil];
    NSArray *array2 = [NSArray array];
    
    STAssertFalse(array1.isEmpty, @"Value should be NO");
    STAssertTrue(array2.isEmpty, @"Value should be YES");
}

- (void) testIsNotEmpty
{
    NSArray *array1 = [NSArray arrayWithObjects:@"a",@"b", nil];
    NSArray *array2 = [NSArray array];
    
    STAssertTrue(array1.isNotEmpty, @"Value should be YES");
    STAssertFalse(array2.isNotEmpty, @"Value should be NO");
}



// ----------------------------------------------------------------------------
   #pragma mark Creating Arrays
// ----------------------------------------------------------------------------

- (void) testArrayWithDoubles
{
    NSArray *expect1 = [NSArray arrayWithObjects:@(0.0),@(1.0),@(2.0), nil];
    NSArray *expect2 = [NSArray array];
    
    NSArray *result = [NSArray arrayWithDoubles:3,0.0,1.0,2.0];
    STAssertEqualObjects(result, expect1, @"Result is not as expected");

    result = [NSArray arrayWithDoubles:0,1.0,2.0];
    STAssertEqualObjects(result, expect2, @"Result is not as expected");
}

- (void) testArrayWithInts
{
    NSArray *expect1 = [NSArray arrayWithObjects:@(0),@(1),@(2), nil];
    NSArray *expect2 = [NSArray array];
    NSArray *expect3 = [NSArray arrayWithObjects:@YES, @NO, nil];
    
    NSArray *result = [NSArray arrayWithInts:3,0,1,2];
    STAssertEqualObjects(result, expect1, @"Result is not as expected");
    
    result = [NSArray arrayWithInts:0,1,2];
    STAssertEqualObjects(result, expect2, @"Result is not as expected");
    
    result = [NSArray arrayWithInts:2,YES,NO];
    STAssertEqualObjects(result, expect3, @"Result is not as expected");
}



// ----------------------------------------------------------------------------
   #pragma mark Generating Arrays
// ----------------------------------------------------------------------------

- (void) testArrayByRemovingObjectAtIndex
{
    NSArray *array1 = [NSArray arrayWithObjects:@"a",@"b",@"c", nil];
    NSArray *array2 = [NSArray arrayWithObjects:@"a",@"c", nil];
    NSArray *array3 = [NSArray arrayWithObjects:@"a", nil];
    NSArray *array4 = [NSArray array];
    
    NSArray *result = [array1 arrayByRemovingObjectAtIndex:1];
    STAssertEqualObjects(array2, result, @"Result not as expected");
    
    result = [array2 arrayByRemovingObjectAtIndex:1];
    STAssertEqualObjects(array3, result, @"Result not as expected");

    result = [array3 arrayByRemovingObjectAtIndex:0];
    STAssertEqualObjects(array4, result, @"Result not as expected");
    
    STAssertThrows([array4 arrayByRemovingObjectAtIndex:0], @"Should have thrown an exception");
}

- (void) testArrayByRemovingFirstObject
{
    NSArray *array1 = [NSArray arrayWithObjects:@"a",@"b",@"c", nil];
    NSArray *array2 = [NSArray arrayWithObjects:@"b",@"c", nil];
    NSArray *array3 = [NSArray arrayWithObjects:@"c", nil];
    NSArray *array4 = [NSArray array];
    
    NSArray *result = [array1 arrayByRemovingFirstObject];
    STAssertEqualObjects(array2, result, @"Result not as expected");
    
    result = [array2 arrayByRemovingFirstObject];
    STAssertEqualObjects(array3, result, @"Result not as expected");
    
    result = [array3 arrayByRemovingFirstObject];
    STAssertEqualObjects(array4, result, @"Result not as expected");
    
    STAssertThrows([array4 arrayByRemovingFirstObject], @"Should have thrown an exception");
}

- (void) testArrayByRemovingLastObject
{
    NSArray *array1 = [NSArray arrayWithObjects:@"a",@"b",@"c", nil];
    NSArray *array2 = [NSArray arrayWithObjects:@"a",@"b", nil];
    NSArray *array3 = [NSArray arrayWithObjects:@"a", nil];
    NSArray *array4 = [NSArray array];
    
    NSArray *result = [array1 arrayByRemovingLastObject];
    STAssertEqualObjects(array2, result, @"Result not as expected");
    
    result = [array2 arrayByRemovingLastObject];
    STAssertEqualObjects(array3, result, @"Result not as expected");
    
    result = [array3 arrayByRemovingLastObject];
    STAssertEqualObjects(array4, result, @"Result not as expected");
    
    STAssertThrows([array4 arrayByRemovingLastObject], @"Should have thrown an exception");
}

- (void) testArrayByRemovingObject
{
    NSArray *array1 = @[@"a", @"b", @"c"];
    NSArray *array2 = @[@"a", @"c"];
    NSArray *array3 = @[@"c"];
    NSArray *array4 = @[];
    
    NSArray *result = [array1 arrayByRemovingObject:@"b"];
    STAssertEqualObjects(result, array2, @"Arrays should be the same");
    
    result = [array2 arrayByRemovingObject:@"a"];
    STAssertEqualObjects(result, array3, @"Arrays should be the same");

    result = [array3 arrayByRemovingObject:@"c"];
    STAssertEqualObjects(result, array4, @"Arrays should be the same");

    result = [array1 arrayByRemovingObject:@"X"];
    STAssertEqualObjects(result, array1, @"Arrays should be the same");

    result = [array4 arrayByRemovingObject:@"X"];
    STAssertEqualObjects(result, array4, @"Arrays should be the same");
}

- (void) testArrayInReverseOrder
{
    NSArray *array1  = [NSArray arrayWithObjects:@"a",@"b", nil];
    NSArray *expect1 = [NSArray arrayWithObjects:@"b",@"a", nil];
    
    NSArray *array2  = [NSArray arrayWithObjects:@"a", nil];
    NSArray *expect2 = [NSArray arrayWithObjects:@"a", nil];

    NSArray *array3  = [NSArray array];
    NSArray *expect3 = [NSArray array];
    
    STAssertEqualObjects([array1 arrayInReverseOrder], expect1, @"Result not as expected");
    STAssertEqualObjects([array2 arrayInReverseOrder], expect2, @"Result not as expected");
    STAssertEqualObjects([array3 arrayInReverseOrder], expect3, @"Result not as expected");
}

- (void) testObjectsAtIndexesInArray
{
    NSArray *indexes = @[@2, @0, @3, @1, @0, @0, @1, @2, @3];
    NSArray *array1  = @[@"a",@"b",@"c",@"d"];
    NSArray *array2  = @[@"c",@"a",@"d",@"b",@"a",@"a",@"b",@"c",@"d"];

    NSArray *result  = [array1 objectsAtIndexesInArray:indexes];
    
    STAssertEqualObjects(array2, result, @"Array content should match");
}

- (void) testArrayWithUniformDistribution
{
    NSArray *array1 = @[];
    NSArray *array2 = @[@0];
    NSArray *array3 = @[@0, @100];
    NSArray *array4 = @[@0, @25, @50, @75, @100];
    
    NSArray *result = [NSArray arrayWithUniformDistributionFromValue:0 toValue:100 count:0];
    STAssertEqualObjects(result, array1, @"Array content should match");

    result = [NSArray arrayWithUniformDistributionFromValue:0 toValue:100 count:1];
    STAssertEqualObjects(result, array2, @"Array content should match");
    
    result = [NSArray arrayWithUniformDistributionFromValue:0 toValue:100 count:2];
    STAssertEqualObjects(result, array3, @"Array content should match");
    
    result = [NSArray arrayWithUniformDistributionFromValue:0 toValue:100 count:5];
    STAssertEqualObjects(result, array4, @"Array content should match");
}



// ----------------------------------------------------------------------------
   #pragma mark Mapping Methods
// ----------------------------------------------------------------------------

- (void) testMap
{
    NSArray *array1 = [NSArray arrayWithObjects:@"A" ,@"B" ,@"C" ,nil];
    NSArray *array2 = [NSArray arrayWithObjects:@"AA",@"BB",@"CC",nil];
    NSArray *array3 = [array1 map:^(id object) {
        return [NSString stringWithFormat:@"%@%@", object, object];
    }];
    
    STAssertNotNil(array3, @"Map should return non-nil array");
    STAssertEqualObjects(array3, array2, @"Arrays should match object for object");
}

- (void) testMapWithIndex
{
    NSArray *array1 = [NSArray arrayWithObjects:@"A",@"B",@"C",nil];
    NSArray *array2 = [NSArray arrayWithObjects:@"0",@"1",@"2",nil];
    NSArray *array3 = [array1 mapWithIndex:^(id object, NSUInteger index) {
        return [NSString stringWithFormat:@"%ld", index];
    }];
    
    STAssertNotNil(array3, @"Map should return non-nil array");
    STAssertEqualObjects(array3, array2, @"Arrays should match object for object");
}

- (void) testMapWithNilResults
{
    NSNull  *null   = [NSNull null];
    NSArray *array1 = [NSArray arrayWithObjects:@"A" ,@"B" ,@"C" ,nil];
    NSArray *array2 = [NSArray arrayWithObjects:null, null, null, nil];
    NSArray *array3 = [array1 map:^(id object) {
        return (id) nil;
    }];
    
    STAssertNotNil(array3, @"Map should return non-nil array");
    STAssertEqualObjects(array3, array2, @"Arrays should match object for object");
}

- (void) testMapSelector
{
    NSArray *array1 = [NSArray arrayWithObjects:@"A",@"B",@"C" ,nil];
    NSArray *array2 = [NSArray arrayWithObjects:@"a",@"b",@"c",nil];
    NSArray *array3 = [array1 mapSelector:@selector(lowercaseString)];
    
    STAssertNotNil(array3, @"Map should return non-nil array");
    STAssertEqualObjects(array3, array2, @"Arrays should match object for object");
}

- (void) testMapKeyPath
{
    NSNull *null = [NSNull null];
    NSDictionary *dict1 = [NSDictionary dictionaryWithObject:@"1" forKey:@"A"];
    NSDictionary *dict2 = [NSDictionary dictionaryWithObject:@"2" forKey:@"A"];
    NSDictionary *dict3 = [NSDictionary dictionaryWithObject:@"3" forKey:@"A"];
    NSDictionary *dict4 = [NSDictionary dictionaryWithObject:@"4" forKey:@"X"];
    
    NSArray *array1 = [NSArray arrayWithObjects:dict1, dict2, dict3, dict4, nil];
    NSArray *array2 = [NSArray arrayWithObjects:@"1",@"2",@"3",null, nil];
    
    STAssertEqualObjects([array1 mapKeyPath:@"A"], array2, @"Values should match");
}



// ----------------------------------------------------------------------------
   #pragma mark Filtering Methods
// ----------------------------------------------------------------------------

- (void) testFilter
{
    NSArray *array1  = [NSArray arrayWithInts:10,0,1,2,3,4,5,6,7,8,9];
    NSArray *expect1 = array1;
    NSArray *expect2 = [NSArray array];
    NSArray *expect3 = [NSArray arrayWithInts:5,0,2,4,6,8];
    
    NSArray *result = [array1 filter:^(id object) { return YES; }];
    STAssertEqualObjects(result, expect1, @"Result not as expected");
    
    result = [array1 filter:^(id object) { return NO; }];
    STAssertEqualObjects(result, expect2, @"Result not as expected");

    result = [array1 filter:^(id object) {
        return (BOOL)([object integerValue] % 2 == 0);
    }];    
    STAssertEqualObjects(result, expect3, @"Result not as expected");
}

- (void) testFilterWithIndex
{
    NSArray *array1  = [NSArray arrayWithInts:10,0,1,2,3,4,5,6,7,8,9];
    NSArray *expect1 = array1;
    NSArray *expect2 = [NSArray array];
    NSArray *expect3 = [NSArray arrayWithInts:5,0,2,4,6,8];
    
    NSArray *result = [array1 filterWithIndex:^(id object, NSUInteger index) { return YES; }];
    STAssertEqualObjects(result, expect1, @"Result not as expected");
    
    result = [array1 filterWithIndex:^(id object, NSUInteger index) { return NO; }];
    STAssertEqualObjects(result, expect2, @"Result not as expected");
    
    result = [array1 filterWithIndex:^(id object, NSUInteger index) {
        return (BOOL)(index % 2 == 0);
    }];    
    STAssertEqualObjects(result, expect3, @"Result not as expected");
}

- (void) testFindFirst
{
    NSArray *array1  = [NSArray arrayWithInts:10,1,2,3,4,5,6,7,8,9,10];
    id expect1 = [NSNumber numberWithInt:1];
    id expect2 = [NSNumber numberWithInt:5];
    
    id result = [array1 findFirst:^(id object) { return YES; }];
    STAssertEqualObjects(result, expect1, @"Result not as expected");
    
    result = [array1 findFirst:^(id object) {
        return (BOOL)([object integerValue] % 5 == 0);
    }];
    STAssertEqualObjects(result, expect2, @"Result not as expected");
    
    result = [array1 findFirst:^(id object) { return NO; }];
    STAssertNil(result, @"Result not as expected");
}

- (void) testFindFirstWithIndex
{
    NSArray *array1  = [NSArray arrayWithInts:10,1,2,3,4,5,6,7,8,9,10];
    id expect1 = [NSNumber numberWithInt:1];
    id expect2 = [NSNumber numberWithInt:6];
    
    id result = [array1 findFirstWithIndex:^(id object, NSUInteger index) { return YES; }];
    STAssertEqualObjects(result, expect1, @"Result not as expected");
    
    result = [array1 findFirstWithIndex:^(id object, NSUInteger index) {
        return (BOOL)(index % 5 == 0 && index > 0);
    }];
    STAssertEqualObjects(result, expect2, @"Result not as expected");
    
    result = [array1 findFirstWithIndex:^(id object, NSUInteger index) { return NO; }];
    STAssertNil(result, @"Result not as expected");
}




// ----------------------------------------------------------------------------
   #pragma mark Miscellaneous Methods
// ----------------------------------------------------------------------------


- (void) testIndexSetForObjectsInArray
{
    NSArray *indexes = [NSArray arrayWithInts:3,2,1,3];
    NSArray *array1  = [NSArray arrayWithInts:6,0,1,2,3,4,5];
    
    NSIndexSet *indexSet1 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 3)];
    
    NSIndexSet *result = [array1 indexSetForObjectsInArray:indexes];
    STAssertEqualObjects(result, indexSet1, @"Index sets should match");
}

- (void) testSortedArrayByKeyPaths
{
    NSArray *content = @[
    @{@"a":@2, @"b":@2, @"c":@4} ,
    @{@"a":@5, @"b":@3, @"c":@2} ,
    @{@"a":@3, @"b":@2, @"c":@1} ,
    @{@"a":@4, @"b":@3, @"c":@1} ,
    @{@"a":@1, @"b":@2, @"c":@4} ,
    ];
    
    NSArray *array1 = @[ // Sort by a
    @{@"a":@1, @"b":@2, @"c":@4} ,
    @{@"a":@2, @"b":@2, @"c":@4} ,
    @{@"a":@3, @"b":@2, @"c":@1} ,
    @{@"a":@4, @"b":@3, @"c":@1} ,
    @{@"a":@5, @"b":@3, @"c":@2} ,
    ];

    NSArray *array2 = @[ // Sort by c,b,a
    @{@"a":@3, @"b":@2, @"c":@1} ,
    @{@"a":@4, @"b":@3, @"c":@1} ,
    @{@"a":@5, @"b":@3, @"c":@2} ,
    @{@"a":@1, @"b":@2, @"c":@4} ,
    @{@"a":@2, @"b":@2, @"c":@4} ,
    ];

    NSArray *array3 = @[ // Sort by b,c,a
    @{@"a":@3, @"b":@2, @"c":@1} ,
    @{@"a":@1, @"b":@2, @"c":@4} ,
    @{@"a":@2, @"b":@2, @"c":@4} ,
    @{@"a":@4, @"b":@3, @"c":@1} ,
    @{@"a":@5, @"b":@3, @"c":@2} ,
    ];
    
    NSArray *result = [content sortedArrayByKeyPaths:@"a",nil];
    STAssertEqualObjects(result, array1, @"Array content should match");

    result = [content sortedArrayByKeyPaths:@"c",@"b",@"a",nil];
    STAssertEqualObjects(result, array2, @"Array content should match");

    result = [content sortedArrayByKeyPaths:@"b",@"c",@"a",nil];
    STAssertEqualObjects(result, array3, @"Array content should match");
}


@end
