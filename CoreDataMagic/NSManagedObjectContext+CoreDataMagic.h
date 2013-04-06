//
//  NSManagedObjectContext+CoreDataMagic.h
//  CoreDataMagic
//
//  Created by Richard Venable on 3/27/13.
//  Copyright (c) 2013 Allogy Interactive. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (CoreDataMagic)

/**
 Executes a fetch request on the parent context, copies the resulting objects to the target context, then passes the results to the completion handler
 
 This is typically used to run a fetch request in the background, when the target context is on the main thread, but the parent context is not.

 The completion handler is called from the target context's thread.
 
 Tip: Since this is running on a different thread, it is often good to go ahead and fault in all the objects at the same time. This can be done by setting returnsObjectsAsFaults to NO on the fetch request.
 */
- (void)executeFetchRequest:(NSFetchRequest *)request onParentContextWithCompletionHandler:(void (^)(NSArray *results, NSError *error))completionHandler;

/**
 Returns the objects for the given object IDs. Objects may be faults.
 
 Calls objectWithObjectID for each object ID.
 */
- (NSArray *)objectsWithObjectIDs:(NSArray *)objectIDs;

/**
 Returns the objects for the given object IDs via a completion handler. Objects are faulted into the context, so no faults are ever returned.
 
 Calls existingObjectWithID:error: for each object ID.

 The completion handler is called from the target context's thread.
 */
- (void)faultedObjectsWithObjectIDs:(NSArray *)objectIDs completionHandler:(void (^)(NSArray *objects, NSError *error))completionHandler;

@end
