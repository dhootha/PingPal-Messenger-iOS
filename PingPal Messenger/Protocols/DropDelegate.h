//
//  DropDelegate.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-18.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DropDelegate <NSObject>

@property NSMutableArray *itemsToMove;

-(void)onDrop: (CGPoint)x sender: (UICollectionViewController*) sender;

//-(void)onHold: (CGPoint)x sender: (UICollectionViewController*) sender;

@end
