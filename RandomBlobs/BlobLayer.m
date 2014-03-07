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

- (void) buildBlobShapeUsingCircluarBlobs: (BOOL) use_circular_blobs
                              point_count: (int) new_point_count;
{
  /*
   (!use_circular_blobs && !_useCirclarBlobs)
   ||
   (use_circular_blobs && point_count == new_point_count)
   */
  BOOL animate =
  //We're not using circlar blobs, and din't last time
  (!use_circular_blobs && !_useCirclarBlobs)
  ||
  //or we're not using circulare blobs, we did last time,
  //and the old count was 8
  (!use_circular_blobs && _useCirclarBlobs && _point_count == 8)
  ||
  //or we're switching from square to circular and the new point count is 8
  (use_circular_blobs && !_useCirclarBlobs && new_point_count == 8)
  
  ||
  (_useCirclarBlobs == use_circular_blobs && _point_count == new_point_count);

  _useCirclarBlobs = use_circular_blobs;
  if (!use_circular_blobs)
    new_point_count = 8;
  
  if (use_circular_blobs && new_point_count == 0)
  {
    [[NSNotificationCenter defaultCenter] postNotificationName: K_PATH_ANIMATION_COMPLETE_NOTICE object: self];
    return;
  }

  
  if (use_circular_blobs)
    _point_count = new_point_count;
  
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
    
    for (step = 0; step < _point_count; step++)
    {
      CGFloat random_val;
      
      //Step around a circle
      angle = M_PI * 2 / _point_count * step + M_PI_4*5;
      
      //randomize the angle slightly
      random_val = [self randomFloatPlusOrMinus: M_PI/_point_count*.9];
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
    for (int index = 0; index<8; index++)
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
    [self rebuildPointsLayerWithAnimation: animate];
  }
  if (animate)
    [self animateNewPath: path
                 inLayer: self];
  else
  {
    self.path = path.CGPath;
    [[NSNotificationCenter defaultCenter] postNotificationName: K_PATH_ANIMATION_COMPLETE_NOTICE object: self];
  }
}

//-----------------------------------------------------------------------------------------------------------

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
    pathAnimation.duration = .8;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    if (layer == self)
      pathAnimation.delegate = self;
    
    [layer addAnimation: pathAnimation
                 forKey: @"pathAnimation"];
  }
  
  
  
  
}
//-----------------------------------------------------------------------------------------------------------
#pragma mark - custom instance methods
//-----------------------------------------------------------------------------------------------------------

- (void) rebuildPointsLayerWithAnimation: (BOOL) animate;
{
  UIBezierPath *pointsPath = [UIBezierPath new];
  
  CGFloat shortest_side = MIN(self.bounds.size.width, self.bounds.size.height);
  CGFloat side_third = shortest_side / 3;
  CGFloat side_half = shortest_side / 2;
  int points = 8;
  if (_useCirclarBlobs)
    points = _point_count;
  
  for (int index = 0; index<points; index++)
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
  
  if (_useCirclarBlobs)
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
  if (animate)
    [self animateNewPath: pointsPath inLayer: pointsLayer];
  else
    pointsLayer.path = pointsPath.CGPath;
  gridLayer.path = gridPath.CGPath;
}



//-----------------------------------------------------------------------------------------------------------
#pragma mark - property methods
//-----------------------------------------------------------------------------------------------------------

- (CGPoint *) randomPointsArray;
{
  return randomPoints;
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
    [self rebuildPointsLayerWithAnimation: YES];
  }
}
//-----------------------------------------------------------------------------------------------------------
#pragma mark - CAAnimation delegate methods
//-----------------------------------------------------------------------------------------------------------
/*
 This method looks for a value added to the animation that just completed
 with the key kAnimationCompletionBlock.
 If it exists, it assumes it is a code block of type animationCompletionBlock, and executes the code block.
 This allows you to add a custom block of completion code to any animation or animation group, rather than
 Having a big complicated switch statement in your animationDidStop:finished: method with global animation
 Completion code.
 (Note that the system won't call the animationDidStop:finished method for individual animations in an
 Animation group - it will only call the completion method for the entire group. Thus, if you want to run
 code after part of an animation group completes, you have to set up a manual timer.)
 */

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
  [[NSNotificationCenter defaultCenter] postNotificationName: K_PATH_ANIMATION_COMPLETE_NOTICE object: self];

}

@end
