//
//  FacebookConnector.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-04-03.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@protocol fbLoginStatusListener;

@interface FacebookConnector : NSObject <FBLoginViewDelegate>

@property NSObject <fbLoginStatusListener> *loginListener;


+(id)sharedInstance;

-(void)checkFriends;

-(void)matchFriends;

@end



@protocol fbLoginStatusListener <NSObject>

@required
-(void)loggedIn;
-(void)loggedOut;
-(void)loggedInWithName:(NSString*)name andID:(NSString*)id;

@end