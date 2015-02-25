//
//  NotifyViewController.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-04-02.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "NotifyViewController.h"
#import "CollectionViewController.h"
#import "NotifyCollectionViewController.h"
#import "GroupWrapper.h"
#import "MyselfObject.h"
#import "Friend.h"

#import <PPLocationManager/Outbox.h>

#define iphoneWidth ((int) 320)

@interface NotifyViewController (){
    
    // CollectionViewControllers
    NotifyCollectionViewController *notifyCVC;
    CollectionViewController *doNotNotifyCVC;
    
    // Drag&Drop
    CGRect topLocation;
    CGRect bottomLocation;
    
    int height;
    
    NSMutableArray *notifyMembers;
    NSMutableArray *doNotNotifyMembers;
}

@property (weak, nonatomic) IBOutlet UIView *notifyView;

@property (weak, nonatomic) IBOutlet UIView *doNotNotifyView;

@property (weak, nonatomic) IBOutlet UINavigationBar *doNotNotifyNavigationBar;

@property (weak, nonatomic) IBOutlet UINavigationBar *notifyNavigationBar;

@end

@implementation NotifyViewController

@synthesize itemsToMove, group;

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // _notifyNavigationBar appearance
    [_notifyNavigationBar setBarTintColor:UIColorFromRGB(0x48BB90)];
    [_notifyNavigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //[_notifyNavigationBar setTintColor:[UIColor whiteColor]];
    
    // _doNotNotifyNavigationBar appearance
    [_doNotNotifyNavigationBar setBarTintColor:UIColorFromRGB(0x48BB90)];
    [_doNotNotifyNavigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //[_doNotNotifyNavigationBar setTintColor:[UIColor whiteColor]];
    
    // DropDelegate
    itemsToMove = [[NSMutableArray alloc]init];
    
    if(IS_IPHONE_5){
        topLocation = CGRectMake(0, 64, 320, 252);
        bottomLocation = CGRectMake(0, 317, 320, 252);
    }else{
        topLocation = CGRectMake(0, 64, 320, 208);
        bottomLocation = CGRectMake(0, 273, 320, 208);
    }
    
    notifyMembers = [[NSMutableArray alloc]init];
    doNotNotifyMembers = [[NSMutableArray alloc]init];
    
    // Height for different screen sizes
    height = 208;
    if (!IS_IPHONE_5) height = 164;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    notifyCVC = [storyboard instantiateViewControllerWithIdentifier:@"NotifyCollectionViewController"];
    doNotNotifyCVC = [storyboard instantiateViewControllerWithIdentifier:@"CollectionViewController"];
    
    [notifyCVC setDropDelegate:self];
    [doNotNotifyCVC setDropDelegate:self];
    
    [_notifyView addSubview:notifyCVC.view];
    [self addChildViewController:notifyCVC];
    [_doNotNotifyView addSubview:doNotNotifyCVC.view];
    [self addChildViewController:doNotNotifyCVC];
    
    
    // Get myselfObject and add to notify or doNotNotify
    if ([GroupWrapper getNotifyMeForGroup:group]) {
        [notifyMembers addObject:[MyselfObject sharedInstance]];
    }else{
        [doNotNotifyMembers addObject:[MyselfObject sharedInstance]];
    }
    
    // Get members in doNotNotify
    [doNotNotifyMembers addObjectsFromArray: [[GroupWrapper getDoNotNotifyMembersForGroup:group]mutableCopy] ];
    
    // Get all members
    [notifyMembers addObjectsFromArray: [[[group members]allObjects]mutableCopy] ];
    
    // Remove members from notify if they are in doNotNotify
    NSMutableArray *objectsToRemove = [[NSMutableArray alloc]init];
    for (NSObject *obj in notifyMembers)
    {
        if ([doNotNotifyMembers containsObject:obj])
        {
            [objectsToRemove addObject:obj];
        }
    }
    [notifyMembers removeObjectsInArray:objectsToRemove];
    
    [notifyCVC addToArrayFromArray:notifyMembers];
    [doNotNotifyCVC addToArrayFromArray:doNotNotifyMembers];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    int dsa = 20;
    if (!IS_IPHONE_5) dsa = 64;
    
    //if (!IS_IPHONE_5) { // 164(height) + 108(64+44) = 272 + 44 = 316
        CGRect rect = _notifyView.frame;
        rect.size.height = height;
        [_notifyView setFrame:rect];
        
        rect = _doNotNotifyNavigationBar.frame;
        rect.origin.y = 272-dsa;
        [_doNotNotifyNavigationBar setFrame:rect];
        
        rect = _doNotNotifyView.frame;
        rect.size.height = height;
        rect.origin.y = 316-dsa;
        [_doNotNotifyView setFrame:rect];
    //}
    
    [notifyCVC.view setFrame:CGRectMake(0, 0, iphoneWidth, height)];
    [doNotNotifyCVC.view setFrame:CGRectMake(0, 0, iphoneWidth, height)];
}

-(void)viewDidLayoutSubviews
{    
    int dsa = 20;
    if (!IS_IPHONE_5) dsa = 64;
    
    //if (!IS_IPHONE_5) { // 164(height) + 108(64+44) = 272 + 44 = 316
        CGRect rect = _notifyView.frame;
        rect.size.height = height;
        [_notifyView setFrame:rect];
        
        rect = _doNotNotifyNavigationBar.frame;
        rect.origin.y = 272-dsa;
        [_doNotNotifyNavigationBar setFrame:rect];
        
        rect = _doNotNotifyView.frame;
        rect.size.height = height;
        rect.origin.y = 316-dsa;
        [_doNotNotifyView setFrame:rect];
    //}
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[ManagedObjectChangeListener sharedInstance] addChangeListener:self];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[ManagedObjectChangeListener sharedInstance] removeChangeListener:self];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)reloadMembers
{
    // Remove everything
    for (NSObject *obj in notifyMembers) {
        [notifyCVC removeFromArray:obj];
    }
    
    for (NSObject *obj in doNotNotifyMembers) {
        [doNotNotifyCVC removeFromArray:obj];
    }
    
    [notifyMembers removeAllObjects];
    [doNotNotifyMembers removeAllObjects];

    
    // Add back in
    
    // Get myselfObject and add to notify or doNotNotify
    if ([GroupWrapper getNotifyMeForGroup:group]) {
        [notifyMembers addObject:[MyselfObject sharedInstance]];
    }else{
        [doNotNotifyMembers addObject:[MyselfObject sharedInstance]];
    }
    
    // Get members in doNotNotify
    [doNotNotifyMembers addObjectsFromArray: [[GroupWrapper getDoNotNotifyMembersForGroup:group]mutableCopy] ];
    
    // Get all members
    [notifyMembers addObjectsFromArray: [[[group members]allObjects]mutableCopy] ];
    
    // Remove members from notify if they are in doNotNotify
    NSMutableArray *objectsToRemove = [[NSMutableArray alloc]init];
    for (NSObject *obj in notifyMembers)
    {
        if ([doNotNotifyMembers containsObject:obj])
        {
            [objectsToRemove addObject:obj];
        }
    }
    [notifyMembers removeObjectsInArray:objectsToRemove];
    
    [notifyCVC addToArrayFromArray:notifyMembers];
    [doNotNotifyCVC addToArrayFromArray:doNotNotifyMembers];
    
//    [notifyCVC.collectionView reloadData];
//    [doNotNotifyCVC.collectionView reloadData];
}


#pragma mark - DropDelegate

-(void)onDrop:(CGPoint)x sender:(CollectionViewController*)sender
{
    //NSLog(@"onDrop: %@",NSStringFromCGPoint(x));
    
    if (CGRectContainsPoint(topLocation, x))
    {
        NSLog(@"Dropped in topLocation");
        
        NSObject<DropViewController> *dropViewController = notifyCVC;
        
        if (sender == doNotNotifyCVC)
        {
            // Remove from doNotNotify
            
            NSMutableArray *membersToRemoveFromDoNotNotify = [[NSMutableArray alloc]init];
            
            for (NSObject *object in itemsToMove)
            {
                //NSLog(@"Object: %@", object);
                
                if ([object isKindOfClass:[Friend class]])
                {
                    [membersToRemoveFromDoNotNotify addObject:object];
                }
                else if ([object isKindOfClass:[MyselfObject class]])
                {
                    // Set myself to notify
                    [GroupWrapper setNotifyMe:YES onGroup:group];
                }
                
                //[sender removeFromArray:object]; only needed if deleteOnDragBegin has been overrided
            }
            
            // Remove members from doNotNotify
            [GroupWrapper removeMembersFromDoNotNotify:membersToRemoveFromDoNotNotify onGroup:group];
            
            // Send a message to the group so they can change their notify screen
            [Outbox put:group.tag withPayload:@{@"groupNotifyChanged": group.tag, @"member":[[MyselfObject sharedInstance]getUserTag], @"changedTo":@"notify"}];
            
            [sender.collectionView reloadData];
        }
        
        if (![dropViewController droppedObjects:itemsToMove])
        {
            //If NO is returned
            NSLog(@"NO was returned. Items can not be dropped in this viewController");
            
            for (NSObject *obj in itemsToMove)
            {
                [sender addToArray:obj];
            }
            [sender.collectionView reloadData];
        }
    }
    else if (CGRectContainsPoint(bottomLocation, x))
    {
        NSLog(@"Dropped in bottomLocation");
        
        NSObject<DropViewController> *dropViewController = doNotNotifyCVC;
        
        if (sender == notifyCVC)
        {
            // Add to doNotNotify
            
            NSMutableArray *membersToAddToDoNotNotify = [[NSMutableArray alloc]init];
            
            for (NSObject *object in itemsToMove)
            {
                //NSLog(@"Object: %@", object);
                
                if ([object isKindOfClass:[Friend class]])
                {
                    [membersToAddToDoNotNotify addObject:object];
                }
                else if ([object isKindOfClass:[MyselfObject class]])
                {
                    //Set myself to doNotNotify
                    [GroupWrapper setNotifyMe:NO onGroup:group];
                }
            }

            // Add members to doNotNotify
            [GroupWrapper addMembersToDoNotNotify:membersToAddToDoNotNotify onGroup:group];
            
            // Send a message to the group so they can change their notify screen
            [Outbox put:group.tag withPayload:@{@"groupNotifyChanged": group.tag, @"member":[[MyselfObject sharedInstance]getUserTag], @"changedTo":@"doNotNotify"}];
            
            [sender.collectionView reloadData];
        }
        
        if (![dropViewController droppedObjects:itemsToMove])
        {
            //If NO is returned
            NSLog(@"NO was returned. Items can not be dropped in this viewController");
            
            for (NSObject *obj in itemsToMove)
            {
                [sender addToArray:obj];
            }
            [sender.collectionView reloadData];
        }
    }
}


#pragma mark - Orientation

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - ChangeListener

-(void)newChangeWithKey:(NSString *)key
{
    if ([key isEqualToString:kUpdatedDoNotNotify]) {
        NSLog(@"newChangeWithKey 'kUpdatedDoNotNotify' in NotifyViewController");
        [self reloadMembers];
    }
}







@end