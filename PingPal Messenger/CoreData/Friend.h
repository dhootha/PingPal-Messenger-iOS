//
//  Friend.h
//  PingPal Messenger
//
//  Created by André Hansson on 15/09/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CollectionItem.h"
#import "TableItem.h"

typedef enum Access : int16_t{
    accessNo = 0,
    accessYes = 1,
    accessAsk = 2
}Access;


@class CFacebook, Contacts, DeletedFriend, DoNotNotify, Group, Thread;

@interface Friend : NSManagedObject <CollectionItem, TableItem>

@property (nonatomic, retain) NSString * tag;
@property (nonatomic) Access pingAccess;
@property (nonatomic, retain) Contacts *contact;
@property (nonatomic, retain) DeletedFriend *deletedFriend;
@property (nonatomic, retain) NSSet *doNotNotify;
@property (nonatomic, retain) CFacebook *facebook;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) Thread *thread;
@end

@interface Friend (CoreDataGeneratedAccessors)

- (void)addDoNotNotifyObject:(DoNotNotify *)value;
- (void)removeDoNotNotifyObject:(DoNotNotify *)value;
- (void)addDoNotNotify:(NSSet *)values;
- (void)removeDoNotNotify:(NSSet *)values;

- (void)addGroupsObject:(Group *)value;
- (void)removeGroupsObject:(Group *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

@end
