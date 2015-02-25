//
//  FriendWrapper.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-24.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Friend.h"

@interface FriendWrapper : NSObject

// Fetch
+(NSArray*)fetchAllFriends; // Returns all friends, deleted or not

+(NSArray*)fetchAllNonDeletedFriends; // Returns all friends that has not been deleted

+(NSArray*)fetchAllDeletedFriends; // Returns all friends that has been deleted

+(NSArray *)fetchAllFriendsWithSortKey:(NSString*)sortKey ascending:(BOOL)ascending;

+(NSArray *)fetchAllNonDeletedFriendsWithSortKey:(NSString*)sortKey ascending:(BOOL)ascending;

+(NSArray *)fetchAllDeletedFriendsWithSortKey:(NSString*)sortKey ascending:(BOOL)ascending;

+(Friend*)fetchFriendWithTag:(NSString*)tag;

+(Friend*)fetchFriendWithFBID:(NSString*)fbid;


// Get stuff
+(NSString*)getImageFilePathForFriendTag:(NSString*)tag;


// Create
+(void)createFriend:(NSString*)tag withFacebook:(CFacebook*)facebook;

+(CFacebook*)createFacebook:(NSString*)fbid withFirstName:(NSString*)firstName andLastName:(NSString*)lastName;


// Delete
+(void)deleteFriend:(Friend*)friend;

+(void)restoreDeletedFriend:(Friend*)friend;


@end