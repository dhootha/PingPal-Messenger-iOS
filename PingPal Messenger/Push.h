//
//  Push.h
//  PingPal Messenger
//
//  Created by André Hansson on 28/07/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Push : NSObject

+(NSDictionary*)createPushForMessageWithAlert:(id)alert andThread:(NSString*)thread;

+(NSDictionary*)createPushForPingWithName:(NSString*)name;

+(NSDictionary*)createPushForPingWithName:(NSString *)name andExtraData:(NSDictionary*)extraData;


+(NSDictionary*)createSilentPushForMessageWithAlert:(id)alert andThread:(NSString*)thread;

+(NSDictionary*)createSilentPushForPingWithName:(NSString*)name;

+(NSDictionary*)createSilentPushForPingWithName:(NSString *)name andExtraData:(NSDictionary*)extraData;


@end