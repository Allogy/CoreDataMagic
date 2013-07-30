//
//  NSManagedObject+CoreDataMagic.m
//  CoreDataMagic
//
//  Created by Richard Venable on 4/26/13.
//  Copyright (c) 2013 Allogy Interactive. All rights reserved.
//

#import "NSManagedObject+CoreDataMagic.h"
#import "NSManagedObjectContext+CoreDataMagic.h"

@implementation NSManagedObject (CoreDataMagic)

+ (id)insertNewObjectWithEntityNameFromClassNameInManagedObjectContext:(NSManagedObjectContext *)context
{
	return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
}

- (id<OMNIObservation>)addObserverForManagedObjectKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(void (^)(OMNINotification *notification))block
{
	OMNIProxyObservation *observation = [[OMNIProxyObservation alloc] init];

	// If this is a fault and the initial value was requested, send the notification.
	// This is necessary because if it is a fault, the block won't be called until it is faulted in, which is unexpected when using NSKeyValueObservingOptionInitial.
	if (self.isFault && (options & NSKeyValueObservingOptionInitial)) {
		// NOTE the target is nil to prevent the block from accidentally firing the fault
		OMNINotification *notification = [[OMNINotification alloc] initWithObserver:nil target:nil keyPath:keyPath change:nil];
		block(notification);
	}

	[self.managedObjectContext faultObject:self onParentContextWithCompletionHandler:^(NSError *error) {
		NSAssert(!error, @"Must be able to fault observation target object %@ but found error %@", self, error);

		if (observation.isValid) {
			observation.actualObservation = [self addObserverForKeyPath:keyPath options:options block:block];
		}
	}];

	return observation;
}

@end
