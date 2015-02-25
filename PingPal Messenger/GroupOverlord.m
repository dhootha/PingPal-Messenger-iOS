//
//  GroupOverlord.m
//  PingPal Messenger
//
//  Created by André Hansson on 06/08/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "GroupOverlord.h"
#import "MyselfObject.h"
#import "GroupWrapper.h"
#import "FriendWrapper.h"
#import "GroupServer.h"

#import <PPLocationManager/Outbox.h>

@implementation GroupOverlord

+(void)createGroupWithName:(NSString *)name
{    
    NSLog(@"GroupOverlord - createGroupWithName: %@", name);
    
    // *** PingPal server ***
    // Create tag for group
    NSString *tag = [Outbox createUniqueTag];
        
        NSLog(@"GroupOverlord - create tag: %@", tag);
        
        // Add myself to the group
        [Outbox subscribeTag:[[MyselfObject sharedInstance]getUserTag] toParent:tag withCallback:^(NSError *error) {
            NSLog(@"GroupOverlord - add myself to group");
            
            if (error) {
                NSLog(@"createGroupWithName - subscribeTag Error: %@", error);
                return;
            }
            
            // *** Group server ***
            // Create the group and set the name and tag
            [[GroupServer sharedInstance]createGroupWithName:name andGroup:tag callback:^(NSDictionary *dict){
                
                NSLog(@"GroupOverlord - createGroupWithName on GroupServer: %@", dict);
                
                 // Add myself to the group
                 [[GroupServer sharedInstance]addMember:[[MyselfObject sharedInstance]getUserTag] toGroup:tag callback:^(NSDictionary *dict){
                     
                     NSLog(@"GroupOverlord - add myself to group on GroupServer: %@", dict);
                     
                      // *** Local ***
                     [GroupWrapper createGroupWithName:name andTag:tag];
                     
                  }];
             }];
        }];
    //}];
}

+(void)addMember:(NSString *)memberTag toGroup:(NSString *)groupTag
{
    // *** PingPal server ***
    [Outbox subscribeTag:memberTag toParent:groupTag withCallback:^(NSError *error) {
        
        if (error) {
            NSLog(@"addMember - subscribeTag Error: %@", error);
            return;
        }
        
        // *** Group server ***
        [[GroupServer sharedInstance]addMember:memberTag toGroup:groupTag callback:^(NSDictionary *dict) {
            
            // Notify group about change
            [Outbox put:groupTag withPayload:@{@"groupUpdated":groupTag}];
            
            // *** Local ***
            [GroupWrapper addMembers:@[[FriendWrapper fetchFriendWithTag:memberTag]] toGroup:[GroupWrapper fetchGroupWithTag:groupTag]];
            
        }];
    }];
}

+(void)removeMember:(NSString *)memberTag fromGroup:(NSString *)groupTag
{
    // *** PingPal server ***
    [Outbox unsubscribeTag:memberTag fromParent:groupTag withCallback:^(NSError *error) {
        
        if (error) {
            NSLog(@"removeMember - unsubscribeTag Error: %@", error);
            return;
        }
        
        // *** Group server ***
        [[GroupServer sharedInstance]removeMember:memberTag fromGroup:groupTag callback:^(NSDictionary *dict) {
            
            // Notify group about change
            [Outbox put:groupTag withPayload:@{@"groupUpdated":groupTag}];
            
            // Notify the member that was removed
            [Outbox put:groupTag withPayload:@{@"removedFromGroup":groupTag}];
            
            // *** Local ***
            [GroupWrapper removeMembers:@[memberTag] fromGroup:[GroupWrapper fetchGroupWithTag:groupTag]];
            
        }];
    }];
}

+(void)joinGroup:(NSString *)groupTag
{
    // *** PingPal server ***
    [Outbox subscribeTag:[[MyselfObject sharedInstance]getUserTag] toParent:groupTag withCallback:^(NSError *error) {
        
        if (error) {
            NSLog(@"joinGroup - subscribeTag Error: %@", error);
            return;
        }
        
        // *** Group server ***
        [[GroupServer sharedInstance]addMember:[[MyselfObject sharedInstance]getUserTag] toGroup:groupTag callback:^(NSDictionary *dict) {
           
            // Notify group of change
            [Outbox put:groupTag withPayload:@{@"groupUpdated":groupTag}];
            
            // *** Local ***
            [GroupWrapper rejoinGroup:[GroupWrapper fetchGroupWithTag:groupTag]];
            
        }];
    }];
}

+(void)leaveGroup:(NSString *)groupTag
{
    // *** PingPal server ***
    [Outbox unsubscribeTag:[[MyselfObject sharedInstance]getUserTag] fromParent:groupTag withCallback:^(NSError *error) {
        
        if (error) {
            NSLog(@"leaveGroup - unsubscribeTag Error: %@", error);
            return;
        }
        
        // *** Group server ***
        [[GroupServer sharedInstance]removeMember:[[MyselfObject sharedInstance]getUserTag] fromGroup:groupTag callback:^(NSDictionary *dict) {
            
            // Notify group about change
            [Outbox put:groupTag withPayload:@{@"groupUpdated":groupTag}];
            
            // *** Local ***
            [GroupWrapper leaveGroup:[GroupWrapper fetchGroupWithTag:groupTag]];
            
        }];
    }];
}


@end