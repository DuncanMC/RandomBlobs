//
//  NSObject+performBlockAfterDelay.h
//
//  Copyright (c) 2012 and 2013 WareTo. May be used by anyone, free of license, as
//  long as this copyright notice remains.
//

/*
 This category adds the mthods performBlockOnMainQueue:afterDelay:
 and performBlock:onQueue:afterDelay: to NSObject.
 
 The method performBlockOnMainQueue:afterDelay: takes a simple code block
 and executes that block on the main queue after the specified delay.
 
 performBlockOnMainQueue:afterDelay: is much more flexible that performSelector:withObject:afterDelay
 because the block has access to variables in it's enclosing scope. Thus you're not limited
 to passing one and only one object as a parameter.
 
 
 The alternate method performBlock:onQueue:afterDelay: allows you to specify the dispatch queue
 on which you want the block to run.
 */

@interface NSObject (performBlockAfterDelay)

- (void) performBlockOnMainQueue: (dispatch_block_t) block
                      afterDelay: (NSTimeInterval) delay;

//-----------------------------------------------------------------------------------------------------------

- (void) performBlock: (dispatch_block_t) block
              onQueue: (dispatch_queue_t) target_queue
           afterDelay: (NSTimeInterval) delay;


@end
