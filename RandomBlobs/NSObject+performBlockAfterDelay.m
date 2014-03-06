//
//  NSObject+performBlockAfterDelay.m
//  ChromaKey
//
//  Copyright (c) 2012 WareTo. May be used by anyone, free of license, as
//  long as this copyright notice remains.
//

#import "NSObject+performBlockAfterDelay.h"


//dispatch_get_current_queue() is deprecated. Reworked to use dispatch_get_main_queue() instead.

@implementation NSObject (performBlockAfterDelay)


- (void) performBlock: (dispatch_block_t) block
              onQueue: (dispatch_queue_t) target_queue
           afterDelay: (NSTimeInterval) delay;
{
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), target_queue,
                 block);
  
}

//-----------------------------------------------------------------------------------------------------------

- (void) performBlockOnMainQueue: (dispatch_block_t) block
                      afterDelay: (NSTimeInterval) delay;
{
  [self performBlock: block
             onQueue:  dispatch_get_main_queue()
          afterDelay:delay];
}

@end

