//
//  Group.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-04-02.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TableItem.h"

@class DoNotNotify, Friend, Thread;

@interface Group : NSManagedObject <TableItem>

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSNumber * notifyMe;
@property (nonatomic, retain) NSSet *members;
@property (nonatomic, retain) Thread *thread;
@property (nonatomic, retain) NSManagedObject *deletedGroup;
@property (nonatomic, retain) DoNotNotify *doNotNotify;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addMembersObject:(Friend *)value;
- (void)removeMembersObject:(Friend *)value;
- (void)addMembers:(NSSet *)values;
- (void)removeMembers:(NSSet *)values;

@end
