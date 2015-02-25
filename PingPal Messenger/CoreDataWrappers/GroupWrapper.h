//
//  GroupWrapper.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-24.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Group.h"

@interface GroupWrapper : NSObject

// Fetch

+(NSArray*)fetchAllGroups;

+(NSArray*)fetchAllNonDeletedGroups;

+(NSArray*)fetchAllDeletedGroups;

+(NSArray*)fetchAllGroupsWithSortKey:(NSString*)sortKey ascending:(BOOL)ascending;

+(NSArray*)fetchAllNonDeletedGroupsWithSortKey:(NSString*)sortKey ascending:(BOOL)ascending;

+(NSArray*)fetchAllDeletedGroupsWithSortKey:(NSString*)sortKey ascending:(BOOL)ascending;

+(Group*)fetchGroupWithTag:(NSString*)tag;


// Create

+(Group*)createGroupWithName:(NSString*)name andTag:(NSString*)tag;


// Manage members

+(void)addMembers:(NSArray*)array toGroup:(Group*)group;

+(void)removeMembers:(NSArray*)array fromGroup:(Group*)group;

+(void)checkMembers:(NSArray*)members forGroup:(Group*)group;


// Manage DoNotNotify

+(void)addMembersToDoNotNotify:(NSArray *)array onGroup:(Group *)group;

+(void)removeMembersFromDoNotNotify:(NSArray *)array onGroup:(Group *)group;

+(NSArray*)getDoNotNotifyMembersForGroup:(Group*)group;

+(void)setNotifyMe:(BOOL)notifyMe onGroup:(Group*)group;

+(BOOL)getNotifyMeForGroup:(Group*)group;


// Leave & rejoin

+(void)leaveGroup:(Group*)group;

+(void)rejoinGroup:(Group*)group;


// Delete

+(void)deleteGroup:(Group*)group; // Delete the group from core data


@end