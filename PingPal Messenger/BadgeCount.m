//
//  BadgeCount.m
//  PingPal Messenger
//
//  Created by André Hansson on 06/05/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "BadgeCount.h"
#import "ThreadWrapper.h"

@implementation BadgeCount

+(void)checkBadgeCount
{
    int bc = 0;
    
    NSArray *threads = [ThreadWrapper fetchAllThreads];
    
    for (Thread *thread in threads)
    {
        bc += [thread.unread intValue];
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = bc;
}

@end