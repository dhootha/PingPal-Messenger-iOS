//
//  MessageItem.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-26.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MessageItem <NSObject>

-(NSDate*)getDate;

-(NSString*)getSenderTag;

-(NSString*)getText;

-(int16_t)getMessageType;

-(NSString*)getIcon;

-(NSString*)getLocation;

@end