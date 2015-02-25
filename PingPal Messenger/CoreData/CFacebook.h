//
//  Facebook.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-20.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friend;

@interface CFacebook : NSManagedObject

@property (nonatomic, retain) NSString * fbid;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * imageFileName;
@property (nonatomic, retain) Friend *friend;

@end
