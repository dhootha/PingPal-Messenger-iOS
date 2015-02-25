//
//  InboxHandler.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-04-07.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "InboxHandler.h"
#import "ThreadWrapper.h"
#import "MessageWrapper.h"
#import "GroupWrapper.h"
#import "FriendWrapper.h"
#import "MyselfObject.h"
#import "OutboxHandler.h"

#import "GroupServer.h"

#import <PPLocationManager/Outbox.h>

#define PP_KEY_USER_DATA @"payload"

static InboxHandler *sharedInstance = nil;

@implementation InboxHandler{
    Inbox messageInbox;
    Inbox iconInbox;
    
    Inbox groupMessageInbox;
    Inbox groupIconInbox;
    
    Inbox groupUpdatedInbox;
    Inbox removedFromGroupInbox;
    
    Inbox groupNotifyChangedInbox;
}

-(id)init{
    self = [super init];
    if (self)
    {
        __weak typeof(self) weakSelf = self;
        
#pragma mark - MessageInbox
        messageInbox = ^(NSMutableDictionary *payload, NSMutableDictionary *options, Outbox *outbox){
            NSLog(@"messageInbox Payload: %@. Options: %@", payload, options);
            
            __strong typeof(self) strongSelf = weakSelf;
            
            if (strongSelf)
            {
                NSString *sender = options[@"from"];
                
                NSString *message = payload[@"message"];
                
                Thread *thread = [ThreadWrapper fetchThreadForTag:sender];
                
                if (!thread)
                {
                    NSLog(@"messageInbox - NO THREAD");
                    Friend *friend = [FriendWrapper fetchFriendWithTag:sender];
                    if (!friend)
                    {
                        NSLog(@"messageInbox - NO FRIEND");
                        [[OutboxHandler sharedInstance]checkFriends];
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict addEntriesFromDictionary:payload];
                        [dict addEntriesFromDictionary:options];
                        [strongSelf performSelector:@selector(retryMessageInbox:) withObject:dict afterDelay:10];
                        return;
                    }
                    else
                    {
                        if ([friend deletedFriend]) {
                            NSLog(@"messageInbox - DeletedFriend");
                            return;
                        }
                    }
                    
                    thread = [ThreadWrapper createThreadForFriend:friend];
                }
                
                int unread = [[thread unread]intValue];
                unread++;
                [thread setUnread:[NSNumber numberWithInt:unread]];
                
                [MessageWrapper createNewMessageWithText:message andSender:sender andDate:[NSDate date] forThread:thread];
                
                [strongSelf saveTicket:options[@"ticket"]];
            }
        };
        [Outbox attachInbox:messageInbox withPredicate:[NSPredicate predicateWithFormat:@"payload.message != nil"]];
        

#pragma mark - IconInbox
        iconInbox = ^(NSMutableDictionary *payload, NSMutableDictionary *options, Outbox *outbox){
            NSLog(@"iconInbox Payload: %@. Options: %@", payload, options);
            
            __strong typeof(self) strongSelf = weakSelf;
            
            if (strongSelf)
            {
                NSString *sender = options[@"from"];
                
                NSString *icon = payload[@"icon"];
                
                Thread *thread = [ThreadWrapper fetchThreadForTag:sender];
                
                if (!thread)
                {
                    NSLog(@"iconInbox - NO THREAD");
                    
                    Friend *friend = [FriendWrapper fetchFriendWithTag:sender];
                    
                    if (!friend)
                    {
                        NSLog(@"iconInbox - NO FRIEND");
                        [[OutboxHandler sharedInstance]checkFriends];
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict addEntriesFromDictionary:payload];
                        [dict addEntriesFromDictionary:options];
                        [strongSelf performSelector:@selector(retryIconInbox:) withObject:dict afterDelay:10];
                        return;
                    }
                    else
                    {
                        if ([friend deletedFriend]) {
                            NSLog(@"iconInbox - DeletedFriend");
                            return;
                        }
                    }
                    
                    thread = [ThreadWrapper createThreadForFriend:friend];
                }
                
                int unread = [[thread unread]intValue];
                unread++;
                [thread setUnread:[NSNumber numberWithInt:unread]];
                
                NSString *text = [NSString stringWithFormat:@"%@ %@", [[FriendWrapper fetchFriendWithTag:sender]getName], NSLocalizedString(@"iconSentText", @"Sent an icon")];
                
                [MessageWrapper createNewMessageWithIcon:icon andText:text andSender:sender andDate:[NSDate date] forThread:thread];
                
                [strongSelf saveTicket:options[@"ticket"]];
            }
        };
        [Outbox attachInbox:iconInbox withPredicate:[NSPredicate predicateWithFormat:@"payload.icon != nil"]];
        

#pragma mark - GroupMessageInbox
        groupMessageInbox = ^(NSMutableDictionary *payload, NSMutableDictionary *options, Outbox *outbox){
            NSLog(@"groupMessageInbox Payload: %@. Options: %@", payload, options);
            
            __strong typeof(self) strongSelf = weakSelf;

            if (strongSelf)
            {
                NSString *sender = options[@"from"]; // The tag of the person who sent the message
                
                if ([sender isEqualToString:[[MyselfObject sharedInstance]getUserTag]]){
                    // I sent the message. Do nothing.
                    NSLog(@"groupChatMessageInbox - I sent the message");
                    return;
                }
                
                NSString *group = options[@"to"]; // The group the message was sent to
                
                NSString *message = payload[@"groupMessage"];
                
                Thread *thread = [ThreadWrapper fetchThreadForTag:group];
                
                if (!thread)
                {
                    NSLog(@"groupMessageInbox - NO THREAD");
                    Group *g = [GroupWrapper fetchGroupWithTag:group];
                    
                    if (!g)
                    {
                        NSLog(@"groupMessageInbox - NO GROUP");
                        [[OutboxHandler sharedInstance]checkGroups];
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict addEntriesFromDictionary:payload];
                        [dict addEntriesFromDictionary:options];
                        [strongSelf performSelector:@selector(retryGroupMessageInbox:) withObject:dict afterDelay:10];
                        return;
                    }
                    
                    thread = [ThreadWrapper createThreadForGroup:g];
                }
                
                [ThreadWrapper incrementUnreadOnThread:thread];
                
                [MessageWrapper createNewMessageWithText:message andSender:sender andDate:[NSDate date] forThread:thread];
                
                [strongSelf saveTicket:options[@"ticket"]];
            }
        };
        [Outbox attachInbox:groupMessageInbox withPredicate:[NSPredicate predicateWithFormat:@"payload.groupMessage != nil"]];
        
        
#pragma mark - GroupIconInbox
        groupIconInbox = ^(NSMutableDictionary *payload, NSMutableDictionary *options, Outbox *outbox){
            NSLog(@"groupIconInbox Payload: %@. Options: %@", payload, options);
            
            __strong typeof(self) strongSelf = weakSelf;

            if (strongSelf)
            {
                NSString *sender = options[@"from"]; // The tag of the person who sent the message
                
                if ([sender isEqualToString:[[MyselfObject sharedInstance]getUserTag]]){
                    // I sent the message. Do nothing.
                    NSLog(@"groupIconInbox. I sent the message");
                    return;
                }
                
                NSString *group = options[@"to"]; // The group the message was sent to
                
                NSString *icon = payload[@"groupIcon"];
                
                Thread *thread = [ThreadWrapper fetchThreadForTag:group];
                
                if (!thread)
                {
                    NSLog(@"groupIconInbox - NO THREAD");
                    Group *g = [GroupWrapper fetchGroupWithTag:group];
                    
                    if (!g)
                    {
                        NSLog(@"groupIconInbox - NO GROUP");
                        [[OutboxHandler sharedInstance]checkGroups];
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                        [dict addEntriesFromDictionary:payload];
                        [dict addEntriesFromDictionary:options];
                        [strongSelf performSelector:@selector(retryGroupIconInbox:) withObject:dict afterDelay:10];
                        return;
                    }
                    
                    thread = [ThreadWrapper createThreadForGroup:g];
                }
                
                [ThreadWrapper incrementUnreadOnThread:thread];
                
                NSString *text = [NSString stringWithFormat:@"%@ %@", [[FriendWrapper fetchFriendWithTag:sender]getName], NSLocalizedString(@"iconSentText", @"Sent an icon")];
                
                [MessageWrapper createNewMessageWithIcon:icon andText:text andSender:sender andDate:[NSDate date] forThread:thread];
                
                [strongSelf saveTicket:options[@"ticket"]];
            }
        };
        [Outbox attachInbox:groupIconInbox withPredicate:[NSPredicate predicateWithFormat:@"payload.groupIcon != nil"]];
        

#pragma mark - GroupUpdatedInbox
        groupUpdatedInbox = ^(NSMutableDictionary *payload, NSMutableDictionary *options, Outbox *outbox){
            NSLog(@"groupUpdatedInbox Payload: %@. Options: %@", payload, options);
            
            NSString *groupTag = options[@"to"];
            
            [[GroupServer sharedInstance]getMembersForGroup:groupTag callback:^(NSArray *members) {
               
                NSLog(@"members: %@", members);
                
                if ([members count] != 0)
                {
                    Group *group = [GroupWrapper fetchGroupWithTag:groupTag];
                    
                    if (group)
                    {
                        [GroupWrapper checkMembers:members forGroup:group];
                    }
                    else
                    {
                        [[GroupServer sharedInstance]getNameForGroup:groupTag callback:^(NSString *name)
                        {
                            Group *newGroup = [GroupWrapper createGroupWithName:name ? : groupTag andTag:groupTag];
                            [GroupWrapper checkMembers:members forGroup:newGroup];
                        }];
                    }
                }
                else
                {
                    NSLog(@"groupUpdatedInbox - getMembersForGroup No member in group");
                }

                
            }];
            
            __strong typeof(self) strongSelf = weakSelf;

            if (strongSelf) {
                [strongSelf saveTicket:options[@"ticket"]];
            }
        };
        [Outbox attachInbox:groupUpdatedInbox withPredicate:[NSPredicate predicateWithFormat:@"payload.groupUpdated != nil"]];
        
        
#pragma mark - removedFromGroupInbox
        removedFromGroupInbox = ^(NSMutableDictionary *payload, NSMutableDictionary *options, Outbox *outbox){
            NSLog(@"removedFromGroupInbox Payload: %@. Options: %@", payload, options);
            
            NSString *groupTag = payload[@"removedFromGroup"];
            Group *group = [GroupWrapper fetchGroupWithTag:groupTag];
            if (group) {
                [GroupWrapper leaveGroup:group];
            }
            
            __strong typeof(self) strongSelf = weakSelf;
            
            if (strongSelf) {
                [strongSelf saveTicket:options[@"ticket"]];
            }
        };
        [Outbox attachInbox:removedFromGroupInbox withPredicate:[NSPredicate predicateWithFormat:@"payload.removedFromGroup != nil"]];
        
        
#pragma mark - groupNotifyChangedInbox
        groupNotifyChangedInbox = ^(NSMutableDictionary *payload, NSMutableDictionary *options, Outbox *outbox){
            NSLog(@"groupNotifyChangedInbox Payload: %@. Options: %@", payload, options);
            
            if ([options[@"from"] isEqualToString:[[MyselfObject sharedInstance]getUserTag]]) {
                NSLog(@"I sent the message");
                return;
            }
            
            NSString *groupTag = payload[@"groupNotifyChanged"];
            NSString *member = payload[@"member"];
            NSString *changedTo = payload[@"changedTo"];
            
            Group *group = [GroupWrapper fetchGroupWithTag:groupTag];
            Friend *friend = [FriendWrapper fetchFriendWithTag:member];
            
            if ([changedTo isEqualToString:@"notify"]) {
                [GroupWrapper removeMembersFromDoNotNotify:@[friend] onGroup:group];
            }else if ([changedTo isEqualToString:@"doNotNotify"]){
                [GroupWrapper addMembersToDoNotNotify:@[friend] onGroup:group];
            }
            
            __strong typeof(self) strongSelf = weakSelf;
            
            if (strongSelf) {
                [strongSelf saveTicket:options[@"ticket"]];
            }
        };
        [Outbox attachInbox:groupNotifyChangedInbox withPredicate:[NSPredicate predicateWithFormat:@"payload.groupNotifyChanged != nil"]];

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

-(void)saveTicket:(NSString*)ticket
{
    NSLog(@"Ticket: %@", ticket);
    [[NSUserDefaults standardUserDefaults]setObject:ticket forKey:@"lastTicket"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

#pragma mark - Retry inboxes

-(void)retryMessageInbox:(NSDictionary*)payload
{
    NSLog(@"retryMessageInbox Payload: %@", payload);
    
    NSString *sender = payload[@"from"];
    
    NSString *message = payload[@"message"];
    
    Thread *thread = [ThreadWrapper fetchThreadForTag:sender];
    
    if (!thread)
    {
        NSLog(@"retryMessageInbox - NO THREAD");
        
        Friend *friend = [FriendWrapper fetchFriendWithTag:sender];
        
        if (!friend)
        {
            NSLog(@"retryMessageInbox - NO FRIEND");
            return;
        }
        else
        {
            if ([friend deletedFriend])
            {
                NSLog(@"retryMessageInbox - DeletedFriend");
                return;
            }
        }
        
        thread = [ThreadWrapper createThreadForFriend:friend];
    }
    
    int unread = [[thread unread]intValue];
    unread++;
    [thread setUnread:[NSNumber numberWithInt:unread]];
    
    [MessageWrapper createNewMessageWithText:message andSender:sender andDate:[NSDate date] forThread:thread];
}

-(void)retryIconInbox:(NSDictionary*)dict
{
    NSLog(@"retryIconInbox dict: %@", dict);
    
    NSString *sender = dict[@"from"];
    
    NSString *icon = dict[@"icon"];
    
    Thread *thread = [ThreadWrapper fetchThreadForTag:sender];
    
    if (!thread)
    {
        NSLog(@"retryIconInbox - NO THREAD");
        
        Friend *friend = [FriendWrapper fetchFriendWithTag:sender];
        
        if (!friend)
        {
            NSLog(@"retryIconInbox - NO FRIEND");
            return;
        }
        else
        {
            if ([friend deletedFriend])
            {
                NSLog(@"retryIconInbox - DeletedFriend");
                return;
            }
        }
        
        thread = [ThreadWrapper createThreadForFriend:friend];
    }
    
    int unread = [[thread unread]intValue];
    unread++;
    [thread setUnread:[NSNumber numberWithInt:unread]];
    
    NSString *text = [NSString stringWithFormat:@"%@ %@", [[FriendWrapper fetchFriendWithTag:sender]getName], NSLocalizedString(@"iconSentText", @"Sent an icon")];
    
    [MessageWrapper createNewMessageWithIcon:icon andText:text andSender:sender andDate:[NSDate date] forThread:thread];
}

-(void)retryGroupMessageInbox:(NSDictionary*)dict
{
    NSLog(@"retryGroupMessageInbox dict: %@", dict);
    
    NSString *sender = dict[@"from"]; // The tag of the person who sent the message
    
    if ([sender isEqualToString:[[MyselfObject sharedInstance]getUserTag]]){
        // I sent the message. Do nothing.
        NSLog(@"retryGroupMessageInbox - I sent the message");
        return;
    }
    
    NSString *group = dict[@"to"]; // The group the message was sent to
    
    NSString *message = dict[@"groupMessage"];
    
    Thread *thread = [ThreadWrapper fetchThreadForTag:group];
    
    if (!thread) {
        NSLog(@"retryGroupMessageInbox - NO THREAD");
        Group *g = [GroupWrapper fetchGroupWithTag:group];
        
        if (!g) {
            NSLog(@"retryGroupMessageInbox - NO GROUP");
            return;
        }
        
        thread = [ThreadWrapper createThreadForGroup:g];
    }
    
    [ThreadWrapper incrementUnreadOnThread:thread];
    
    [MessageWrapper createNewMessageWithText:message andSender:sender andDate:[NSDate date] forThread:thread];
}

-(void)retryGroupIconInbox:(NSDictionary*)dict
{
    NSLog(@"retryGroupIconInbox dict: %@", dict);
    
    NSString *sender = dict[@"from"]; // The tag of the person who sent the message
    
    if ([sender isEqualToString:[[MyselfObject sharedInstance]getUserTag]]){
        // I sent the message. Do nothing.
        NSLog(@"groupIconInbox. I sent the message");
        return;
    }
    
    NSString *group = dict[@"to"]; // The group the message was sent to
    
    NSString *icon = dict[@"groupIcon"];
    
    Thread *thread = [ThreadWrapper fetchThreadForTag:group];
    
    if (!thread)
    {
        NSLog(@"retryGroupIconInbox - NO THREAD");
        Group *g = [GroupWrapper fetchGroupWithTag:group];
        
        if (!g)
        {
            NSLog(@"retryGroupIconInbox - NO GROUP");
            return;
        }
        
        thread = [ThreadWrapper createThreadForGroup:g];
    }
    
    [ThreadWrapper incrementUnreadOnThread:thread];
    
    NSString *text = [NSString stringWithFormat:@"%@ %@", [[FriendWrapper fetchFriendWithTag:sender]getName], NSLocalizedString(@"iconSentText", @"Sent an icon")];
    
    [MessageWrapper createNewMessageWithIcon:icon andText:text andSender:sender andDate:[NSDate date] forThread:thread];
}


@end