//
//  UIDocument+CoreDataMagic.m
//  CoreDataMagic
//
//  Created by Richard Venable on 4/5/13.
//  Copyright (c) 2013 Allogy Interactive. All rights reserved.
//

#import "UIDocument+CoreDataMagic.h"
#import <objc/runtime.h>

static const char * const CoreDataMagicUIDocumentOpenCompletionHandlersKey = "CoreDataMagicUIDocumentOpenCompletionHandlersKey";

@interface UIDocument ()

@property (nonatomic, strong) NSMutableArray *openCompletionHandlers;

@end

@implementation UIDocument (CoreDataMagic)

- (void)openAndQueueCompletionHandler:(void (^)(BOOL))completionHandler
{
	// Run on the main queue because we want to make sure we only modify self.openCompletionHandlers on that queue
	dispatch_async(dispatch_get_main_queue(), ^() {

		if (!self.openCompletionHandlers) {
			self.openCompletionHandlers = [NSMutableArray arrayWithObject:completionHandler];

			[self openWithCompletionHandler:^(BOOL success) {
				// This block is on the main queue, according to the documentation, which is important for self.openCompletionHandlers

				[self.openCompletionHandlers enumerateObjectsUsingBlock:^(void (^completionHandler)(BOOL success), NSUInteger index, BOOL *stop) {
					completionHandler(success);
				}];
				self.openCompletionHandlers = nil;
			}];
		}
		else {
			[self.openCompletionHandlers addObject:completionHandler];
		}

	});
}

- (NSMutableArray *)openCompletionHandlers
{
	return objc_getAssociatedObject(self, &CoreDataMagicUIDocumentOpenCompletionHandlersKey);
}

- (void)setOpenCompletionHandlers:(NSMutableArray *)openCompletionHandlers
{
	objc_setAssociatedObject(self, &CoreDataMagicUIDocumentOpenCompletionHandlersKey, openCompletionHandlers, OBJC_ASSOCIATION_RETAIN);
}

@end
