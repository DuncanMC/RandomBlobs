//
//  BlobLayer.h
//  RandomBlobs
//
//  Created by Duncan Champney on 3/4/14.
//  Copyright (c) 2014 WareTo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface BlobLayer : CAShapeLayer
{
  CGPoint gridPoints[8];
  BOOL gridPointsBuilt;
}

- (void) buildBlobShapeUsingCircluarBlobs: (BOOL) use_circular_blobs;

@end
