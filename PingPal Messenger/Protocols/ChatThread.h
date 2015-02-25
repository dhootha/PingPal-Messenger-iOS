//
//  ChatThread.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-26.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChatThread <NSObject>

-(NSString*)getCellIdentifier;

-(NSString*)getSegueIdentifier;

-(NSString*)getName;

-(NSDate*)getLastDate;

-(NSString*)getLastMessage;

-(NSString*)getImageFilePath;

-(int)getUnread;

@end