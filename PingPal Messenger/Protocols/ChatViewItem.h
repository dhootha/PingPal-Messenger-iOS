//
//  ChatViewItem.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-26.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChatViewItem <NSObject>

// Returna all the messages in the thread sorted by date
-(NSArray*)getMessages;

-(NSObject*)getGroup;

-(NSString*)getTag;

-(NSObject*)getFriend;


@end