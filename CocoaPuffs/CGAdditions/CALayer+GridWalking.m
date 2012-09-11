
#import "CALayer+GridWalking.h"
#import "CGAdditions.h"

@implementation CALayer (GridWalking)

- (void) walkGridInBoundsRows:(int)rows
                      columns:(int)cols
                        yield:(void(^)(CGRect rect, int row, int col)) block
{
    CGRectWalkGrid(self.bounds, rows, cols, block);
}


- (void) walkGridInRect:(CGRect) rect 
                   rows:(int) rows
                columns:(int) cols
                  yield:(void(^)(CGRect rect, int row, int col)) block
{
    CGRectWalkGrid(rect, rows, cols, block);
}

@end
