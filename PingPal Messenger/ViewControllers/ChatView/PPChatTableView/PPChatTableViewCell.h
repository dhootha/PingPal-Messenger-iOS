//
//  PPTableViewCell.h
//  PPChatTableView
//
//  Created by André Hansson on 03/06/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPMessageData.h"

@interface PPChatTableViewCell : UITableViewCell

@property (nonatomic, strong) PPMessageData *data;
@property (nonatomic) BOOL showAvatar;
@property (nonatomic) BOOL showOnlySomeoneElseAvatar;

@end