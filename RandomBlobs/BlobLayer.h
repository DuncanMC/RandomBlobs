//
//  BlobLayer.h
//  RandomBlobs
//
//  Created by Duncan Champney on 3/4/14.
//  Copyright (c) 2014 WareTo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#define point_count 8

@interface BlobLayer : CAShapeLayer
{
  CGPoint gridPoints[point_count];
  CGPoint randomPoints[point_count];
  BOOL gridPointsBuilt;
  BOOL useCirclarBlobs;
  
  CAShapeLayer *pointsLayer;
}

@property (nonatomic, assign) BOOL showPoints;

- (void) buildBlobShapeUsingCircluarBlobs: (BOOL) use_circular_blobs;

@end
