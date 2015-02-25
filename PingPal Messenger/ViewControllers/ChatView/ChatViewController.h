//
//  ChatViewController.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-13.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPChatTableView.h"
#import "AHChatBarViewController.h"
#import "ChatViewItem.h"
#import "ManagedObjectChangeListener.h"
#import "IconChooserViewController.h"

#import <PPLocationManager/Outbox.h>

@interface ChatViewController : UIViewController <PPChatTableViewDataSource, PPChatTableViewDelegate, AHChatBarViewControllerDelegate, ChangeListener, iconChooserDelegate>

@property (weak, nonatomic) IBOutlet PPChatTableView *bubbleTable;

@property NSObject<ChatViewItem> *chatViewItem;

@property BOOL indicatorSent;

-(void)setupWritingInboxes;
-(void)addWritingInboxes;
-(void)removeWritingInboxes;

-(void)removeIconView;

@end
