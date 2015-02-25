//
//  TableItem.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-04-03.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TableItem <NSObject>

-(NSString*)getName;

-(NSString*)getImageFilePath;

// Groups
-(NSArray*)getImageFilePaths;

@end