//
//  NSManagedObject+CoreDataMagic.h
//  CoreDataMagic
//
//  Created by Richard Venable on 4/26/13.
//  Copyright (c) 2013 Allogy Interactive. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Omniscience.h"

@interface NSManagedObject (CoreDataMagic)

+ (id)insertNewObjectWithEntityNameFromClassNameInManagedObjectContext:(NSManagedObjectContext *)context;

/**
 Adds an observer for a keypath on a managed object. If the managed object's context has a parent context, the the managed object is faulted in on the parent context before beginning the observation. This is helpful for observing data that takes a substantial time to fault in.
 
 When using NSKeyValueObservingOptionInitial, if the managed object is a fault, the block will be called immediately, before faulting in the object, so that the block can perform necessary initializations before waiting for the fault. When the block is called before faulting in the object, the target will be set to nil (it would normally be the managed object) in order to prevent the block from accidentially firing the fault itself. The block will be called again with the initial value after the object is faulted.
 */
- (id<OMNIObservation>)addObserverForManagedObjectKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(void (^)(OMNINotification *notification))block;

@end
