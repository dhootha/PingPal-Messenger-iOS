//
//  Friend.m
//  PingPal Messenger
//
//  Created by André Hansson on 15/09/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "Friend.h"
#import "CFacebook.h"
#import "Contacts.h"
#import "DeletedFriend.h"
#import "DoNotNotify.h"
#import "Group.h"
#import "Thread.h"


@implementation Friend

@dynamic tag;
@dynamic pingAccess;
@dynamic contact;
@dynamic deletedFriend;
@dynamic doNotNotify;
@dynamic facebook;
@dynamic groups;
@dynamic thread;


-(NSString*)getName
{
    if (self.facebook)
    {
        CFacebook *fb = (CFacebook*)self.facebook;
        return [NSString stringWithFormat:@"%@ %@", [fb firstName], [fb lastName]];
    }
    else if (self.contact)
    {
        Contacts *c = (Contacts*)self.contact;
        return c.name;
    }
    else
    {
        NSLog(@"No name on this friend");
        return @"ERROR";
    }
}

-(NSString *)getFirstName
{
    if (self.facebook)
    {
        CFacebook *fb = (CFacebook*)self.facebook;
        return [fb firstName];
    }
    else if (self.contact)
    {
        Contacts *c = (Contacts*)self.contact;
        return c.name;
    }
    else
    {
        return @"ERROR";
    }
}

-(NSString *)getImageFilePath
{
    if (self.facebook)
    {
        CFacebook *fb = (CFacebook*)self.facebook;
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * jpegFilePath = [docDir stringByAppendingPathComponent:[fb imageFileName]];
        
        return jpegFilePath;
    }
    else if (self.contact)
    {
        Contacts *c = (Contacts*)self.contact;
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * jpegFilePath = [docDir stringByAppendingPathComponent:[c imageFileName]];
        
        return jpegFilePath;
    }
    else
    {
        NSLog(@"No imageFilePath on friend: %@", [self getName]);
        return @"ERROR";
    }
}

-(NSArray *)getImageFilePaths{
    return NULL;
}



@end