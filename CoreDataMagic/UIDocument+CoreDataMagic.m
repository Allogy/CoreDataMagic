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

+ (void)openDocuments:(NSArray *)documents andQueueCompletionHandler:(void (^)(BOOL))completionHandler
{
	__block BOOL cumulativeSuccess = YES;
	NSMutableSet *documentsRemaining = [NSMutableSet setWithArray:documents];
	[documents enumerateObjectsUsingBlock:^(UIDocument *document, NSUInteger index, BOOL *stop) {
		[document openAndQueueCompletionHandler:^(BOOL success) {
			cumulativeSuccess = cumulativeSuccess && success;
			[documentsRemaining removeObject:document];
			if (!documentsRemaining.count) {
				completionHandler(cumulativeSuccess);
			}
		}];
	}];
}

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

- (void)closeAndAlwaysCallCompletionHandler:(void (^)(BOOL))completionHandler
{
	if (self.documentState & UIDocumentStateClosed) {
		if (completionHandler)
			completionHandler(YES);
	}
	else {
		[self closeWithCompletionHandler:completionHandler];
	}
}

- (void)deleteWithCompletionHandler:(void (^)(BOOL))completionHandler
{
	[self closeAndAlwaysCallCompletionHandler:^(BOOL success) {
		if (success) {
			// Copied from http://developer.apple.com/library/ios/#documentation/DataManagement/Conceptual/DocumentBasedAppPGiOS/ManageDocumentLifeCycle/ManageDocumentLifeCycle.html#//apple_ref/doc/uid/TP40011149-CH4-SW4
			// Also see http://stackoverflow.com/a/15026829/456366
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
				NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
				[fileCoordinator coordinateWritingItemAtURL:self.fileURL options:NSFileCoordinatorWritingForDeleting error:nil byAccessor:^(NSURL* writingURL) {
					NSError *error = nil;
					NSFileManager* fileManager = [[NSFileManager alloc] init];
					if ([fileManager fileExistsAtPath:writingURL.path]) {
						[fileManager removeItemAtURL:writingURL error:&error];

						BOOL success = error ? NO : YES;
						if (completionHandler)
							completionHandler(success);
					}
					else if (completionHandler)
						completionHandler(YES);
				}];
			});
		}
		else if (completionHandler)
			completionHandler(success);
	}];
}

@end
