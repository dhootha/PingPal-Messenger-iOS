//
//  ManageGroupsViewController.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-12.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDelegate.h"
#import "DropViewController.h"
#import "ManagedObjectChangeListener.h"

@interface ManageGroupsViewController : UIViewController <DropDelegate, DropViewController, UIScrollViewDelegate, ChangeListener>

@end
