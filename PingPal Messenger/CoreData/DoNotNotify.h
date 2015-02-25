//
//  DoNotNotify.h
//  PingPal Messenger
//
//  Created by André Hansson on 2014-04-02.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friend, Group;

@interface DoNotNotify : NSManagedObject

@property (nonatomic, retain) NSSet *doNotNotifyMembers;
@property (nonatomic, retain) Group *group;
@end

@interface DoNotNotify (CoreDataGeneratedAccessors)

- (void)addDoNotNotifyMembersObject:(Friend *)value;
- (void)removeDoNotNotifyMembersObject:(Friend *)value;
- (void)addDoNotNotifyMembers:(NSSet *)values;
- (void)removeDoNotNotifyMembers:(NSSet *)values;

@end
