//
//  GroupCollectionViewController.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-20.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "CollectionViewController.h"
#import "Group.h"

@interface GroupCollectionViewController : CollectionViewController

@property Group *group;

-(NSString*)getName;

@end