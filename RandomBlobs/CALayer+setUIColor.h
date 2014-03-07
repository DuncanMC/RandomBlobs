//
//  CALayer+setUIColor.h
//
//  Created by Duncan Champney on 12/6/12.
//  Copyright (c) 2013 WareTo. All rights reserved.
//

/*
 This category adds new set-only property borderUIColor to CALayer. 
 With this category in your project, you can set the border color on a layer 
 from the "User Defined Runtime Attributes" settings in the identity inspector.
 You would add a key "layer.borderUIColor"
 and a value of type Color (which is a UIColor in the iOS SDK)
 The setBorderUIColor method sets the layer's borderColor with the result of converting the 
 UIColor to a CGColor
 */

#import <QuartzCore/QuartzCore.h>

@interface CALayer (setUIColor)

- (void) setBorderUIColor: (UIColor *) newBorderColor;

@end
