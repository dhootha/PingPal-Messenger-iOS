//
//  OutboxHandler.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-04-16.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "OutboxHandler.h"
#import "InboxHandler.h"
#import "GroupWrapper.h"
#import "MyselfObject.h"
#import "FacebookConnector.h"
#import "GroupOverlord.h"
#import "GroupServer.h"

#import <PPLocationManager/Outbox.h>

static OutboxHandler *sharedInstance = nil;

@implementation OutboxHandler

-(id)init{
    self = [super init];
    if (self)
    {
        NSLog(@"OutboxHandler init");
    }
    return self;
}

+(id)sharedInstance{
    if (sharedInstance == nil)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

-(void)listMyGroups{
    NSLog(@"listMyGroups");
    
    if ([[MyselfObject sharedInstance]getUserTag])
    {
        [[GroupServer sharedInstance]getGroupsForMember:[[MyselfObject sharedInstance]getUserTag] callback:^(NSArray *groups)
         {
             NSLog(@"listMyGroups - groups: %@", groups);
             
             // Fetch groups from core data
             NSMutableArray *groupsInCoreData = [[GroupWrapper fetchAllGroups]mutableCopy];
             
             if ([groups count] != 0)
             {
                 // All the groups I'm in. From server
                 NSArray *allGroups = groups;
                 
                 NSMutableArray *groupsNotInCoreData = [[NSMutableArray alloc]init];
                 
                 // Loop through the groups and add their Tags to another array
                 NSMutableArray *groupTags = [[NSMutableArray alloc]init];
                 
                 for (Group *g in groupsInCoreData) // Loop through all the groups that are in core data
                 {
                     // All the groups tags needs to be added to an array
                     [groupTags addObject:g.tag];
                     
                     // Leave and rejoin
                     if (![allGroups containsObject:g.tag]) // If the group isn't in allGroups then it needs to be deleted or it's already deleted
                     {
                         if (!g.deletedGroup) {
                             // No longer member. Leave group
                             [GroupWrapper leaveGroup:g];
                         }
                         // else - This group is already deleted
                     }
                     else // The groups is in allGroups
                     {
                         if (g.deletedGroup) // If the group is deleted I need to rejoin
                         {
                             [GroupWrapper rejoinGroup:g];
                         }
                         // else - The group is in allGroups and core data and it's not deleted
                         
                         [[GroupServer sharedInstance]getMembersForGroup:g.tag callback:^(NSArray *members) {
                             [GroupWrapper checkMembers:members forGroup:g];
                         }];
                     }
                 }
                 
                 // Create groups that are not in core data
                 for (NSString *tag in allGroups)
                 {
                     if (![groupTags containsObject:tag])
                     {
                         [groupsNotInCoreData addObject:tag]; // Group not in core data. This group will have to be created
                     }
                     // else - Group is already in core data
                 }
                 
                 for (NSString *tag in groupsNotInCoreData)
                 {
                     // Create the groups - fetch name later
                     [[GroupServer sharedInstance]getNameForGroup:tag callback:^(NSString *name)
                      {
                          Group *newGroup = [GroupWrapper createGroupWithName:name ? : tag andTag:tag];
                          
                          [[GroupServer sharedInstance]getMembersForGroup:tag callback:^(NSArray *members) {
                              [GroupWrapper checkMembers:members forGroup:newGroup];
                          }];
                      }];
                 }
             }
             else
             {
                 // Response empty - I'm not in any groups at all - Leave them all
                 for (Group *g in groupsInCoreData)
                 {
                     [GroupWrapper leaveGroup:g];
                 }
             }
         }];
    }
    else
    {
        NSLog(@"Error in listMyGroups. Can't list groups without tag");
    }
}

-(void)listDeletedGroups{
    NSLog(@"listDeletedGroups");
    // Fetch all the deleted groups from the server
    NSArray *arr = [GroupWrapper fetchAllDeletedGroups];
    for (Group *group in arr)
    {
        
        [[GroupServer sharedInstance]getMembersForGroup:group.tag callback:^(NSArray *members)
        {
            if ([members count] != 0)
            {
                if (group)
                {
                    [GroupWrapper checkMembers:members forGroup:group];
                }
            }
            else
            {
                NSLog(@"no members");
                
                [GroupWrapper deleteGroup:group];
            }

        }];
    }
}

-(void)checkFriendsAndGroups
{
    [self checkFriends];
    [self performSelector:@selector(checkGroups) withObject:nil afterDelay:4];
}

-(void)checkFriends
{
    NSLog(@"checkFriends");
    
    // If registered with Facebook
    if ([[MyselfObject sharedInstance]getFBID]) {
        NSLog(@"checkFriends - FBID");
        // Check facebook
        if ([FBSession.activeSession isOpen])
        {
            [[FacebookConnector sharedInstance]checkFriends];
        }
        else
        {
            NSLog(@"OutboxHandler checkFriends - No session");
            // No open session. Creating a FBLoginView will check if there is a session to open
            FBLoginView *loginView = [[FBLoginView alloc]initWithReadPermissions:@[@"public_profile", @"user_friends"]];
            [loginView setDelegate:[FacebookConnector sharedInstance]];
            [[FacebookConnector sharedInstance]checkFriends];
        }
    }
}

-(void)checkGroups
{
    [self listMyGroups];
    [self listDeletedGroups];
}


@end