//
//  GroupOverlord.h
//  PingPal Messenger
//
//  Created by André Hansson on 06/08/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupOverlord : NSObject

+(void)createGroupWithName:(NSString*)name;

+(void)addMember:(NSString*)memberTag toGroup:(NSString*)groupTag;

+(void)removeMember:(NSString*)memberTag fromGroup:(NSString*)groupTag;

+(void)joinGroup:(NSString*)groupTag;

+(void)leaveGroup:(NSString*)groupTag;

@end