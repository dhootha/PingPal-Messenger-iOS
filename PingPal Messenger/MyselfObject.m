//
//  MyselfObject.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-20.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "MyselfObject.h"

static MyselfObject *sharedInstance = nil;

@implementation MyselfObject

-(id)init{
    self = [super init];
    if (self) {

    }
    return self;
}

+(id)sharedInstance{
    if (sharedInstance == nil)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}


#pragma mark - Name

-(void)setFirstName:(NSString *)firstName{
    [[NSUserDefaults standardUserDefaults]setObject:firstName forKey:@"myFirstName"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(NSString *)getFirstName{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"myFirstName"];
}

-(void)setLastName:(NSString *)lastName{
    [[NSUserDefaults standardUserDefaults]setObject:lastName forKey:@"myLastName"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(NSString *)getLastName{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"myLastName"];
}

-(NSString *)getName{
    return [NSString stringWithFormat:@"%@ %@", [self getFirstName], [self getLastName]];
}


#pragma mark - Image

-(void)setImageFileName:(NSString *)imageFileName{
    [[NSUserDefaults standardUserDefaults]setObject:imageFileName forKey:@"myImageFileName"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(NSString *)getImageFileName{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"myImageFileName"];
}

-(NSString *)getImageFilePath
{
    NSString *imageFileName = [self getImageFileName];

    if (!imageFileName) {
        NSLog(@"MyselfObject getImageFilePath - No imageFileName");
    }
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * jpegFilePath = [docDir stringByAppendingPathComponent:imageFileName];
    
    return jpegFilePath;
}


#pragma mark - Tag

-(void)setUserTag:(NSString *)tag{
    [[NSUserDefaults standardUserDefaults]setObject:tag forKey:@"myTag"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(NSString *)getUserTag{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"myTag"];
}

-(void)setDeviceTag:(NSString *)tag{
    [[NSUserDefaults standardUserDefaults]setObject:tag forKey:@"myDeviceTag"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(NSString *)getDeviceTag{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"myDeviceTag"];
}


#pragma mark - FacebookID

-(void)setFBID:(NSString *)fbid{
    [[NSUserDefaults standardUserDefaults]setObject:fbid forKey:@"myFBID"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(NSString *)getFBID{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"myFBID"];
}


@end