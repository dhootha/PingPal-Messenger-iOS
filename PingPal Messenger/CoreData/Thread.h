//
//  Thread.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-04-22.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "ChatThread.h"
#import "ChatViewItem.h"

@class Friend, Group, Message;

@interface Thread : NSManagedObject<ChatThread, ChatViewItem>

@property (nonatomic, retain) NSNumber * unread;
@property (nonatomic, retain) Friend *friend;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) NSMutableSet *messages;
@end

@interface Thread (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end