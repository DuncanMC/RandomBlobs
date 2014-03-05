/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 */

#import "UIBezierPath-Smoothing.h"
#import "UIBezierPath-Points.h"

#define K_BUG_FIX 1

#define POINT(_INDEX_) [(NSValue *)[points objectAtIndex:_INDEX_] CGPointValue]

@implementation UIBezierPath (Smoothing)
- (UIBezierPath *) smoothedPath: (int) granularity
{
    NSMutableArray *points = [self.points mutableCopy];
    if (points.count < 4) return [self copy];
    
    // Add control points to make the math make sense
    // Via Josh Weinberg
    [points insertObject:[points objectAtIndex:0] atIndex:0];
    [points addObject:[points lastObject]];
  
//  [points insertObject:[points lastObject] atIndex:0];
//  [points addObject:[points objectAtIndex:0]];
  
    UIBezierPath *smoothedPath = [UIBezierPath bezierPath];  
    
    // Copy traits
    smoothedPath.lineWidth = self.lineWidth;
    
    // Draw out the first 3 points (0..2)
    [smoothedPath moveToPoint:POINT(0)];
  
  int line_points = 3;
#if K_BUG_FIX
  line_points = 2;
#endif
  
    for (int index = 1; index < line_points; index++) //change "for (int index = 1; index < 3; index++)" to "for (int index = 1; index < 2; index++)".
        [smoothedPath addLineToPoint:POINT(index)];
    
    for (int index = line_points+1; index < points.count; index++)  //Change "for (int index = 4; index < points.count; index++)" to "for (int index = 3; index < points.count; index++)"
    {
        CGPoint p0 = POINT(index - 3);
        CGPoint p1 = POINT(index - 2);
        CGPoint p2 = POINT(index - 1);
        CGPoint p3 = POINT(index);
        
        // now add n points starting at p1 + dx/dy up until p2 using Catmull-Rom splines
        for (int i = 1; i < granularity; i++)
        {
            float t = (float) i * (1.0f / (float) granularity);
            float tt = t * t;
            float ttt = tt * t;
            
            CGPoint pi; // intermediate point
            pi.x = 0.5 * (2*p1.x+(p2.x-p0.x)*t + (2*p0.x-5*p1.x+4*p2.x-p3.x)*tt + (3*p1.x-p0.x-3*p2.x+p3.x)*ttt);
            pi.y = 0.5 * (2*p1.y+(p2.y-p0.y)*t + (2*p0.y-5*p1.y+4*p2.y-p3.y)*tt + (3*p1.y-p0.y-3*p2.y+p3.y)*ttt);
            [smoothedPath addLineToPoint:pi];
        }
        
        // Now add p2
        [smoothedPath addLineToPoint:p2];
    }
    
    // finish by adding the last point
    [smoothedPath addLineToPoint:POINT(points.count - 1)];
    
    return smoothedPath;
}

@end
