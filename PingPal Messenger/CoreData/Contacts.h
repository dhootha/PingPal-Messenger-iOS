//
//  Contacts.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-20.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friend;

@interface Contacts : NSManagedObject

@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * imageFileName;
@property (nonatomic, retain) Friend *friend;

@end
