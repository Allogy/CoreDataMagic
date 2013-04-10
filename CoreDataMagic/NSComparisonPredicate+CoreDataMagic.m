//
//  NSComparisonPredicate+CoreDataMagic.m
//  CoreDataMagic
//
//  Created by Richard Venable on 4/6/13.
//  Copyright (c) 2013 Allogy Interactive. All rights reserved.
//

#import "NSComparisonPredicate+CoreDataMagic.h"

@implementation NSComparisonPredicate (CoreDataMagic)

+ (NSPredicate *)predicateWithKeyPath:(NSString *)keyPath value:(id)value
{
	return [self predicateWithKeyPath:keyPath value:value modifier:NSDirectPredicateModifier type:NSEqualToPredicateOperatorType options:0];
}

+ (NSPredicate *)predicateWithKeyPath:(NSString *)keyPath value:(id)value modifier:(NSComparisonPredicateModifier)modifier type:(NSPredicateOperatorType)type options:(NSComparisonPredicateOptions)options
{
	return [[NSComparisonPredicate alloc] initWithKeyPath:keyPath value:value modifier:modifier type:type options:options];
}

- (id)initWithKeyPath:(NSString *)keyPath value:(id)value modifier:(NSComparisonPredicateModifier)modifier type:(NSPredicateOperatorType)type options:(NSComparisonPredicateOptions)options
{
	return [self initWithLeftExpression:[NSExpression expressionForKeyPath:keyPath] rightExpression:[NSExpression expressionForConstantValue:value] modifier:modifier type:type options:options];
}


@end
