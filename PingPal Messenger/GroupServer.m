//
//  GroupServer.m
//  PingPal Messenger
//
//  Created by André Hansson on 06/08/14.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "GroupServer.h"

@implementation GroupServer

static GroupServer *sharedInstance = nil;

+(id)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

-(void)createGroupWithName:(NSString *)name andGroup:(NSString *)groupTag callback:(void (^)(NSDictionary *))callback
{
    NSLog(@"createGroupWithName: %@", name);
    
    name = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    groupTag = [groupTag stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self request:[NSString stringWithFormat:@"http://ppmapi.com/ppmess/rest/msggroup/creategroup?name=%@&tag=%@", name, groupTag] withCallback:^(NSDictionary *dict) {
        
        NSLog(@"createGroupWithName data: %@", dict);
        
        callback(dict);
        
    }];
}

-(void)setName:(NSString *)name forGroup:(NSString *)groupTag callback:(void (^)(NSDictionary *))callback
{
    name = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    groupTag = [groupTag stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [self request:[NSString stringWithFormat:@"http://ppmapi.com/ppmess/rest/msggroup/setgroupname?name=%@&tag=%@", name, groupTag] withCallback:^(NSDictionary *dict) {
        
        NSLog(@"setName:forGroup data: %@", dict);
        
        callback(dict);

    }];
}

-(void)getNameForGroup:(NSString *)groupTag callback:(void (^)(NSString *))callback
{
    NSLog(@"getNameForGroup: %@", groupTag);
    
    groupTag = [groupTag stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self request:[NSString stringWithFormat:@"http://ppmapi.com/ppmess/rest/msggroup/getgroupname?tag=%@", groupTag] withCallback:^(NSDictionary *dict) {
        
        NSLog(@"getNameForGroup data: %@", dict);
        NSString *name = dict[@"response"][@"name"];
        
        callback(name);
        
    }];
}

-(void)getMembersForGroup:(NSString *)groupTag callback:(void (^)(NSArray *))callback
{
    NSLog(@"getMembersForGroup: %@", groupTag);
    
    groupTag = [groupTag stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [self request:[NSString stringWithFormat:@"http://ppmapi.com/ppmess/rest/msggroup/getmembers?tag=%@", groupTag] withCallback:^(NSDictionary *dict) {
        NSLog(@"getMembersForGroup data: %@", dict);
        
        NSMutableArray *members = [[NSMutableArray alloc]init];
        NSArray *arr = dict[@"response"];
        
        for (NSDictionary *dsa in arr)
        {
            [members addObject:dsa[@"name"]];
        }
        
        callback(members);
    }];
}

-(void)addMember:(NSString *)member toGroup:(NSString *)groupTag callback:(void (^)(NSDictionary *))callback
{
    NSLog(@"addMember: %@ toGroup: %@", member, groupTag);
    
    member = [member stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    groupTag = [groupTag stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [self request:[NSString stringWithFormat:@"http://ppmapi.com/ppmess/rest/msgmember/addmember?name=%@&tag=%@", member, groupTag] withCallback:^(NSDictionary *dict) {
        
        NSLog(@"addMember:toGroup data: %@", dict);
        
        callback(dict);
        
    }];
}

-(void)removeMember:(NSString *)member fromGroup:(NSString *)groupTag callback:(void (^)(NSDictionary *))callback
{
    NSLog(@"removeMember: %@ toGroup: %@", member, groupTag);
    
    member = [member stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    groupTag = [groupTag stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self request:[NSString stringWithFormat:@"http://ppmapi.com/ppmess/rest/msgmember/removemember?name=%@&tag=%@", member, groupTag] withCallback:^(NSDictionary *dict) {
        
        NSLog(@"removeMember:fromGroup data: %@", dict);
        
        callback(dict);

    }];
}

-(void)getGroupsForMember:(NSString *)member callback:(void (^)(NSArray *))callback
{
    NSLog(@"getGroupsForMember: %@", member);
    
    member = [member stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self request:[NSString stringWithFormat:@"http://ppmapi.com/ppmess/rest/msgmember/getgroups?name=%@", member] withCallback:^(NSDictionary *dict) {
        
        NSMutableArray *groups = [[NSMutableArray alloc]init];
        NSArray *arr = dict[@"response"];
        
        for (NSDictionary *dsa in arr)
        {
            [groups addObject:dsa[@"tag"]];
        }
        
        callback(groups);

    }];
}

-(void)request:(NSString *)url withCallback:(void (^)(NSDictionary *))callback
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:url]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError)
        {
            NSLog(@"GroupServer - NSURLConnection Error: %@", connectionError);
        }
        else
        {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(dict);
            });
        }
    }];
}


@end