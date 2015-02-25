//
//  Thread.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-04-22.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "Thread.h"
#import "Friend.h"
#import "Group.h"
#import "Message.h"


@implementation Thread

@dynamic unread;
@dynamic friend;
@dynamic group;
@dynamic messages;


#pragma mark - ChatThread

-(NSString*)getCellIdentifier{
    if (self.friend) {
        return @"friendCell";
    }else{
        return @"groupCell";
    }
}

-(NSString*)getSegueIdentifier{
    if (self.friend) {
        return @"SegueToFriendChatView";
    }else{
        return @"SegueToGroupChatView";
    }
}

-(NSString*)getName{
    if (self.friend) {
        Friend *f = (Friend*)self.friend;
        return [f getName];
    }else{
        Group *g = (Group*)self.group;
        return [g getName];
    }
}

-(NSDate*)getLastDate{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    NSArray *array = [self.messages sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    if (array.count != 0){
        return [(Message*)[array objectAtIndex:0] date];
    }else{
        return NULL;
    }
}

-(NSString*)getLastMessage{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    NSArray *array = [self.messages sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    if (array.count != 0) {
        return [(Message*)[array objectAtIndex:0] text];
    }else{
        return @"";
    }
}

-(NSString *)getImageFilePath{
    if (self.friend) {
        Friend *f = (Friend*)self.friend;
        return [f getImageFilePath];
    }else{
        Group *g = (Group*)self.group;
        return [g getImageFilePath];
    }
}

-(int)getUnread{
    return [self.unread intValue];
}


#pragma mark - ChatViewItem

-(NSArray *)getMessages{
    NSArray *array = [[self.messages allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
    return array;
}

-(NSObject *)getGroup{
    return self.group;
}

-(NSString*)getTag{
    if (self.friend) {
        Friend *f = (Friend*)self.friend;
        return [f tag];
    }else{
        Group *g = (Group*)self.group;
        return [g tag];
    }
}

-(NSObject *)getFriend{
    return self.friend;
}


// Apple bug workaround
-(void)addMessagesObject:(Message *)value{
    //NSLog(@"addMessagesObject: %@", value);
    [self.messages addObject:value];
}

- (void)removeMessagesObject:(Message *)value{
    //NSLog(@"removeMessagesObject: %@", value);
    [self.messages removeObject:value];
}

- (void)addMessages:(NSSet *)values{
    //NSLog(@"addMessages: %@", values);
    [self.messages addObjectsFromArray:[values allObjects]];
}

// Causes crash
//- (void)removeMessages:(NSSet *)values{
//    NSLog(@"removeMessages: %@", values);
//    for (Message *value in values) {
//        [self.messages removeObject:value];
//    }
//}


@end