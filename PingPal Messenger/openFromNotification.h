//
//  openFromNotification.h
//  PingPal Messenger
//
//  Created by André Hansson on 23/07/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface openFromNotification : NSObject

+(void)openWithTag:(NSString*)tag;

+(BOOL)shouldOpen;

+(NSString*)TagToOpen;

@end