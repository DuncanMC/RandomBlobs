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
  self.point_count = 8;
  
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
                                 animateImageViewButton.enabled = YES;
                                 pointCountField.enabled = theBlobView.make_circle_blobs;

                                 if (loopChangesSwitch.isOn)
                                   if (!animationInFlight)
                                     [self updateBlobShape: nil];
                               }
                               ];
  
  showKeyboardNotificaiton = [[NSNotificationCenter defaultCenter] addObserverForName: UIKeyboardWillShowNotification
                              
                                                                               object: nil
                                                                                queue: nil
                                                                           usingBlock: ^(NSNotification *note)
                              {
                                CGRect keyboardFrame;
                                NSDictionary* userInfo = note.userInfo;
                                keyboardSlideDuration = [[userInfo objectForKey: UIKeyboardAnimationDurationUserInfoKey] floatValue];
                                keyboardFrame = [[userInfo objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue];
                                keyboardAnimationCurve = [[userInfo objectForKey: UIKeyboardAnimationCurveUserInfoKey] integerValue]<<16;
                                
                                UIInterfaceOrientation theStatusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
                                
                                CGFloat keyboardHeight;
                                if UIInterfaceOrientationIsLandscape(theStatusBarOrientation)
                                  keyboardHeight = keyboardFrame.size.width;
                                else
                                  keyboardHeight = keyboardFrame.size.height;
                                
                                CGRect fieldFrame = textFieldToEdit.bounds;
                                fieldFrame = [self.view convertRect: fieldFrame fromView: textFieldToEdit];
                                CGRect contentFrame = self.view.frame;
                                CGFloat fieldBottom = fieldFrame.origin.y + fieldFrame.size.height;
                                
                                keyboardShiftAmount= 0;
                                if (contentFrame.size.height - fieldBottom <keyboardHeight)
                                {
                                  keyboardShiftAmount = keyboardHeight - (contentFrame.size.height - fieldBottom);
                                  
//                                  keyboardConstraint.constant -= keyboardShiftAmount;
//                                  keyboardBottomConstraint.constant += keyboardShiftAmount;
                                  [UIView animateWithDuration: keyboardSlideDuration
                                                        delay: 0
                                                      options: keyboardAnimationCurve
                                                   animations:
                                   ^{
                                     CGRect frame = self.view.frame;
                                     frame.origin.y -= keyboardShiftAmount;
                                     self.view.frame = frame;
                                   }
                                                   completion: nil
                                   ];
                                }
                              }
                              ];
  hideKeyboardNotificaiton = [[NSNotificationCenter defaultCenter] addObserverForName: UIKeyboardWillHideNotification
                                                                               object: nil
                                                                                queue: nil
                                                                           usingBlock: ^(NSNotification *note)
                              {
                                if (keyboardShiftAmount != 0)
                                  [UIView animateWithDuration: keyboardSlideDuration
                                                        delay: 0
                                                      options: keyboardAnimationCurve
                                                   animations:
                                   ^{
                                     CGRect frame = self.view.frame;
                                     frame.origin.y += keyboardShiftAmount;
                                     self.view.frame = frame;

//                                     keyboardConstraint.constant += keyboardShiftAmount;
//                                     keyboardBottomConstraint.constant -= keyboardShiftAmount;
//                                     [self.view setNeedsUpdateConstraints];
//                                     [viewToShift layoutIfNeeded];
                                   }
                                                   completion: nil
                                   ];
                                
                                
                              }
                              ];

}

- (void) dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver: animationCompleteObserver];
  [[NSNotificationCenter defaultCenter] removeObserver: showKeyboardNotificaiton];
  [[NSNotificationCenter defaultCenter] removeObserver: hideKeyboardNotificaiton];
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
    BlobLayer *theBlobLayer = (BlobLayer*)theBlobView.layer;

    [theBlobView updateBlobShapeWithPointCount: theBlobLayer.point_count];
    changeShapeButton.enabled = NO;
    make_circle_blobs_switch.enabled = NO;
    animateImageViewButton.enabled = NO;
    pointCountField.enabled = NO;

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
      changeShapeButton.enabled = NO;
      make_circle_blobs_switch.enabled = NO;
      pointCountField.enabled = NO;
      animateImageViewButton.enabled = YES;
      theBlobView.make_circle_blobs = sender.isOn;
    }
    else
      sender.on = wasOn;
  }
  pointCountField.enabled = theBlobView.make_circle_blobs;
}

- (IBAction)handleShowControlPointsSwitch:(UISwitch *)sender
{
  theBlobView.showPoints = sender.isOn;
}

- (IBAction)handleLoopChangesSwitch:(UISwitch *)sender
{
}

- (IBAction)handleAnimateImageButton:(UIButton *)sender
{
  CGPoint *randomPointsArray = ((BlobLayer*)theBlobView.layer).randomPointsArray;
  CGPoint startPoint = [theBlobView convertPoint: randomPointsArray[0] toView: theBlobView.superview ];
  animationImageView.center = startPoint;
  animationImageView.alpha = .75;
  animationImageView.hidden = NO;
  
  pointCountField.enabled = NO;

  
  changeShapeButton.enabled = NO;
  make_circle_blobs_switch.enabled = NO;
  animateImageViewButton.enabled = NO;
  CGFloat totalDuration = 5;
  
  int pointCount;
  
  if (theBlobView.make_circle_blobs)
    pointCount = _point_count;
  else
    pointCount = 8;
  CGFloat relDuration = 1.0 / pointCount;
  
  [self performBlockOnMainQueue: ^
   {
     [UIView animateKeyframesWithDuration: totalDuration
                                    delay:0.0
                                  options: UIViewKeyframeAnimationOptionCalculationModeCubicPaced + UIViewAnimationOptionCurveLinear
                               animations:
      ^{
        for (int index = 1; index <= pointCount; index++)
        {
          CGFloat startTime = ((CGFloat)index-1)/pointCount;
          CGFloat thisDuration = relDuration;
          
          [UIView addKeyframeWithRelativeStartTime: startTime
                                  relativeDuration: thisDuration
                                        animations: ^
           {
             int arrayIndex = index % pointCount;
             CGPoint thisPoint =randomPointsArray[arrayIndex];
             thisPoint = [theBlobView convertPoint: thisPoint toView: theBlobView.superview ];
             animationImageView.center = thisPoint;
           }
           ];
        }
        
      }
                               completion: ^(BOOL finished)
      {
        changeShapeButton.enabled = YES;
        make_circle_blobs_switch.enabled = YES;
        animateImageViewButton.enabled = YES;
        pointCountField.enabled = theBlobView.make_circle_blobs;

        [self performBlockOnMainQueue: ^
         {
           animationImageView.hidden = YES;
         }
                           afterDelay:.5];
      }
      ];
   }
                     afterDelay: 0.5];
}

//-----------------------------------------------------------------------------------------------------------
#pragma mark -	UITextFieldDelegate methods
//-----------------------------------------------------------------------------------------------------------

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  return YES;
}

//-----------------------------------------------------------------------------------------------------------

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
  textFieldToEdit = textField;
  return YES;
}

//-----------------------------------------------------------------------------------------------------------

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  //dlog(0, @"Entering %s. text field = %@", __PRETTY_FUNCTION__, textField);
  [textField resignFirstResponder];
  return TRUE;
}

//-----------------------------------------------------------------------------------------------------------

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  //[defaults setInteger: _majorValue1 forKey: K_DEFAULT_MAJOR_VALUE_1];
  
  //dlog(0, @"Entering %s. text field = %@", __PRETTY_FUNCTION__, textField);
  if (textField == pointCountField)
  {
    NSInteger new_value = [pointCountField.text integerValue];
    if (new_value > 2 && new_value <= K_MAX_POINT_COUNT)
    {
      self.point_count = new_value;
    }
    else
      pointCountField.text = [NSString stringWithFormat: @"%d", _point_count];
  }
}

//-----------------------------------------------------------------------------------------------------------
#pragma mark - property methods
//-----------------------------------------------------------------------------------------------------------

- (void) setPoint_count:(int)point_count
{
  if (point_count != _point_count)
  {
    _point_count = point_count;
    BlobLayer *theBlobLayer = (BlobLayer*)theBlobView.layer;
//    theBlobLayer.point_count = _point_count;
    BOOL make_circular_blobs = theBlobLayer.useCirclarBlobs;
    [theBlobLayer buildBlobShapeUsingCircluarBlobs: make_circular_blobs point_count: point_count];
    pointCountField.text = [NSString stringWithFormat: @"%d", _point_count];
  }
}

@end
