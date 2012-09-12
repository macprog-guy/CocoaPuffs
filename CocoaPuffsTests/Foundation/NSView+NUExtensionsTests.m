#import <SenTestingKit/SenTestingKit.h>
#import <CocoaPuffs/CocoaPuffs.h>

@interface NSView_NUExtensionsTests : SenTestCase

@end

@implementation NSView_NUExtensionsTests

- (void) testRecursivelyDisableAutoresizingMaskConstraint
{
    NSView *viewA = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    viewA.translatesAutoresizingMaskIntoConstraints = YES;
    
    NSView *viewB = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    viewB.translatesAutoresizingMaskIntoConstraints = YES;

    NSView *viewC = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    viewC.translatesAutoresizingMaskIntoConstraints = YES;
    
    [viewB addSubview:viewC];
    [viewA addSubview:viewB];
    
    [viewA recursivelyDisableAutorisizingMaskConstraints];
    
    STAssertFalse(viewA.translatesAutoresizingMaskIntoConstraints, @"Should be NO");
    STAssertFalse(viewB.translatesAutoresizingMaskIntoConstraints, @"Should be NO");
    STAssertFalse(viewC.translatesAutoresizingMaskIntoConstraints, @"Should be NO");
}

@end
