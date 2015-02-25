//
//  CollectionViewController.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-16.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDelegate.h"
#import "DropViewController.h"

@interface CollectionViewController : UICollectionViewController <DropViewController>

-(void)setDropDelegate:(NSObject<DropDelegate> *)drop;

-(void) deleteOnDragBegin: (NSArray*)dictionaries;


// Array

@property NSMutableArray *array;

-(void)addToArray:(NSObject*)object;

-(void)addToArrayFromArray:(NSArray*)arr;

-(void)removeFromArray:(NSObject*)object;

-(BOOL)arrayContainsObject:(id)object;


// GestureRecognizers

-(BOOL)addGestureRecognizersToCell:(UICollectionViewCell*)cell WithIndexPath:(NSIndexPath*)indexPath;

-(UIGestureRecognizer *)myTGRMethod;

-(UIGestureRecognizer *)myLPGRMethod;

@end