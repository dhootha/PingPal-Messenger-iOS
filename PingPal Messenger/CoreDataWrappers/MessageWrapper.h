//
//  MessageWrapper.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-31.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Friend.h"
#import "Group.h"
#import "Message.h"

@interface MessageWrapper : NSObject

// Text
+(void)createNewMessageWithText:(NSString *)text andSender:(NSString *)senderTag andDate:(NSDate *)date forThread:(NSObject*)thread;

// Icon
+(void)createNewMessageWithIcon:(NSString*)icon andText:(NSString*)text andSender:(NSString*)senderTag andDate:(NSDate*)date forThread:(NSObject*)thread;

// Location
+(void)createNewMessageWithLocation:(NSString*)location andText:(NSString*)text andSender:(NSString*)senderTag andDate:(NSDate*)date forThread:(NSObject*)thread;

@end