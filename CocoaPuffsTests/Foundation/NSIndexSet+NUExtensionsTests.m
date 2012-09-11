//
//  NSIndexSet+NUExtensionsTests.m
//  ChartClips
//
//  Created by Eric Methot on 12/04/12.
//  Copyright (c) 2012 NUascent Sàrl. All rights reserved.
//


#import <SenTestingKit/SenTestingKit.h>
#import "NSIndexSet+NUExtensions.h"

@interface NSIndexSet_NUExtensionsTests : SenTestCase

@end




@implementation NSIndexSet_NUExtensionsTests

- (void) testIndexSetByAddingIndex
{
    NSIndexSet *empty = [NSIndexSet indexSet];
    NSIndexSet *expect1 = [NSIndexSet indexSetWithIndex:2];
    NSIndexSet *expect2 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)];
    
    NSIndexSet *result = [empty indexSetByAddingIndex:2];
    STAssertEqualObjects(result, expect1, @"Result not as expected");

    result = [expect1 indexSetByAddingIndex:3];
    STAssertEqualObjects(result, expect2, @"Result not as expected");

    result = [expect2 indexSetByAddingIndex:3];
    STAssertEqualObjects(result, expect2, @"Result not as expected");
}

- (void) testIndexSetByRemovingIndex
{
    NSIndexSet *set23 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)];
    NSIndexSet *expect1 = [NSIndexSet indexSetWithIndex:2];
    NSIndexSet *expect2 = [NSIndexSet indexSet];
    
    NSIndexSet *result = [set23 indexSetByRemovingIndex:3];
    STAssertEqualObjects(result, expect1, @"Result not as expected");
    
    result = [expect1 indexSetByRemovingIndex:2];
    STAssertEqualObjects(result, expect2, @"Result not as expected");
    
    result = [expect2 indexSetByRemovingIndex:2];
    STAssertEqualObjects(result, expect2, @"Result not as expected");
}


- (void) testIndexSetByAddingIndexes
{
    NSIndexSet *empty = [NSIndexSet indexSet];
    NSIndexSet *expect1 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)];
    
    NSIndexSet *result = [empty indexSetByAddingIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)]];
    STAssertEqualObjects(result, expect1, @"Result not as expected");
}

- (void) testIndexSetByRemovingIndexes
{
    NSIndexSet *set234 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)];
    NSIndexSet *empty  = [NSIndexSet indexSet];
    
    NSIndexSet *result = [set234 indexSetByRemovingIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)]];
    STAssertEqualObjects(result, empty, @"Result not as expected");
}


@end
