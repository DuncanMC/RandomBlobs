/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "UIBezierPath-Points.h"

#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]

@implementation UIBezierPath (Points)
void getPointsFromBezier(void *info, const CGPathElement *element) 
{
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;    
    
    // Retrieve the path element type and its points
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    
    // Add the points if they're available (per type)
    if (type != kCGPathElementCloseSubpath)
    {
        [bezierPoints addObject:VALUE(0)];
        if ((type != kCGPathElementAddLineToPoint) &&
            (type != kCGPathElementMoveToPoint))
            [bezierPoints addObject:VALUE(1)];
    }    
    if (type == kCGPathElementAddCurveToPoint)
        [bezierPoints addObject:VALUE(2)];
}

void isSubPathClosed(void *info, const CGPathElement *element)
{
  BOOL *subPathIsClosed = (BOOL *) info;
  if (*subPathIsClosed) return;
  
  
  // Retrieve the path element type and its points
  CGPathElementType type = element->type;
  
  // Add the points if they're available (per type)
  if (type == kCGPathElementCloseSubpath)
  {
    *subPathIsClosed = YES;
    return;
  }
}

- (NSArray *)points
{
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(self.CGPath, (__bridge void *)points, getPointsFromBezier);
    return points;
}

- (BOOL) pathIsClosed;
{
  BOOL pathIsClosed = NO;
  CGPathApply(self.CGPath, (void *) &pathIsClosed, isSubPathClosed);
  return pathIsClosed;
}
@end
