//
//  ThreadWrapper.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-26.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "ThreadWrapper.h"
#import "AppDelegate.h"
#import "Message.h"

#import "FriendWrapper.h"
#import "GroupWrapper.h"
#import "MyselfObject.h"

@implementation ThreadWrapper


#pragma mark - Fetch

+(NSArray *)fetchAllThreads
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Thread" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
        NSLog(@"ERROR: %@", error);
    }
    
    return fetchedObjects;
}

+(NSArray *)fetchAllThreadsWithSortKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Thread" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
        NSLog(@"ERROR: %@", error);
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:sortKey ascending:ascending];
    fetchedObjects = [fetchedObjects sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    return fetchedObjects;
}

+(Thread *)fetchThreadForTag:(NSString *)tag
{
    NSLog(@"fetchThreadForTag: %@", tag);
    Friend *friend = [FriendWrapper fetchFriendWithTag:tag];
    if (friend) {
        NSLog(@"fetchThreadForTag - is friend");
        return friend.thread;
    }else{
        NSLog(@"fetchThreadForTag - is group");
        Group *group = [GroupWrapper fetchGroupWithTag:tag];
        if (group) {
            return group.thread;
        }else{
            return NULL;
        }
    }
}


#pragma mark - Create

+(Thread*)createThreadForFriend:(Friend *)f
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    Thread *newThread = [NSEntityDescription insertNewObjectForEntityForName:@"Thread" inManagedObjectContext:context];
    [newThread setFriend:f];
    [newThread setUnread:0];
    
    [appDelegate saveContext];
    
    return newThread;
}

+(Thread*)createThreadForGroup:(Group *)g
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    Thread *newThread = [NSEntityDescription insertNewObjectForEntityForName:@"Thread" inManagedObjectContext:context];
    [newThread setGroup:g];
    [newThread setUnread:0];
    
    [appDelegate saveContext];
    
    return newThread;
}


#pragma mark - Delete

+(void)deleteThread:(NSObject *)thread
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    [context deleteObject:(Thread*)thread];
    
    [appDelegate saveContext];
}


#pragma mark - Unread

+(void)resetUnreadOnThread:(NSObject *)thread
{
    [(Thread*)thread setUnread:0];
    
    [(AppDelegate *)[[UIApplication sharedApplication]delegate] saveContext];
}

+(void)incrementUnreadOnThread:(NSObject *)thread
{
    int unread = [[(Thread*)thread unread]intValue];
    unread++;
    [(Thread*)thread setUnread:[NSNumber numberWithInt:unread]];
    
    [(AppDelegate *)[[UIApplication sharedApplication]delegate] saveContext];
}


#pragma mark - Get stuff

+(NSString*)getImageFilePathForSender:(NSString *)tag onThread:(Thread *)thread
{
    if ([tag isEqualToString: [[MyselfObject sharedInstance]getUserTag] ]) {
        return [[MyselfObject sharedInstance]getImageFilePath];
    }
    
    if ([thread group])
    {
        for (Friend *f in [[[thread group]members]allObjects])
        {
            if ([f.tag isEqualToString:tag])
            {
                return [f getImageFilePath];
            }
        }
    }
    else
    {
        Friend *f = [FriendWrapper fetchFriendWithTag:tag];
        if (f)
        {
            return [f getImageFilePath];
        }
    }
    
    NSLog(@"Can't find friend in getImageFilePathForSender:%@ onThread:%@", tag,[thread getName]);
    return NULL;
}


@end