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
  __weak IBOutlet UISwitch *show_control_points_switch;
  __weak IBOutlet UIButton *changeShapeButton;
  __weak IBOutlet UISwitch *loopChangesSwitch;
  id animationCompleteObserver;
  
  BOOL animationInFlight;
}


- (IBAction)updateBlobShape:(UIButton *)sender;
- (IBAction)handleCircleBlobSwitch:(UISwitch *)sender;
- (IBAction)handleShowControlPointsSwitch:(UISwitch *)sender;
- (IBAction)handleLoopChangesSwitch:(UISwitch *)sender;


@end
