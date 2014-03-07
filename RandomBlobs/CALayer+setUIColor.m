//
//  CALayer+setUIColor.m
//
//  Created by Duncan Champney on 12/6/12.
//
//

#import "CALayer+setUIColor.h"

@implementation CALayer (setUIColor)

- (void) setBorderUIColor: (UIColor *) newBorderColor;
{
  self.borderColor = [newBorderColor CGColor];
}
@end
