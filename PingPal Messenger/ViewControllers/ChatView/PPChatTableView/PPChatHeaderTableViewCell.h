//
//  PPChatHeaderTableViewCell.h
//  PPChatTableView
//
//  Created by André Hansson on 03/06/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPChatHeaderTableViewCell : UITableViewCell

+ (CGFloat)height;

@property (nonatomic, strong) NSDate *date;

@end
