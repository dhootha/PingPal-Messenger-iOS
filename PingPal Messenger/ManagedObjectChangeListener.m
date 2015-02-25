//
//  ManagedObjectChangeListener.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-04-01.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "ManagedObjectChangeListener.h"
#import "Group.h"
#import "DeletedGroup.h"
#import "Friend.h"
#import "DeletedFriend.h"
#import "Thread.h"
#import "Message.h"
#import "DoNotNotify.h"

static ManagedObjectChangeListener *sharedInstance = nil;

@implementation ManagedObjectChangeListener{
    NSMutableArray *changeListeners;
}

-(id)init{
    self = [super init];
    if (self)
    {
        // NSManagedObjectContextObjectsDidChange notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NSManagedObjectContextObjectsDidChange:) name: NSManagedObjectContextObjectsDidChangeNotification object:nil];
        
        changeListeners = [[NSMutableArray alloc]init];
    }
    return self;
}

+(id)sharedInstance{
    if (sharedInstance == nil)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

-(void)addChangeListener:(NSObject<ChangeListener> *)listener{
    [changeListeners addObject:listener];
}

-(void)removeChangeListener:(NSObject<ChangeListener> *)listener{
    [changeListeners removeObject:listener];
}

-(void)NSManagedObjectContextObjectsDidChange: (NSNotification *)notification
{
    //NSLog(@"NSManagedObjectContextObjectsDidChange: %@", notification);
    
    if ([notification.userInfo objectForKey:NSInsertedObjectsKey])
    {
        //NSLog(@"Inserted");
        NSArray *arr = [[notification.userInfo objectForKey:NSInsertedObjectsKey] allObjects];
        //NSLog(@"Inserted objects: %@", arr);
        for (NSObject *obj in arr)
        {
            if ([obj isKindOfClass:[Group class]])
            {
                NSLog(@"New group created. Name: %@", [(Group*)obj getName]);
                // A group was created
                [self notifyChangeWithKey:kNewGroup];
            }
            else if ([obj isKindOfClass:[Friend class]])
            {
                NSLog(@"New friend created. Name: %@", [(Friend*)obj getName]);
                // A friend was created
                [self notifyChangeWithKey:kNewFriend];
            }
            else if ([obj isKindOfClass:[Message class]])
            {
                NSLog(@"New message created. Text: %@", [(Message*)obj text]);
                // A message was created
                [self notifyChangeWithKey:kNewMessage];
            }
            else if ([obj isKindOfClass:[Thread class]])
            {
                NSLog(@"New thread created. Name: %@", [(Thread*)obj getName]);
                // A thread was created
                [self notifyChangeWithKey:kNewThread];
            }
            else if ([obj isKindOfClass:[DeletedGroup class]])
            {
                NSLog(@"New DeletedGroup created");
                // A group was left
                [self notifyChangeWithKey:kNewDeletedGroup];
            }
            else if ([obj isKindOfClass:[DeletedFriend class]])
            {
                NSLog(@"New DeletedFriend created");
                // A friend was "deleted"
                [self notifyChangeWithKey:kNewDeletedFriend];
            }
            else if ([obj isKindOfClass:[DoNotNotify class]])
            {
                NSLog(@"New DoNotNotify created.");
                // A group was created and a DoNotNotify was created with it.
                [self notifyChangeWithKey:kNewDoNotNotify];
            }
            else
            {
                NSLog(@"Inserted class: %@", [obj class]);
            }
        }
    }
    
    if ([notification.userInfo objectForKey:NSDeletedObjectsKey])
    {
        //NSLog(@"Deleted");
        NSArray *arr = [[notification.userInfo objectForKey:NSDeletedObjectsKey] allObjects];
        //NSLog(@"Deleted objects: %@", arr);
        for (NSObject *obj in arr)
        {
            if ([obj isKindOfClass:[Group class]])
            {
                NSLog(@"Group deleted. Name: %@", [(Group*)obj getName]);
                // A group was deleted
                [self notifyChangeWithKey:kDeletedGroup];
            }
            else if ([obj isKindOfClass:[Friend class]])
            {
                NSLog(@"Friend deleted. Name: %@", [(Friend*)obj getName]);
                // A friend was deleted
                [self notifyChangeWithKey:kDeletedFriend];
            }
            else if ([obj isKindOfClass:[Message class]])
            {
                NSLog(@"Message deleted. Text: %@", [(Message*)obj text]);
                // A message was deleted. Only happens when a thread gets deleted
                [self notifyChangeWithKey:kDeletedMessage];
            }
            else if ([obj isKindOfClass:[Thread class]])
            {
                NSLog(@"Thread deleted. Name: %@", [(Thread*)obj getName]);
                // A thread was deleted. Also deletes all the messages of the thread
                [self notifyChangeWithKey:kDeletedThread];
            }
            else if ([obj isKindOfClass:[DeletedGroup class]])
            {
                NSLog(@"DeletedGroup deleted");
                // A group was rejoined or a "deleted" group was deleted from the context
                [self notifyChangeWithKey:kDeletedDeletedGroup];
            }
            else if ([obj isKindOfClass:[DeletedFriend class]])
            {
                NSLog(@"DeletedFriend deleted");
                // A friend was restored or a "deleted" friend was deleted from the context
                [self notifyChangeWithKey:kDeletedDeletedFriend];
            }
            else if ([obj isKindOfClass:[DoNotNotify class]])
            {
                NSLog(@"DoNotNotify deleted");
                // A group was deleted and a DoNotNotify was deleted with it.
                [self notifyChangeWithKey:kDeletedDoNotNotify];
            }
            else
            {
                NSLog(@"Deleted class: %@", [obj class]);
            }
        }
    }
    
    if ([notification.userInfo objectForKey:NSUpdatedObjectsKey])
    {
        //NSLog(@"Updated");
        NSArray *arr = [[notification.userInfo objectForKey:NSUpdatedObjectsKey] allObjects];
        //NSLog(@"Updated objects: %@", arr);
        for (NSObject *obj in arr)
        {
            if ([obj isKindOfClass:[Group class]])
            {
                NSLog(@"Group updated. Group: %@", [(Group*)obj getName]);
                // A friend was added or removed from the group, or a thread was added or deleted
                [self notifyChangeWithKey:kUpdatedGroup];
            }
            else if ([obj isKindOfClass:[Friend class]])
            {
                NSLog(@"Friend updated. Name: %@", [(Friend*)obj getName]);
                // Friend was added or removed from a group, or a thread was added or deleted
                [self notifyChangeWithKey:kUpdatedFriend];
            }
            else if ([obj isKindOfClass:[Message class]])
            {
                NSLog(@"Message updated. Text: %@", [(Message*)obj text]);
                // Don't know
                [self notifyChangeWithKey:kUpdatedMessage];
            }
            else if ([obj isKindOfClass:[Thread class]])
            {
                NSLog(@"Thread updated. Name: %@", [(Thread*)obj getName]);
                // Don't know
                [self notifyChangeWithKey:kUpdatedThread];
            }
            else if ([obj isKindOfClass:[DeletedGroup class]])
            {
                NSLog(@"DeletedGroup updated");
                // The deletedGroup was added to a group ???????
                [self notifyChangeWithKey:kUpdatedDeletedGroup];
            }
            else if ([obj isKindOfClass:[DeletedFriend class]])
            {
                NSLog(@"DeletedFriend updated");
                // The deletedFriend was added to a friend ?????????
                [self notifyChangeWithKey:kUpdatedDeletedFriend];
            }
            else if ([obj isKindOfClass:[DoNotNotify class]])
            {
                NSLog(@"DoNotNotify updated");
                // A member was added or removed from DoNotNotify
                [self notifyChangeWithKey:kUpdatedDoNotNotify];
            }
            else
            {
                NSLog(@"Updated class: %@", [obj class]);
            }
            
        }
    }
}

-(void)notifyChangeWithKey:(NSString*)key{
    for (NSObject<ChangeListener> *listener in changeListeners) {
        [listener newChangeWithKey:key];
    }
}

@end