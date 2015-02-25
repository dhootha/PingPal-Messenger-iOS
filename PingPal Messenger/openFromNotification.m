//
//  openFromNotification.m
//  PingPal Messenger
//
//  Created by André Hansson on 23/07/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "openFromNotification.h"

@implementation openFromNotification

static NSString *TAG = NULL;

+(void)openWithTag:(NSString *)tag{
    NSLog(@"openWithTag: %@", tag);
    TAG = tag;
}

+(BOOL)shouldOpen{
    NSLog(@"shouldOpen: %@", TAG ? @"YES" : @"NO");
    if (TAG) {
        return YES;
    }else{
        return NO;
    }
}

+(NSString *)TagToOpen{
    NSLog(@"TagToOpen: %@", TAG);
    return TAG;
}

@end
