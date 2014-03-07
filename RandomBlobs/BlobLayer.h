//
//  BlobLayer.h
//  RandomBlobs
//
//  Created by Duncan Champney on 3/4/14.
//  Copyright (c) 2014 WareTo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#define K_PATH_ANIMATION_COMPLETE_NOTICE @"PathAnimatinonComplete"

//#define point_count 8
#define K_MAX_POINT_COUNT 40

@interface BlobLayer : CAShapeLayer
{
  CGPoint gridPoints[8];
  CGPoint randomPoints[K_MAX_POINT_COUNT];
  BOOL gridPointsBuilt;
  
  CAShapeLayer *pointsLayer;
  CAShapeLayer *gridLayer;
}

@property (nonatomic, assign) BOOL showPoints;
@property (nonatomic, assign) CGPoint *randomPointsArray;
@property (nonatomic, assign) int point_count;
@property (nonatomic, assign) BOOL useCirclarBlobs;

- (void) buildBlobShapeUsingCircluarBlobs: (BOOL) use_circular_blobs
                              point_count: (int) new_point_count;

@end
