//
//  NSManagedObjectContext+CoreDataMagic.m
//  CoreDataMagic
//
//  Created by Richard Venable on 3/27/13.
//  Copyright (c) 2013 Allogy Interactive. All rights reserved.
//

#import "NSManagedObjectContext+CoreDataMagic.h"

@implementation NSManagedObjectContext (CoreDataMagic)

- (void)executeFetchRequest:(NSFetchRequest *)request onParentContextWithCompletionHandler:(void (^)(NSArray *, NSError *))completionHandler
{
	NSManagedObjectContext *parentContext = self.parentContext;

	BOOL returnObjectsAsFaults = request.returnsObjectsAsFaults;

	[parentContext performBlock:^() {
		NSError *error = nil;
		request.resultType = NSManagedObjectIDResultType;
		NSArray *objectIDs = [parentContext executeFetchRequest:request error:&error];

		[self performBlock:^() {
			if (returnObjectsAsFaults) {
				NSArray *results = [self objectsWithObjectIDs:objectIDs];
				completionHandler(results, error);
			}
			else {
				if (error) {
					completionHandler(nil, error);
				}
				else {
					[self faultedObjectsWithObjectIDs:objectIDs completionHandler:completionHandler];
				}
			}
		}];
	}];
}

- (NSArray *)objectsWithObjectIDs:(NSArray *)objectIDs
{
	NSMutableArray *objects = [NSMutableArray arrayWithCapacity:objectIDs.count];
	[objectIDs enumerateObjectsUsingBlock:^(NSManagedObjectID *objectID, NSUInteger index, BOOL *stop) {
		NSManagedObject *object = [self objectWithID:objectID];
		[objects addObject:object];
	}];
	return objects;
}

- (void)faultedObjectsWithObjectIDs:(NSArray *)objectIDs completionHandler:(void (^)(NSArray *objects, NSError *error))completionHandler
{
	// Run this asynchronously because we are going to be calling performBlockAndWait multiple times
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
		NSMutableArray *faultedObjects = [NSMutableArray arrayWithCapacity:objectIDs.count];
		__block NSError *error = nil;

		[objectIDs enumerateObjectsUsingBlock:^(NSManagedObjectID *objectID, NSUInteger index, BOOL *stop) {
			// By calling the performBlockAndWait each time, we don't block the thread while we fault all the objects at once, we just block it for each object and let it run in between. This increases the total run time for this method, but is helpful for the main thread, enabling user's to still interact in between faulting in each object.
			// We need to use performBlockAndWait instead of performBlock so that we maintain the order of the array we are populating
			[self performBlockAndWait:^() {
				// This method faults in the object
				NSManagedObject *object = [self existingObjectWithID:objectID error:&error];
				if (object)
					[faultedObjects addObject:object];
			}];

			// If there is an error, we need to stop
			if (error)
				*stop = YES;
		}];

		// Don't return any objects when we have an error, since we might not have enumerated through the entire object IDs array
		if (error)
			faultedObjects = nil;

		[self performBlock:^() {
			completionHandler(faultedObjects, error);
		}];
	});
}

@end
