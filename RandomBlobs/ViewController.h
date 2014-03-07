//
//  ViewController.h
//  RandomBlobs
//
//  Created by Duncan Champney on 3/4/14.
//  Copyright (c) 2014 WareTo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlobView.h"

@interface ViewController : UIViewController <UITextFieldDelegate>
{
  __weak IBOutlet BlobView *theBlobView;
  __weak IBOutlet UISwitch *make_circle_blobs_switch;
  __weak IBOutlet UISwitch *show_control_points_switch;
  __weak IBOutlet UIButton *changeShapeButton;
  __weak IBOutlet UIButton *animateImageViewButton;
  __weak IBOutlet UISwitch *loopChangesSwitch;
  __weak IBOutlet UIImageView *animationImageView;
  __weak IBOutlet UITextField *pointCountField;
  id animationCompleteObserver;
  
  id showKeyboardNotificaiton;
  id hideKeyboardNotificaiton;

  __weak UITextField* textFieldToEdit;

  BOOL animationInFlight;
  
  CGFloat keyboardShiftAmount;
  CGFloat keyboardSlideDuration;
  NSUInteger keyboardAnimationCurve;

}

@property (nonatomic, assign) int point_count;
- (IBAction)updateBlobShape:(UIButton *)sender;
- (IBAction)handleCircleBlobSwitch:(UISwitch *)sender;
- (IBAction)handleShowControlPointsSwitch:(UISwitch *)sender;
- (IBAction)handleLoopChangesSwitch:(UISwitch *)sender;
- (IBAction)handleAnimateImageButton:(UIButton *)sender;



@end
