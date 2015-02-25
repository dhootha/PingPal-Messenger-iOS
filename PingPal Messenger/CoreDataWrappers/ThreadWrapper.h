//
//  ThreadWrapper.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-26.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Friend.h"
#import "Group.h"
#import "Thread.h"


@interface ThreadWrapper : NSObject

// Fetch
+(NSArray*)fetchAllThreads;

+(NSArray*)fetchAllThreadsWithSortKey:(NSString*)sortKey ascending:(BOOL)ascending;

+(Thread*)fetchThreadForTag:(NSString*)tag;


// Create
+(Thread*)createThreadForFriend:(Friend*)f;

+(Thread*)createThreadForGroup:(Group*)g;


// Delete
+(void)deleteThread:(NSObject*)thread;


// Unread
+(void)resetUnreadOnThread:(NSObject*)thread;

+(void)incrementUnreadOnThread:(NSObject*)thread;


// Get stuff
+(NSString*)getImageFilePathForSender:(NSString*)tag onThread:(Thread*)thread;

@end