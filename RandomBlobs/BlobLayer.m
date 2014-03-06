//
//  BlobLayer.m
//  RandomBlobs
//
//  Created by Duncan Champney on 3/4/14.
//  Copyright (c) 2014 WareTo. All rights reserved.
//

#import "BlobLayer.h"
#import "UIBezierPath-Smoothing.h"

@implementation BlobLayer

- (id)init
{
  self = [super init];
  if (!self)
    return nil;
  self.strokeColor = [UIColor blackColor].CGColor;
  self.lineWidth = 1;
  self.fillColor = [UIColor colorWithRed: 1.0
                                   green: 1.0
                                    blue: .75
                                   alpha: 0.5].CGColor;
  pointsLayer = [CAShapeLayer layer];
  pointsLayer.frame = self.bounds;
  [self addSublayer: pointsLayer];
  
  
  pointsLayer.fillColor = [UIColor colorWithRed: 0
                                            green: 0
                                             blue: 128
                                            alpha: .5].CGColor;
  pointsLayer.strokeColor = [UIColor colorWithRed: 0
                                            green: 0
                                             blue: 0
                                            alpha: .5].CGColor;
  
  
  gridLayer = [CAShapeLayer layer];
  gridLayer.frame = self.bounds;
  
  gridLayer.fillColor = [UIColor clearColor].CGColor;
  gridLayer.strokeColor = [UIColor colorWithRed: 0
                                            green: 0
                                             blue: 128
                                            alpha: .5].CGColor;

  [self addSublayer: gridLayer];
  return self;
}

- (CGFloat) randomFloat: (CGFloat) max_value;
{
	CGFloat aRandom = (arc4random() % 1000000001);
	aRandom = (aRandom * max_value) / 1000000000;
	return aRandom;
}

//-----------------------------------------------------------------------------------------------------------

- (CGFloat) randomFloatPlusOrMinus: (CGFloat) max_value;
{
	CGFloat aRandom = [self randomFloat: max_value*2] - max_value;
	return aRandom;
}

- (void) buildBlobShapeUsingCircluarBlobs: (BOOL) use_circular_blobs;
{
  useCirclarBlobs = use_circular_blobs;
  //build a closed path that is a distorted polygon.
  
  UIBezierPath *path = [UIBezierPath new];
  CGFloat shortest_side = MIN(self.bounds.size.width, self.bounds.size.height);

  if (use_circular_blobs)
  {
    CGFloat angle, radius_base, radius;
    int step;
    CGFloat x, y;
    CGPoint aPoint;
    radius_base = roundf(shortest_side * 3.0/9);
    
    for (step = 0; step < point_count; step++)
    {
      CGFloat random_val;
      
      //Step around a circle
      angle = M_PI * 2 / point_count * step + M_PI_4*5;
      
      //randomize the angle slightly
      random_val = [self randomFloatPlusOrMinus: M_PI/point_count*.9];
      angle += random_val;
      
      
      radius = radius_base;
      random_val = [self randomFloatPlusOrMinus: radius_base/3];
      radius += random_val;
      x = roundf(cosf(angle)* radius+shortest_side/2) ;
      y = roundf(sinf(angle)* radius+shortest_side/2);
      aPoint = CGPointMake (x, y);
      randomPoints[step] = aPoint;
      if (step == 0)
        [path moveToPoint: aPoint];
      else
      {
        [path addLineToPoint: aPoint];
      }
    }
  }
  else
  {

    CGFloat side_sixth = shortest_side / 6;
    if (!gridPointsBuilt)
    {
      gridPointsBuilt = YES;
      //Create an array of points are the centers of a 3x3 grid of boxes inside our view
      
      CGFloat side_third = shortest_side / 3;
      CGFloat side_half = shortest_side / 2;
      int x;
      int index = 0;
      //Add the centers of the boxes along the top, left to right
      for (x = 0; x < 3; x++)
        gridPoints[index++] = CGPointMake(roundf(side_sixth + x*side_third), roundf(side_sixth));
      
      //Add the middle right box
      gridPoints[index++] = CGPointMake( roundf(side_sixth * 5), roundf(side_half));
      
      //Add the centers of the boxes along the bottom, right to left
      for (x = 2; x >= 0; x--)
        gridPoints[index++] = CGPointMake( roundf(side_sixth + x*side_third), roundf(side_sixth * 5));
      
      //finally add the center point of the middle left box
      gridPoints[index++] = CGPointMake( roundf(side_sixth), roundf(side_half));
    }
    CGPoint aPoint;
    for (int index = 0; index<point_count; index++)
    {
      aPoint = gridPoints[index];
      aPoint.x += roundf([self randomFloatPlusOrMinus: side_sixth * 3 / 4]);
      aPoint.y += roundf([self randomFloatPlusOrMinus: side_sixth * 3 / 4]);
      randomPoints[index] = aPoint;
      if (index == 0)
        
      [path moveToPoint: aPoint];
      else
      {
        [path addLineToPoint: aPoint];
//        if (index == 2)
//          [path addLineToPoint: aPoint];
      }
    }
  }
  
  //Now convert our polygon path to a curved shape
  if (YES)
    [path closePath];
  path = [path smoothedPath: 16];
  
  if (_showPoints)
  {
    [self rebuildPointsLayer];
  }
  [self animateNewPath: path
               inLayer: self];
}

- (void) animateNewPath: (UIBezierPath *) newPath
                inLayer: (CAShapeLayer *) layer;
{
  CGPathRef oldPath = layer.path;
  layer.path = newPath.CGPath;

  BOOL animate = oldPath != nil;
  if (animate)
  {
  CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath: @"path"];
  [pathAnimation setFromValue:(__bridge id) oldPath];
  [pathAnimation setToValue:(__bridge id)newPath.CGPath];
  pathAnimation.duration = .5;

  [layer addAnimation: pathAnimation
              forKey: @"pathAnimation"];
  }

}
//-----------------------------------------------------------------------------------------------------------
#pragma mark - property methods
//-----------------------------------------------------------------------------------------------------------

- (void) rebuildPointsLayer;
{
  UIBezierPath *pointsPath = [UIBezierPath new];
  
  CGFloat shortest_side = MIN(self.bounds.size.width, self.bounds.size.height);
  CGFloat side_third = shortest_side / 3;
  CGFloat side_half = shortest_side / 2;

  for (int index = 0; index<point_count; index++)
  {
    static int dot_radius = 3;
    [pointsPath moveToPoint:      CGPointMake(randomPoints[index].x + dot_radius, randomPoints[index].y)];
    [pointsPath addArcWithCenter: randomPoints[index]
                    radius: dot_radius
                startAngle: 0
                  endAngle: M_PI * 2
                 clockwise: YES];
  }
  UIBezierPath *gridPath = [UIBezierPath new];

  if (useCirclarBlobs)
  {
    CGFloat radius_base = roundf(shortest_side * 3.0/9);
    [gridPath moveToPoint: CGPointMake( side_half+radius_base, side_half)];
    [gridPath addArcWithCenter: CGPointMake(side_half, side_half)
                    radius: radius_base
                startAngle: 0
                  endAngle: M_PI * 2
                 clockwise: YES];
  }
  else
  {
    for(int index = 1; index< 3; index++)
    {
      [gridPath moveToPoint: CGPointMake( roundf( side_third*index), 0)];
      [gridPath addLineToPoint: CGPointMake( roundf(side_third*index ), shortest_side)];
      
      [gridPath moveToPoint: CGPointMake(0, roundf(side_third*index))];
      [gridPath addLineToPoint: CGPointMake(shortest_side, roundf(side_third*index))];
      
    }
    
  }
  [self animateNewPath: pointsPath inLayer: pointsLayer];
  //pointsLayer.path = pointsPath.CGPath;
  gridLayer.path = gridPath.CGPath;
}

//-----------------------------------------------------------------------------------------------------------

- (void) setShowPoints:(BOOL)showPoints;
{
  _showPoints = showPoints;
  if (!showPoints)
  {
    pointsLayer.path = nil;
    gridLayer.path = nil;
  }
  else
  {
    [self rebuildPointsLayer];
  }
}
@end
