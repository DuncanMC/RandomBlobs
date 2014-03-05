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
  [(BlobLayer *)self.layer buildBlobShapeUsingCircluarBlobs: _make_circle_blobs];
}

- (void) setShowPoints:(BOOL)showPoints
{
  _showPoints = showPoints;
  ((BlobLayer *)self.layer).showPoints = showPoints;
}

//-----------------------------------------------------------------------------------------------------------
#pragma mark - property methods
//-----------------------------------------------------------------------------------------------------------

- (void) updateBlobShape;
{
  [(BlobLayer *)self.layer buildBlobShapeUsingCircluarBlobs: _make_circle_blobs];
}

- (void) didMoveToSuperview;
{
  //[(BlobLayer *)self.layer buildBlobShapeUsingCircluarBlobs: _make_circle_blobs];
}

@end
