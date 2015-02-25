//
//  GroupWrapper.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-24.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "GroupWrapper.h"
#import "FriendWrapper.h"
#import "AppDelegate.h"
#import "DoNotNotify.h"
#import "MyselfObject.h"

@implementation GroupWrapper


#pragma mark - Fetch

+(NSArray *)fetchAllGroups
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
        NSLog(@"ERROR: %@", error);
    }
    
    return fetchedObjects;
}

+(NSArray *)fetchAllNonDeletedGroups
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deletedGroup == nil"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
        NSLog(@"ERROR: %@", error);
    }
    
    return fetchedObjects;
}

+(NSArray *)fetchAllDeletedGroups
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deletedGroup != nil"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
        NSLog(@"ERROR: %@", error);
    }
    
    return fetchedObjects;
}

+(NSArray *)fetchAllGroupsWithSortKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
        NSLog(@"ERROR: %@", error);
    }
    
    return fetchedObjects;
}

+(NSArray *)fetchAllNonDeletedGroupsWithSortKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deletedGroup == nil"];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
        NSLog(@"ERROR: %@", error);
    }
    
    return fetchedObjects;
}

+(NSArray *)fetchAllDeletedGroupsWithSortKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deletedGroup != nil"];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
        NSLog(@"ERROR: %@", error);
    }
    
    return fetchedObjects;
}

+(Group *)fetchGroupWithTag:(NSString *)tag
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:context];
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
        NSLog(@"fetchGroupWithTag - fetchedObjects is empty. Can't fetch group with tag:%@", tag);
        return NULL;
    }
    
    Group *group = [fetchedObjects objectAtIndex:0];
    
    return group;
}


#pragma mark - Create

+(Group*)createGroupWithName:(NSString *)name andTag:(NSString *)tag
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    Group *newGroup = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
    [newGroup setName:name];
    [newGroup setTag:tag];
    
    DoNotNotify *newDoNotNotify = [NSEntityDescription insertNewObjectForEntityForName:@"DoNotNotify" inManagedObjectContext:context];
    [newGroup setDoNotNotify:newDoNotNotify];
    
    [self setNotifyMe:YES onGroup:newGroup];
    
    [appDelegate saveContext];
    
    return newGroup;
}


#pragma mark - Manage members

+(void)addMembers:(NSArray *)array toGroup:(Group*)group
{
    //NSLog(@"addMembers: %@. To group: %@", array, group.name);

    [group addMembers:[NSSet setWithArray:array]];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate saveContext];
}

+(void)removeMembers:(NSArray *)array fromGroup:(Group *)group
{
    NSLog(@"removeMembers: %@. From group: %@", array, group.name);
    [group removeMembers:[NSSet setWithArray:array]];
    
    if ([group.members count] == 0 && group.deletedGroup) {
        // All members have left the group
        // It will automatically be removed from the server
        // Delete it from core data
        [self deleteGroup:group];
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate saveContext];
}

+(void)checkMembers:(NSArray *)members forGroup:(Group *)group
{
    // Members are the groups members on the server
        
    NSMutableArray *tagsInGroup = [[NSMutableArray alloc]init];
    
    for (Friend *friend in group.members)
    {
        [tagsInGroup addObject: friend.tag];
        
        if (![members containsObject:friend.tag])
        {
             // Is in the group localy but not on the server
            // No longer member in the group - remove it
            [GroupWrapper removeMembers:@[friend] fromGroup:group];
        }
    }
    
    for (NSString *memberTag in members)
    {
        // if it's the groups tag, skip it
        if ([memberTag isEqualToString:group.tag]) continue;
        
        // if it's my tag
        if ([memberTag isEqualToString:[[MyselfObject sharedInstance]getUserTag]])
        {
            if (group.deletedGroup) {
                [GroupWrapper rejoinGroup:group];
            }
            
            continue;
        }
        
        if (![tagsInGroup containsObject:memberTag])
        {
            // Member not in group - add to group if it's in core data
            Friend *f = [FriendWrapper fetchFriendWithTag:memberTag];
            if (f) [GroupWrapper addMembers:@[f] toGroup:group];
        }
    }
}


#pragma mark - Manage DoNotNotify

+(void)addMembersToDoNotNotify:(NSArray *)array onGroup:(Group *)group
{
    [group.doNotNotify addDoNotNotifyMembers:[NSSet setWithArray:array]];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate saveContext];
}

+(void)removeMembersFromDoNotNotify:(NSArray *)array onGroup:(Group *)group
{
    [group.doNotNotify removeDoNotNotifyMembers:[NSSet setWithArray:array]];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate saveContext];
}

+(NSArray *)getDoNotNotifyMembersForGroup:(Group *)group{
    return [[[group doNotNotify]doNotNotifyMembers]allObjects];
}

+(void)setNotifyMe:(BOOL)notifyMe onGroup:(Group *)group{
    [group setNotifyMe:[NSNumber numberWithBool:notifyMe]];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate saveContext];
}

+(BOOL)getNotifyMeForGroup:(Group *)group{
    return [[group notifyMe]boolValue];
}


#pragma mark - Leave & rejoin

+(void)leaveGroup:(Group *)group
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSManagedObject *deletedGroup = [NSEntityDescription insertNewObjectForEntityForName:@"DeletedGroup" inManagedObjectContext:context];
    [group setDeletedGroup:deletedGroup];
    
    if ([group thread]) {
        Thread *thread = [group thread];
        [context deleteObject:(NSManagedObject*)thread];
    }
    
    if ([group.members count] == 0) {
        // All members have left the group
        // It will automatically be removed from the server
        // Delete it from core data
        [self deleteGroup:group];
    }
    
    [appDelegate saveContext];
}

+(void)rejoinGroup:(Group *)group
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    [context deleteObject:group.deletedGroup];
    
    [appDelegate saveContext];
}


#pragma mark - Delete

+(void)deleteGroup:(Group *)group
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    [context deleteObject:group];
    
    [appDelegate saveContext];
}


@end