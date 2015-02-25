//
//  PPChatTypingTableViewCell.m
//  PPChatTableView
//
//  Created by André Hansson on 03/06/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "PPChatTypingTableViewCell.h"

@interface PPChatTypingTableViewCell ()

@property (nonatomic, retain) UIImageView *typingImageView;

@end

@implementation PPChatTypingTableViewCell

+ (CGFloat)height
{
    return 40.0;
}

- (void)setType:(PPTypingType)value
{
    if (!self.typingImageView)
    {
        self.typingImageView = [[UIImageView alloc] init];
        [self addSubview:self.typingImageView];
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImage *bubbleImage = nil;
    CGFloat x = 0;
    
    if (value == PPTypingTypeMe)
    {
        bubbleImage = [UIImage imageNamed:@"typingMine.png"];
        x = self.frame.size.width - bubbleImage.size.width;
    }
    else
    {
        bubbleImage = [UIImage imageNamed:@"typingSomeone.png"];
        x = 0;
    }
    
    self.typingImageView.image = bubbleImage;
    self.typingImageView.frame = CGRectMake(x, 4, 73, 31);
}

@end