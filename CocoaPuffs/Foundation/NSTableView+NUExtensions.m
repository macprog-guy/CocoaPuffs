
#import "NSTableView+NUExtensions.h"

@implementation NSTableView (NUExtensions)

// COV_NF_START

- (NSTableRowView*) firstMatchingRowView:(BOOL(^)(NSTableRowView *rowView))test
{
    if (![self.delegate respondsToSelector:@selector(tableView:viewForTableColumn:row:)] || test == nil)
        return nil;
    
    NSTableRowView __block *rowView = nil;
    
    [self.subviews enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
        if (test((NSTableRowView*)object)) {
            rowView = object;
            *stop = YES;
        }
    }];
    
    return rowView;
}

- (NSTableCellView*) firstMatchingCellView:(BOOL(^)(NSTableRowView *rowView, NSTableCellView *cellView))test
{
    if (![self.delegate respondsToSelector:@selector(tableView:viewForTableColumn:row:)] || test == nil)
        return nil;
    
    NSTableCellView __block *cellView = nil;
    
    [self.subviews enumerateObjectsUsingBlock:^(id rowObject, NSUInteger rowIndex, BOOL *rowStop) {
        [[(NSTableRowView*)rowObject subviews] enumerateObjectsUsingBlock:^(id colObject, NSUInteger colIndex, BOOL *colStop) {
            if (test((NSTableRowView*)rowObject, (NSTableCellView*)colObject)) {
                cellView = colObject;
                *colStop = YES;
                *rowStop = YES;
            }
        }];
    }];

    return cellView;
}

// COV_NF_END

@end
