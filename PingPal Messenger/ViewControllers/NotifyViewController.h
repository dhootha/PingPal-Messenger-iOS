//
//  NotifyViewController.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-04-02.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDelegate.h"
#import "Group.h"
#import "ManagedObjectChangeListener.h"

@interface NotifyViewController : UIViewController <DropDelegate, ChangeListener>

@property Group *group;

@end
