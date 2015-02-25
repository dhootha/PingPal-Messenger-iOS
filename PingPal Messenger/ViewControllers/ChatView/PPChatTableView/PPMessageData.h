//
//  PPMessageData.h
//  PPChatTableView
//
//  Created by André Hansson on 03/06/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    PPMessageTypeMine,
    PPMessageTypeSomeoneElse
} PPMessageType;

typedef enum {
    PPMessageStyleText,
    PPMessageStyleImage,
    PPMessageStyleIcon,
    PPMessageStyleMap
} PPMessageStyle;

@interface PPMessageData : NSObject

@property (readonly, nonatomic, strong) NSDate *date;
@property (readonly, nonatomic) PPMessageType type;
@property (readonly, nonatomic) PPMessageStyle style;
@property (readonly, nonatomic, strong) UIView *view;
@property (readonly, nonatomic) UIEdgeInsets insets;
@property (nonatomic, strong) UIImage *avatar;

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(PPMessageType)type;
+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(PPMessageType)type;
- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(PPMessageType)type;
+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(PPMessageType)type;
- (id)initWithIcon:(UIImage *)icon date:(NSDate *)date type:(PPMessageType)type;
+ (id)dataWithIcon:(UIImage *)icon date:(NSDate *)date type:(PPMessageType)type;
- (id)initWithView:(UIView *)view date:(NSDate *)date type:(PPMessageType)type style:(PPMessageStyle)style insets:(UIEdgeInsets)insets;
+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(PPMessageType)type style:(PPMessageStyle)style insets:(UIEdgeInsets)insets;

@end