//
//  GroupChatViewController.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-18.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "GroupChatViewController.h"
#import "NotifyViewController.h"
#import "MessageWrapper.h"
#import "MyselfObject.h"
#import "Push.h"
#import "DoNotNotify.h"

#import <PPLocationManager/Outbox.h>

@interface GroupChatViewController (){
    NSPredicate *writing;
    NSPredicate *notWriting;

    Inbox dataWritingInbox;
    Inbox dataNotWritingInbox;
}

@end

@implementation GroupChatViewController

#pragma mark - Inbox

-(void)setupWritingInboxes
{
    writing = [NSPredicate predicateWithFormat:@"payload.writing == 1"];
    notWriting = [NSPredicate predicateWithFormat:@"payload.writing == 0"];
    
    dataWritingInbox = ^(NSMutableDictionary *payload, NSMutableDictionary *options, Outbox *outbox){
        NSLog(@"groupChatViewController - dataWritingInbox Payload: %@. Options: %@", payload, options);
        
            // If it's to the group, and not sent by me
            if ([options[@"to"] isEqualToString:[super.chatViewItem getTag]] && ![options[@"from"]isEqualToString:[[MyselfObject sharedInstance]getUserTag]])
            {
                super.bubbleTable.typingBubble = PPTypingTypeSomebody;
                [super.bubbleTable reloadData];
                [super.bubbleTable scrollBubbleViewToBottomAnimated:YES];
            }
    };
    
    dataNotWritingInbox = ^(NSMutableDictionary *payload, NSMutableDictionary *options, Outbox *outbox){
        NSLog(@"groupChatViewController - dataNotWritingInbox Payload: %@. Options: %@", payload, options);
        
            // If it's to the group, and not sent by me
            if ([options[@"to"] isEqualToString:[super.chatViewItem getTag]] && ![options[@"from"]isEqualToString:[[MyselfObject sharedInstance]getUserTag]])
            {
                super.bubbleTable.typingBubble = PPTypingTypeNobody;
                [super.bubbleTable reloadData];
                [super.bubbleTable scrollBubbleViewToBottomAnimated:YES];
            }
    };
}

-(void)addWritingInboxes
{
    [Outbox attachInbox:dataWritingInbox withPredicate:writing];
    [Outbox attachInbox:dataNotWritingInbox withPredicate:notWriting];
}

-(void)removeWritingInboxes
{
    [Outbox detachInbox:dataWritingInbox withPredicate:writing];
    [Outbox detachInbox:dataNotWritingInbox withPredicate:notWriting];
}


#pragma mark - AHChatBarViewDelegate

-(void)chatBarViewDidPressButton:(NSString *)chatTextViewText
{
    // Override to send with groupMessage instead of message
    Group *group = (Group*)[super.chatViewItem getGroup];
    
    // Push
    NSString *myName = [[MyselfObject sharedInstance]getName];
    NSString *groupName = [group getName];
    NSString *alert = [[NSString alloc]initWithFormat:@"%@: %@: %@", groupName, myName, chatTextViewText];

    NSDictionary *push;
    
    if ([[[group doNotNotify]doNotNotifyMembers]count] == 0) {
        push = [Push createPushForMessageWithAlert:alert andThread:[super.chatViewItem getTag]];
    }else{
        push = [Push createSilentPushForMessageWithAlert:alert andThread:[super.chatViewItem getTag]];
    }
    
    // Send message
    [Outbox put:[super.chatViewItem getTag] withPayload:@{@"groupMessage":chatTextViewText} andOptions:@{@"push":push}];
    
    // Create local
    [MessageWrapper createNewMessageWithText:chatTextViewText andSender:[[MyselfObject sharedInstance]getUserTag] andDate:[NSDate date] forThread:super.chatViewItem];
    
    super.indicatorSent = NO;
}

-(void)iconChooserDidSelectIcon:(NSString *)icon
{
    NSLog(@"iconChooserDidSelectIcon: %@", icon);
    
    Group *group = (Group*)[super.chatViewItem getGroup];
    
    NSString *myName = [[MyselfObject sharedInstance]getName];
    NSString *groupName = [group getName];
    
    NSDictionary *alert = @{
                            @"loc-key" : @"iconSentPushText",
                            @"loc-args" : @[[NSString stringWithFormat:@"%@: %@", groupName, myName]]
                            };
    
    NSDictionary *push;
    
    if ([[[group doNotNotify]doNotNotifyMembers]count] == 0) {
        push = [Push createPushForMessageWithAlert:alert andThread:[super.chatViewItem getTag]];
    }else{
        push = [Push createSilentPushForMessageWithAlert:alert andThread:[super.chatViewItem getTag]];
    }
    
    // Send message
    [Outbox put:[super.chatViewItem getTag] withPayload:@{@"groupIcon":icon} andOptions:@{@"push":push}];
    
    NSString *text = [NSString stringWithFormat:@"%@ %@", myName, NSLocalizedString(@"iconSentText", @"Sent an icon")];

    // Create local
    [MessageWrapper createNewMessageWithIcon:icon andText:text andSender:[[MyselfObject sharedInstance]getUserTag] andDate:[NSDate date] forThread:super.chatViewItem];
    
    super.indicatorSent = NO;
    
    [super removeIconView];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueToNotifyView"])
    {
        NotifyViewController *NVC = [segue destinationViewController];
        [NVC setGroup:(Group*)[super.chatViewItem getGroup]];
    }
}

@end