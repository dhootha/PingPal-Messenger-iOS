//
//  MessageWrapper.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-31.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "MessageWrapper.h"
#import "AppDelegate.h"

@implementation MessageWrapper


#pragma mark - Text

+(void)createNewMessageWithText:(NSString *)text andSender:(NSString *)senderTag andDate:(NSDate *)date forThread:(NSObject *)thread
{
    //NSLog(@"createNewMessage");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    Message *newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    [newMessage setText:text];
    [newMessage setMessageType:typeText];
    [newMessage setSenderTag:senderTag];
    [newMessage setDate:date];
    [newMessage setThread:(Thread*)thread];
    
    [appDelegate saveContext];
}


#pragma mark - Icon

+(void)createNewMessageWithIcon:(NSString *)icon andText:(NSString*)text andSender:(NSString *)senderTag andDate:(NSDate *)date forThread:(NSObject *)thread
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    Message *newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    [newMessage setIcon:icon];
    [newMessage setText:text];
    [newMessage setMessageType:typeIcon];
    [newMessage setSenderTag:senderTag];
    [newMessage setDate:date];
    [newMessage setThread:(Thread*)thread];
    
    [appDelegate saveContext];
}


#pragma mark - Location

+(void)createNewMessageWithLocation:(NSString *)location andText:(NSString *)text andSender:(NSString *)senderTag andDate:(NSDate *)date forThread:(NSObject *)thread
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    Message *newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    [newMessage setLocation:location];
    [newMessage setText:text];
    [newMessage setMessageType:typeLocation];
    [newMessage setSenderTag:senderTag];
    [newMessage setDate:date];
    [newMessage setThread:(Thread*)thread];
    
    [appDelegate saveContext];
}


@end
