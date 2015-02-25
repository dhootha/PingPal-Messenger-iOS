//
//  Message.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-31.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "Message.h"
#import "Thread.h"


@implementation Message

@dynamic date;
@dynamic senderTag;
@dynamic text;
@dynamic icon;
@dynamic location;
@dynamic messageType;
@dynamic thread;

-(NSDate *)getDate{
    return self.date;
}

-(NSString *)getSenderTag{
    return self.senderTag;
}

-(NSString *)getText{
    return self.text;
}

-(int16_t)getMessageType{
    return self.messageType;
}

-(NSString *)getIcon{
    return  self.icon;
}

-(NSString *)getLocation{
    return self.location;
}

@end
