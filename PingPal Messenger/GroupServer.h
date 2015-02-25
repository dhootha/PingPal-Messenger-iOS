//
//  GroupServer.h
//  PingPal Messenger
//
//  Created by André Hansson on 06/08/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupServer : NSObject

+ (id)sharedInstance;

-(void)createGroupWithName:(NSString*)name andGroup:(NSString*)groupTag callback:(void (^)(NSDictionary*)) callback;

-(void)setName:(NSString*)name forGroup:(NSString*)groupTag callback:(void (^)(NSDictionary*)) callback;;

-(void)getNameForGroup:(NSString*)groupTag callback:(void (^)(NSString*)) callback;

-(void)getMembersForGroup:(NSString*)groupTag callback:(void (^)(NSArray*)) callback;

-(void)addMember:(NSString*)member toGroup:(NSString*)groupTag callback:(void (^)(NSDictionary*)) callback;

-(void)removeMember:(NSString*)member fromGroup:(NSString*)groupTag callback:(void (^)(NSDictionary*)) callback;

-(void)getGroupsForMember:(NSString*)member callback:(void (^)(NSArray*)) callback;

@end