//
//  UIDocument+CoreDataMagic.h
//  CoreDataMagic
//
//  Created by Richard Venable on 4/5/13.
//  Copyright (c) 2013 Allogy Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDocument (CoreDataMagic)

/**
 Opens multiple documents in parallel and calls completion handler after all have been opened, passing the cumulative success of all the documents.
 */
+ (void)openDocuments:(NSArray *)documents andQueueCompletionHandler:(void (^)(BOOL))completionHandler;

/**
 Calls openWithCompletionHandler. Multiple calls to this queue up the completion handlers.
 
 The openWithCompletionHandler method is not safe to call a second time before it completes its first time. This method can be called multiple times safely. The completionHandlers will be queued and called one after another once openWithCompletionHandler is finished.
 */
- (void)openAndQueueCompletionHandler:(void (^)(BOOL))completionHandler;

/**
 Closes the document if it isn't already close and calls the completion handler whether it had been closed or not.
 
 - closeWithCompletionHandler: only calls the completionHandler if the document wasn't already closed, so if you are relying on the completion handler you might miss it. For cases like that, use this method instead.
 */
- (void)closeAndAlwaysCallCompletionHandler:(void (^)(BOOL))completionHandler;

/**
 Deletes the document
 */
- (void)deleteWithCompletionHandler:(void (^)(BOOL))completionHandler;

@end
