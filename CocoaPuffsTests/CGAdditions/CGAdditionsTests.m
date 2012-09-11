
#import <SenTestingKit/SenTestingKit.h>
#import "CGAdditions.h"

@interface CGAdditionsTests : SenTestCase

@end

@implementation CGAdditionsTests

// ----------------------------------------------------------------------------
   #pragma mark Additions for CGPoint
// ----------------------------------------------------------------------------

- (void) testCGPointOffset
{
    CGPoint p = CGPointOffset(CGPointZero, 2, 3);
    CGPoint q = CGPointOffset(CGPointZero, -3, 0);
    
    STAssertTrue(CGPointEqualToPoint(p, CGPointMake( 2, 3)), @"Points should be equal");
    STAssertTrue(CGPointEqualToPoint(q, CGPointMake(-3, 0)), @"Points should be equal");
}

- (void) testCGPointDiff
{
    CGPoint a = CGPointMake(1, 2);
    CGPoint b = CGPointMake(3, 4);
    
    CGPoint ab = CGPointDiff(b, a);
    CGPoint ba = CGPointDiff(a, b);
    
    STAssertTrue(CGPointEqualToPoint(ab, CGPointMake( 2, 2)), @"Result not as expected");
    STAssertTrue(CGPointEqualToPoint(ba, CGPointMake(-2,-2)), @"Result not as expected");
}

- (void) testCGPointAdd
{
    CGPoint a = CGPointMake(1, 2);
    CGPoint b = CGPointMake(3, 4);
    
    CGPoint ab = CGPointAdd(b, a);
    CGPoint ba = CGPointAdd(a, b);
    
    STAssertTrue(CGPointEqualToPoint(ab, CGPointMake( 4, 6)), @"Result not as expected");
    STAssertTrue(CGPointEqualToPoint(ba, CGPointMake( 4, 6)), @"Result not as expected");
}

- (void) testCGPointAngleWithPoint
{
    CGPoint o = CGPointMake(1,1);
    CGPoint a = CGPointMake(4,1);
    CGPoint b = CGPointMake(1,4);
    CGPoint c = CGPointMake(5,5);
    CGPoint d = CGPointMake(-1,1);
    CGPoint e = CGPointMake(1,-1);
    CGPoint f = CGPointMake(1,1);
    
    CGFloat ta = CGPointAngleWithPoint(o, a, 2.0);
    CGFloat tb = CGPointAngleWithPoint(o, b, 2.0);
    CGFloat tc = CGPointAngleWithPoint(o, c, 2.0);
    CGFloat td = CGPointAngleWithPoint(o, d, 2.0);
    CGFloat te = CGPointAngleWithPoint(o, e, 2.0);
    CGFloat tf = CGPointAngleWithPoint(o, f, 2.0);
    
    STAssertEqualsWithAccuracy(ta, 0.0, 0.0001, @"Angle should be 0 degrees");
    STAssertEqualsWithAccuracy(tb, M_PI_2, 0.0001, @"Angle should be 90 degrees");
    STAssertEqualsWithAccuracy(tc, M_PI_4, 0.0001, @"Angle should be 45 degrees");
    STAssertEqualsWithAccuracy(td, M_PI, 0.0001, @"Angle should be 180 degrees");
    STAssertEqualsWithAccuracy(te, 3*M_PI_2, 0.0001, @"Angle should be 270 degrees");
    STAssertEqualsWithAccuracy(tf, 2.0, 0.0001, @"Angle should be 2.0 degrees (default)");
}

- (void) testCGPointAfterTransformAndInverseTransform
{
    CGPoint o = CGPointMake(1, 1);
    CGPoint a = CGPointMake(3, 1);
    CGPoint b = CGPointMake(2, 2);
    
    CATransform3D rotate90  = CATransform3DMakeRotation(M_PI_2, 0, 0, 1);
    CATransform3D rotate180 = CATransform3DMakeRotation(M_PI, 0, 0, 1);
    
    CGPoint a1 = CGPointAfterTransform(a, o, rotate180);
    CGPoint b1 = CGPointAfterTransform(b, o, rotate90);
    
    STAssertEqualsWithAccuracy(a1.x, -1.0, 0.0001, @"Result not as expected");
    STAssertEqualsWithAccuracy(a1.y,  1.0, 0.0001, @"Result not as expected");
    STAssertEqualsWithAccuracy(b1.x,  0.0, 0.0001, @"Result not as expected");
    STAssertEqualsWithAccuracy(b1.y,  2.0, 0.0001, @"Result not as expected");
    
    a1 = CGPointAfterInverseTransform(a1, o, rotate180);
    b1 = CGPointAfterInverseTransform(b1, o, rotate90);
    
    STAssertEqualsWithAccuracy(a1.x, a.x, 0.0001, @"Result not as expected");
    STAssertEqualsWithAccuracy(a1.y, a.y, 0.0001, @"Result not as expected");
    STAssertEqualsWithAccuracy(b1.x, b.x, 0.0001, @"Result not as expected");
    STAssertEqualsWithAccuracy(b1.y, b.y, 0.0001, @"Result not as expected");
}

- (void) testCGPointDistance
{
    CGPoint a = CGPointZero;
    CGPoint b = CGPointMake(3, 0);
    CGPoint c = CGPointMake(3, 4);
    
    STAssertEqualsWithAccuracy(CGPointDistance(a, b), 3.0, 0.0001, @"Values should be equal");
    STAssertEqualsWithAccuracy(CGPointDistance(b, c), 4.0, 0.0001, @"Values should be equal");
    STAssertEqualsWithAccuracy(CGPointDistance(a, c), 5.0, 0.0001, @"Values should be equal");
}

- (void) testCGPointScale
{
    CGPoint a = CGPointZero;
    CGPoint b = CGPointMake(3, 0);
    CGPoint c = CGPointMake(3, 4);

    CGPoint a1 = CGPointScale(a, 2.0);
    CGPoint b1 = CGPointScale(b, 3.0);
    CGPoint c1 = CGPointScale(c, 4.0);

    STAssertTrue(CGPointEqualToPoint(a1, CGPointMake( 0,  0)), @"Values should be equal");
    STAssertTrue(CGPointEqualToPoint(b1, CGPointMake( 9,  0)), @"Values should be equal");
    STAssertTrue(CGPointEqualToPoint(c1, CGPointMake(12, 16)), @"Values should be equal");
}

// ----------------------------------------------------------------------------
   #pragma mark Additions for CGSize 
// ----------------------------------------------------------------------------

- (void) testCGSizeMax
{
    CGSize a = CGSizeMake(1, 10);
    CGSize b = CGSizeMake(10, 1);
    CGSize c = CGSizeMake(20,20);
    
    STAssertTrue(CGSizeEqualToSize(CGSizeMax(a, b), CGSizeMake(10, 10)), @"Sizes should be equal");
    STAssertTrue(CGSizeEqualToSize(CGSizeMax(b, a), CGSizeMake(10, 10)), @"Sizes should be equal");
    STAssertTrue(CGSizeEqualToSize(CGSizeMax(a, c), CGSizeMake(20, 20)), @"Sizes should be equal");
    STAssertTrue(CGSizeEqualToSize(CGSizeMax(c, c), CGSizeMake(20, 20)), @"Sizes should be equal");
}


// ----------------------------------------------------------------------------
   #pragma mark Additions for CGRect
// ----------------------------------------------------------------------------

- (void) testCGRectInsetTRBL
{
    CGRect r = CGRectMake(0, 0, 10, 10);
    
    STAssertTrue(CGRectEqualToRect(CGRectInsetTRBL(r, 1, 2, 1, 2), CGRectMake(2, 1, 6, 8)) , @"Rects should be equal");
    STAssertTrue(CGRectEqualToRect(CGRectInsetTRBL(r, 0, 0, 0,-1), CGRectMake(-1, 0, 11, 10)) , @"Rects should be equal");
}

- (void) testCGRectWithPoints
{
    CGPoint a = CGPointMake(10, 10);
    CGPoint b = CGPointMake(20, 20);
    CGPoint c = CGPointMake( 0, 20);
    
    STAssertTrue(CGRectEqualToRect(CGRectWithPoints(CGPointZero, a), CGRectMake(0, 0, 10, 10)), @"Rects should be equal");
    STAssertTrue(CGRectEqualToRect(CGRectWithPoints(a, b), CGRectMake(10, 10, 10, 10)), @"Rects should be equal");
    STAssertTrue(CGRectEqualToRect(CGRectWithPoints(b, a), CGRectMake(10, 10, 10, 10)), @"Rects should be equal");
    STAssertTrue(CGRectEqualToRect(CGRectWithPoints(a, c), CGRectMake(0, 10, 10, 10)), @"Rects should be equal");    
    STAssertTrue(CGRectEqualToRect(CGRectWithPoints(c, a), CGRectMake(0, 10, 10, 10)), @"Rects should be equal");    
}

- (void) testCGRectWithOriginAndSize
{
    STAssertTrue(CGRectEqualToRect(CGRectWithOriginAndSize(CGPointZero, CGSizeMake(2, 2)), CGRectMake(0, 0, 2, 2)), @"Rects should be equal");
    STAssertTrue(CGRectEqualToRect(CGRectWithOriginAndSize(CGPointMake(1, 1), CGSizeMake(1, 1)), CGRectMake(1, 1, 1, 1)), @"Rects should be equal");
}

- (void) testCGRectWalkGrid
{
    CGRect bounds = CGRectMake(0, 0, 100, 100);
    
    __block CGRect walked = CGRectZero;
    __block int rowSum   = 0;
    __block int colSum = 0;
    __block int cellCount = 0;
    
    CGRectWalkGrid(bounds, 10, 5, ^(CGRect rect, int row, int col) {
        walked = CGRectUnion(walked, rect);
        rowSum += row;
        colSum += col;
        cellCount++;
    });
    
    STAssertTrue(CGRectEqualToRect(walked, bounds), @"Rects should be equal");
    STAssertEquals(rowSum, (int)225, @"Sum should be (9 * 10 / 2) x 5 = 225 ");
    STAssertEquals(colSum, (int)100, @"Sum should be (4 * 5 / 2) x 10 = 100 ");
    STAssertEquals(cellCount, (int)50, @"Count should be 50");
}

- (void) testCGRectCenterInRect
{
    CGRect bounds = CGRectMake(0, 0, 100, 100);
    CGRect rect1  = CGRectMake(0, 0, 50, 50);
    CGRect rect2  = CGRectMake(-10,-10,100,100);
    
    CGRect center1 = CGRectCenterInRect(bounds, rect1);
    CGRect center2 = CGRectCenterInRect(bounds, rect2);
    
    STAssertTrue(CGRectEqualToRect(center1, CGRectMake(25, 25, 50, 50)), @"Rects should be equal");
    STAssertTrue(CGRectEqualToRect(center2, bounds), @"Rects should be equal");
}

- (void) testCGRectCorner
{
    CGRect  r = CGRectMake(0, 0, 100, 100);
    
    STAssertTrue(CGPointEqualToPoint(CGRectCornerTL(r, NO), CGPointMake(0, 100)), @"Result not as expected");
    STAssertTrue(CGPointEqualToPoint(CGRectCornerTL(r, YES), CGPointMake(0, 0)), @"Result not as expected");

    STAssertTrue(CGPointEqualToPoint(CGRectCornerTR(r, NO), CGPointMake(100, 100)), @"Result not as expected");
    STAssertTrue(CGPointEqualToPoint(CGRectCornerTR(r, YES), CGPointMake(100, 0)), @"Result not as expected");

    STAssertTrue(CGPointEqualToPoint(CGRectCornerBR(r, NO), CGPointMake(100, 0)), @"Result not as expected");
    STAssertTrue(CGPointEqualToPoint(CGRectCornerBR(r, YES), CGPointMake(100,100)), @"Result not as expected");

    STAssertTrue(CGPointEqualToPoint(CGRectCornerBL(r, NO), CGPointMake(0, 0)), @"Result not as expected");
    STAssertTrue(CGPointEqualToPoint(CGRectCornerBL(r, YES), CGPointMake(0, 100)), @"Result not as expected");


    STAssertTrue(CGPointEqualToPoint(CGRectCorner(r, NO, YES, NO), CGPointMake(0, 100)), @"Result not as expected");
    STAssertTrue(CGPointEqualToPoint(CGRectCorner(r, NO, YES, YES), CGPointMake(0, 0)), @"Result not as expected");
    
    STAssertTrue(CGPointEqualToPoint(CGRectCorner(r, NO, NO, NO), CGPointMake(100, 100)), @"Result not as expected");
    STAssertTrue(CGPointEqualToPoint(CGRectCorner(r, NO, NO, YES), CGPointMake(100, 0)), @"Result not as expected");
    
    STAssertTrue(CGPointEqualToPoint(CGRectCorner(r, YES, NO, NO), CGPointMake(100, 0)), @"Result not as expected");
    STAssertTrue(CGPointEqualToPoint(CGRectCorner(r, YES, NO, YES), CGPointMake(100,100)), @"Result not as expected");
    
    STAssertTrue(CGPointEqualToPoint(CGRectCorner(r, YES, YES, NO), CGPointMake(0, 0)), @"Result not as expected");
    STAssertTrue(CGPointEqualToPoint(CGRectCorner(r, YES, YES, YES), CGPointMake(0, 100)), @"Result not as expected");
}

- (void) testCGRectCenter
{
    CGRect  r = CGRectMake(0, 0, 100, 100);
    CGPoint p = CGRectCenter(r);
    
    STAssertTrue(CGPointEqualToPoint(p, CGPointMake(50, 50)), @"Result not as expected");
}

- (void) testCGRectRelativePoint
{
    CGRect  r = CGRectMake(100,100,100,100);
    CGPoint a = CGRectRelativePoint(r, CGPointZero);
    CGPoint b = CGRectRelativePoint(r, CGPointMake(0.25, 0.75));
    CGPoint c = CGRectRelativePoint(r, CGPointMake(-1, -1));
    
    STAssertTrue(CGPointEqualToPoint(a, CGPointMake(100, 100)), @"Result not as expected");
    STAssertTrue(CGPointEqualToPoint(b, CGPointMake(125, 175)), @"Result not as expected");
    STAssertTrue(CGPointEqualToPoint(c, CGPointMake(  0,   0)), @"Result not as expected");
}

- (void) testCGRectNormalizedPosition
{
    CGRect  r = CGRectMake(100,100,100,100);
    CGPoint a = CGRectNormalizedPosition(r, CGPointMake(100, 100));
    CGPoint b = CGRectNormalizedPosition(r, CGPointMake(125, 175));
    CGPoint c = CGRectNormalizedPosition(r, CGPointMake(  0,   0));
    
    STAssertTrue(CGPointEqualToPoint(a, CGPointMake( 0,   0)), @"Result not as expected");
    STAssertTrue(CGPointEqualToPoint(b, CGPointMake( 0.25,0.75)), @"Result not as expected");
    STAssertTrue(CGPointEqualToPoint(c, CGPointMake(-1,  -1)), @"Result not as expected");
}


// ----------------------------------------------------------------------------
   #pragma mark Additions for CGPath
// ----------------------------------------------------------------------------

- (void) testCGPathCreateWithRectAnd4CornerRadius
{
    // Just for code coverage because not really testable.
    CGPathRef path = CGPathCreateWithRectAnd4CornerRadius(CGRectZero, 0, 0, 0, 0);
    CGPathRelease(path);
}



// ----------------------------------------------------------------------------
   #pragma mark Additions for CGColor
// ----------------------------------------------------------------------------

- (void) testCGColorCreateWithMultipliedComponents
{
    CGColorRef gray50 = CGColorCreateGenericRGB(0.5, 0.5, 0.5, 0.5);
    CGColorRef gray75 = CGColorCreateWithMultipliedComponents(gray50, 1.5);
    CGColorRef gray100 = CGColorCreateWithMultipliedComponents(gray50, 9.9); 
    
    const CGFloat *gray75rgba = CGColorGetComponents(gray75);
    const CGFloat *gray100rgba = CGColorGetComponents(gray100);
    
    STAssertEquals(gray75rgba[0], 0.75, @"Red should be 0.75");
    STAssertEquals(gray75rgba[1], 0.75, @"Green should be 0.75");
    STAssertEquals(gray75rgba[2], 0.75, @"Blue should be 0.75");
    STAssertEquals(gray75rgba[3], 0.50, @"Alpha should have remained 0.50");

    STAssertEquals(gray100rgba[0], 1.00, @"Red should be 1.00");
    STAssertEquals(gray100rgba[1], 1.00, @"Green should be 1.00");
    STAssertEquals(gray100rgba[2], 1.00, @"Blue should be 1.00");
    STAssertEquals(gray100rgba[3], 0.50, @"Alpha should have remained 0.50");
}

- (void) testCGColorCreateWithOffsetComponents
{
    CGColorRef gray50 = CGColorCreateGenericRGB(0.5, 0.5, 0.5, 0.5);
    CGColorRef gray75 = CGColorCreateWithOffsetComponents(gray50, 0.25);
    CGColorRef gray100 = CGColorCreateWithOffsetComponents(gray50, 1.25);
    
    const CGFloat *gray75rgba = CGColorGetComponents(gray75);
    const CGFloat *gray100rgba = CGColorGetComponents(gray100);
    
    
    STAssertEquals(gray75rgba[0], 0.75, @"Red should be 0.75");
    STAssertEquals(gray75rgba[1], 0.75, @"Green should be 0.75");
    STAssertEquals(gray75rgba[2], 0.75, @"Blue should be 0.75");
    STAssertEquals(gray75rgba[3], 0.50, @"Alpha should have remained 0.50");

    STAssertEquals(gray100rgba[0], 1.00, @"Red should be 1.00");
    STAssertEquals(gray100rgba[1], 1.00, @"Green should be 1.00");
    STAssertEquals(gray100rgba[2], 1.00, @"Blue should be 1.00");
    STAssertEquals(gray100rgba[3], 0.50, @"Alpha should have remained 0.50");
}

#define DEGREES2UNIT(a) ((a)/360.0)

- (void) testCGColorCreateWithGenericHSBA
{
    // See http://en.wikipedia.org/wiki/HSL_and_HSV for details of test cases.
    
    CGColorRef a = CGColorCreateWithGenericHSBA(DEGREES2UNIT(0.0), 1.0, 1.0, 1.0);
    CGColorRef a1 = CGColorCreateGenericRGB(1, 0, 0, 1);

    CGColorRef b = CGColorCreateWithGenericHSBA(DEGREES2UNIT(180), 0.5, 1.0, 1.0);
    CGColorRef b1 = CGColorCreateGenericRGB(0.5, 1.0, 1.0, 1);

    CGColorRef c = CGColorCreateWithGenericHSBA(DEGREES2UNIT(300), 2.0/3.0, 0.75, 1.0);
    CGColorRef c1 = CGColorCreateGenericRGB(0.75, 0.25, 0.75, 1);

    CGColorRef d = CGColorCreateWithGenericHSBA(DEGREES2UNIT(60), 1.0, 0.75, 1.0);
    CGColorRef d1 = CGColorCreateGenericRGB(0.75, 0.75, 0.0, 1);
    
    CGColorRef e = CGColorCreateWithGenericHSBA(DEGREES2UNIT(240), 0.5, 1.0, 1.0);
    CGColorRef e1 = CGColorCreateGenericRGB(0.5, 0.5, 1.0, 1);
    
    CGColorRef f = CGColorCreateWithGenericHSBA(DEGREES2UNIT(120), 1.0, 0.5, 1.0);
    CGColorRef f1 = CGColorCreateGenericRGB(0, 0.5, 0, 1);
    

    STAssertTrue(CGColorApproximatelyEqualsColor(a, a1, 0.01), @"Colors should match");
    STAssertTrue(CGColorApproximatelyEqualsColor(b, b1, 0.01), @"Colors should match");
    STAssertTrue(CGColorApproximatelyEqualsColor(c, c1, 0.01), @"Colors should match");
    STAssertTrue(CGColorApproximatelyEqualsColor(d, d1, 0.01), @"Colors should match");
    STAssertTrue(CGColorApproximatelyEqualsColor(e, e1, 0.01), @"Colors should match");
    STAssertTrue(CGColorApproximatelyEqualsColor(f, f1, 0.01), @"Colors should match");
}

#undef RAD2DEGREES


- (void) testCGColorApproximatelyEqualsColor
{
    CGColorRef a = CGColorCreateGenericRGB(0, 0, 0, 1.0);
    CGColorRef b = CGColorCreateGenericRGB(0.001, 0.001, 0.001, 1.0);
    CGColorRef c = CGColorCreateGenericRGB(0.2, 0.2, 0.2, 1.0);
    
    STAssertTrue(CGColorApproximatelyEqualsColor(a, b, 0.01), @"Colors should be almost equal");
    STAssertFalse(CGColorApproximatelyEqualsColor(a, c, 0.01), @"Colors should NOT be almost equal");
}

@end
