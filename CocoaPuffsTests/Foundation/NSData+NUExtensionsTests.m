
#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NSData_NUExtensionsTests : SenTestCase

@end

@implementation NSData_NUExtensionsTests

- (void) testRampWithUInt64StartingAtIncrementCountReverseOrder
{
    uint64_t values1 [] = {0,1,2,3,4,5,6,7,8,9};
    NSData *valuesData1 = [NSData dataWithBytesNoCopy:values1 length:sizeof(uint64_t)*10 freeWhenDone:NO];

    uint64_t values2 [] = {9,8,7,6,5,4,3,2,1,0};
    NSData *valuesData2 = [NSData dataWithBytesNoCopy:values2 length:sizeof(uint64_t)*10 freeWhenDone:NO];

    NSData *result = [NSData rampWithUInt64StartingAt:0 increment:1 count:10 reverseOrder:NO];
    STAssertEqualObjects(result, valuesData1, @"Data should be the same");

    result = [NSData rampWithUInt64StartingAt:0 increment:1 count:10];
    STAssertEqualObjects(result, valuesData1, @"Data should be the same");

    result = [NSData rampWithUInt64StartingAt:0 increment:1 count:10 reverseOrder:YES];
    STAssertEqualObjects(result, valuesData2, @"Data should be the same");
}

- (void) testAsciiArtOfWidthAndHeight
{
    const uint8_t values[] = {
        0,  0,  0,  0,  0,  0,  0,  0,  0,
        0,  8,  8,  8,  8,  8,  8,  8,  0,
        0, 31, 63, 95,127,159,191,233,  0,
        0, 32, 64, 96,128,160,192,234,  0,
        0, 33, 65, 97,129,161,193,235,  0,
        0,  0,  0,  0,  0,  0,  0,  0,255,
    };
    
    NSString *art1 =
        @"+---------+\n"
        @"|         |\n"
        @"| ....... |\n"
        @"| .-+=o#@ |\n"
        @"| .-+=o#@ |\n"
        @"| -+=o#@8 |\n"
        @"|        8|\n"
        @"+---------+\n";

    NSData *data = [NSData dataWithBytesNoCopy:(void*)values length:9*6 freeWhenDone:NO];
    
    NSString *result = [data asciiArtOfWidth:9 andHeight:6];
    STAssertEqualObjects(result, art1, @"ASCII Art should match");
}

@end
