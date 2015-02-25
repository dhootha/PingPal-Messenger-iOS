//
//  OutboxHandler.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-04-16.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OutboxHandler : NSObject

+(id)sharedInstance;

-(void)listMyGroups;

-(void)listDeletedGroups;


-(void)checkFriendsAndGroups;

-(void)checkFriends;

-(void)checkGroups;

@end