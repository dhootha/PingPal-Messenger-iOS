//
//  ChatViewController.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-13.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "ChatViewController.h"
#import "MessageItem.h"
#import "MyselfObject.h"
#import "MessageWrapper.h"
#import "ThreadWrapper.h"
#import "BadgeCount.h"
#import <MapKit/MapKit.h>
#import "PPFullscreenViewController.h"
#import "FriendWrapper.h"
#import "Push.h"

#import <PPLocationManager/PPLocationManager.h>

@interface ChatViewController (){
    NSMutableArray *bubbleData;
    NSString *myTag;
    
    AHChatBarViewController *chatBarViewController;

    NSLayoutConstraint *heightConstraint;
    
    IconChooserViewController *iconChooser;
    
    BOOL fromFullscreen;
    
    Inbox pingInbox;
    Inbox dataWritingInbox;
    Inbox dataNotWritingInbox;
    
    NSPredicate *writing;
    NSPredicate *notWriting;
    
    UIRefreshControl *refreshControl;
    BOOL moreThan30;
    NSUInteger indexOfEarliestMessage;
    NSMutableArray *arr;
}

@end

@implementation ChatViewController

@synthesize bubbleTable, chatViewItem, indicatorSent;

- (void)viewDidLoad{
    [super viewDidLoad];
    
    myTag = [[MyselfObject sharedInstance]getUserTag];
    arr = [[NSMutableArray alloc]init];
    
    __weak typeof(self) weakSelf = self;
    
#pragma mark - PingInbox
    pingInbox = ^(NSMutableDictionary *payload, NSMutableDictionary *options, Outbox *outbox){
        NSLog(@"pingInbox Payload: %@. Options: %@", payload, options);
        
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf)
        {
            NSString *sender = options[@"from"];
            
            NSDictionary *location = payload[@"location"];
            
            NSData *plist = [NSPropertyListSerialization
                             dataWithPropertyList:location
                             format:NSPropertyListXMLFormat_v1_0
                             options:kNilOptions
                             error:NULL];
            
            NSString *str = [[NSString alloc] initWithData:plist encoding:NSUTF8StringEncoding];
            
            Friend *friend = [FriendWrapper fetchFriendWithTag:sender];
            
            NSString *text = [NSString stringWithFormat:@"%@ %@", [friend getName], NSLocalizedString(@"locationSentText", @"Sent location")];
            
            [MessageWrapper createNewMessageWithLocation:str andText:text andSender:sender andDate:[NSDate date] forThread:strongSelf.chatViewItem];
        }
    };
    
    [self setupWritingInboxes];
    
    // ***** AHChatBarView *****
    chatBarViewController = [[AHChatBarViewController alloc]init];
    [chatBarViewController setDelegate:self];
    [self addChildViewController:chatBarViewController];
    [self.view addSubview:chatBarViewController.view];
    [chatBarViewController addConstraintsWithView:self.view];
    
    [chatBarViewController setPlaceholderText:@"PingPal Messenger"];
    
    
    //[self.view addSubview:chatBarView];
    
    // ***** UIBubbleTableView *****
    bubbleData = [[NSMutableArray alloc] init];
    bubbleTable.PPDataSource = self;
    bubbleTable.PPDelegate = self;
    bubbleTable.snapInterval = 120;
    bubbleTable.showAvatars = YES;
    bubbleTable.typingBubble = PPTypingTypeNobody;
    //[bubbleTable setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    // ***** RefreshControl *****
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
//    NSAttributedString *attString = [[NSAttributedString alloc]initWithString:@"Pull to refresh"];
//    [refreshControl setAttributedTitle:attString];
    
    // Get the messages and add them to the bubbleTable
    [self reloadMessages];
    
    [bubbleTable reloadData];
    [bubbleTable scrollBubbleViewToBottomAnimated:NO];
    
    indicatorSent = NO;
    fromFullscreen = NO;
    
    heightConstraint = [NSLayoutConstraint constraintWithItem:bubbleTable attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.view.frame.size.height-50-64];
    [self.view addConstraint:heightConstraint];
}

-(void)setupWritingInboxes
{
    writing = [NSPredicate predicateWithFormat:@"payload.writing == 1"];
    notWriting = [NSPredicate predicateWithFormat:@"payload.writing == 0"];
    
    __weak typeof(self) weakSelf = self;

    dataWritingInbox = ^(NSMutableDictionary *payload, NSMutableDictionary *options, Outbox *outbox){
        NSLog(@"dataWritingInbox Payload: %@. Options: %@", payload, options);
        
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf)
        {
            // If from is who I'm chatting with, and it's to me, not group
            if ([options[@"from"] isEqualToString:[strongSelf.chatViewItem getTag]] && [options[@"to"] isEqualToString:[[MyselfObject sharedInstance]getUserTag]])
            {
                strongSelf.bubbleTable.typingBubble = PPTypingTypeSomebody;
                [strongSelf.bubbleTable reloadData];
                [strongSelf.bubbleTable scrollBubbleViewToBottomAnimated:YES];
            }
        }
    };
    
    dataNotWritingInbox = ^(NSMutableDictionary *payload, NSMutableDictionary *options, Outbox *outbox){
        NSLog(@"dataNotWritingInbox Payload: %@. Options: %@", payload, options);
        
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf)
        {
            // If from is who I'm chatting with, and it's to me, not group
            if ([options[@"from"] isEqualToString:[strongSelf.chatViewItem getTag]] && [options[@"to"] isEqualToString:[[MyselfObject sharedInstance]getUserTag]])
            {
                strongSelf.bubbleTable.typingBubble = PPTypingTypeNobody;
                [strongSelf.bubbleTable reloadData];
                [strongSelf.bubbleTable scrollBubbleViewToBottomAnimated:YES];
            }
        }
    };
}

-(void)addWritingInboxes
{
    [Outbox attachInbox:dataWritingInbox withPredicate:writing];
    [Outbox attachInbox:dataNotWritingInbox withPredicate:notWriting];
}

-(void)removeWritingInboxes
{
    [Outbox detachInbox:dataWritingInbox withPredicate:writing];
    [Outbox detachInbox:dataNotWritingInbox withPredicate:notWriting];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(PPMessageType)getType:(NSString*)tag{
    if ([tag isEqualToString:myTag]) {
        return PPMessageTypeMine;
    }else{
        return PPMessageTypeSomeoneElse;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSLog(@"ChatViewController - viewDidAppear");
    
    if (!fromFullscreen) {
        [bubbleTable scrollBubbleViewToBottomAnimated:YES];
    }else{
        fromFullscreen = NO;
        [self reloadMessages];
        [bubbleTable reloadData];
        //[bubbleTable scrollBubbleViewToBottomAnimated:YES];
    }
    
    [self addWritingInboxes];

    [[ManagedObjectChangeListener sharedInstance]addChangeListener:self];
    
    [ThreadWrapper resetUnreadOnThread:chatViewItem];
    
    [BadgeCount checkBadgeCount];
    
    //NSLog(@"chatBarViewFrame: %@", NSStringFromCGRect(chatBarView.frame));
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    NSLog(@"ChatViewController - viewDidDisappear");
    
    [self removeWritingInboxes];
    
    [[ManagedObjectChangeListener sharedInstance]removeChangeListener:self];
}


#pragma mark - Load/Refresh messages

-(void)loadMessegesFromArray:(NSArray*)array
{
    for (NSObject<MessageItem> *m in array)
    {
        PPMessageData *newMessage;
        if ([m getMessageType] == typeText)
        {
            newMessage = [PPMessageData dataWithText:[m getText] date:[m getDate] type:[self getType:[m getSenderTag]]];
            
        }
        else if ([m getMessageType] == typeImage)
        {
            newMessage = [PPMessageData dataWithImage:[UIImage imageNamed:[m getText]] date:[m getDate] type:[self getType:[m getSenderTag]]];
            
        }
        else if ([m getMessageType] == typeIcon)
        {
            newMessage = [PPMessageData dataWithIcon:[UIImage imageNamed:[m getIcon]] date:[m getDate] type:[self getType:[m getSenderTag]]];
        }
        else //if ([m getMessageType] == typeLocation)
        {
            NSDictionary *location = [NSPropertyListSerialization
                                      propertyListWithData:[[m getLocation] dataUsingEncoding:NSUTF8StringEncoding]
                                      options:kNilOptions
                                      format:NULL
                                      error:NULL];
            
            MKMapView *mapView = [self createMapViewWithLocation:location];
            
            newMessage = [PPMessageData dataWithView:mapView date:[m getDate] type:[self getType:[m getSenderTag]] style:PPMessageStyleMap insets:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        
        NSString *imageFilePath = [ThreadWrapper getImageFilePathForSender:[m getSenderTag] onThread:(Thread*)chatViewItem];
        if (imageFilePath) {
            newMessage.avatar = [UIImage imageWithContentsOfFile:imageFilePath];
        }else{
            newMessage.avatar = [UIImage imageNamed:@"PingPal-ikon_mörk.png"];
        }
        [bubbleData addObject:newMessage];
    }
}

-(void)reloadMessages
{
    [bubbleData removeAllObjects];
    [arr removeAllObjects];
    
    NSArray *sortedMessages = [chatViewItem getMessages];
    
    NSLog(@"number of sortedMessages: %lu", (unsigned long)sortedMessages.count);
    
    if (sortedMessages.count > 30)
    {
        NSLog(@"more than 30");
        
        moreThan30 = YES;
        
        if (![bubbleTable.subviews containsObject:refreshControl]) {
            [bubbleTable addSubview:refreshControl];
        }
        
        arr = [[sortedMessages objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(sortedMessages.count-30, 30)]]mutableCopy];
    }
    else
    {
        moreThan30 = NO;
        
        if ([bubbleTable.subviews containsObject:refreshControl]) {
            [refreshControl removeFromSuperview];
        }
        
        arr = [sortedMessages mutableCopy];
    }
    
    indexOfEarliestMessage = [sortedMessages indexOfObject:[arr firstObject]];
    NSLog(@"indexOfEarliestMessage: %lu", (unsigned long)indexOfEarliestMessage);
    
    [self loadMessegesFromArray:arr];
}

- (void)refresh:(id)sender
{
    // do your refresh here and reload the tableview
    
    NSLog(@"indexOfEarliestMessage: %lu",(unsigned long)indexOfEarliestMessage);
    
    NSMutableArray *sortedMessages = [[chatViewItem getMessages]mutableCopy];
    
    NSMutableArray *srtdMssgs = [sortedMessages copy];
    
    NSUInteger asd = sortedMessages.count - arr.count;
    NSLog(@"arr.count: %lu", (unsigned long)arr.count);
    NSLog(@"sortedMessages.count: %lu", (unsigned long)sortedMessages.count);
    NSLog(@"asd: %lu", (unsigned long)asd);
    
    if (asd > 30) asd = 30;
    
    sortedMessages = [[sortedMessages objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexOfEarliestMessage-asd, asd)]]mutableCopy];
    
    [bubbleData removeAllObjects];
    
    [arr insertObjects:sortedMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sortedMessages.count)]];
    
    indexOfEarliestMessage = [srtdMssgs indexOfObject:[arr firstObject]];
    
    [self loadMessegesFromArray:arr];
    
    [bubbleTable reloadData];
    
    [refreshControl endRefreshing];
    
    if (indexOfEarliestMessage == 0 && [bubbleTable.subviews containsObject:refreshControl])
        [refreshControl removeFromSuperview];
}


#pragma mark - ManagedObjectChangeListener

-(void)newChangeWithKey:(NSString *)key
{
    if ([key isEqualToString:kNewMessage] || [key isEqualToString:kUpdatedThread])
    {
        NSLog(@"New message in ChatViewController");
        NSObject<MessageItem> *message = [[chatViewItem getMessages]lastObject];
        
        // Check if it's a new message
        PPMessageData *lastBubble = [bubbleData lastObject];
        double lastDate = [[lastBubble date]timeIntervalSince1970];
        if (lastDate == [[message getDate]timeIntervalSince1970]){
            NSLog(@"Message is not new");
            return;
        }
        
        [(Thread*)chatViewItem setUnread:0];
        
        NSLog(@"Sender: %@", [message getSenderTag]);
        PPMessageData *newMessage;
        
        if ([message getMessageType] == typeText)
        {
            newMessage = [PPMessageData dataWithText:[message getText] date:[message getDate] type: [self getType:[message getSenderTag]]];
        }
        else if ([message getMessageType] == typeImage)
        {
            newMessage = [PPMessageData dataWithImage:[UIImage imageNamed:[message getText]] date:[message getDate] type:[self getType:[message getSenderTag]]];
        }
        else if ([message getMessageType] == typeIcon)
        {
            newMessage = [PPMessageData dataWithIcon:[UIImage imageNamed:[message getIcon]] date:[message getDate] type:[self getType:[message getSenderTag]]];
        }
        else //if ([message getMessageType] == typeLocation)
        {
            NSDictionary *location = [NSPropertyListSerialization
                                   propertyListWithData:[[message getLocation] dataUsingEncoding:NSUTF8StringEncoding]
                                   options:kNilOptions
                                   format:NULL
                                   error:NULL];
            
            MKMapView *mapView = [self createMapViewWithLocation:location];
            
            newMessage = [PPMessageData dataWithView:mapView date:[message getDate] type:[self getType:[message getSenderTag]] style:PPMessageStyleMap insets:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        
        NSString *imageFilePath = [ThreadWrapper getImageFilePathForSender:[message getSenderTag] onThread:(Thread*)chatViewItem];
        if (imageFilePath) {
            newMessage.avatar = [UIImage imageWithContentsOfFile:imageFilePath];
        }else{
            newMessage.avatar = [UIImage imageNamed:@"PingPal-ikon_mörk.png"];
        }
        
        [bubbleData addObject:newMessage];
        bubbleTable.typingBubble = PPTypingTypeNobody;
        [bubbleTable reloadData];
        [bubbleTable scrollBubbleViewToBottomAnimated:YES];
//        if (newMessage.type == PPMessageTypeSomeoneElse){
//            [bubbleTable scrollBubbleViewToBottomAnimated:YES];
//        }else if (newMessage.style == PPMessageStyleIcon){
//            [bubbleTable scrollBubbleViewToBottomAnimated:YES];
//        }
    }
}


#pragma mark - AHChatBarViewDelegate

-(void)chatBarViewDidPressSendWithText:(NSString *)chatTextViewText
{
    // Push
    NSString *myName = [[MyselfObject sharedInstance]getName];
    NSString *alert = [[NSString alloc]initWithFormat:@"%@: %@",myName, chatTextViewText];
    
    NSDictionary *push = [Push createPushForMessageWithAlert:alert andThread:[[MyselfObject sharedInstance]getUserTag]];
    
    // Send message
    [Outbox put:[chatViewItem getTag] withPayload:@{@"message":chatTextViewText} andOptions:@{@"push":push}];
    
    // Create local
    [MessageWrapper createNewMessageWithText:chatTextViewText andSender:[[MyselfObject sharedInstance]getUserTag] andDate:[NSDate date] forThread:chatViewItem];
    
    indicatorSent = NO;
}

-(void)chatTextViewDidChange:(UITextView *)textView
{
    if ([[textView text] length])
    {
        if (!indicatorSent)
        {
            indicatorSent = YES;
            [Outbox put:[chatViewItem getTag] withPayload:@{@"writing":@(YES)} andOptions:@{@"ttl":@0}];
        }
    }else{
        if (indicatorSent)
        {
            indicatorSent = NO;
            [Outbox put:[chatViewItem getTag] withPayload:@{@"writing":@(NO)} andOptions:@{@"ttl":@0}];
        }
    }
}

-(void)chatBarViewDidPressAccessoryItem:(int)button
{
    switch (button) {
//        case 0:
//            NSLog(@"My Location");
//            break;
        case 0:
            NSLog(@"Ping");
            [self ping];
            break;
        case 1:
            NSLog(@"Icon");
            [self setupIconView];
            break;
//        case 3:
//            NSLog(@"Image");
//            break;
            
        default:
            break;
    }
}

-(void)chatBarViewFrameDidChange:(CGRect)frame
{
    NSLog(@"chatBarViewFrameDidChange: %@", NSStringFromCGRect(frame));
    
    NSTimeInterval animationDuration = 0.25;
    UIViewAnimationOptions keyboardTransitionAnimationCurve = 7 << 16;
    
    heightConstraint.constant = frame.origin.y;
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:keyboardTransitionAnimationCurve | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [bubbleTable scrollBubbleViewToBottomAnimated:YES];
                     }];
}


#pragma mark - Ping

-(void)showPingSentView
{
    UIView *pingSentView = [[UIView alloc]initWithFrame:CGRectMake(20, self.view.frame.size.height-120, 280, 40)];
    [pingSentView setBackgroundColor:UIColorFromRGB(0x48BB90)];
    [pingSentView.layer setCornerRadius:20];
    [pingSentView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [pingSentView.layer setBorderWidth:1];
    
    UILabel *pingLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 5, 230, 30)];
    [pingLabel setNumberOfLines:1];
    [pingLabel setTextAlignment:NSTextAlignmentLeft];
    [pingLabel setTextColor:[UIColor whiteColor]];
    [pingLabel setText:@"Ping sent. Wait for response"];
    
    [pingSentView addSubview:pingLabel];
    
    UIImageView *pingImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"PingPal-ikon_mörk.png"]];
    [pingImageView setFrame:CGRectMake(1, 1, 38, 38)];
    [pingImageView.layer setCornerRadius:19];
    [pingImageView setClipsToBounds:YES];
    
    [pingSentView addSubview:pingImageView];
    
    CATransition *applicationLoadViewIn =[CATransition animation];
    [applicationLoadViewIn setDuration:.4];
    [applicationLoadViewIn setType:kCATransitionReveal];
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[pingSentView layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    
    [self.view addSubview:pingSentView];
    
    [UIView animateWithDuration:.3
                          delay:3
                        options:0
                     animations:^{
                         [pingSentView setAlpha:0];
                     }
                     completion:^(BOOL finished) {
                         [pingSentView removeFromSuperview];
                     }
     ];
}

-(void)ping
{
    NSDictionary *push = [Push createPushForPingWithName:[[MyselfObject sharedInstance]getName] andExtraData:@{@"thread":[[MyselfObject sharedInstance]getUserTag]}];
    
    [PPLocationManager getDevicePosition:[chatViewItem getTag] withAccuracy:300 andTimeout:30 AndInbox:pingInbox AndOptions:@{@"push": push}];
    [chatBarViewController dismissWithAnimation:YES];
    
    [self showPingSentView];
}

-(MKMapView*)createMapViewWithLocation:(NSDictionary*)location
{
    MKMapView *mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([location[@"latitude"]doubleValue], [location[@"longitude"]doubleValue]);
    
    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc]init];
    [pointAnnotation setCoordinate:coord];
    //[pointAnnotation setTitle:name];
    [mapView addAnnotation:pointAnnotation];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(pointAnnotation.coordinate, 2000, 2000);
    [mapView setRegion:region animated:YES];
    
    [mapView setUserInteractionEnabled:NO];
    
    return mapView;
}


#pragma mark - Icon

-(void)setupIconView
{
    CGRect finalFrame = CGRectMake(0, self.view.frame.size.height-266, self.view.frame.size.width, 266);
    CGRect startFrame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 266);
    
    if (!iconChooser)
    {
        iconChooser = [[IconChooserViewController alloc]init];
        [iconChooser.view setFrame:startFrame];
    }

    [iconChooser setDelegate:self];
    [self addChildViewController:iconChooser];
    [self.view addSubview:iconChooser.view];
    
    
    [UIView animateWithDuration:.25
                     animations:^{
                         [iconChooser.view setFrame:finalFrame];
                     }
                     completion:^(BOOL finished){
                     }];
    
    NSLayoutConstraint *iconChooserWidthConstraint = [NSLayoutConstraint constraintWithItem:iconChooser.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    [self.view addConstraint:iconChooserWidthConstraint];
}

-(void)removeIconView
{
    CGRect endFrame = CGRectMake(0, self.view.frame.size.height, 320, 266);
    
    [chatBarViewController dismissWithAnimation:YES];
    
    [UIView animateWithDuration:.25
                     animations:^{
                         [iconChooser.view setFrame:endFrame];
                     }
                     completion:^(BOOL finished){
                         [iconChooser removeFromParentViewController];
                         [iconChooser.view removeFromSuperview];
                     }];
}

-(void)iconChooserDidSelectIcon:(NSString *)icon
{
    NSLog(@"iconChooserDidSelectIcon: %@", icon);
    
    NSString *myName = [[MyselfObject sharedInstance]getName];
    
    NSDictionary *alert = @{
                            @"loc-key" : @"iconSentPushText",
                            @"loc-args" : @[myName]
                            };
    
    NSDictionary *push = [Push createPushForMessageWithAlert:alert andThread:[[MyselfObject sharedInstance]getUserTag]];
    
    // Send message
    [Outbox put:[chatViewItem getTag] withPayload:@{@"icon":icon} andOptions:@{@"push":push}];
    
    // Create local
    NSString *text = [NSString stringWithFormat:@"%@ %@", myName, NSLocalizedString(@"iconSentText", @"Sent an icon")];

    [MessageWrapper createNewMessageWithIcon:icon andText:text andSender:[[MyselfObject sharedInstance]getUserTag] andDate:[NSDate date] forThread:chatViewItem];
    
    indicatorSent = NO;
    
    [self removeIconView];
}

-(void)iconChooserDidClickCancel
{
    [self removeIconView];
}


#pragma mark - PPChatTableViewDelegate

-(void)chatTableViewDidSelectRowWithData:(PPMessageData *)data
{
    NSLog(@"chatTableViewDidSelectRowWithData: %@", data);
    
    if (data.style == PPMessageStyleImage)
    {
        NSLog(@"chatTableViewDidSelectRowWithData style: Image");
        
        // Show image in fullscreen
        UIImage *image = [(UIImageView*)[data.view.subviews objectAtIndex:0] image];
        PPFullscreenViewController *fullscreenViewController = [[PPFullscreenViewController alloc]initWithImage:image];
        fromFullscreen = YES;
        [chatBarViewController dismissWithAnimation:YES];
        [self presentViewController:fullscreenViewController animated:YES completion:nil];
    }
    else if (data.style == PPMessageStyleMap)
    {
        NSLog(@"chatTableViewDidSelectRowWithData style: Map");

        // Show map in fullscreen
        PPFullscreenViewController *fullscreenViewController = [[PPFullscreenViewController alloc]initWithMapView:(MKMapView*)data.view];
        fromFullscreen = YES;
        [chatBarViewController dismissWithAnimation:YES];
        [self presentViewController:fullscreenViewController animated:YES completion:nil];
    }
}


#pragma mark - PPChatTableViewDataSource implementation

-(NSInteger)rowsForChatTable:(PPChatTableView *)tableView{
    return [bubbleData count];
}

-(PPMessageData *)chatTableView:(PPChatTableView *)tableView dataForRow:(NSInteger)row{
    return [bubbleData objectAtIndex:row];
}

@end