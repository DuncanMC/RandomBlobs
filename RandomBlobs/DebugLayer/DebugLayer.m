//
//  DebugLayer.m
//  KeyframeViewAnimations
//
//  Created by Duncan Champney on 2/25/14.
//  Copyright (c) 2014 WareTo. All rights reserved.
//

#import "DebugLayer.h"
#import "Constants.h"

@implementation DebugLayer

- (void)addAnimation:(CAAnimation *)anim forKey:(NSString *)key
{

#if K_LOG_KEYFRAME_STEPS
  printf("\n");
  NSLog(@"Adding animation for key \"%@\". Animation = %@", key, anim);
#endif
  if ( [anim isMemberOfClass: [CAKeyframeAnimation class]])
  {
#if K_LOG_KEYFRAME_STEPS || K_FIX_ANIMATION
    NSValue *previousValue = nil;
    NSNumber *previousTime = nil;
    BOOL duplicates_found = NO;
    CAKeyframeAnimation *keyframe = (CAKeyframeAnimation *) anim;
#endif
    
#if K_LOG_KEYFRAME_STEPS || K_FIX_ANIMATION
    NSString *dupeString;
    for (int index = 0; index<keyframe.values.count; index++ )
    {
      NSValue *aValue = keyframe.values[index];
      NSNumber *aTime = keyframe.keyTimes[index];
      if (([aValue isEqual: previousValue] &&
           fabs(aTime.doubleValue - previousTime.doubleValue) < .0001))
      {
        dupeString = @" - Duplicate!";
        duplicates_found = YES;
      }
      else
        dupeString = @"";
#if K_LOG_KEYFRAME_STEPS
      const char *aValueType = [aValue objCType];
      if (strstr(aValueType, "Point") != NULL)
        NSLog(@"  Key %d, value = %@,\ttime = %.2f%@", index, aValue, aTime.floatValue, dupeString);
      else
        NSLog(@"  Key %d, value = %s,\ttime = %.2f%@", index, aValueType, aTime.floatValue, dupeString);
#endif
      previousValue = aValue;
      previousTime = aTime;
 
    }
#endif
    
    
#if K_FIX_ANIMATION
    if (duplicates_found)
    {
      NSMutableArray *newValues = [NSMutableArray arrayWithCapacity: keyframe.values.count];
      //[keyframe.values mutableCopy];
      
      NSMutableArray *newTimes = [NSMutableArray arrayWithCapacity: keyframe.keyTimes.count];
      //[keyframe.keyTimes mutableCopy];
#endif
#if K_LOG_KEYFRAME_STEPS && K_FIX_ANIMATION
      NSLog(@"\n\n>--->> Removing extra indexes from values and keyTimes <<---");
#endif
      
      previousValue = nil;
      previousTime = nil;
      
      for (int index = 0; index<keyframe.values.count; index++ )
      {
        NSValue *aValue = keyframe.values[index];
        NSNumber *aTime = keyframe.keyTimes[index];
        
        if (!([aValue isEqual: previousValue] &&
              fabs(aTime.doubleValue - previousTime.doubleValue) < .0001))
        {
#if K_FIX_ANIMATION

          [newValues addObject: aValue];
          if (aTime)
            [newTimes addObject: aTime];
#endif
        }
        else
        {
#if K_LOG_KEYFRAME_STEPS && K_FIX_ANIMATION
          NSLog(@"Skipping index %d", index);
#endif
        }
        previousValue = aValue;
        previousTime = aTime;
      }
#if K_FIX_ANIMATION
      keyframe.values = newValues;
      keyframe.keyTimes = newTimes;
      
      for (int index = 0; index<keyframe.values.count; index++ )
      {
        NSNumber *aTime;
        if (keyframe.keyTimes.count >= index+1)
          aTime = keyframe.keyTimes[index];
#if K_LOG_KEYFRAME_STEPS
        NSValue *aValue = keyframe.values[index];
        const char *aValueType = [aValue objCType];
        if (strstr(aValueType, "Point") != NULL)
          NSLog(@"  Key %d, value = %@,\ttime = %.2f", index, aValue, aTime.floatValue);
        else
          NSLog(@"  Key %d, value = %s,\ttime = %.2f", index, aValueType, aTime.floatValue);
      }
#endif
#endif

#if K_FIX_ANIMATION
    }
#endif
  }
  [super addAnimation: anim
               forKey: key];
}
@end
