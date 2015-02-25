//
//  NotifyCollectionViewController.m
//  PingPal Messenger
//
//  Created by André Hansson on 10/09/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "NotifyCollectionViewController.h"
#import "MyselfObject.h"

@interface NotifyCollectionViewController ()

@end

@implementation NotifyCollectionViewController

-(BOOL)addGestureRecognizersToCell:(UICollectionViewCell *)cell WithIndexPath:(NSIndexPath *)indexPath
{
    if ([(NSObject<CollectionItem>*)[super.array objectAtIndex:indexPath.item] isKindOfClass:[MyselfObject class]])
    {
        NSLog(@"NotifyCollectionViewController addGestureRecognizersToCell is Myself");
        [cell addGestureRecognizer: super.myLPGRMethod];
        [cell addGestureRecognizer: super.myTGRMethod];
        return YES;
    }else{
        NSLog(@"NotifyCollectionViewController addGestureRecognizersToCell is not me");
        return NO;
    }
}

@end