//
//  NSComparisonPredicate+CoreDataMagic.h
//  CoreDataMagic
//
//  Created by Richard Venable on 4/6/13.
//  Copyright (c) 2013 Allogy Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSComparisonPredicate (CoreDataMagic)

+ (NSPredicate *)predicateWithKeyPath:(NSString *)keyPath value:(id)value;
+ (NSPredicate *)predicateWithKeyPath:(NSString *)keyPath value:(id)value modifier:(NSComparisonPredicateModifier)modifier type:(NSPredicateOperatorType)type options:(NSComparisonPredicateOptions)options;

- (id)initWithKeyPath:(NSString *)keyPath value:(id)value modifier:(NSComparisonPredicateModifier)modifier type:(NSPredicateOperatorType)type options:(NSComparisonPredicateOptions)options;

@end
