//
//  UIManagedDocument+CoreDataMagic.m
//  CoreDataMagic
//
//  Created by Richard Venable on 3/27/13.
//  Copyright (c) 2013 Allogy Interactive. All rights reserved.
//

#import "UIManagedDocument+CoreDataMagic.h"
#import "NSManagedObjectContext+CoreDataMagic.h"

@implementation UIManagedDocument (CoreDataMagic)

- (void)executeFetchRequest:(NSFetchRequest *)request inBackgroundWithCompletionHandler:(void (^)(NSArray *, NSError *))completionHandler
{
	[self.managedObjectContext executeFetchRequest:request onParentContextWithCompletionHandler:completionHandler];
}

@end
