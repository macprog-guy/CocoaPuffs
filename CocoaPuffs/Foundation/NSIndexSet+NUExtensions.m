
#import "NSIndexSet+NUExtensions.h"

@implementation NSIndexSet (NUExtensions)

- (NSIndexSet*) indexSetByAddingIndex:(NSUInteger)index
{
    NSMutableIndexSet *derivedSet = [NSMutableIndexSet indexSet];
    [derivedSet addIndexes:self];
    [derivedSet addIndex:index];
    
    return derivedSet;
}

- (NSIndexSet*) indexSetByRemovingIndex:(NSUInteger)index
{
    NSMutableIndexSet *derivedSet = [NSMutableIndexSet indexSet];
    [derivedSet addIndexes:self];
    [derivedSet removeIndex:index];
    
    return derivedSet;
}

- (NSIndexSet*) indexSetByAddingIndexes:(NSIndexSet*)indexes
{
    NSMutableIndexSet *derivedSet = [NSMutableIndexSet indexSet];
    [derivedSet addIndexes:self];
    [derivedSet addIndexes:indexes];
    
    return derivedSet;
}

- (NSIndexSet*) indexSetByRemovingIndexes:(NSIndexSet*)indexes
{
    NSMutableIndexSet *derivedSet = [NSMutableIndexSet indexSet];
    [derivedSet addIndexes:self];
    [derivedSet removeIndexes:indexes];
    
    return derivedSet;
}

@end
