
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
  
  BOOL pathIsClosed = [self pathIsClosed];
//  NSString *notString = pathIsClosed ? @"" : @" not";
//  NSLog(@"Path is%@ closed", notString);
  
  if (points.count < 4) return [self copy];
  
  // Add control points to make the math make sense
  // Via Josh Weinberg
  if (!pathIsClosed)
  {
  [points insertObject:[points objectAtIndex:0] atIndex:0];
  [points addObject:[points lastObject]];
  }
  
  UIBezierPath *smoothedPath = [UIBezierPath bezierPath];
  
  // Copy traits
  smoothedPath.lineWidth = self.lineWidth;
  
  // Draw out the first 3 points (0..2)
  [smoothedPath moveToPoint:POINT(0)];
  
  if (!pathIsClosed)
    [smoothedPath addLineToPoint:POINT(1)];
  
  int start = 3;
  NSUInteger end = points.count;
  if (pathIsClosed)
  {
    start--;
    end+= 2;
  }
  for (int index = start; index < end; index++)
  {
    CGPoint p0 = POINT((points.count +index - 3) % points.count);
    CGPoint p1 = POINT((points.count +index - 2) % points.count);
    CGPoint p2 = POINT((points.count +index - 1) % points.count);
    CGPoint p3 = POINT(index % points.count);
    
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
  if (!pathIsClosed)
    [smoothedPath addLineToPoint:POINT(points.count - 1)];
  if (pathIsClosed)
    [smoothedPath closePath];
  return smoothedPath;
}

@end
