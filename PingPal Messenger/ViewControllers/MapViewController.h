//
//  MapViewController.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-04-04.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <PPLocationManager/Outbox.h>

@interface MapViewController : UIViewController

@property (nonatomic, copy) Inbox pingInbox;

//-(void)pingInbox:(NSDictionary*)dict;

@end