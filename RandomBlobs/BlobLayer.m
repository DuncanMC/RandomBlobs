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
#define points 8
  CGPoint randomPoints[points];

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
    
    for (step = 0; step < points; step++)
    {
      CGFloat random_val;
      
      //Step around a circle
      angle = M_PI * 2 / points * step;
      
      //randomize the angle slightly
      random_val = [self randomFloatPlusOrMinus: M_PI/points*.9];
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
        [path addLineToPoint: aPoint];
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
    for (int index = 0; index<8; index++)
    {
      aPoint = gridPoints[index];
      aPoint.x += roundf([self randomFloatPlusOrMinus: side_sixth - 10]);
      aPoint.y += roundf([self randomFloatPlusOrMinus: side_sixth - 10]);
      randomPoints[index] = aPoint;
      if (index == 0)
        
      [path moveToPoint: aPoint];
      else
        [path addLineToPoint: aPoint];
    }
  }
  
  //Now convert our polygon path to a curved shape
  [path closePath];
  path = [path smoothedPath: 16];
  [path closePath];
  
  if (TRUE)
  {
    for (int index = 0; index<8; index++)
    {
      static int dot_radius = 3;
      [path moveToPoint:      CGPointMake(randomPoints[index].x + dot_radius, randomPoints[index].y)];
      [path addArcWithCenter: randomPoints[index]
                      radius: dot_radius
                  startAngle: 0
                    endAngle: M_PI * 2
                   clockwise: YES];
    }
  }
  self.path = path.CGPath;
}

@end