//
//  Group.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-04-02.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "Group.h"
#import "DoNotNotify.h"
#import "Friend.h"
#import "Thread.h"


@implementation Group

@dynamic name;
@dynamic tag;
@dynamic notifyMe;
@dynamic members;
@dynamic thread;
@dynamic deletedGroup;
@dynamic doNotNotify;

-(NSString *)getName
{
    return self.name;
}

-(NSString *)getImageFilePath
{
    return NULL;
}

-(NSArray *)getImageFilePaths{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    for (Friend *f in self.members)
    {
        NSString *imageFilePath = [f getImageFilePath];
        [array addObject:imageFilePath];
    }
    
    return array;
}

@end
