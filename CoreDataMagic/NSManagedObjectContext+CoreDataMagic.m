//
//  NSManagedObjectContext+CoreDataMagic.m
//  CoreDataMagic
//
//  Created by Richard Venable on 3/27/13.
//  Copyright (c) 2013 Allogy Interactive. All rights reserved.
//

#import "NSManagedObjectContext+CoreDataMagic.h"
#import "NSComparisonPredicate+CoreDataMagic.h"

@implementation NSManagedObjectContext (CoreDataMagic)

- (void)faultObject:(NSManagedObject *)object onParentContextWithCompletionHandler:(void (^)(NSError *error))completionHandler
{
	NSManagedObjectContext *parentContext = self.parentContext;
	NSManagedObjectID *objectID = object.objectID;

	// If this isn't a fault, then we don't need to fault it in
	// Also, if there isn't a parent context, we can't fault in the background anyway, so just call the completion handler and let the object be faulted in regularly
	if (!object.isFault || !parentContext) {
		// Perform the completion handler in the correct block (the 'AndWait' ensures that if we are already on the right thread, it will run now instead of getting queued).
		[self performBlockAndWait:^() {
			completionHandler(nil);
		}];
		return;
	}

	[parentContext performBlock:^() {
		NSError *error = nil;
		NSManagedObject *objectInParentContext = [self existingObjectWithID:objectID error:&error];

		[self performBlock:^() {
			completionHandler(error);
		}];
	}];
}

- (void)executeFetchRequest:(NSFetchRequest *)request onParentContextWithCompletionHandler:(void (^)(NSArray *, NSError *))completionHandler
{
	NSManagedObjectContext *parentContext = self.parentContext;

	NSParameterAssert(parentContext);

	BOOL returnObjectsAsFaults = request.returnsObjectsAsFaults;

	[parentContext performBlock:^() {
		NSError *error = nil;

		// In the background, we only need the Object IDs
		NSFetchRequestResultType originalResultType = request.resultType;
		request.resultType = NSManagedObjectIDResultType;

		NSArray *objectIDs = [parentContext executeFetchRequest:request error:&error];

		// Restore the original result type, in case the calling code still wants to use it
		request.resultType = originalResultType;

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

- (void)fetchObjectWithRequest:(NSFetchRequest *)request onParentContextWithCompletionHandler:(void (^)(id object, NSError *error))completionHandler
{
	request.fetchLimit = 1;

	[self executeFetchRequest:request onParentContextWithCompletionHandler:^(NSArray *results, NSError *error) {
		completionHandler([results lastObject], error);
	}];
}

- (void)fetchObjectWithEntityName:(NSString *)entityName andPredicate:(NSPredicate *)predicate onParentContextWithCompletionHandler:(void (^)(id object, NSError *error))completionHandler
{
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
	fetchRequest.predicate = predicate;

	[self fetchObjectWithRequest:fetchRequest onParentContextWithCompletionHandler:completionHandler];
}

- (void)fetchObjectWithEntityName:(NSString *)entityName keyPath:(NSString *)keyPath value:(id)value onParentContextWithCompletionHandler:(void (^)(id object, NSError *error))completionHandler
{
	[self fetchObjectWithEntityName:entityName andPredicate:[NSComparisonPredicate predicateWithKeyPath:keyPath value:value] onParentContextWithCompletionHandler:completionHandler];
}

- (id)fetchObjectWithRequest:(NSFetchRequest *)fetchRequest error:(NSError **)error
{
	fetchRequest.fetchLimit = 1;

	NSArray *results = [self executeFetchRequest:fetchRequest error:error];
	id object = [results lastObject];

	return object;
}

- (id)fetchObjectWithEntityName:(NSString *)entityName andPredicate:(NSPredicate *)predicate error:(NSError **)error
{
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
	fetchRequest.predicate = predicate;

	return [self fetchObjectWithRequest:fetchRequest error:error];
}

- (id)fetchObjectWithEntityName:(NSString *)entityName keyPath:(NSString *)keyPath value:(id)value error:(NSError **)error
{
	return [self fetchObjectWithEntityName:entityName andPredicate:[NSComparisonPredicate predicateWithKeyPath:keyPath value:value] error:error];
}

@end
