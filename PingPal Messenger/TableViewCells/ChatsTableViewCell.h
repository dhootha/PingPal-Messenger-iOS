//
//  ChatsTableViewCell.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-18.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "SWTableViewCell.h"

@interface ChatsTableViewCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UIView *unreadView;

@property (weak, nonatomic) IBOutlet UILabel *unreadLabel;

@end