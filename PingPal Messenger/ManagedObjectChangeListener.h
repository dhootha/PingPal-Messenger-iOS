//
//  ManagedObjectChangeListener.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-04-01.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNewGroup @"newGroup"
#define kNewFriend @"newFriend"
#define kNewMessage @"newMessage"
#define kNewThread @"newThread"
#define kNewDoNotNotify @"newDoNotNotify"
#define kNewDeletedGroup @"newDeletedGroup"
#define kNewDeletedFriend @"newDeletedFriend"

#define kDeletedGroup @"deletedGroup"
#define kDeletedFriend @"deletedFriend"
#define kDeletedMessage @"deletedMessage"
#define kDeletedThread @"deletedThread"
#define kDeletedDoNotNotify @"deletedDoNotNotify"
#define kDeletedDeletedGroup @"deletedDeletedGroup"
#define kDeletedDeletedFriend @"deletedDeletedFriend"

#define kUpdatedGroup @"updatedGroup"
#define kUpdatedFriend @"updatedFriend"
#define kUpdatedMessage @"updatedMessage"
#define kUpdatedThread @"updatedThread"
#define kUpdatedDoNotNotify @"updatedDoNotNotify"
#define kUpdatedDeletedGroup @"updatedDeletedGroup"
#define kUpdatedDeletedFriend @"updatedDeletedFriend"


@protocol ChangeListener;

@interface ManagedObjectChangeListener : NSObject

+ (id)sharedInstance;

-(void)addChangeListener:(NSObject<ChangeListener>*)listener;

-(void)removeChangeListener:(NSObject<ChangeListener>*)listener;

@end

@protocol ChangeListener <NSObject>

@required
-(void)newChangeWithKey:(NSString*)key;

@end