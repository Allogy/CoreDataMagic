//
//  NSManagedObject+CoreDataMagic.m
//  CoreDataMagic
//
//  Created by Richard Venable on 4/26/13.
//  Copyright (c) 2013 Allogy Interactive. All rights reserved.
//

#import "NSManagedObject+CoreDataMagic.h"

@implementation NSManagedObject (CoreDataMagic)

+ (id)insertNewObjectWithEntityNameFromClassNameInManagedObjectContext:(NSManagedObjectContext *)context
{
	return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
}

@end
