//
//  GroupsTableViewController.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-18.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupCell.h"
#import "ManagedObjectChangeListener.h"

@interface GroupsTableViewController : UITableViewController <SWTableViewCellDelegate, ChangeListener> //UIActionSheetDelegate

@end
