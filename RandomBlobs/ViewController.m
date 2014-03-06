//
//  ViewController.m
//  RandomBlobs
//
//  Created by Duncan Champney on 3/4/14.
//  Copyright (c) 2014 WareTo. All rights reserved.
//

#import "ViewController.h"
#import "BlobLayer.h"
#import "NSObject+performBlockAfterDelay.h"

@interface ViewController ()

@end

@implementation ViewController

//-----------------------------------------------------------------------------------------------------------
#pragma mark - View controller lifecycle methods
//-----------------------------------------------------------------------------------------------------------

- (void) doInitSetup;
{
  
}

//-----------------------------------------------------------------------------------------------------------

- (void)viewDidLoad
{
  theBlobView.make_circle_blobs = YES;
  make_circle_blobs_switch.on = YES;
  
  theBlobView.showPoints = YES;
  show_control_points_switch.on = YES;
  
  
  [super viewDidLoad];
  animationCompleteObserver = [[NSNotificationCenter defaultCenter] addObserverForName: K_PATH_ANIMATION_COMPLETE_NOTICE
                                                                                object: nil
                                                                                 queue: nil
                                                                            usingBlock: ^(NSNotification *note)
                               {
                                 animationInFlight = NO;
                                 //NSLog(@"In path animation complete block");
                                 changeShapeButton.enabled = YES;
                                 make_circle_blobs_switch.enabled = YES;
                                 if (loopChangesSwitch.isOn)
                                   if (!animationInFlight)
                                     [self updateBlobShape: nil];
//                                   [self performBlockOnMainQueue:
//                                    ^{
//                                      if (!animationInFlight)
//                                        [self updateBlobShape: nil];
//                                    } afterDelay:0];
                               }
                               ];
}

- (void) dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver: animationCompleteObserver];
}
//-----------------------------------------------------------------------------------------------------------

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-----------------------------------------------------------------------------------------------------------

- (id) initWithCoder:(NSCoder *)aDecoder;
{
  self = [super initWithCoder: aDecoder];
  if (!self)
    return nil;
  [self doInitSetup];
  return self;
}

//-----------------------------------------------------------------------------------------------------------
#pragma mark - instance methods
//-----------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------
#pragma mark - IBAction methods
//-----------------------------------------------------------------------------------------------------------

- (IBAction)updateBlobShape:(UIButton *)sender
{
  if (!animationInFlight)
  {
    animationInFlight = YES;
    [theBlobView updateBlobShape];
    changeShapeButton.enabled = NO;
    make_circle_blobs_switch.enabled = NO;
  }
}

//-----------------------------------------------------------------------------------------------------------

- (IBAction)handleCircleBlobSwitch:(UISwitch *)sender
{
  BOOL wasOn = theBlobView.make_circle_blobs;
  if (wasOn != sender.isOn )
  {
    if (!animationInFlight)
    {
      animationInFlight = YES;
      theBlobView.make_circle_blobs = sender.isOn;
      changeShapeButton.enabled = NO;
      make_circle_blobs_switch.enabled = NO;
    }
    else
      sender.on = wasOn;
  }
}

- (IBAction)handleShowControlPointsSwitch:(UISwitch *)sender
{
  theBlobView.showPoints = sender.isOn;
}

- (IBAction)handleLoopChangesSwitch:(UISwitch *)sender {
}

@end
