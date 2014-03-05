//
//  ViewController.m
//  RandomBlobs
//
//  Created by Duncan Champney on 3/4/14.
//  Copyright (c) 2014 WareTo. All rights reserved.
//

#import "ViewController.h"

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
	// Do any additional setup after loading the view, typically from a nib.
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
  [theBlobView updateBlobShape];
}

//-----------------------------------------------------------------------------------------------------------

- (IBAction)handleCircleBlobSwitch:(UISwitch *)sender
{
  theBlobView.make_circle_blobs = sender.isOn;
}

- (IBAction)handleShowControlPointsSwitch:(UISwitch *)sender
{
  theBlobView.showPoints = sender.isOn;
}

@end
