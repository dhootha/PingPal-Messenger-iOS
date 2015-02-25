//
//  Push.m
//  PingPal Messenger
//
//  Created by André Hansson on 28/07/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "Push.h"

@implementation Push

+(NSDictionary *)createPushForMessageWithAlert:(id)alert andThread:(NSString *)thread
{
    NSDictionary *push = @{@"mode": @"fallback",
                           @"apns": @{
                                   @"message":@0,
                                   @"expire":@604800,
                                   @"data":@{
                                           @"aps": @{
                                                   @"alert":alert,
                                                   @"sound":@"default",
                                                   @"content-available":@1
                                                   },
                                           @"thread":thread}
                                   },
                           @"gcm": @{
                                   @"data":@{
                                           }
                                   }
                           };
    
    return push;
}

+(NSDictionary *)createPushForPingWithName:(NSString *)name
{
    NSDictionary *push = @{@"mode": @"fallback",
                           @"apns": @{
                                   @"message":@0,
                                   @"expire":@604800,
                                   @"data":@{
                                           @"aps": @{
                                                   @"alert":@{
                                                           @"loc-key" : @"pingPushText",
                                                           @"loc-args" : @[name]
                                                           },
                                                   @"sound":@"default"}
                                           }
                                   },
                           @"gcm": @{
                                   @"data":@{
                                           }
                                   }
                           };
    
    return push;
}

+(NSDictionary *)createPushForPingWithName:(NSString *)name andExtraData:(NSDictionary *)extraData
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc]initWithDictionary:@{@"aps": @{
                                                                                         @"alert":@{
                                                                                                 @"loc-key" : @"pingPushText",
                                                                                                 @"loc-args" : @[name]
                                                                                                 },
                                                                                         @"sound":@"default"
                                                                                         }
                                                                                 }];
    [data addEntriesFromDictionary:extraData];
    
    NSDictionary *push = @{@"mode": @"fallback",
                           @"apns": @{
                                   @"message":@0,
                                   @"expire":@604800,
                                   @"data":data
                                   },
                           @"gcm": @{
                                   @"data":@{
                                           }
                                   }
                           };
    
    return push;
}


+(NSDictionary *)createSilentPushForMessageWithAlert:(id)alert andThread:(NSString *)thread
{
    NSDictionary *push = @{@"mode": @"fallback",
                           @"apns": @{
                                   @"message":@0,
                                   @"expire":@604800,
                                   @"data":@{
                                           @"aps": @{
                                                   @"content-available":@1,
                                                   @"sound":@""
                                                   },
                                           @"thread":thread,
                                           @"alert":alert
                                           }
                                   },
                           @"gcm": @{
                                   @"data":@{
                                           }
                                   }
                           };
    
    return push;
}

+(NSDictionary *)createSilentPushForPingWithName:(NSString *)name
{
    NSDictionary *push = @{@"mode": @"fallback",
                           @"apns": @{
                                   @"message":@0,
                                   @"expire":@604800,
                                   @"data":@{
                                           @"aps": @{
                                                   @"content-available":@1,
                                                   @"sound":@""}
                                           },
                                   @"alert":@{
                                           @"loc-key" : @"pingPushText",
                                           @"loc-args" : @[name]
                                           }
                                   },
                           @"gcm": @{
                                   @"data":@{
                                           }
                                   }
                           };
    
    return push;
}

+(NSDictionary *)createSilentPushForPingWithName:(NSString *)name andExtraData:(NSDictionary *)extraData
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc]initWithDictionary:@{@"aps": @{
                                                                                         @"content-available":@1,
                                                                                         @"sound":@""
                                                                                         }
                                                                                 }];
    [data addEntriesFromDictionary:@{@"alert":@{
                                            @"loc-key" : @"pingPushText",
                                            @"loc-args" : @[name]
                                            }
                                     }];
    
    [data addEntriesFromDictionary:extraData];
    
    NSDictionary *push = @{@"mode": @"fallback",
                           @"apns": @{
                                   @"message":@0,
                                   @"expire":@604800,
                                   @"data":data
                                   },
                           @"gcm": @{
                                   @"data":@{
                                           }
                                   }
                           };
    
    return push;
}



@end