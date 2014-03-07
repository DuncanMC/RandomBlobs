//
//  BlobView.m
//  RandomBlobs
//
//  Created by Duncan Champney on 3/4/14.
//  Copyright (c) 2014 WareTo. All rights reserved.
//

#import "BlobView.h"
#import "BlobLayer.h"

@implementation BlobView

//-----------------------------------------------------------------------------------------------------------
#pragma mark - class methods
//-----------------------------------------------------------------------------------------------------------

+ (Class)layerClass
{
  return [BlobLayer class];
}

//-----------------------------------------------------------------------------------------------------------
#pragma mark - property methods
//-----------------------------------------------------------------------------------------------------------

- (void) setMake_circle_blobs:(BOOL)make_circle_blobs;
{
  _make_circle_blobs = make_circle_blobs;
  BlobLayer *theBlobLayer = (BlobLayer *)self.layer;
  int thePointCount = theBlobLayer.point_count;
  [theBlobLayer buildBlobShapeUsingCircluarBlobs: _make_circle_blobs
                                     point_count: thePointCount];
}

//-----------------------------------------------------------------------------------------------------------

- (void) setShowPoints:(BOOL)showPoints
{
  _showPoints = showPoints;
  ((BlobLayer *)self.layer).showPoints = showPoints;
}

//-----------------------------------------------------------------------------------------------------------
#pragma mark - property methods
//-----------------------------------------------------------------------------------------------------------

- (void) updateBlobShapeWithPointCount: (int) point_count;
{
  BlobLayer *theBlobLayer = (BlobLayer *)self.layer;
  [theBlobLayer buildBlobShapeUsingCircluarBlobs: _make_circle_blobs
                                                point_count: point_count];
}

- (void) didMoveToSuperview;
{
  //[(BlobLayer *)self.layer buildBlobShapeUsingCircluarBlobs: _make_circle_blobs];
}

@end
