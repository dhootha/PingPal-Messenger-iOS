//
//  DropViewController.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-18.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DropViewController <NSObject>

-(BOOL)droppedObjects:(NSMutableArray*)objects;

@end
