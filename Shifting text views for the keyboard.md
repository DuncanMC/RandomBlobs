#Shifting views to make room for the keyboard

When you use an input text field (`UITextField` or `UITextView`) in your application, tapping in the text field causes the iOS keyboard to animate up from the bottom of the screen. For a few situations like `UITableViewController`s, the system shifts the contents up to make room for the keyboard, but in most cases it does not, and you have deal with this yourself. It's frankly a pain to do this well. You have to allow for fact that the keyboard hight is different for different countries and languages, screen and screen orientations, and can change with OS releases as well. Also Apple can change the timing of the keyboard animation.

Handling this properly involves several steps. The specific details depend on whether your app uses AutoLayout or the older "struts and springs" style resizing rules.

This application uses struts and springs, and shifts the view by altering the view's frame. If you use AutoLayout the details of how you shift the view are slightly different, but the basic idea is the same.

When you receive a `UIKeyboardWillShowNotification`, it includes a pointer to the `NSNotification` object. Notification objects include an optional userInfo property that can contain a dictionary with more info about the notification. In the case of keyboard notifications, the userInfo block contains a number of useful key/value pairs, including the frame of the keyboard,in screen coordinates, and the duration of the keyboard show/hide animation. Search on the string "Keyboard Notification User Info Keys" in the Xcode docs for more info on hte user dictionary that is passed to you for keyboard notifications.

Handling keyboard animations requires several steps:

1. Add observers for 2 different system notifications, `UIKeyboardWillShowNotification` and `UIKeyboardWillHideNotification`. If you're writing a single-view application (like the RandomBlobs application) you can add your notification observers in your `viewDidLoad:animated` method. If you are developing an app with multiple view controllers, though, you probably want to add your observers in your `viewWillAppear:animated` method. I like to use the new block-based `addObserverForName:object:queue:usingBlock:` method. You can also use the older `addObserver:selector:name:object:' method, which requires that you have a second method that gets called when the observer gets a notification. Both flavors of observer receive a pointer to the triggering notification object, which is important in handling the keyboard notification.

2. Add corresponding code to remove your `UIKeyboardWillShowNotification` and `UIKeyboardWillHideNotification` observers. For single-view applications, you can do this in your view controlller's `dealloc` method. For an app with multiple view controllers, you probably want to remove your observers in your `viewWillDisappear:animated` method.


3. In order to figure out how far to shift the text field, we need to know it's postion. In order to do **that**, we need the position of the text field. Sadly, the keyboard notifications don't give us any information about the field that is about to be edited. So, we have to somehow figure out which field is about to begin editing. To do that:

    a. Tell the compiler your view controller conforms to the correct protocol (`UITextViewDelegate` protocol for a `UITextView`, or `UITextFieldDelegate` protocol for a `UITextField`.)
    
    b. Add an instance variable to remember the about-to-be-edited view. (**textFieldToEdit** in the demo project.)
    
    c. implement the "begin editing" method for your view type (`textViewShouldBeginEditing:` for a `UITextView` or `textFieldShouldBeginEditing:` for a `UITextField`). The code is simple: 
    
      ```objective-c
      - (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
      {
        textFieldToEdit = textField;
        return YES;
      }
      ```
      
    d. In IB, set your view controller as the delegate of your `UITextView` or `UITextField`. 

4. In the `UIKeyboardWillShowNotification` code, fetch the keyboard frame and animation duration, as well as the animation curve. These values are provided in both the `UIKeyboardWillShowNotification` and the `UIKeyboardWillHideNotification`, but it's usually simpler to just record the information you need into instance variables, which you then use in the handler for the `UIKeyboardWillHideNotification` handler. 

    a. Extract the height of the keyboard (from the frame provided in the **UIKeyboardFrameBeginUserInfoKey** key/value pair) and use it to calculate the amount we need to shift the keybard. We need to figure ot the Y coorindate of the bottom of the input field, in screen coorindates, and then figure out the minimum we need to shift the view up to fully expose the view. (see the code in the demo app, below). In the demo app, we save this value to the instance variable **keyboardShiftAmount**.
 
     b. Get the animation duration (from the **UIKeyboardAnimationDurationUserInfoKey** key/value pair) and save it to the float instance variable (called  keyboardSlideDuration in the sample app)
     
     c. Save the keyboard animation curve (from the **UIKeyboardAnimationCurveUserInfoKey** key/value pair) into an instance variable (called **keyboardAnimationCurve** in the demo project). The keyboard animation curve is a variable of type **UIViewAnimationCurve**, which ranges from 0 to 4, and is used by the older `beginAnimations:context:`… `commitAnimations` style of view animations. We want to use the newer block-based UIView animation method `animateWithDuration:delay:options:animations:completion:`, which takes animation curve information of enum type **UIViewAnimationOptions**. The animation curve info in the **UIViewAnimationOptions** is shifted up by 16 bits, so we have to convert the specified **UIViewAnimationCurve** to the corresponding **UIViewAnimationOptions** bit flags by shifting the values by 16 bits (as shown in the code) 

5. Animate the view's frame by the (negative of the) specified keyboard shift amount, and using the duration and animation curve that we got in step 3, above. Some developers only shift the field that's being edited. I think this is confusing, since the field will float up and not longer be at the same position relative to the other fields in the form. Instead, I usually animate the view controller's entire content view up.

6. In the `UIKeyboardWillHideNotification` code, do the reverse of the previous step, and animate the view down again. Since we saved the keyboard shift amount, animation duration, and animation curve in the `UIKeyboardWillShowNotification` handler, this code is pretty simple.


Putting all this togther, let's look at the code from our demo app that adds observers for the `UIKeyboardWillShowNotification` and  `UIKeyboardWillHideNotification` observers:

```objective-c
showKeyboardNotificaiton = [[NSNotificationCenter defaultCenter] addObserverForName: UIKeyboardWillShowNotification
  object: nil
  queue: nil
  usingBlock: ^(NSNotification *note)
  {
    //Get the keyboard frame from the notificaiton's userinfo dictionary (in non-rotated screen coordinates)
    CGRect keyboardFrame;
    NSDictionary* userInfo = note.userInfo;
    keyboardSlideDuration = [[userInfo objectForKey: UIKeyboardAnimationDurationUserInfoKey] floatValue];
    keyboardFrame = [[userInfo objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    keyboardAnimationCurve = [[userInfo objectForKey: UIKeyboardAnimationCurveUserInfoKey] integerValue]<<16;
      
    UIInterfaceOrientation theStatusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
  
    CGFloat keyboardHeight;
    
    //if we're in landscape, treat use the reported keyboard width as the height
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
//----------------------------------------------------------------------------------------------
//This is the code to shift the view if we're using AutoLayout
//    keyboardConstraint.constant -= keyboardShiftAmount;
//    keyboardBottomConstraint.constant += keyboardShiftAmount;
//    [self.view layoutIfNeeded];
//----------------------------------------------------------------------------------------------

      //----------------------------------------------------------------------------------------------
      //This is the code for handling the keyboard animations for strut-and-spring style view resizing
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
      //----------------------------------------------------------------------------------------------
    }
  }
];

hideKeyboardNotificaiton = [[NSNotificationCenter defaultCenter] addObserverForName: UIKeyboardWillHideNotification
  object: nil
  queue: nil
  usingBlock: ^(NSNotification *note)
{
  if (keyboardShiftAmount != 0)
  {
    //------------------------------------------------------------------------------------------
    //This is the code for animating the view back down for strut-and-spring style view resizing

    [UIView animateWithDuration: keyboardSlideDuration
      delay: 0
      options: keyboardAnimationCurve
      animations:
     ^{
       CGRect frame = self.view.frame;
       frame.origin.y += keyboardShiftAmount;
       self.view.frame = frame;
    //------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------
//This is the code to shift the view back down if we're using AutoLayout
//     keyboardConstraint.constant += keyboardShiftAmount;
//     keyboardBottomConstraint.constant -= keyboardShiftAmount;
//     [self.view setNeedsUpdateConstraints];
//     [viewToShift layoutIfNeeded];
//----------------------------------------------------------------------------------------------
     }
                     completion: nil
     ];
   }
  
  
}
];
```

Note that if you're using AutoLayout, there are several more steps and the code is a little different. You need to add a top constraint on your view, with a constant offset from the top layout guide, and a bottom constraint to the view that's tied to the bottom layout guide. Then you need to link thise to IBOutlets in your view controller so you can change their offset amounts in code. In the code above, we've used constraints who's IBOutlets are called **keyboardConstraint** and **keyboardBottomConstraint**

