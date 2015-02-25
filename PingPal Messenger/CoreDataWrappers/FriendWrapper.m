//
//  FriendWrapper.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-24.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "FriendWrapper.h"
#import "AppDelegate.h"
#import "Friend.h"
#import "CFacebook.h"

@implementation FriendWrapper


#pragma mark - Fetch

+(NSArray *)fetchAllFriends
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
        NSLog(@"ERROR: %@", error);
    }
    
    return fetchedObjects;
}

+(NSArray *)fetchAllNonDeletedFriends
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deletedFriend == nil"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
        NSLog(@"ERROR: %@", error);
    }
    
    return fetchedObjects;
}

+(NSArray *)fetchAllDeletedFriends
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deletedFriend != nil"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
        NSLog(@"ERROR: %@", error);
    }
    
    return fetchedObjects;
}

+(NSArray *)fetchAllFriendsWithSortKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:context];
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

+(NSArray *)fetchAllNonDeletedFriendsWithSortKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deletedFriend == nil"];
    [fetchRequest setPredicate:predicate];
    
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

+(NSArray *)fetchAllDeletedFriendsWithSortKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deletedFriend != nil"];
    [fetchRequest setPredicate:predicate];
    
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

+(Friend *)fetchFriendWithTag:(NSString *)tag
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag == %@", tag];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
        NSLog(@"ERROR: %@", error);
    }
    
    if (fetchedObjects.count == 0) {
        NSLog(@"fetchFriendWithTag - fetchedObjects is empty. Can't fetch friend with tag:%@", tag);
        return NULL;
    }
    
    Friend *friend = [fetchedObjects objectAtIndex:0];
    
    return friend;
}

+(Friend *)fetchFriendWithFBID:(NSString *)fbid
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    // fetch facebook
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CFacebook" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fbid == %@", fbid];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
        NSLog(@"ERROR: %@", error);
    }
    
    if (fetchedObjects.count == 0) {
        NSLog(@"fetchFriendWithFBID - fetchedObjects is empty. Can't fetch facebook with fbid:%@", fbid);
        return NULL;
    }
    
    CFacebook *facebook = [fetchedObjects objectAtIndex:0];
    
    // fetch friend with facebook
    NSFetchRequest *fetchRequest2 = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity2 = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:context];
    [fetchRequest2 setEntity:entity2];
    
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"facebook == %@", facebook];
    [fetchRequest2 setPredicate:predicate2];
    
    NSArray *fetchedObjects2 = [context executeFetchRequest:fetchRequest2 error:&error];
    if (fetchedObjects2 == nil) {
        // Handle the error
        NSLog(@"ERROR: %@", error);
    }
    
    if (fetchedObjects2.count == 0) {
        NSLog(@"fetchFriendWithFBID - fetchedObjects is empty. Can't fetch friend with facebook:%@", facebook);
        return NULL;
    }
    
    Friend *friend = [fetchedObjects2 objectAtIndex:0];
    
    return friend;
}


#pragma mark - Get stuff

+(NSString *)getImageFilePathForFriendTag:(NSString *)tag{
    Friend *friend = [self fetchFriendWithTag:tag];
    return [friend getImageFilePath];
}


#pragma mark - Create

+(void)createFriend:(NSString *)tag withFacebook:(CFacebook *)facebook
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    Friend *newFriend = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:context];
    [newFriend setTag:tag];
    [newFriend setFacebook:facebook];
    [newFriend setPingAccess:accessAsk];
    
    [appDelegate saveContext];
}

+(CFacebook *)createFacebook:(NSString *)fbid withFirstName:(NSString *)firstName andLastName:(NSString *)lastName
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    CFacebook *newFacebook = [NSEntityDescription insertNewObjectForEntityForName:@"CFacebook" inManagedObjectContext:context];
    [newFacebook setFbid:fbid];
    [newFacebook setFirstName:firstName];
    [newFacebook setLastName:lastName];
    NSString *imageName = [NSString stringWithFormat:@"%@.jpeg", fbid];
    [newFacebook setImageFileName:imageName];
    
    [appDelegate saveContext];
    
    return newFacebook;
}


#pragma mark - Delete and restore

+(void)deleteFriend:(Friend *)friend
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    DeletedFriend *deletedFriend = [NSEntityDescription insertNewObjectForEntityForName:@"DeletedFriend" inManagedObjectContext:context];
    [friend setDeletedFriend:deletedFriend];
    
    if ([friend thread]) {
        Thread *thread = [friend thread];
        [context deleteObject:(NSManagedObject*)thread];
    }
    
    [appDelegate saveContext];
}

+(void)restoreDeletedFriend:(Friend *)friend
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];

    [context deleteObject:(NSManagedObject*)friend.deletedFriend];
    
    [appDelegate saveContext];
}


@end