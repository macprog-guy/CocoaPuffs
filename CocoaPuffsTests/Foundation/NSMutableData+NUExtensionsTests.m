#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NSMutableData_NUExtensionsTests : SenTestCase

@end

@implementation NSMutableData_NUExtensionsTests

- (void) testReverseBytesInChunksOfSize8Bits
{
    uint8_t bytes1[] = {0,1,2,3,4,5,6,7,8,9};
    uint8_t bytes2[] = {9,8,7,6,5,4,3,2,1,0};
    NSMutableData *data1 = [NSMutableData dataWithBytesNoCopy:bytes1 length:sizeof(uint8_t)*10 freeWhenDone:NO];
    NSMutableData *data2 = [NSMutableData dataWithBytesNoCopy:bytes2 length:sizeof(uint8_t)*10 freeWhenDone:NO];
    
    [data1 reverseBytesInChunksOfSize:1];
    
    STAssertEqualObjects(data1, data2, @"Data content should match");
}

- (void) testReverseBytesInChunksOfSize16Bits
{
    uint16_t bytes1[] = {0,1,2,3,4,5,6,7,8,9};
    uint16_t bytes2[] = {9,8,7,6,5,4,3,2,1,0};
    NSMutableData *data1 = [NSMutableData dataWithBytesNoCopy:bytes1 length:sizeof(uint16_t)*10 freeWhenDone:NO];
    NSMutableData *data2 = [NSMutableData dataWithBytesNoCopy:bytes2 length:sizeof(uint16_t)*10 freeWhenDone:NO];
    
    [data1 reverseBytesInChunksOfSize:2];
    
    STAssertEqualObjects(data1, data2, @"Data content should match");
}

- (void) testReverseBytesInChunksOfSize32Bits
{
    uint32_t bytes1[] = {0,1,2,3,4,5,6,7,8,9};
    uint32_t bytes2[] = {9,8,7,6,5,4,3,2,1,0};
    NSMutableData *data1 = [NSMutableData dataWithBytesNoCopy:bytes1 length:sizeof(uint32_t)*10 freeWhenDone:NO];
    NSMutableData *data2 = [NSMutableData dataWithBytesNoCopy:bytes2 length:sizeof(uint32_t)*10 freeWhenDone:NO];
    
    [data1 reverseBytesInChunksOfSize:4];
    
    STAssertEqualObjects(data1, data2, @"Data content should match");    
}

- (void) testReverseBytesInChunksOfSize64Bits
{
    uint64_t bytes1[] = {0,1,2,3,4,5,6,7,8,9};
    uint64_t bytes2[] = {9,8,7,6,5,4,3,2,1,0};
    NSMutableData *data1 = [NSMutableData dataWithBytesNoCopy:bytes1 length:sizeof(uint64_t)*10 freeWhenDone:NO];
    NSMutableData *data2 = [NSMutableData dataWithBytesNoCopy:bytes2 length:sizeof(uint64_t)*10 freeWhenDone:NO];
    
    [data1 reverseBytesInChunksOfSize:8];
    
    STAssertEqualObjects(data1, data2, @"Data content should match");
}

- (void) testReverseBytesInChunksOfOtherBits
{
    uint64_t bytes1[] = {0,1,2,3,4,5,6,7,8,9};
    NSMutableData *data1 = [NSMutableData dataWithBytesNoCopy:bytes1 length:sizeof(uint64_t)*10 freeWhenDone:NO];
    
    STAssertThrows([data1 reverseBytesInChunksOfSize:3], @"Should throw an exception");
    STAssertThrows([data1 reverseBytesInChunksOfSize:5], @"Should throw an exception");
    STAssertThrows([data1 reverseBytesInChunksOfSize:6], @"Should throw an exception");
    STAssertThrows([data1 reverseBytesInChunksOfSize:7], @"Should throw an exception");
    STAssertThrows([data1 reverseBytesInChunksOfSize:9], @"Should throw an exception");
    STAssertThrows([data1 reverseBytesInChunksOfSize:10], @"Should throw an exception");
}

@end
