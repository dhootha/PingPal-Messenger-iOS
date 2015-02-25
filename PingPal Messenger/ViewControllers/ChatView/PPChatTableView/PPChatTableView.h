//
//  PPChatTableView.h
//  PPChatTableView
//
//  Created by André Hansson on 03/06/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPMessageData.h"

@protocol PPChatTableViewDataSource;
@protocol PPChatTableViewDelegate;

typedef enum {
    PPTypingTypeNobody,
    PPTypingTypeMe,
    PPTypingTypeSomebody
} PPTypingType;


@interface PPChatTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) IBOutlet id<PPChatTableViewDataSource> PPDataSource;
@property (nonatomic, assign) IBOutlet id<PPChatTableViewDelegate> PPDelegate;
@property (nonatomic) NSTimeInterval snapInterval;
@property (nonatomic) PPTypingType typingBubble;
@property (nonatomic) BOOL showAvatars;
@property (nonatomic) BOOL showOnlySomeoneElseAvatar;

- (void) scrollBubbleViewToBottomAnimated:(BOOL)animated;

@end


@protocol PPChatTableViewDataSource <NSObject>

@optional

@required

- (NSInteger)rowsForChatTable:(PPChatTableView *)tableView;
- (PPMessageData *)chatTableView:(PPChatTableView *)tableView dataForRow:(NSInteger)row;

@end


@protocol PPChatTableViewDelegate <NSObject>

@optional

@required

-(void)chatTableViewDidSelectRowWithData:(PPMessageData*)data;

@end


