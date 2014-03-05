//
//  BlobView.h
//  RandomBlobs
//
//  Created by Duncan Champney on 3/4/14.
//  Copyright (c) 2014 WareTo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlobView : UIView

//-----------------------------------------------------------------------------------------------------------
#pragma mark - properties
//-----------------------------------------------------------------------------------------------------------
@property (nonatomic, assign)   BOOL make_circle_blobs;

//-----------------------------------------------------------------------------------------------------------
#pragma mark - instance methods
//-----------------------------------------------------------------------------------------------------------
- (void) updateBlobShape;

@end
