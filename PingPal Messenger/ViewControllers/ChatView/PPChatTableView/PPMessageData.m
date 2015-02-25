//
//  PPMessageData.m
//  PPChatTableView
//
//  Created by André Hansson on 03/06/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "PPMessageData.h"

@implementation PPMessageData

#pragma mark - Text

const UIEdgeInsets textInsetsMine = {5, 10, 5, 40};
const UIEdgeInsets textInsetsSomeone = {5, 40, 5, 10};

+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(PPMessageType)type
{
    return [[PPMessageData alloc] initWithText:text date:date type:type];
}

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(PPMessageType)type
{
    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:font forKey: NSFontAttributeName];
    CGSize size = [(text ? text : @"") boundingRectWithSize:CGSizeMake(220, 9999) // Max width, height
                                                     options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:stringAttributes context:nil].size;
        
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = (text ? text : @"");
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    
    if (type == PPMessageTypeMine)
    {
        label.textColor = [UIColor whiteColor];
    }
    
    UIEdgeInsets insets = (type == PPMessageTypeMine ? textInsetsMine : textInsetsSomeone);
    return [self initWithView:label date:date type:type style:PPMessageStyleText insets:insets];
}


#pragma mark - Image

const UIEdgeInsets imageInsets = {10, 0, 10, 0};

+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(PPMessageType)type
{
    return [[PPMessageData alloc] initWithImage:image date:date type:type];
}

- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(PPMessageType)type
{
    CGSize size = image.size;
    
    if (size.width > 320)
    {
        size.height /= (size.width / 320);
        size.width = 320;
    }
 
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    imageView.image = image;
    
    CGRect holderFrame;
    holderFrame.origin.x = 0;
    holderFrame.origin.y = 0;
    holderFrame.size.width = 320;
    
    if (size.height < 200) {
        holderFrame.size.height = size.height;
    }else{
        holderFrame.size.height = 200;
    }
    
    UIView *holderView = [[UIView alloc]initWithFrame:holderFrame];
    [holderView setClipsToBounds:YES];
        
    [holderView addSubview:imageView];
    [imageView setCenter:holderView.center];
    
    return [self initWithView:holderView date:date type:type style:PPMessageStyleImage insets:imageInsets];
}


#pragma mark - Ikon

const UIEdgeInsets iconInsetsMine = {5, 0, 5, 40};
const UIEdgeInsets iconInsetsSomeone = {5, 40, 5, 0};

+(id)dataWithIcon:(UIImage *)icon date:(NSDate *)date type:(PPMessageType)type
{
    return [[PPMessageData alloc]initWithIcon:icon date:date type:type];
}

-(id)initWithIcon:(UIImage *)icon date:(NSDate *)date type:(PPMessageType)type
{
    CGSize size = icon.size;
    
    if (size.width > 220)
    {
        size.height /= (size.width / 220);
        size.width = 220;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    imageView.image = icon;
    
    UIEdgeInsets insets = (type == PPMessageTypeMine ? iconInsetsMine : iconInsetsSomeone);
    
    return [self initWithView:imageView date:date type:type style:PPMessageStyleIcon insets:insets];
}

#pragma mark - Custom view

+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(PPMessageType)type style:(PPMessageStyle)style insets:(UIEdgeInsets)insets
{
    return [[PPMessageData alloc] initWithView:view date:date type:type style:style insets:insets];
}

- (id)initWithView:(UIView *)view date:(NSDate *)date type:(PPMessageType)type style:(PPMessageStyle)style insets:(UIEdgeInsets)insets
{
    self = [super init];
    if (self)
    {
        _view = view;
        _date = date;
        _type = type;
        _style = style;
        _insets = insets;
    }
    return self;
}

@end