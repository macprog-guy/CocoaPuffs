#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NSTreeController_NUExtensionsTests : SenTestCase {
    NSTreeController *_controller;
    NSArray *_rootObjects;

    NSTreeNode *_node_0_0;
    NSTreeNode *_node_2_3;
    NSTreeNode *_node_4_1;
    
    NSIndexPath *_path_0_0;
    NSIndexPath *_path_2_3;
    NSIndexPath *_path_4_1;
}
@end

@implementation NSTreeController_NUExtensionsTests

- (void) setUp
{
    NSMutableArray *objects = [NSMutableArray array];
    for (int i=0;  i<10;  i++) {
       
        NSTreeNode *rootNode = [NSTreeNode treeNodeWithRepresentedObject:[NSString stringWithFormat:@"%d",i]];
        [objects addObject:rootNode];
        
        for (int j=0;  j<4;  j++) {
            NSTreeNode *lev1Node = [NSTreeNode treeNodeWithRepresentedObject:[NSString stringWithFormat:@"%d",j]];
            [rootNode.mutableChildNodes addObject:lev1Node];
        }
    }
    
    _node_0_0 = [[(NSTreeNode*)[objects objectAtIndex:0] childNodes] objectAtIndex:0];
    _node_4_1 = [[(NSTreeNode*)[objects objectAtIndex:4] childNodes] objectAtIndex:1];
    _node_2_3 = [[(NSTreeNode*)[objects objectAtIndex:2] childNodes] objectAtIndex:3];

    NSUInteger indexes[] = {0,0,2,3,4,1};
    _path_0_0 = [NSIndexPath indexPathWithIndexes:&indexes[0] length:2];
    _path_2_3 = [NSIndexPath indexPathWithIndexes:&indexes[2] length:2];
    _path_4_1 = [NSIndexPath indexPathWithIndexes:&indexes[4] length:2];

    _controller = [[NSTreeController alloc] initWithContent:objects];
    _controller.childrenKeyPath = @"childNodes";
    
}

- (void) testSetSelectedObjects
{
    NSArray *expectedIndexPaths = @[_path_0_0, _path_2_3, _path_4_1];
    _controller.selectedObjects = @[_node_0_0, _node_2_3, _node_4_1];
    
    STAssertEqualObjects(_controller.selectionIndexPaths, expectedIndexPaths, @"Index paths should match");
}

- (void) testIndexPathToObject
{
    STAssertEqualObjects([_controller indexPathToObject:_node_0_0], _path_0_0, @"Index paths should match");
    STAssertEqualObjects([_controller indexPathToObject:_node_2_3], _path_2_3, @"Index paths should match");
    STAssertEqualObjects([_controller indexPathToObject:_node_4_1], _path_4_1, @"Index paths should match");
}

- (void) testObjectAtIndexPath
{
    STAssertEqualObjects([_controller objectAtIndexPath:_path_0_0], _node_0_0, @"Objects should be the same");
    STAssertEqualObjects([_controller objectAtIndexPath:_path_2_3], _node_2_3, @"Objects should be the same");
    STAssertEqualObjects([_controller objectAtIndexPath:_path_4_1], _node_4_1, @"Objects should be the same");
}

@end
