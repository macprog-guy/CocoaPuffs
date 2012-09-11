
#import <SenTestingKit/SenTestingKit.h>
#import "CALayer+GridWalking.h"

@interface CALayer_GridWalkingTests : SenTestCase

@end

@implementation CALayer_GridWalkingTests

- (void) testWalkGridInRectRowsColumnsYield
{
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, 100, 100);
    
    __block CGRect walked = CGRectNull;
    __block int rowSum = 0;
    __block int colSum = 0;
    __block int cellCount = 0;
    
    [layer walkGridInRect:CGRectMake(10, 10, 10, 10) rows:10 columns:5 yield:^(CGRect rect, int row, int col) {
        walked = CGRectUnion(walked, rect);
        rowSum += row;
        colSum += col;
        cellCount++;
    }];
    
    STAssertTrue(CGRectEqualToRect(walked, CGRectMake(10, 10, 10, 10)), @"Rects should be equal");
    STAssertEquals(rowSum, (int)225, @"Sum should be (9 * 10 / 2) x 5 = 225 ");
    STAssertEquals(colSum, (int)100, @"Sum should be (4 * 5 / 2) x 10 = 100 ");
    STAssertEquals(cellCount, (int)50, @"Count should be 50");
}

- (void) testWalkGridInBoundsRowsColumnsYield
{
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, 100, 100);
    
    __block CGRect walked = CGRectNull;
    __block int rowSum = 0;
    __block int colSum = 0;
    __block int cellCount = 0;
    
    [layer walkGridInBoundsRows:10 columns:5 yield:^(CGRect rect, int row, int col) {
        walked = CGRectUnion(walked, rect);
        rowSum += row;
        colSum += col;
        cellCount++;
    }];
    
    STAssertTrue(CGRectEqualToRect(walked, layer.bounds), @"Rects should be equal");
    STAssertEquals(rowSum, (int)225, @"Sum should be (9 * 10 / 2) x 5 = 225 ");
    STAssertEquals(colSum, (int)100, @"Sum should be (4 * 5 / 2) x 10 = 100 ");
    STAssertEquals(cellCount, (int)50, @"Count should be 50");
}


@end
