
#import <SenTestingKit/SenTestingKit.h>
#import "NSURL+NUExtensions.h"

@interface NSURL_NUExtensionsTests : SenTestCase {
    NSURL *testFileDirectory;
}
@end

@implementation NSURL_NUExtensionsTests

- (void) setUp
{
    testFileDirectory = [[NSURL fileURLWithPath:[NSString stringWithFormat:@"%s/../../Test Files/",__FILE__]] URLByStandardizingPath];
}

- (void) testURLTypeIdentifier
{
    NSURL *file001 = [testFileDirectory URLByAppendingPathComponent:@"test001.txt"];
    NSURL *fileXXX = [NSURL URLWithString:@"file:///does-not-exist"];
    NSString *type1 = [file001 URLTypeIdentifier];
    NSString *typeX = [fileXXX URLTypeIdentifier];
    
    STAssertEqualObjects(type1, (__bridge NSString*)kUTTypePlainText, @"UTType should be plain text");
    STAssertNil(typeX, @"Non-existing file should not have a type identifier");
}

- (void) testConformsToType
{
    NSString *testFilePath = [NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL fileURLWithPath:testFilePath];
    
    STAssertTrue([url conformsToType:(__bridge NSString*)kUTTypeText], @"Should conform to type text");
    STAssertTrue([url conformsToType:(__bridge NSString*)kUTTypeSourceCode], @"Should conform to type source code");
    STAssertFalse([url conformsToType:(__bridge NSString*)kUTTypeVideo], @"Should not conform to type video");
}

- (void) testConformsToAnyTypeInTypes
{
    NSString *testFilePath = [NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL fileURLWithPath:testFilePath];
    
    NSArray *anyOfTheseTwoTypes = [NSArray arrayWithObjects:(__bridge NSString*)kUTTypeSourceCode, (__bridge NSString*)kUTTypeVideo, nil];
    NSArray *anyOfTheseOneTypes = [NSArray arrayWithObjects:(__bridge NSString*)kUTTypeVideo, nil];
    
    STAssertTrue([url conformsToAnyTypeInTypes:anyOfTheseTwoTypes], @"Should conform to type text");
    STAssertFalse([url conformsToAnyTypeInTypes:anyOfTheseOneTypes], @"Should conform to type text");
}

- (void) testEachLine
{
    NSURL *file001 = [testFileDirectory URLByAppendingPathComponent:@"test001.txt"];
    uint64_t line_count = [file001 eachLine:^(uint64_t line_no, char *line, long length, BOOL *stop) {
        
    }];
    
    STAssertEquals(line_count, 5ULL, @"There should be 5 lines in the test file");
}

- (void) testEachLineWithLineOver4096bytes
{
    NSURL *file007 = [testFileDirectory URLByAppendingPathComponent:@"test007.txt"];

    uint64_t line_count = [file007 eachLine:^(uint64_t line_no, char *line, long length, BOOL *stop) {
        
    }];
    
    STAssertEquals(line_count, 2ULL, @"There should be 2 lines in the test file");
}

- (void) testEachLineWithLineOver8192bytes
{
    NSURL *file008 = [testFileDirectory URLByAppendingPathComponent:@"test008.txt"];
    
    uint64_t line_count = [file008 eachLine:^(uint64_t line_no, char *line, long length, BOOL *stop) {
        
    }];
    
    STAssertEquals(line_count, 0ULL, @"There should be 2 lines in the test file");
}

- (void) testEachField
{
    uint64_t  *counts = malloc(sizeof(uint64_t) * 6);
    uint64_t expect[] = {4, 3, 4, 4, 4, 7};
    
    NSURL *file006 = [testFileDirectory URLByAppendingPathComponent:@"test006.txt"];
    uint64_t line_count = [file006 eachFieldSplitBy:',' do:^(uint64_t line_no, uint64_t field_no, char *text, long length, BOOL *stop) {
        if (line_no < 6)
            counts[line_no] = field_no + 1;
    }];
    
    free(counts);
    
    STAssertEquals(line_count, 6ULL, @"values should match");
    STAssertEquals(counts[0], expect[0], @"values should match");
    STAssertEquals(counts[1], expect[1], @"values should match");
    STAssertEquals(counts[2], expect[2], @"values should match");
    STAssertEquals(counts[3], expect[3], @"values should match");
    STAssertEquals(counts[4], expect[4], @"values should match");
    STAssertEquals(counts[5], expect[5], @"values should match");
}

- (void) testEachFieldStopParam
{
    NSURL *file005 = [testFileDirectory URLByAppendingPathComponent:@"test005.txt"];
    uint64_t line_count = [file005 eachFieldSplitBy:',' do:^(uint64_t line_no, uint64_t field_no, char *text, long length, BOOL *stop) {
        *stop = YES;
    }];
    
    STAssertEquals(line_count, 1ULL, @"Should have read only 1 line");
    
    line_count = [file005 eachFieldSplitBy:',' fieldCount:3 do:^(uint64_t line_no, uint64_t field_no, char *text, long length, BOOL *stop) {
        *stop = YES;
    }];

    STAssertEquals(line_count, 1ULL, @"Should have read only 1 line");
}

- (void) testEachFieldCount
{
    uint64_t  *counts = malloc(sizeof(uint64_t) * 6);
    uint64_t expect[] = {4, 4, 4, 4, 4, 4};
    
    NSURL *file006 = [testFileDirectory URLByAppendingPathComponent:@"test006.txt"];
    uint64_t line_count = [file006 eachFieldSplitBy:',' fieldCount:4 do:^(uint64_t line_no, uint64_t field_no, char *text, long length, BOOL *stop) {
        if (line_no < 6)
            counts[line_no] = field_no + 1;
    }];
    
    free(counts);
    
    STAssertEquals(line_count, 6ULL, @"values should match");
    STAssertEquals(counts[0], expect[0], @"values should match");
    STAssertEquals(counts[1], expect[1], @"values should match");
    STAssertEquals(counts[2], expect[2], @"values should match");
    STAssertEquals(counts[3], expect[3], @"values should match");
    STAssertEquals(counts[4], expect[4], @"values should match");
    STAssertEquals(counts[5], expect[5], @"values should match");
}


@end
