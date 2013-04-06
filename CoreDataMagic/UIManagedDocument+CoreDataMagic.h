//
//  UIManagedDocument+CoreDataMagic.h
//  CoreDataMagic
//
//  Created by Richard Venable on 3/27/13.
//  Copyright (c) 2013 Allogy Interactive. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "UIDocument+CoreDataMagic.h"

@interface UIManagedDocument (CoreDataMagic)

/**
 Executes a fetch request in the background on the parent context, copies the resulting objects to the main context, then passes the results to the completion handler

 The completion handler is called from the main context's thread.

 Tip: Since this is running in the background, it is often good to go ahead and fault in all the objects at the same time. This can be done by setting returnsObjectsAsFaults to NO on the fetch request.
 */
- (void)executeFetchRequest:(NSFetchRequest *)request inBackgroundWithCompletionHandler:(void (^)(NSArray *results, NSError *error))completionHandler;

@end
