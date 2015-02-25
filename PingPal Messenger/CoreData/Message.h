//
//  Message.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-31.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MessageItem.h"

typedef enum Types : int16_t{
    typeText = 0,
    typeImage = 1,
    typeIcon = 2,
    typeLocation = 3
}Type;

@class Thread;

@interface Message : NSManagedObject <MessageItem>

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * senderTag;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * location;
@property (nonatomic) Type messageType;
@property (nonatomic, retain) Thread *thread;

@end
