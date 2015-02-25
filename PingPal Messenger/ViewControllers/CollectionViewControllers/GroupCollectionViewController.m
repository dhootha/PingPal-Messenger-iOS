//
//  GroupCollectionViewController.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-20.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "GroupCollectionViewController.h"
#import "Friend.h"
#import "MyselfObject.h"
#import "GroupWrapper.h"
#import "InboxHandler.h"
#import "GroupOverlord.h"

@interface GroupCollectionViewController ()

@end

@implementation GroupCollectionViewController

@synthesize group;

-(NSString *)getName{
    return group.name;
}

-(BOOL)droppedObjects:(NSMutableArray*)objects
{
    NSLog(@"Dropped in %@",[self description]);
    
    for (NSObject<CollectionItem> *object in objects)
    {
        if ([self arrayContainsObject:object])
        {
            NSLog(@"Object is already in array");
            //Nothing
        }
        else
        {
            NSLog(@"Add object to array");
            [self addToArray:object];
            
            // Add members to group            
            if ([object isKindOfClass:[Friend class]])
            {
                NSLog(@"Friend. Add to group");

                [GroupOverlord addMember:[(Friend*)object tag] toGroup:group.tag];
            }
            else if ([object isKindOfClass:[MyselfObject class]])
            {
                NSLog(@"Me. Join group");

                [GroupOverlord joinGroup:group.tag];
            }
        }
    }
    
    return YES;
}





@end