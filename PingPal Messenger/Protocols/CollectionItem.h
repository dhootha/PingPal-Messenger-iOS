//
//  CollectionItem.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-20.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CollectionItem <NSObject>

-(NSString*)getFirstName;

-(NSString*)getImageFilePath;

@end