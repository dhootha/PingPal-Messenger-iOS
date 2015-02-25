//
//  PPChatTypingTableViewCell.h
//  PPChatTableView
//
//  Created by André Hansson on 03/06/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPChatTableView.h"

@interface PPChatTypingTableViewCell : UITableViewCell

+ (CGFloat)height;

@property (nonatomic) PPTypingType type;
@property (nonatomic) BOOL showAvatar;

@end
