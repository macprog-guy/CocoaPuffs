
#import <SenTestingKit/SenTestingKit.h>
#import "CocoaPuffs.h"

@interface NUFileBrowserNodeItemTests : SenTestCase {
    NSURL *_testDirectory;
    NUFileBrowserNodeItem *_root;
}
@end

@implementation NUFileBrowserNodeItemTests  // COV_NF_LINE

- (void) setUp
{
    _testDirectory = [[NSURL fileURLWithPath:[NSString stringWithFormat:@"%s/../../Test Files/",__FILE__]] URLByStandardizingPath];
    _root = [NUFileBrowserNodeItem treeNodeWithRepresentedObject:_testDirectory];
}

- (void) testProperties
{
    STAssertNotNil(_root.image, @"Folders should have images");
    STAssertNotNil(_root.image, @"Folders should have cached image");
    STAssertEqualObjects(_root.label, @"Test Files", @"Values should match");
    STAssertEqualObjects(_root.label, @"Test Files", @"Values should match (cached)");
    STAssertEqualObjects(_root.type, (__bridge NSString*)kUTTypeFolder, @"Folder should have a type of directory");
    STAssertNotNil(_root.typeDescription, @"Description should not be nil");
    STAssertNotNil(_root.creationDate, @"Value should exist");
    STAssertNotNil(_root.lastAccessDate, @"Value should exist");
    STAssertNotNil(_root.lastModificationDate, @"Value should exist");
    STAssertTrue(_root.isDirectory, @"Node is a directory");
    STAssertFalse(_root.isLeaf, @"Directory has content and so is not a leaf");
    STAssertTrue(_root.enabled, @"Value should be true");
    STAssertEquals(_root.fileSize, 0ULL, @"Values should match");
    STAssertEquals(_root.fileSizeKB, 0.0, @"Values should match");
    STAssertEquals(_root.fileSizeMB, 0.0, @"Values should match");
    STAssertNil(_root.supportedTypes, @"Value should be nil");
}

- (void) testChildNodes
{
    NSArray *files = _root.childNodes;
    NUFileBrowserNodeItem *file001 = [files objectAtIndex:0];
    
    STAssertNotNil(files, @"There should be some test files");
    STAssertEquals(files.count, 9ULL, @"There should be 10 test files or directories");
    STAssertNotNil(file001, @"Value should not be nil");
    
    STAssertNotNil(file001.image, @"Folders should have images");
    STAssertEqualObjects(file001.label, @"test001.txt", @"Values should match");
    STAssertEqualObjects(file001.type, (__bridge NSString*)kUTTypePlainText, @"Should be plain-text");
    STAssertNotNil(file001.typeDescription, @"Description should not be nil");
    STAssertNotNil(file001.creationDate, @"Value should exist");
    STAssertNotNil(file001.lastAccessDate, @"Value should exist");
    STAssertNotNil(file001.lastModificationDate, @"Value should exist");
    STAssertFalse(file001.isDirectory, @"Node is a directory");
    STAssertTrue(file001.isLeaf, @"Directory has content and so is not a leaf");
    STAssertTrue(file001.enabled, @"Value should be true");
    STAssertEquals(file001.fileSize, 111ULL, @"Values should match");
    STAssertEqualsWithAccuracy(file001.fileSizeKB, 0.11, 0.01, @"Values should match within tolerence");
    STAssertEqualsWithAccuracy(file001.fileSizeMB, 0.00010, 0.00001, @"Values should match within tolerence");
    
    file001.enabled = NO;
    
    STAssertFalse(file001.enabled, @"Should now be disabled");
}

/*
- (void) testInaccessibleDirectory
{
    NSArray *files = _root.childNodes;
    NUFileBrowserNodeItem *dir = files.firstObject;

    STAssertNotNil(dir.image, @"Folders should have images");
    STAssertEqualObjects(dir.label, @"inaccessible", @"Values should match");
    STAssertEqualObjects(dir.type, (__bridge NSString*)kUTTypeFolder, @"Folder should have a type of directory");
    STAssertNotNil(dir.typeDescription, @"Description should not be nil");
    STAssertNotNil(dir.creationDate, @"Value should exist");
    STAssertNotNil(dir.lastAccessDate, @"Value should exist");
    STAssertNotNil(dir.lastModificationDate, @"Value should exist");
    STAssertTrue(dir.isDirectory, @"Node is a directory");

    STAssertTrue(dir.isLeaf, @"Directory has content and so is not a leaf");
    STAssertFalse(dir.enabled, @"Value should be true");
    
    STAssertEquals(dir.fileSize, 0ULL, @"Values should match");
    STAssertEquals(dir.fileSizeKB, 0.0, @"Values should match");
    STAssertEquals(dir.fileSizeMB, 0.0, @"Values should match");
    
    STAssertEqualObjects(dir.childNodes, @[], @"This directory should have no child items");
}
*/

@end
