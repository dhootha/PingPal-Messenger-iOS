//
//  PPTableViewCell.m
//  PPChatTableView
//
//  Created by André Hansson on 03/06/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "PPChatTableViewCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface PPChatTableViewCell ()

@property (nonatomic, retain) UIView *customView;
//@property (nonatomic, retain) UIImageView *bubbleImage;
@property (nonatomic, retain) UIView *bubbleView;
@property (nonatomic, retain) UIImageView *avatarImage;

- (void) setupInternalData;

@end

@implementation PPChatTableViewCell

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
    
//    if (!self.bubbleImage)
//    {
//        self.bubbleImage = [[UIImageView alloc] init];
//
//        [self addSubview:self.bubbleImage];
//    }
    
    if (self.data.style != PPMessageStyleImage)
    {
        if (!self.bubbleView)
        {
            self.bubbleView = [[UIView alloc]init];
            [self.bubbleView.layer setCornerRadius:14];
            [self addSubview: self.bubbleView];
        }
    }
    else
    {
        if (self.bubbleView) {
            [self.bubbleView removeFromSuperview];
        }
    }
    
    PPMessageType type = self.data.type;
    
    CGFloat width = self.data.view.frame.size.width;
    CGFloat height = self.data.view.frame.size.height;
    
    CGFloat x = 0; //(type == PPMessageTypeSomeoneElse) ? 0 : self.frame.size.width - width - self.data.insets.left - self.data.insets.right;
    CGFloat y = 0;
    
    CGFloat bubbleX = 0;
    CGFloat bubbleY = 0;
    
    // Adjusting the x coordinate for avatar
    //if (self.showAvatar)
    if (self.showAvatar || (self.showOnlySomeoneElseAvatar && type == PPMessageTypeSomeoneElse))
    {
        
//        [self.avatarImage removeFromSuperview];
//        self.avatarImage = [[UIImageView alloc] initWithImage:(self.data.avatar ? self.data.avatar : [UIImage imageNamed:@"missingAvatar.png"])];
        
        if (!self.avatarImage) {
            self.avatarImage = [[UIImageView alloc]init];
        }
        [self.avatarImage setImage:(self.data.avatar ? self.data.avatar : [UIImage imageNamed:@"missingAvatar.png"])];


        self.avatarImage.layer.cornerRadius = 20.0;
        self.avatarImage.layer.masksToBounds = YES;
        self.avatarImage.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
        self.avatarImage.layer.borderWidth = 1.0;
        
        CGFloat avatarX = (type == PPMessageTypeSomeoneElse) ? 5 : self.frame.size.width - 45;
        CGFloat avatarY = 5;
        
        self.avatarImage.frame = CGRectMake(avatarX, avatarY, 40, 40);
        [self addSubview:self.avatarImage];
        
        // What was the use of delta?????
        //CGFloat delta = self.frame.size.height - (self.data.insets.top + self.data.insets.bottom + self.data.view.frame.size.height);
        //if (delta > 0) y = delta;
        
//        if (type == PPMessageTypeSomeoneElse) x += 34;
//        if (type == PPMessageTypeMine) x -= 54;
        
        bubbleX = avatarX+5;
        if (type == PPMessageTypeMine) bubbleX = avatarX - width - 15;
        bubbleY = avatarY+5;
    }
    
    [self.customView removeFromSuperview];
    self.customView = self.data.view;
    if (self.data.style != PPMessageStyleImage)
    {
        self.customView.frame = CGRectMake(x + self.data.insets.left, y + self.data.insets.top, width, height);
        [self.bubbleView addSubview: self.customView];
    }
    else
    {
        self.customView.frame = CGRectMake(0, 0, 320, 320);
        [self addSubview: self.customView];
    }
    
    
    if (self.data.style == PPMessageStyleText)
    {
        if (type == PPMessageTypeSomeoneElse)
        {
            //self.bubbleImage.image = [[UIImage imageNamed:@"bubbleSomeone.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(19.5, 19.5, 19.5, 19.5)];
            [self.bubbleView setBackgroundColor:[UIColor colorWithWhite:0.90 alpha:1]];
        }
        else {
            //self.bubbleImage.image = [[UIImage imageNamed:@"bubbleMine.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(19.5, 19.5, 19.5, 19.5)];
            [self.bubbleView setBackgroundColor:UIColorFromRGB(0x48BB90)];
        }
    }
    else if (self.data.style == PPMessageStyleIcon)
    {
        [self.bubbleView setBackgroundColor:[UIColor clearColor]];
    }
    
    //if (type == PPMessageTypeSomeoneElse) self.bubbleImage.frame = CGRectMake(bubbleX, bubbleY, width + self.data.insets.left, height + 20);
    if (type == PPMessageTypeSomeoneElse) self.bubbleView.frame = CGRectMake(bubbleX, bubbleY, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
    
    //if (type == PPMessageTypeMine) self.bubbleImage.frame = CGRectMake(bubbleX, bubbleY, width + self.data.insets.right, height + 20);
    if (type == PPMessageTypeMine) self.bubbleView.frame = CGRectMake(bubbleX, bubbleY, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
    
    if (self.bubbleView.frame.size.height < self.avatarImage.frame.size.height)
    {
        CGRect frame = self.bubbleView.frame;
        frame.origin.y = self.frame.size.height/2 - self.bubbleView.frame.size.height/2;
        self.bubbleView.frame = frame;
    }
}

@end
