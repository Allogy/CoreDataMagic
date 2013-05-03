//
//  NSManagedObject+CoreDataMagic.h
//  CoreDataMagic
//
//  Created by Richard Venable on 4/26/13.
//  Copyright (c) 2013 Allogy Interactive. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (CoreDataMagic)

+ (id)insertNewObjectWithEntityNameFromClassNameInManagedObjectContext:(NSManagedObjectContext *)context;

@end
