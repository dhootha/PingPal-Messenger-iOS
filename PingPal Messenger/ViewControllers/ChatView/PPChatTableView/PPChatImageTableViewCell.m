//
//  PPChatImageTableViewCell.m
//  PPChatTableView
//
//  Created by André Hansson on 09/06/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "PPChatImageTableViewCell.h"

@interface PPChatImageTableViewCell ()

@property (nonatomic, retain) UIView *customView;
@property (nonatomic, retain) UIImageView *avatarImage;

- (void) setupInternalData;

@end

@implementation PPChatImageTableViewCell

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
	[self setupInternalData];
}

- (void)setDataInternal:(PPMessageData *)value
{
	self.data = value;
	[self setupInternalData];
}

- (void) setupInternalData
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    PPMessageType type = self.data.type;
    
    if (self.showAvatar || (self.showOnlySomeoneElseAvatar && type == PPMessageTypeSomeoneElse))
    {
        [self.avatarImage removeFromSuperview];
        
        self.avatarImage = [[UIImageView alloc] initWithImage:(self.data.avatar ? self.data.avatar : [UIImage imageNamed:@"missingAvatar.png"])];
        
        self.avatarImage.layer.cornerRadius = 20.5;
        self.avatarImage.layer.masksToBounds = YES;
        self.avatarImage.layer.borderColor = [UIColor whiteColor].CGColor;
        self.avatarImage.layer.borderWidth = 1.0;
        
        CGFloat avatarX = (type == PPMessageTypeSomeoneElse) ? 5 : self.frame.size.width - 45;
        CGFloat avatarY = 5 + self.data.insets.top;
        
        self.avatarImage.frame = CGRectMake(avatarX, avatarY, 41, 41);
        [self addSubview:self.avatarImage];
    }
    
    [self.customView removeFromSuperview];
    self.customView = self.data.view;
    
    CGRect frame = self.customView.frame;
    frame.origin.y = self.data.insets.top;
    frame.origin.x = (type == PPMessageTypeSomeoneElse ? 0 : self.frame.size.width-320);
    self.customView.frame = frame;
        
    [self.contentView addSubview:self.customView];
}


@end