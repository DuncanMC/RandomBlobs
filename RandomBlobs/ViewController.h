//
//  ViewController.h
//  RandomBlobs
//
//  Created by Duncan Champney on 3/4/14.
//  Copyright (c) 2014 WareTo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlobView.h"

@interface ViewController : UIViewController
{
  __weak IBOutlet BlobView *theBlobView;
  __weak IBOutlet UISwitch *make_circle_blobs_switch;
}


- (IBAction)updateBlobShape:(UIButton *)sender;
- (IBAction)handleCircleBlobSwitch:(UISwitch *)sender;


@end
