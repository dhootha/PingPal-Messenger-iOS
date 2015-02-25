//
//  AppDelegate.m
//  PingPal Messenger
//
//  Created by André Hansson on 2014-03-12.
//  Copyright (c) 2014 PingPal AB. All rights reserved.
//

#import "AppDelegate.h"
#import "MyselfObject.h"
#import "ManagedObjectChangeListener.h"
#import "InboxHandler.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FriendWrapper.h"
#import "BadgeCount.h"
#import "OutboxHandler.h"
#import "openFromNotification.h"
#import "GroupServer.h"
#import "GroupWrapper.h"

#import <PPLocationManager/PPLocationManager.h>
#import <PPLocationManager/Outbox.h>

#define PUBLIC_KEY @"PUBLIC"
#define PRIVATE_KEY @"PRIVATE"

@implementation AppDelegate{
    ManagedObjectChangeListener *changeListener;
    InboxHandler *inboxes;
    BOOL isObserving;
    UIView *screenshotView;
    BOOL screenshotViewIsPresent;
    
    AccessHandler accessHandler;
    AccessYes accessGranted;
    Friend *pingFriend;
    
    IntroViewController *intro;
    BOOL introPresent;
}

void (^_completionHandler)(UIBackgroundFetchResult);

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"application didFinishLaunchingWithOptions: %@", launchOptions);
    
    NSString *userTag = [[MyselfObject sharedInstance]getUserTag];
    NSString *deviceTag = [[MyselfObject sharedInstance]getDeviceTag];
    NSString *FBID = [[MyselfObject sharedInstance]getFBID];
    NSLog(@"UserTag: %@", userTag);
    NSLog(@"DeviceTag: %@", deviceTag);
    NSLog(@"FBID: %@", FBID);
    
    [Outbox setAPIKeys:PUBLIC_KEY andPrivate:PRIVATE_KEY];
    
    [Outbox setLogLevelMask:LOG_FLAG_INFO andContextMask:LOG_CONTEXT_ALL];
    
    NSString *startTicket = [[NSUserDefaults standardUserDefaults] objectForKey:@"pingpal.ticket"];
    NSLog(@"***** startTicket: %@ *****", startTicket);
    
    [Outbox startHistory:startTicket andSaveBlock:^(NSError *error, NSString *ticket) {
        if (error) {
            NSLog(@"startHistoryandSaveBlock - Error: %@", error);
        }
        
        NSLog(@"startHistoryandSaveBlock - Ticket: %@", ticket);
        
        [[NSUserDefaults standardUserDefaults] setObject:ticket forKey:@"pingpal.ticket"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    
    if (FBID)
    {
        [self startWithFacebookID:FBID];
        
        // Register push
        [self registerForRemotePush];
        
        isObserving = NO;
    }
    else
    {
        //No FBID avalible. When i get one I need to register
        [[NSUserDefaults standardUserDefaults]addObserver:self forKeyPath:@"myFBID" options:NSKeyValueObservingOptionNew context:NULL];
        
        isObserving = YES;
    }
        
    // Setup LocationManager
    [PPLocationManager setup];
    
    // Create access handler
    __weak typeof(self) weakSelf = self;
    accessHandler = ^(NSMutableDictionary *payload, NSMutableDictionary *options, AccessYes Ok)
    {
        NSLog(@"AccessHandler - Payload: %@. Options: %@", payload, options);
        
        NSString *sender = options[@"from"];
        
        if ([sender isEqualToString:[[MyselfObject sharedInstance]getUserTag]])
        {
            //NSLog(@"AccessHandler - I sent the ping to a group");
            return;
        }
        
        __strong typeof(self) strongSelf = weakSelf;
        
        if (strongSelf)
        {
            strongSelf->accessGranted = Ok;
            
            Friend *friend = [FriendWrapper fetchFriendWithTag:sender];
            
            if ([friend deletedFriend]) {
                return;
            }
            
            if ([friend pingAccess] == accessAsk)
            {
                strongSelf->pingFriend = friend;
                
                NSString *senderName = [friend getName];
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@ %@", senderName, NSLocalizedString(@"pingAlertText", @"")] message:NSLocalizedString(@"Allow?", @"") delegate:strongSelf cancelButtonTitle:NSLocalizedString(@"No", @"") otherButtonTitles:NSLocalizedString(@"Yes", @""), NSLocalizedString(@"AlwaysYes", @""), NSLocalizedString(@"AlwaysNo", @""), nil];
                [alertView show];
            }
            else if ([friend pingAccess] == accessYes)
            {
                // Automatically answer ping
                Ok();
            }
        }
    };
    
    // Set access handler
    [PPLocationManager setAccesshandler: accessHandler];
    
    // init changeListener and inboxes
    changeListener = [ManagedObjectChangeListener sharedInstance];
    inboxes = [InboxHandler sharedInstance];
    
    // Appearance
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UITextView appearance] setTintColor:UIColorFromRGB(0x48BB90)];
    [[UITextField appearance] setTintColor:UIColorFromRGB(0x48BB90)];
    
    // Create screenshot view to hide the app in multitask switcher
    screenshotView = [[UIView alloc]initWithFrame:self.window.frame];
    [screenshotView setBackgroundColor:UIColorFromRGB(0x48BB90)];
    
    UIImageView *imageV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"PingPalLogo_inverted.png"]];
    [imageV setCenter:screenshotView.center];
    [screenshotView addSubview:imageV];
    
    
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notification) {
        //NSLog(@"app recieved notification: %@",notification);
        [self application:application didReceiveRemoteNotification:(NSDictionary*)notification];
    } //else{
//        NSLog(@"app did not recieve notification");
//    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // Multitasking switcher screenshot
    [self.window addSubview:screenshotView];
    screenshotViewIsPresent = YES;
    
    [BadgeCount checkBadgeCount];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if (screenshotViewIsPresent) {
        [screenshotView removeFromSuperview];
        screenshotViewIsPresent = NO;
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]){
        // This is the first launch. Show intro.
        if (!introPresent) {
            [self showIntro];
        }
    }else{
        [[OutboxHandler sharedInstance]checkFriendsAndGroups];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Intro

-(void)showIntro
{
    intro = [[IntroViewController alloc]init];
    [intro setDelegate:self];
    [intro.view setFrame:self.window.bounds];
    [self.window addSubview:intro.view];
    introPresent = YES;
}

-(void)introDone
{
    introPresent = NO;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    intro = nil;
    
    [self registerForRemotePush];
    
    [[OutboxHandler sharedInstance]checkFriendsAndGroups];
}

-(void)startWithFacebookID:(NSString*)FBID
{
    NSString *userTag = [[MyselfObject sharedInstance]getUserTag];
    NSString *deviceTag = [[MyselfObject sharedInstance]getDeviceTag];
    
    if (!userTag) {
        userTag = [NSString stringWithFormat:@"#%@", FBID];
        [[MyselfObject sharedInstance]setUserTag:userTag];
    }
    
    if (!deviceTag) {
        deviceTag = [Outbox createUniqueTag];
        [[MyselfObject sharedInstance]setDeviceTag:deviceTag];
    }
    
    [Outbox startWithTag:deviceTag andAlias:userTag andCallback:^(NSError *error) {
        if (error) {
            NSLog(@"startWithTag:andAlias:andCallback: Error: %@", error);
        }
    }];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]){
        [[OutboxHandler sharedInstance]checkFriendsAndGroups];
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            //NSLog(@"No");
            break;
        case 1:
            //NSLog(@"Yes");
            accessGranted();
            break;
        case 2:
            //NSLog(@"Always yes");
            [pingFriend setPingAccess:accessYes];
            accessGranted();
            break;
        case 3:
            //NSLog(@"Always no");
            [pingFriend setPingAccess:accessNo];
            break;
            
        default:
            break;
    }
}


#pragma mark - Register Push

-(void)registerForRemotePush
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        //NSLog(@"registerForRemotePush - iOS 8");
        
        UIUserNotificationType type = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        //NSLog(@"registerForRemotePush - iOS 7");
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
}

- (void)observeValueForKeyPath:(NSString *) keyPath ofObject:(id) object change:(NSDictionary *) change context:(void *) context
{
    if([keyPath isEqual:@"myFBID"])
    {
        [self startWithFacebookID:[[MyselfObject sharedInstance]getFBID]];
        
        //[self registerForRemotePush];
    }
}

// Push registration
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken");
    
    // Check if push is registered for this device
    BOOL isPushRegistered = [[NSUserDefaults standardUserDefaults]boolForKey:@"isPushRegistered"];
    if (!isPushRegistered)
    {
        NSLog(@"push is not registered");
        NSString *Tag = [[MyselfObject sharedInstance]getUserTag];
        
        if (Tag)
        {
            #if DEBUG
            BOOL isDebug = YES;
            #else
            BOOL isDebug = NO;
            #endif
            
            [Outbox registerForPushNotifications:Tag withPushToken:deviceToken isDebug:isDebug andCallback:^(NSError *error) {
                if (!error) {
                    NSLog(@"Push registered");
                    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isPushRegistered"];
                }else{
                    NSLog(@"registerForPushNotifications ERROR: %@", error);
                }
            }];
            
            if (isObserving) {
                [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"myFBID"];
            }
        }
    }else{
        NSLog(@"Push is already registered");
    }
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    NSLog(@"didRegisterUserNotificationSettings");
}


#pragma mark - Receive Push

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"didReceiveLocalNotification: %@", notification.userInfo);
    
    if (application.applicationState == UIApplicationStateInactive) {
        NSLog(@"LocalNotification - Inactive");
        // The app opened on the notification. Go to correct chat
        [openFromNotification openWithTag:notification.userInfo[@"thread"]];
    }
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"didReceiveRemoteNotification: %@", userInfo);
    
    if ( application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground  )
    {
        //opened from a push notification when the app was on background
        NSLog(@"opened from a push notification when the app was on background");
                
        [openFromNotification openWithTag:userInfo[@"thread"]];
    }
}

-(void)showLocalNotificationWithAlert:(NSString*)alert AndThread:(NSString*)thread
{
    NSLog(@"showLocalNotificationWithAlertAndThread");
    
    UILocalNotification *localNotification = [[UILocalNotification alloc]init];
    [localNotification setAlertBody: alert];
    [localNotification setSoundName: @"default"];
    if (thread) [localNotification setUserInfo:@{@"thread": thread}];
    [localNotification setFireDate:[NSDate date]];
    
    NSLog(@"localNotification: %@", localNotification);
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSLog(@"didReceiveRemoteNotification:fetchCompletionHandler: %@", userInfo);
    
    NSString *sound = userInfo[@"aps"][@"sound"];
    
    if ([sound isEqualToString:@""]) {
        NSLog(@"Silent push");
        
        NSString *alert;
        
        if ([userInfo[@"alert"] isKindOfClass:[NSString class]])
        {
            alert = userInfo[@"alert"];
        }
        else if ([userInfo[@"alert"] isKindOfClass:[NSDictionary class]])
        {
            NSString *arg = [userInfo[@"alert"][@"loc-args"] objectAtIndex:0];
            NSString *key = NSLocalizedString(userInfo[@"alert"][@"loc-key"], @"");
            NSString *alertString = [NSString stringWithFormat:key, arg];
            NSLog(@"alertString: %@", alertString);
            
            alert = alertString;
        }
        
        // Check if notification should be shown
        Group *group = [GroupWrapper fetchGroupWithTag:userInfo[@"thread"]];
        
        if (group && ![GroupWrapper getNotifyMeForGroup:group]) {
            NSLog(@"DO NOT NOTIFY");
        }
        else
        {
            [self showLocalNotificationWithAlert:alert AndThread:userInfo[@"thread"]];
        }
    }
    else
    {
        NSLog(@"Regular push");
    }
    
    if (application.applicationState == UIApplicationStateInactive) {
        NSLog(@"didReceiveRemoteNotification fetchCompletionHandler - Inactive");
        // The app opened on the notification. Go to correct chat
        [openFromNotification openWithTag:userInfo[@"thread"]];
    }

    if (application.applicationState == UIApplicationStateBackground) {
        //NSLog(@"Background");
        // The app is in the background. Fetch messages.
        
        //Outbox will automatically fetch on bind
        [Outbox resume];
        
        _completionHandler = [completionHandler copy];
        
        [self performSelector:@selector(done) withObject:NULL afterDelay:7];
    }
}

-(void)done{
    NSLog(@"Fetch done");
    
    [BadgeCount checkBadgeCount];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        NSLog(@"Still in background. Resign");
        [Outbox resign];
    }else{
        NSLog(@"Did not resign.");
    }
    
    _completionHandler(UIBackgroundFetchResultNewData);
}

// iOS 8
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    NSLog(@"handleActionWithIdentifier:forRemoteNotification:completionHandler: - Identifier: %@.  Notification: %@", identifier, userInfo);
    
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}


#pragma mark - Facebook

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}


#pragma mark - Save Core Data

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ChatApp2" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ChatApp2.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
