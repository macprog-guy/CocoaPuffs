
#import <SenTestingKit/SenTestingKit.h>
#import "NSString+NUExtensions.h"

@interface NUString_NUExtensionsTests : SenTestCase

@end



@implementation NUString_NUExtensionsTests

- (void)testStringForPathToTemporaryFileWithTemplateAndExtension
{
    NSMutableSet *paths = [NSMutableSet set];
    
    const NSUInteger count = 2500;
    
    // -------------------------------------------------------------------------
    //
    // Test large enough template.
    //
    // Eight Xs allows for 62^6 possible values.
    // There is but a very small chance that in sample of 2500 we hit a duplicate.
    //
    // -------------------------------------------------------------------------
    
    for (NSUInteger i=0;  i<count;  i++) 
        [paths addObject:[NSString stringForPathToTemporaryFileWithTemplate:@"XXXXXX" andExtension:@"txt"]];
        
    STAssertEquals(paths.count, count, @"Duplicate filenames seem to have been generated");


    // -------------------------------------------------------------------------
    //
    // Test small templates.
    //
    // A single Xs allows for only 62 possible values.
    // With a sample of 2500, we will encounter many duplicates.
    //
    // -------------------------------------------------------------------------

    [paths removeAllObjects];
    for (NSUInteger i=0;  i<count;  i++) 
        [paths addObject:[NSString stringForPathToTemporaryFileWithTemplate:@"X" andExtension:@"txt"]];

    STAssertFalse(paths.count == count, @"Duplicate filenames should have been generated");
}

- (void) testStringForPathToTemporaryFileWithExtension
{
    NSString *path = [NSString stringForPathToTemporaryFileWithExtension:@"txt"];
    STAssertTrue([path hasSuffix:@".txt"], @"The path should have a .txt suffix");
}

- (void) testStringForPathToTemporaryFileWithTemplate
{
    NSString *path = [NSString stringForPathToTemporaryFileWithTemplate:@"XXXooXXX"];
    NSString *file = [path componentsSeparatedByString:@"/"].lastObject;
    STAssertEquals(file.length, 8ULL, @"The path should have 8 characters");
}

- (void) testStringForPathToTemporaryFile
{
    NSString *path = [NSString stringForPathToTemporaryFile];
    NSString *file = [path componentsSeparatedByString:@"/"].lastObject;
    STAssertEquals(file.length, 16ULL, @"The path should have 16 characters");
}


- (void)testTitleCase
{
    NSString *original1 = @"this_is_nice";
    NSString *title1 = @"This Is Nice";
    
    NSString *original2 = @"helloWorld ";
    NSString *title2 = @"Hello World";

    NSString *original3 = @"thisIsACamelCase__String";
    NSString *title3 = @"This Is A Camel Case String";

    NSString *original4 = @"_this__Is_not__a___camelCase__String__";
    NSString *title4 = @"This Is Not A Camel Case String";
    
    STAssertEqualObjects([original1 stringWithTitleCase], title1, @"Results are not as expected");
    STAssertEqualObjects([original2 stringWithTitleCase], title2, @"Results are not as expected");
    STAssertEqualObjects([original3 stringWithTitleCase], title3, @"Results are not as expected");
    STAssertEqualObjects([original4 stringWithTitleCase], title4, @"Results are not as expected");
}

- (void) testStringByRemovingAccents
{
    STAssertEqualObjects([@"ãàäâåêéëèîïíìõòôöóùüûúñ" stringByRemovingAccents], @"aaaaaeeeeiiiiooooouuuun", @"Values should match");
    STAssertEqualObjects([@"Hello" stringByRemovingAccents], @"Hello", @"Values should match");
}

- (void) testSringFromUUID
{
    NSString *a = [NSString stringFromUUID];
    NSString *b = [NSString stringFromUUID];
    
    STAssertTrue(![a isEqualToString:b], @"UUIDs should never be the same");
}

@end
