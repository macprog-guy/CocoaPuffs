
#import "CGAdditions.h"
#import "NUFunctions.h"

// ----------------------------------------------------------------------------
   #pragma mark Additions for CGPoint 
// ----------------------------------------------------------------------------

CGPoint CGPointOffset(CGPoint p, CGFloat dx, CGFloat dy)
{
    return CGPointMake(p.x + dx, p.y + dy);
}

CGPoint CGPointDiff(CGPoint p, CGPoint q)
{
    return CGPointMake(p.x - q.x, p.y - q.y);
}

CGPoint CGPointAdd(CGPoint p, CGPoint q)
{
    return CGPointMake(p.x + q.x, p.y + q.y);
}


CGFloat CGPointAngleWithPoint(CGPoint a, CGPoint b, CGFloat defaultValue)
{
    CGPoint ab = CGPointDiff(b, a);
    CGFloat r  = hypot(ab.x, ab.y);
    
    if (r < 0.001)
        return defaultValue;
    
    CGFloat angle = asin(ab.y / r);
    
    if (b.x < a.x) {
        angle = M_PI - angle;
    } else if (b.y < a.y) {
        angle = 2 * M_PI + angle;
    }
 
    return angle;
}

CGPoint CGPointAfterTransform(CGPoint p, CGPoint origin, CATransform3D transform)
{
    CGAffineTransform t  = CATransform3DGetAffineTransform(transform);
    CGAffineTransform a  = CGAffineTransformMakeTranslation(-origin.x, -origin.y);
    CGAffineTransform a1 = CGAffineTransformInvert(a);
    
    t = CGAffineTransformConcat(CGAffineTransformConcat(a, t), a1);
    
    p = CGPointApplyAffineTransform(p, t);
    
    return p;
}

CGPoint CGPointAfterInverseTransform(CGPoint p, CGPoint origin, CATransform3D transform)
{
    return CGPointAfterTransform(p, origin, CATransform3DInvert(transform));
}

double CGPointDistance(CGPoint a, CGPoint b)
{
    return hypot(b.x - a.x, b.y - a.y);
}

CGPoint CGPointScale(CGPoint a, double scale)
{
    return CGPointMake(a.x * scale, a.y * scale);
}


// ----------------------------------------------------------------------------
   #pragma mark Additions for CGSize 
// ----------------------------------------------------------------------------

CGSize CGSizeMax(CGSize a, CGSize b) 
{
    return CGSizeMake(fmaxf(a.width, b.width), fmaxf(a.height, b.height));
}



// ----------------------------------------------------------------------------
   #pragma mark Additions for CGRect
// ----------------------------------------------------------------------------

CGRect CGRectInsetTRBL(CGRect rect, CGFloat t, CGFloat r, CGFloat b, CGFloat l) 
{
    CGRect result = rect;
    
    result.origin.x += l;
    result.origin.y += b;
    result.size.width  -= r + l;
    result.size.height -= t + b;
    
    return result;
}

CGRect CGRectWithPoints(CGPoint a, CGPoint b)
{
    return CGRectStandardize(CGRectMake(a.x, a.y, b.x - a.x, b.y - a.y));
}

CGRect CGRectWithOriginAndSize(CGPoint origin, CGSize size)
{
    CGRect rect = { origin, size };
    return rect;
}

void CGRectWalkGrid(CGRect rect, int rows, int columns, void(^callback)(CGRect rect, int row, int col)) 
{
    
    CGRect box = rect;
    
    box.size.width  /= columns;
    box.size.height /= rows;
    
    for (int i=0;  i<columns;  i++) {
        for (int j=0;  j<rows;  j++) {
            CGFloat x = rect.origin.x + i * box.size.width;
            CGFloat y = rect.origin.y + j * box.size.height;
            box.origin = CGPointMake(x, y);
            callback(box, j, i);
        }
    }
}

CGRect CGRectCenterInRect(CGRect refRect, CGRect rect)
{
    rect.origin.x = CGRectGetMidX(refRect) - rect.size.width/2;
    rect.origin.y = CGRectGetMidY(refRect) - rect.size.height/2;
    return rect;
}

CGRect CGRectCenterVerticallyInRect(CGRect refRect, CGRect rect)
{
    rect.origin.y = CGRectGetMidY(refRect) - rect.size.height/2;
    return rect;
}

CGRect CGRectCenterHorizontallyInRect(CGRect refRect, CGRect rect)
{
    rect.origin.x = CGRectGetMidX(refRect) - rect.size.width/2;
    return rect;
}


CGPoint CGRectCornerTL(CGRect rect, BOOL flipped)
{
    CGPoint p = flipped? rect.origin : CGPointOffset(rect.origin, 0, rect.size.height);
    return p;
}

CGPoint CGRectCornerTR(CGRect rect, BOOL flipped)
{
    CGPoint p = CGPointOffset(rect.origin, rect.size.width, flipped? 0 : rect.size.height);
    return p;
}

CGPoint CGRectCornerBR(CGRect rect, BOOL flipped)
{
    return CGPointOffset(rect.origin, rect.size.width, flipped? rect.size.height : 0);
}

CGPoint CGRectCornerBL(CGRect rect, BOOL flipped)
{
    return flipped ? CGPointOffset(rect.origin, 0, rect.size.height) : rect.origin;
}

CGPoint CGRectCorner(CGRect rect, BOOL isBottom, BOOL isLeft, BOOL flipped)
{
    return isBottom?
        (isLeft? CGRectCornerBL(rect, flipped) : CGRectCornerBR(rect, flipped)) :
        (isLeft? CGRectCornerTL(rect, flipped) : CGRectCornerTR(rect, flipped)) ;
}

CGPoint CGRectCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CGPoint CGRectRelativePoint(CGRect rect, CGPoint relPos)
{
    return CGPointMake(rect.origin.x + rect.size.width * relPos.x, rect.origin.y + rect.size.height * relPos.y);
}

CGPoint CGRectNormalizedPosition(CGRect rect, CGPoint p)
{
    p.x -= rect.origin.x;
    p.y -= rect.origin.y;
    
    p.x  = (rect.size.width  != 0.0)? p.x / rect.size.width  : 0.0;
    p.y  = (rect.size.height != 0.0)? p.y / rect.size.height : 0.0;
    
    return p;
}



// ----------------------------------------------------------------------------
   #pragma mark Additions for CGPathRef
// ----------------------------------------------------------------------------

CGMutablePathRef CGPathCreateWithRectAnd4CornerRadius(CGRect rect, CGFloat rtl, CGFloat rtr, CGFloat rbr, CGFloat rbl) 
{
    
    float minX = CGRectGetMinX(rect); 
    float midX = CGRectGetMidX(rect);
    float maxX = CGRectGetMaxX(rect);
    float minY = CGRectGetMinY(rect);
    float midY = CGRectGetMidY(rect);
    float maxY = CGRectGetMaxY(rect);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, minX, midY);
    CGPathAddArcToPoint(path, NULL, minX, maxY, midX, maxY, rtl);
    CGPathAddArcToPoint(path, NULL, maxX, maxY, maxX, midY, rtr);
    CGPathAddArcToPoint(path, NULL, maxX, minY, midX, minY, rbr);
    CGPathAddArcToPoint(path, NULL, minX, minY, minX, midY, rbl);
    CGPathCloseSubpath(path);
    
    return path;    
}



// ----------------------------------------------------------------------------
   #pragma mark Additions for CGColorRef
// ----------------------------------------------------------------------------

CGColorRef CGColorCreateWithMultipliedComponents(CGColorRef rgba, CGFloat factor)
{
    const CGFloat *c = CGColorGetComponents(rgba);
    
    CGFloat r = fclamp(0, c[0] * factor, 1);
    CGFloat g = fclamp(0, c[1] * factor, 1);
    CGFloat b = fclamp(0, c[2] * factor, 1);
    CGFloat a = c[3];
    
    return CGColorCreateGenericRGB(r, g, b, a);
}

CGColorRef CGColorCreateWithOffsetComponents(CGColorRef rgba, CGFloat white)
{
    const CGFloat *c = CGColorGetComponents(rgba);
    
    CGFloat r = c[0] + white;
    CGFloat g = c[1] + white;
    CGFloat b = c[2] + white;
    CGFloat a = c[3];
    
    if (r > 1.0) r = c[0] - white;
    if (g > 1.0) g = c[1] - white;
    if (b > 1.0) b = c[2] - white;
    
    if (r < 0.0) r = fclamp(0, c[0] + white, 1);
    if (g < 0.0) g = fclamp(0, c[1] + white, 1);
    if (b < 0.0) b = fclamp(0, c[2] + white, 1);
    
    return CGColorCreateGenericRGB(r, g, b, a);
}


CGColorRef CGColorCreateWithGenericHSBA(CGFloat h, CGFloat s, CGFloat b, CGFloat a)
{
    CGFloat c = s * b;
    CGFloat h1 = fmod(h, 1.0) * 6.0;
    CGFloat x = c * (1 - fabs(fmod(h1, 2) - 1));
    CGFloat m = b - c;
    
    CGFloat r1=0, g1=0, b1=0;
    
    
    if ((h1>=0) && (h1<1)) {
        r1 = c + m;   
        g1 = x + m;
        b1 = 0 + m;
    } else if ((h1>=1) && (h1<2)) {
        r1 = x + m;   
        g1 = c + m;
        b1 = 0 + m;
    } else if ((h1>=2) && (h1<3)) {
        r1 = 0 + m;   
        g1 = c + m;
        b1 = x + m;
    } else if ((h1>=3) && (h1<4)) {
        r1 = 0 + m;   
        g1 = x + m;
        b1 = c + m;
    } else if ((h1>=4) && (h1<5)) {
        r1 = x + m;   
        g1 = 0 + m;
        b1 = c + m;
    } else if ((h1>=5) && (h1<6)) {
        r1 = c + m;   
        g1 = 0 + m;
        b1 = x + m;
    }
    
    return CGColorCreateGenericRGB(r1, g1, b1, a);
}

BOOL CGColorApproximatelyEqualsColor(CGColorRef a, CGColorRef b, CGFloat tolerence)
{
    tolerence = tolerence * tolerence;
    
    NSColorSpace *rgbColorSpace = [NSColorSpace genericRGBColorSpace];
    
    NSColor *color1 = [[NSColor colorWithCGColor:a] colorUsingColorSpace:rgbColorSpace];
    NSColor *color2 = [[NSColor colorWithCGColor:b] colorUsingColorSpace:rgbColorSpace];
    
    CGFloat r1,g1,b1,a1, r2,g2,b2,a2, rd,gd,bd,ad;
    
    [color1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [color2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    
    rd = r2 - r1;
    gd = g2 - g1;
    bd = b2 - b1;
    ad = a2 - a1;
    
    CGFloat dist2 = rd*rd + gd*gd + bd*bd + ad*ad;
    
    return (dist2 < tolerence);
}
