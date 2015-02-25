//
//  MyselfObject.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-20.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionItem.h"

@interface MyselfObject : NSObject <CollectionItem>

+ (id)sharedInstance;


// Name

-(void)setFirstName:(NSString*)firstName;

-(void)setLastName:(NSString*)lastName;

//-(NSString*)getFirstName;  already in CollectionItem

-(NSString*)getLastName;

-(NSString*)getName; // Full name


// Image

-(void)setImageFileName:(NSString*)imageFileName;

-(NSString*)getImageFileName;

//-(NSString*)getImageFilePath;  already in CollectionItem


// Tag

-(void)setUserTag:(NSString*)tag;

-(NSString*)getUserTag;

-(void)setDeviceTag:(NSString*)tag;

-(NSString*)getDeviceTag;


// Facebook ID

-(void)setFBID:(NSString*)fbid;

-(NSString*)getFBID;


@end