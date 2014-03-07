//
//  DebugImageView.m
//  KeyframeViewAnimations
//
//  Created by Duncan Champney on 2/25/14.
//  Copyright (c) 2014 WareTo. All rights reserved.
//

#import "DebugImageView.h"
#import "DebugLayer.h"


@implementation DebugImageView

+ (Class)layerClass
{
  return [DebugLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
