//
//  DeletedGroup.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-04-23.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group;

@interface DeletedGroup : NSManagedObject

@property (nonatomic, retain) Group *theGroup;

@end
